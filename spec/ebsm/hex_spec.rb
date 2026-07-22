# frozen_string_literal: true

require 'ebsm'

RSpec.describe Ebsm::Hex do
  let(:hex) { described_class.new }

  describe '#pack_hex' do
    it 'packs a 32-bit little-endian integer as hex pairs' do
      expect(hex.pack_hex(0x12345678, 'V', 0xffffffff)).to eq('78 56 34 12')
    end

    it 'packs a 32-bit big-endian integer as hex pairs' do
      expect(hex.pack_hex(0x12345678, 'N', 0xffffffff)).to eq('12 34 56 78')
    end

    it 'packs a single byte' do
      expect(hex.pack_hex(0x41, 'C', 0xff)).to eq('41')
    end

    it 'raises Ebsm::Error if the value is not an Integer' do
      expect { hex.pack_hex('hi', 'C', 0xff) }
        .to raise_error(Ebsm::Error, /not an Integer/)
    end

    it 'raises Ebsm::Error on overflow' do
      expect { hex.pack_hex(0x1_0000_0000, 'V', 0xffffffff) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xffffffff/)
    end

    it 'raises Ebsm::Error on a negative value' do
      expect { hex.pack_hex(-1, 'V', 0xffffffff) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xffffffff/)
    end

    it 'accepts the max boundary value' do
      expect(hex.pack_hex(0xff, 'C', 0xff)).to eq('ff')
    end
  end

  describe '#hex_pair' do
    it 'renders a byte as two hex digits' do
      expect(hex.hex_pair(0x41)).to eq('41')
    end

    it 'raises Ebsm::Error if the value is not an Integer' do
      expect { hex.hex_pair('hi') }.to raise_error(Ebsm::Error, /not an Integer/)
    end

    it 'raises Ebsm::Error on overflow' do
      expect { hex.hex_pair(0x100) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xff/)
    end

    it 'raises Ebsm::Error on a negative value' do
      expect { hex.hex_pair(-1) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xff/)
    end

    it 'accepts 0xff' do
      expect(hex.hex_pair(0xff)).to eq('ff')
    end
  end

  describe '#pack_float' do
    it 'packs a 32-bit little-endian float as hex pairs' do
      expect(hex.pack_float(1.0, 'e')).to eq('00 00 80 3f')
    end

    it 'packs a 32-bit big-endian float as hex pairs' do
      expect(hex.pack_float(1.0, 'g')).to eq('3f 80 00 00')
    end

    it 'packs a 64-bit little-endian float as hex pairs' do
      expect(hex.pack_float(3.14, 'E')).to eq('1f 85 eb 51 b8 1e 09 40')
    end

    it 'packs a 64-bit big-endian float as hex pairs' do
      expect(hex.pack_float(3.14, 'G')).to eq('40 09 1e b8 51 eb 85 1f')
    end

    it 'raises Ebsm::Error if the value is not a Float' do
      expect { hex.pack_float(1, 'e') }.to raise_error(Ebsm::Error, /not a Float/)
    end
  end
end
