# Overflow is rejected with a source-context diagnostic

`le32` only holds 32 bits; `0x1_0000_0000` must error, pointing at the
offending bracket with an arrow.

```text file:overflow.ebsm
; [le32 0x1_0000_0000]
```

```text command
bundle exec ruby exe/ebsm overflow.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 3)
---
    | *beginning of file*
> 1 | ; [le32 0x1_0000_0000]
        ^~~~~~~~~~~~~~~~~~~~ 0x100000000 out of range 0..0xffffffff
```

```text expected exitcode
1
```
