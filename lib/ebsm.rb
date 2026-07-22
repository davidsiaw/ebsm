# frozen_string_literal: true

require 'ebsm/version'
require 'ebsm/hex'
require 'ebsm/dsl'
require 'ebsm/renderer'
require 'bsm'

# Ebsm is a literate binary generator: a templating layer over bsm2 that lets
# you mix prose, Ruby scripting (# lines), and byte data (; lines) in one
# source file. See Ebsm::Renderer and Ebsm::Dsl.
module Ebsm
  # An error raised while evaluating ebsm source. Carries the source position
  # of the offending line plus (for bsm2-stage errors) the expanded bsm2 line
  # the arrow actually points at, so the CLI can show both source and expanded
  # context like bsm2 does.
  class Error < StandardError
    # Source position of the offending line/bracket, filled in by the renderer.
    attr_accessor :line_number, :column, :char_length, :line_text
    # All source lines (chomped), for printing context lines above the error.
    attr_accessor :source_lines
    # The expanded bsm2 line the arrow points at. nil for ebsm-stage helper
    # errors (where the source line is the arrow target).
    attr_accessor :expanded_line

    # Format this error as a diagnostic with source context (2 lines above)
    # and, for bsm2-stage errors, the expanded line the arrow points at:
    #
    #   EBSM: bsm2 error at source line 2 (expanded column 17)
    #   ---
    #     1 | # x = 0x12345678
    #   > 2 | ; [le32 x] 45 asd
    #       expanded:
    #       ; 78 56 34 12 45 asd
    #                       ^ hex byte needs two hex digits
    # @return [String] the formatted diagnostic.
    def format
      body = "#{header}\n---\n"
      body << context_lines
      body << expanded_section if expanded_line
      body << arrow_line
      body
    end

    # The header line, noting whether the column is expanded (bsm2-stage) or
    # source (ebsm-stage).
    # @return [String] the header line.
    def header
      if expanded_line
        "EBSM: bsm2 error at source line #{line_number} (expanded column #{column})"
      else
        "EBSM: error at source line #{line_number} (column #{column})"
      end
    end

    # The "expanded:" label and the expanded bsm2 line -- shown only for
    # bsm2-stage errors where the arrow target differs from source.
    # @return [String] the expanded section.
    def expanded_section
      pad = ' ' * prefix_width
      "#{pad}expanded:\n#{pad}#{expanded_line}\n"
    end

    # The arrow (with leading spaces to align under the displayed line) and the
    # error message.
    # @return [String] the arrow line with the message.
    def arrow_line
      indent = ' ' * (prefix_width + (column - 1))
      "#{indent}#{arrow} #{message}\n"
    end

    # The numbered source lines from 2 above the error up to the error line,
    # with `> ` marking the error line. Line numbers are right-padded to the
    # error line's digit width so the `|` pipes align. When the error is near
    # the top of the file and there are fewer than 2 source lines above, a
    # single `beginning of file` marker fills the gap.
    # @return [String] the numbered context lines.
    def context_lines
      width = line_number.to_s.length
      first = [line_number - 2, 1].max
      bof = line_number < 3 ? [bof_line(width)] : []
      real = (first..line_number).map { |n| context_line(n, width) }
      (bof + real).join
    end

    private

    def prefix_width
      "> #{line_number} | ".length
    end

    def arrow
      "^#{'~' * (char_length - 1)}"
    end

    def context_line(number, width)
      prefix = number == line_number ? '> ' : '  '
      "#{prefix}#{number.to_s.rjust(width)} | #{source_lines[number - 1]}\n"
    end

    def bof_line(width)
      "  #{' ' * width} | *beginning of file*\n"
    end
  end
end
