# frozen_string_literal: true

require 'ebsm'

RSpec.describe Ebsm::Dsl do
  let(:dsl) { described_class.new }

  describe 'byte helpers' do
    it 'byte emits a single hex pair' do
      expect(dsl.byte(0x41)).to eq('41')
    end

    it 'le16 emits 2 little-endian hex pairs' do
      expect(dsl.le16(0x1234)).to eq('34 12')
    end

    it 'be16 emits 2 big-endian hex pairs' do
      expect(dsl.be16(0x1234)).to eq('12 34')
    end

    it 'le32 emits 4 little-endian hex pairs' do
      expect(dsl.le32(0x12345678)).to eq('78 56 34 12')
    end

    it 'be32 emits 4 big-endian hex pairs' do
      expect(dsl.be32(0x12345678)).to eq('12 34 56 78')
    end

    it 'le64 emits 8 little-endian hex pairs' do
      expect(dsl.le64(0x0123456789abcdef)).to eq('ef cd ab 89 67 45 23 01')
    end

    it 'be64 emits 8 big-endian hex pairs' do
      expect(dsl.be64(0x0123456789abcdef)).to eq('01 23 45 67 89 ab cd ef')
    end

    it 'lef32 emits a 32-bit little-endian float' do
      expect(dsl.lef32(1.0)).to eq('00 00 80 3f')
    end

    it 'bef32 emits a 32-bit big-endian float' do
      expect(dsl.bef32(1.0)).to eq('3f 80 00 00')
    end

    it 'lef64 emits a 64-bit little-endian float' do
      expect(dsl.lef64(3.14)).to eq('1f 85 eb 51 b8 1e 09 40')
    end

    it 'bef64 emits a 64-bit big-endian float' do
      expect(dsl.bef64(3.14)).to eq('40 09 1e b8 51 eb 85 1f')
    end
  end

  describe 'boundary values' do
    it 'byte accepts 0xff' do
      expect(dsl.byte(0xff)).to eq('ff')
    end

    it 'le16 accepts 0xffff' do
      expect(dsl.le16(0xffff)).to eq('ff ff')
    end

    it 'le32 accepts 0xffffffff' do
      expect(dsl.le32(0xffffffff)).to eq('ff ff ff ff')
    end

    it 'le64 accepts 0xffffffffffffffff' do
      expect(dsl.le64(0xffffffffffffffff)).to eq('ff ff ff ff ff ff ff ff')
    end
  end

  describe 'helper errors' do
    it 'raises Ebsm::Error on overflow' do
      expect { dsl.le32(0x1_0000_0000) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xffffffff/)
    end

    it 'raises Ebsm::Error on a negative value' do
      expect { dsl.le32(-1) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xffffffff/)
    end

    it 'raises Ebsm::Error for a non-Integer' do
      expect { dsl.le32('hi') }.to raise_error(Ebsm::Error, /not an Integer/)
    end

    it 'errors per-width, not globally (le16 rejects 0x10000)' do
      expect { dsl.le16(0x10000) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xffff/)
    end

    it 'byte rejects 0x100 (out of range 0..0xff)' do
      expect { dsl.byte(0x100) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xff/)
    end

    it 'lef32 rejects a non-Float' do
      expect { dsl.lef32(1) }.to raise_error(Ebsm::Error, /not a Float/)
    end
  end

  describe 'bytes' do
    it 'emits every byte of a string' do
      expect(dsl.bytes('Hello')).to eq('48 65 6c 6c 6f')
    end

    it 'emits every byte of an array of integers' do
      expect(dsl.bytes([0x48, 0x65, 0x6c, 0x6c, 0x6f])).to eq('48 65 6c 6c 6f')
    end

    it 'raises Ebsm::Error when an array element is out of range' do
      expect { dsl.bytes([0x100]) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xff/)
    end

    it 'raises Ebsm::Error when an array element is not an Integer' do
      expect { dsl.bytes(['x']) }.to raise_error(Ebsm::Error, /not an Integer/)
    end
  end

  describe 'repeat' do
    it 'emits count copies of a byte' do
      expect(dsl.repeat(0x41, 4)).to eq('41 41 41 41')
    end

    it 'emits nothing when count is zero' do
      expect(dsl.repeat(0x00, 0)).to eq('')
    end

    it 'raises Ebsm::Error when the byte value is out of range' do
      expect { dsl.repeat(0x100, 4) }
        .to raise_error(Ebsm::Error, /out of range 0\.\.0xff/)
    end

    it 'raises Ebsm::Error for a negative count' do
      expect { dsl.repeat(0x00, -1) }
        .to raise_error(Ebsm::Error, /not a non-negative Integer/)
    end
  end

  describe '#eval_at' do
    it 'annotates an Ebsm::Error with source line, column, and length' do
      dsl.lines = ['some prose', '# x = 1', '; [le32 0x1_0000_0000] ff']
      error = begin
        dsl.eval_at(3, 3, 20) { dsl.le32(0x1_0000_0000) }
      rescue Ebsm::Error => e
        e
      end
      expect(error).to have_attributes(line_number: 3, column: 3,
                                       char_length: 20,
                                       line_text: '; [le32 0x1_0000_0000] ff')
    end

    it 'wraps a StandardError as an Ebsm::Error with position' do
      dsl.lines = ['; [bytes 1.2]']
      error = begin
        dsl.eval_at(1, 3, 11) { dsl.bytes(1.2) }
      rescue Ebsm::Error => e
        e
      end
      expect(error).to have_attributes(line_number: 1, column: 3,
                                       char_length: 11,
                                       line_text: '; [bytes 1.2]',
                                       message: /to_a.*NoMethodError/)
    end
  end
end
