# frozen_string_literal: true

module Ebsm
  # Formats numbers as the hex byte pairs the bsm2 lexer consumes on a '; '
  # data line. Owns the responsibility of validating a number (Integer in range,
  # or Float) and rendering it as lowercase hex pairs, so that Ebsm::Renderer can
  # stay focused on templating.
  class Hex
    # Convert +value+ to a byte sequence via Array#pack using +directive+ and
    # render it as space-separated lowercase hex pairs. Raises Ebsm::Error if
    # +value+ is not an Integer or lies outside 0..+max+.
    # @param value [Integer] the integer to encode.
    # @param directive [String] an Array#pack directive (e.g. 'V', 'N', 'C').
    # @param max [Integer] the inclusive upper bound for +value+.
    # @return [String] space-separated lowercase hex byte pairs.
    def pack_hex(value, directive, max)
      raise Ebsm::Error, "#{value.inspect} is not an Integer" unless value.is_a?(Integer)

      if value.negative? || value > max
        raise Ebsm::Error, format('0x%<v>s out of range 0..0x%<m>x',
                                  v: value.to_s(16), m: max)
      end

      [value].pack(directive).bytes.map { |b| format('%02x', b) }.join(' ')
    end

    # Render a single Integer byte (0..255) as a two-digit lowercase hex pair,
    # raising Ebsm::Error if it is not an Integer or is out of range.
    # @param byte [Integer] the byte value, 0..255.
    # @return [String] two lowercase hex digits.
    def hex_pair(byte)
      raise Ebsm::Error, "#{byte.inspect} is not an Integer" unless byte.is_a?(Integer)

      raise Ebsm::Error, format('0x%<v>s out of range 0..0xff', v: byte.to_s(16)) if byte.negative? || byte > 0xff

      format('%02x', byte)
    end

    # Convert a Float +value+ to its IEEE 754 binary representation via
    # Array#pack using +directive+ and render it as space-separated lowercase
    # hex pairs. Raises Ebsm::Error if +value+ is not a Float.
    # @param value [Float] the float to encode.
    # @param directive [String] an Array#pack float directive ('e','g','E','G').
    # @return [String] space-separated lowercase hex byte pairs.
    def pack_float(value, directive)
      raise Ebsm::Error, "#{value.inspect} is not a Float" unless value.is_a?(Float)

      [value].pack(directive).bytes.map { |b| format('%02x', b) }.join(' ')
    end
  end
end
