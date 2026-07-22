# IEEE 754 floats

`lef32`/`bef32` emit a 32-bit single-precision float; `lef64`/`bef64` emit a
64-bit double. Each takes a Float and renders its IEEE 754 bytes as
space-separated hex pairs in the named endianness. A non-Float (e.g. an
Integer) is rejected.

## lef32 / bef32 (single-precision, 1.0)

1.0 as f32 is 0x3f800000; little-endian bytes are `00 00 80 3f`, big-endian
`3f 80 00 00`.

```text file:f32.ebsm
; [lef32 1.0] [bef32 1.0]
```

```text command
bundle exec ruby exe/ebsm f32.ebsm
```

```binary expected stdout
00 00 80 3f 3f 80 00 00
```

## lef64 / bef64 (double-precision, 3.14)

3.14 as f64 is 0x40091EB851EB851F. Output piped through `od -An -tx1` so the
high bytes (> 0x80) compare as text.

```text file:f64.ebsm
; [lef64 3.14] [bef64 3.14]
```

```text command
bundle exec ruby exe/ebsm f64.ebsm | od -An -tx1
```

```text expected stdout
 1f 85 eb 51 b8 1e 09 40 40 09 1e b8 51 eb 85 1f
```

## A non-Float is rejected

```text file:float_err.ebsm
; [lef32 1]
```

```text command
bundle exec ruby exe/ebsm float_err.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 3)
---
    | *beginning of file*
> 1 | ; [lef32 1]
        ^~~~~~~~~ 1 is not a Float
```

```text expected exitcode
1
```
