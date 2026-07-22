# An ARM instruction: big-endian 32-bit

Builds a real ARM A32 instruction word -- `MOV R0, #0x41` (move the immediate
0x41 into register R0) -- by composing the bit fields with `<<` and `|`, then
emitting it as a big-endian 32-bit word with `be32`.

The encoded word is 0xE3A00041; big-endian bytes are `e3 a0 00 41`.

Piped through `od -An -tx1` so the high bytes (> 0x80) compare as text instead
of tripping markspec's binary matcher.

```text file:arm.ebsm
ARM A32 instruction: MOV R0, #0x41  (move immediate 0x41 into register R0)
The 32-bit word is 0xE3A00041; emitted big-endian as e3 a0 00 41.

Fields (ARM data-processing immediate encoding):
    cond        31:28  always (AL) = 0b1110
    I           25     immediate operand = 1
    opcode      24:21  MOV = 0b1101
    S           20     don't set flags = 0
    Rn          19:16  ignored for MOV = 0
    Rd          15:12  destination = R0 = 0
    imm         7:0    0x41

# cond = 0b1110
# I = 0b1
# opcode_mov = 0b1101
# S = 0b0
# Rn = 0b0000
# Rd = 0b0000
# imm = 0x41
# instr = (cond << 28) | (I << 25) | (opcode_mov << 21) | (S << 20) | (Rn << 16) | (Rd << 12) | imm
; [be32 instr]
```

```text command
bundle exec ruby exe/ebsm arm.ebsm | od -An -tx1
```

```text expected stdout
 e3 a0 00 41
```
