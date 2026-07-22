# frozen_string_literal: true

require 'erb'
require 'ebsm/dsl'

module Ebsm
  # Renders ebsm source to bsm2 literate text. Owns the source -> ERB template
  # translation; the byte helpers users call inside [...] live on Ebsm::Dsl,
  # whose binding the template is evaluated against.
  class Renderer
    # Translate ebsm source into an ERB program, evaluate it against a Dsl
    # instance, and return the resulting bsm2 literate text. Each [expr] on a
    # '; ' data line is wrapped so that an Ebsm::Error raised while evaluating
    # it is annotated with its source line, column, and length for diagnostics.
    # @param content [String] the ebsm source.
    # @return [String] the expanded bsm2 literate text.
    def render(content)
      dsl = evaluate(content)
      ERB.new(build_template(content), trim_mode: '-').result(dsl.erb_binding)
    end

    # Evaluate the template, then feed each emitted ; line to bsm2 individually
    # so a bsm2 lexer error is reported against the original source line (not
    # the expanded text's line number). Returns the concatenated binary bytes.
    # @param content [String] the ebsm source.
    # @return [String] the concatenated binary bytes.
    def bsm2_evaluate(content)
      dsl = evaluate(content)
      ERB.new(build_template(content), trim_mode: '-').result(dsl.erb_binding)
      generator = Bsm::Generator.new
      source_lines = content.lines.map(&:chomp)
      dsl.emitted.each_with_object(+'') do |(source_line, text), output|
        output << generate_line(generator, source_line, text, source_lines)
      end
    end

    # Compile a single expanded ; line, re-raising a bsm2 error as an
    # Ebsm::Error annotated with the original +source_line+ and source context.
    # @param generator [Bsm::Generator] the bsm2 generator.
    # @param source_line [Integer] 1-indexed source line of the ; line.
    # @param text [String] the expanded ; line text.
    # @param source_lines [Array<String>] all source lines (chomped).
    # @return [String] the compiled binary bytes for this line.
    def generate_line(generator, source_line, text, source_lines)
      generator.generate("#{text}\n")
    rescue Bsm::InvalidInput => e
      raise bsm_error(e, source_line, text, source_lines)
    end

    # Translate ebsm source into an ERB program. A '# ' line becomes an ERB
    # code block, a '; ' line is wrapped in a #line call (so the renderer can
    # track which source line each expanded ; line came from), anything else
    # passes through verbatim (bsm2 ignores it).
    # @param content [String] the ebsm source.
    # @return [String] the ERB program.
    def build_template(content)
      content.lines.each_with_index.map do |line, index|
        stripped = line.chomp
        if stripped.start_with?('#')
          "<% #{stripped[1..]} -%>\n"
        elsif stripped.start_with?(';')
          "<%= line(#{index + 1}) { #{expand_brackets(stripped, index + 1)} } %>\n"
        else
          line
        end
      end.join
    end

    # Build a Ruby double-quoted string expression that evaluates to the
    # expanded ; line, with each [expr] replaced by an `eval_at(N, col, len)`
    # interpolation. Literal text is escaped for a double-quoted Ruby string.
    # An unclosed [ is left literal.
    # @param stripped [String] the chomped ; source line.
    # @param line_number [Integer] 1-indexed source line number.
    # @return [String] a Ruby double-quoted string expression.
    def expand_brackets(stripped, line_number)
      expr = +'"'
      index = 0
      expr, index = expand_segment(expr, stripped, index, line_number) while index < stripped.length
      "#{expr}\""
    end

    # Expand one segment of a ; line starting at +index+, returning the updated
    # [expr, next_index]. A [expr] bracket becomes an eval_at interpolation; a
    # literal run is escaped; an unclosed [ ends the walk.
    # @param expr [String] the accumulator expression so far.
    # @param stripped [String] the chomped ; source line.
    # @param index [Integer] the current position in +stripped+.
    # @param line_number [Integer] 1-indexed source line number.
    # @return [Array(String, Integer)] the updated [expr, next_index].
    def expand_segment(expr, stripped, index, line_number)
      if stripped[index] == '['
        close = stripped.index(']', index)
        return [expr, stripped.length] unless close

        [expr + bracket_expr(stripped, index, close, line_number), close + 1]
      else
        chunk_end = stripped.index('[', index) || stripped.length
        [expr + escape_dq(stripped[index...chunk_end]), chunk_end]
      end
    end

    private

    def evaluate(content)
      dsl = Dsl.new
      dsl.lines = content.lines.map(&:chomp)
      dsl
    end

    # The `eval_at(...)` interpolation expression for a [expr] bracket
    # spanning +open+..+close+ in +stripped+.
    def bracket_expr(stripped, open, close, line_number)
      inner = stripped[(open + 1)...close]
      column = open + 1
      length = close - open + 1
      "\#{eval_at(#{line_number}, #{column}, #{length}) { #{inner} }}"
    end

    # Escape a literal chunk for a double-quoted Ruby string: backslash,
    # double-quote, and # when it would start an interpolation.
    def escape_dq(chunk)
      chunk.gsub(/[\\"]|\#(?=[{@$])/) { |m| "\\#{m}" }
    end

    # Build an Ebsm::Error from a bsm2 error, pointing at +source_line+ with
    # +expanded_text+ as the arrow target and +source_lines+ for context.
    def bsm_error(error, source_line, expanded_text, source_lines)
      result = Ebsm::Error.new(error.message)
      result.line_number = source_line
      result.column = error.column
      result.char_length = error.length
      result.line_text = error.line_text
      result.source_lines = source_lines
      result.expanded_line = expanded_text unless expanded_text == source_lines[source_line - 1]
      result
    end
  end
end
