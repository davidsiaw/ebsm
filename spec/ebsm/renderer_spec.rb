# frozen_string_literal: true

require 'ebsm'

RSpec.describe Ebsm::Renderer do
  let(:ctx) { described_class.new }

  describe '#render' do
    it 'passes non-;/# lines through verbatim (bsm2 ignores them)' do
      expect(ctx.render("hello world\n")).to eq("hello world\n")
    end

    context 'with a # scripting line' do
      it 'runs the code and produces no output of its own' do
        expect(ctx.render("# x = 1\n")).to eq('')
      end

      it 'lets # code drive # control flow around ; data lines' do
        src = <<~EBSM
          # if false
          ; 41
          # else
          ; 42
          # end
        EBSM
        # 0x42 == 'B'
        expect(ctx.render(src)).to eq("; 42\n")
      end

      it 'raises a Ruby error for non-Ruby on a # line (it is live code)' do
        # # lines are live Ruby code, not comments, so they must be valid Ruby.
        expect { ctx.render("# )\n") }.to raise_error(SyntaxError)
      end
    end

    context 'with a ; data line' do
      it 'keeps the leading ; so the line stays a bsm2 data line' do
        expect(ctx.render('; 48 65')).to eq("; 48 65\n")
      end

      it 'expands [expr] into the value of expr' do
        src = <<~EBSM
          # name = 'World'
          ; " [name] "
        EBSM
        expect(ctx.render(src)).to eq("; \" World \"\n")
      end

      it 'expands multiple [expr] on one line' do
        src = <<~EBSM
          # a = 48
          # b = 65
          ; [a] [b]
        EBSM
        expect(ctx.render(src)).to eq("; 48 65\n")
      end
    end

    context 'with # and ; working together' do
      it 'loops over an array emitting one ; line per element' do
        src = <<~EBSM
          # %w[48 65 6c].each do |b|
          ; [b]
          # end
        EBSM
        expect(ctx.render(src)).to eq("; 48\n; 65\n; 6c\n")
      end
    end
  end

  describe '#bsm2_evaluate' do
    it 'produces the same bytes as bsm2 for valid input' do
      require 'bsm'
      src = "; 48 65 6c\n; 6c 6f\n"
      expect(ctx.bsm2_evaluate(src)).to eq(Bsm::Generator.new.generate(src))
    end

    it 'reports a bsm2 error against the original source line' do
      error = begin
        ctx.bsm2_evaluate("# x = 1\nsome prose\n; 45 asd\n")
      rescue Ebsm::Error => e
        e
      end
      expect(error).to have_attributes(line_number: 3, column: 5,
                                       char_length: 1,
                                       line_text: '; 45 asd',
                                       message: 'hex byte needs two hex digits')
    end

    it 'reports the correct source line through a # loop' do
      error = begin
        ctx.bsm2_evaluate("# bytes = %w[48 65 6c]\n# bytes.each do |b|\n; [b]\n# end\nsome prose\n; 45 asd\n")
      rescue Ebsm::Error => e
        e
      end
      expect(error.line_number).to eq(6)
    end
  end
end
