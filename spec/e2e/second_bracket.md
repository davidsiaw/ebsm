# An error points at the correct [expr] when a line has two

```text file:second_bracket.ebsm
; ff [le16 0x1_0000]
```

```text command
bundle exec ruby exe/ebsm second_bracket.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 6)
---
    | *beginning of file*
> 1 | ; ff [le16 0x1_0000]
           ^~~~~~~~~~~~~~~ 0x10000 out of range 0..0xffff
```

```text expected exitcode
1
```
