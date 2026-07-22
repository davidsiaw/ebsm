# Bits via Ruby binary literals

Ruby's `0b...` binary literals work inside `[...]` via the `byte` helper, which
emits a single byte as a hex pair. Bits are MSB first (Ruby literal order).

```text file:bits.ebsm
# A = 0b01000001
; [byte 0b01000001]
```

```text command
bundle exec ruby exe/ebsm bits.ebsm
```

```binary expected stdout
41
```

## Mixing binary literals with hex and strings on one line

```text file:mixed.ebsm
; [byte 0b01000001] 42 [byte 0b00000001]
```

```text command
bundle exec ruby exe/ebsm mixed.ebsm
```

```binary expected stdout
41 42 01
```

## A status flags byte

Bit 6 = running, bit 0 = ready, the rest 0.

```text file:flags.ebsm
# flags = 0b01000001
; [byte flags]
```

```text command
bundle exec ruby exe/ebsm flags.ebsm
```

```binary expected stdout
41
```

## Composing flags from named bits

Build the byte by OR-ing named bit constants -- clearer than a raw literal.

```text file:named_bits.ebsm
# RUNNING = 0b01000000
# READY   = 0b00000001
# flags = RUNNING | READY
; [byte flags]
```

```text command
bundle exec ruby exe/ebsm named_bits.ebsm
```

```binary expected stdout
41
```
