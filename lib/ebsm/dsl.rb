# frozen_string_literal: true

require 'ebsm/hex'

module Ebsm
  # The evaluation context for an ebsm template -- the object whose binding an
  # ERB template is evaluated against. Any public method here is available
  # inside a [expr] interpolation or a <% ... %> code block.
  #
  # Helper methods are expected to return strings that the bsm2 lexer can
  # consume on a '; ' data line -- typically space-separated hex byte pairs, so
  # that e.g. [le32 0x12345678] expands to "; 78 56 34 12".
  class Dsl
    def initialize
      @emitted = []
    end

    # Source lines of the template being rendered, set by the renderer before
    # evaluation so #eval_at can report the text of an offending line.
    attr_writer :lines

    # The [source_line, expanded_text] pairs emitted by #line, in order. The
    # renderer reads this to feed each ; line to bsm2 individually so a bsm2
    # error can be reported against the original source line.
    attr_reader :emitted

    # --- Byte helpers -------------------------------------------------------
    # Each helper emits +value+ as space-separated hex byte pairs, raising
    # Ebsm::Error if +value+ is not an Integer or does not fit the width.

    # Emit +value+ as a single hex byte pair (0..0xff).
    # @param value [Integer] the byte value, 0..255.
    # @return [String] two lowercase hex digits.
    def byte(value)
      hex.pack_hex(value, 'C', 0xff)
    end

    # Emit +count+ copies of +value+ as space-separated lowercase hex pairs.
    # Handy for padding/filling, e.g. [repeat 0x00, 16] pads 16 zero bytes.
    # +value+ must be an Integer 0..255; +count+ must be a non-negative Integer.
    # @param value [Integer] the byte to repeat, 0..255.
    # @param count [Integer] non-negative number of copies.
    # @return [String] space-separated hex byte pairs.
    def repeat(value, count)
      unless count.is_a?(Integer) && !count.negative?
        raise Ebsm::Error,
              "#{count.inspect} is not a non-negative Integer"
      end

      hex_val = hex.hex_pair(value)
      Array.new(count, hex_val).join(' ')
    end

    # Emit every byte of +value+ as space-separated lowercase hex pairs.
    # Accepts a String (its bytes) or an Enumerable of Integers (each 0..255).
    # Useful for dumping a whole string or byte array in one call, e.g.
    # [bytes chunk] where chunk is a binary String, or [bytes arr] where arr
    # is an Array of Integers assigned on a # line.
    # @param value [String, Enumerable<Integer>] the bytes to emit.
    # @return [String] space-separated hex byte pairs.
    def bytes(value)
      ints = value.is_a?(String) ? value.bytes : value.to_a
      ints.map { |b| hex.hex_pair(b) }.join(' ')
    end

    # Emit +value+ as 2 little-endian hex byte pairs (0..0xffff).
    # @param value [Integer] 0..0xffff.
    # @return [String] two space-separated hex byte pairs.
    def le16(value)
      hex.pack_hex(value, 'v', 0xffff)
    end

    # Emit +value+ as 2 big-endian hex byte pairs (0..0xffff).
    # @param value [Integer] 0..0xffff.
    # @return [String] two space-separated hex byte pairs.
    def be16(value)
      hex.pack_hex(value, 'n', 0xffff)
    end

    # Emit +value+ as 4 little-endian hex byte pairs (0..0xffffffff).
    # @param value [Integer] 0..0xffffffff.
    # @return [String] four space-separated hex byte pairs.
    def le32(value)
      hex.pack_hex(value, 'V', 0xffffffff)
    end

    # Emit +value+ as 4 big-endian hex byte pairs (0..0xffffffff).
    # @param value [Integer] 0..0xffffffff.
    # @return [String] four space-separated hex byte pairs.
    def be32(value)
      hex.pack_hex(value, 'N', 0xffffffff)
    end

    # Emit +value+ as 8 little-endian hex byte pairs.
    # @param value [Integer] 0..0xffffffffffffffff.
    # @return [String] eight space-separated hex byte pairs.
    def le64(value)
      hex.pack_hex(value, 'Q<', 0xffffffffffffffff)
    end

    # Emit +value+ as 8 big-endian hex byte pairs.
    # @param value [Integer] 0..0xffffffffffffffff.
    # @return [String] eight space-separated hex byte pairs.
    def be64(value)
      hex.pack_hex(value, 'Q>', 0xffffffffffffffff)
    end

    # Emit +value+ as a 32-bit (single-precision) little-endian IEEE 754 float.
    # @param value [Float] the float to encode.
    # @return [String] four space-separated hex byte pairs.
    def lef32(value)
      hex.pack_float(value, 'e')
    end

    # Emit +value+ as a 32-bit (single-precision) big-endian IEEE 754 float.
    # @param value [Float] the float to encode.
    # @return [String] four space-separated hex byte pairs.
    def bef32(value)
      hex.pack_float(value, 'g')
    end

    # Emit +value+ as a 64-bit (double-precision) little-endian IEEE 754 float.
    # @param value [Float] the float to encode.
    # @return [String] eight space-separated hex byte pairs.
    def lef64(value)
      hex.pack_float(value, 'E')
    end

    # Emit +value+ as a 64-bit (double-precision) big-endian IEEE 754 float.
    # @param value [Float] the float to encode.
    # @return [String] eight space-separated hex byte pairs.
    def bef64(value)
      hex.pack_float(value, 'G')
    end

    # Evaluate a [expr] interpolation, annotating any error with the source
    # position of the bracket so the CLI can draw an arrow/tilde. Ebsm::Error
    # (from helpers) is passed through with position attached; any other
    # StandardError raised by the expression (NoMethodError, ArgumentError,
    # etc.) is wrapped in an Ebsm::Error so it gets the same diagnostic.
    # @param line_number [Integer] 1-indexed source line of the bracket.
    # @param column [Integer] 1-indexed column of the opening bracket.
    # @param char_length [Integer] length of the [...] bracket span.
    # @return [Object] the result of the block.
    # @yieldreturn [Object] the result of the [expr] expression.
    def eval_at(line_number, column, char_length)
      yield
    rescue Ebsm::Error => e
      raise annotate(e, line_number, column, char_length)
    rescue StandardError => e
      raise annotate(Ebsm::Error.new("#{e.message} (#{e.class})"),
                     line_number, column, char_length)
    end

    # The binding the renderer evaluates the ERB template against. Methods set
    # or called in <% %> / <%= %> resolve on this object.
    # @return [Binding] this DSL's binding.
    def erb_binding
      binding
    end

    private

    # Attach source position to +error+ and return it for re-raising.
    def annotate(error, line_number, column, char_length)
      error.line_number = line_number
      error.column = column
      error.char_length = char_length
      error.line_text = @lines[line_number - 1]
      error.source_lines = @lines
      error
    end

    # Record that a ; data line (the fully-expanded +text+) came from
    # +source_line+, and return +text+ so ERB still emits it. The renderer
    # reads #emitted to bsm2_evaluate each ; line individually.
    # @param source_line [Integer] 1-indexed source line of the ; line.
    # @return [String] the expanded ; line text.
    # @yieldreturn [String] the expanded ; line text.
    def line(source_line)
      text = yield
      @emitted << [source_line, text]
      text
    end

    # @return [Ebsm::Hex] a fresh Hex formatter.
    def hex
      Hex.new
    end
  end
end
