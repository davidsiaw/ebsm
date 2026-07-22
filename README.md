# ebsm

Ebsm is a **literate binary generator**. You write a text file that mixes prose, Ruby scripting, and byte data; `ebsm` evaluates the scripting and compiles the data lines into raw bytes.

It is a templating layer over [bsm](https://github.com/davidsiaw/bsm), a literate binary format where a line is data **only** if it starts with `;`.

## Documentation

Detailed documentation is here: https://davidsiaw.github.io/ebsm/

## Literate Language

Ebsm deliberately steals the two most common comment markers in programming
and makes them both **live code**:

| sigil | meaning in ebsm | what it usually means elsewhere |
|-------|-----------------|--------------------------------|
| `;`   | **data** line   | asm / Lisp comment             |
| `#`   | **Ruby** code   | shell / Ruby / Python comment  |

Only a **plain line** (lines with no `;` or `#` as the first character) is actually a comment - ebsm
ignores it.

## Line syntax

### Raw BSM

`; <bsm2 data>` is a data line. Everything after the `;` is bsm2.
 - H hex byte pairs (`48 65`)
 - single chars (`'A'`)
 - double-quoted strings (`"hi"`)
 - bitfields (`<01010101>`)

Any `[expr]` is interpolated via ERB `<%= expr %>`

### Scripting lines

`# <ruby>` is a scripting line. Lines that start with `#` mark Ruby code.
Equivalent to ERB `<% ... %>` for its side effects (assignments, loops, conditionals).

### Comment by default

Anything else is a comment, ignored.

## Example Usage

This is an example of how to use ebsm.

More usage examples here: https://davidsiaw.github.io/ebsm/file.arm.html

```ebsm
file: arm.ebsm

ARM A32 instruction: MOV R0, #0x41  (move immediate 0x41 into register R0)
The 32-bit word is 0xE3A00041; emitted big-endian as e3 a0 00 41.

Fields (ARM data-processing immediate encoding):
    cond        31:28  always (AL) = 0b1110
    imop        25     immediate operand = 1
    opcode      24:21  MOV = 0b1101
    set         20     don't set flags = 0
    rn          19:16  ignored for MOV = 0
    rd          15:12  destination = R0 = 0
    imm         7:0    0x41

# cond = 0b1110
# imop = 0b1
# opcode_mov = 0b1101
# set = 0b0
# rn = 0b0000
# rd = 0b0000
# imm = 0x41
# instr = (cond << 28) | (imop << 25) | (opcode_mov << 21) | (set << 20) | (rn << 16) | (rd << 12) | imm
; [be32 instr]
```

Run it:

    $ bundle exec exe/ebsm arm.ebsm | msb
    ; e3 a0 00 41
    Total bytes: 4

## Debugging

Pass `--bsm` (or `-b`) to print the expanded bsm2 literate text instead of compiling it to binary. This shows exactly what the templating produced.

The `; ` data lines after `#` scripting and `[...]` interpolation is handy for debugging your ebsm code:

    $ echo '; [le32 0x12345678] 41 "ok"' | bundle exec ruby exe/ebsm --bsm
    ; 78 56 34 12 41 "ok"

## EBSM methods

`Ebsm::Dsl` provides endian helpers for use inside the square brackets `[...]`. Each returns space-separated hex byte pairs and raises `Ebsm::Error` on overflow or non-Integer input.

| helper   | width | endianness   |
|----------|-------|--------------|
| `byte`   | 1     | --           |
| `bytes`  | many  | --           |
| `repeat` | many  | --           |
| `le16`   | 2     | little       |
| `be16`   | 2     | big          |
| `le32`   | 4     | little       |
| `be32`   | 4     | big          |
| `le64`   | 8     | little       |
| `be64`   | 8     | big          |
| `lef32`  | 4     | little (f32) |
| `bef32`  | 4     | big (f32)    |
| `lef64`  | 8     | little (f64) |
| `bef64`  | 8     | big (f64)    |


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ebsm'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ebsm

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the unit tests and `bundle exec markspec` to run the end-to-end markdown tests. You can also run `bin/console` for an interactive prompt.

Generate API documentation (including the e2e spec files as browsable pages) with `rake yard`; the output lands in `doc/`.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidsiaw/ebsm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/davidsiaw/ebsm/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ebsm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davidsiaw/ebsm/blob/master/CODE_OF_CONDUCT.md).
