# frozen_string_literal: true

require 'ebsm'

RSpec.describe Ebsm::Error do
  let(:error) do
    described_class.new('0x100000000 out of range 0..0xffffffff').tap do |e|
      e.line_number = 1
      e.column = 3
      e.char_length = 20
      e.line_text = '; [le32 0x1_0000_0000] ff'
      e.source_lines = ['; [le32 0x1_0000_0000] ff']
    end
  end

  describe '#format' do
    it 'produces a source-context diagnostic with an arrow' do
      expect(error.format).to eq(<<~TEXT)
        EBSM: error at source line 1 (column 3)
        ---
            | *beginning of file*
        > 1 | ; [le32 0x1_0000_0000] ff
                ^~~~~~~~~~~~~~~~~~~~ 0x100000000 out of range 0..0xffffffff
      TEXT
    end

    it 'shows the expanded line for a bsm2-stage error' do
      err = described_class.new('hex byte needs two hex digits').tap do |e|
        e.line_number = 2
        e.column = 17
        e.char_length = 1
        e.line_text = '; 78 56 34 12 45 asd'
        e.source_lines = ['# x = 0x12345678', '; [le32 x] 45 asd']
        e.expanded_line = '; 78 56 34 12 45 asd'
      end
      expect(err.format).to eq(<<~TEXT)
        EBSM: bsm2 error at source line 2 (expanded column 17)
        ---
            | *beginning of file*
          1 | # x = 0x12345678
        > 2 | ; [le32 x] 45 asd
              expanded:
              ; 78 56 34 12 45 asd
                              ^ hex byte needs two hex digits
      TEXT
    end

    it 'shows context lines above when the error is mid-file' do
      err = described_class.new('hex byte needs two hex digits').tap do |e|
        e.line_number = 3
        e.column = 5
        e.char_length = 1
        e.line_text = '; 45 asd'
        e.source_lines = ['some prose here', '# x = 1', '; 45 asd']
      end
      expect(err.format).to eq(<<~TEXT)
        EBSM: error at source line 3 (column 5)
        ---
          1 | some prose here
          2 | # x = 1
        > 3 | ; 45 asd
                  ^ hex byte needs two hex digits
      TEXT
    end

    it 'pads line numbers so pipes align for 2-digit lines' do
      lines = (1..10).map { |i| "line #{i}" } + ['; 45 asd']
      err = described_class.new('hex byte needs two hex digits').tap do |e|
        e.line_number = 11
        e.column = 5
        e.char_length = 1
        e.line_text = '; 45 asd'
        e.source_lines = lines
      end
      expect(err.format).to eq(<<~TEXT)
        EBSM: error at source line 11 (column 5)
        ---
           9 | line 9
          10 | line 10
        > 11 | ; 45 asd
                   ^ hex byte needs two hex digits
      TEXT
    end
  end
end
