# A bsm2 error on an interpolated ; line shows source and expanded

When a ; line mixes [expr] interpolation with literal bsm2 data and the
literal part is invalid, the diagnostic shows both the source line (with
context) and the expanded bsm2 line the arrow points at.

Here [le32 x] expands to "78 56 34 12", so the expanded line is
"; 78 56 34 12 45 asd" and bsm2 chokes on "asd". The error reports source
line 2, shows the source line, then shows the expanded line under the
"expanded:" marker with the arrow pointing at the bad bytes.

```text file:interp_bsm_error.ebsm
# x = 0x12345678
; [le32 x] 45 asd
```

```text command
bundle exec ruby exe/ebsm interp_bsm_error.ebsm
```

```text expected stderr
EBSM: bsm2 error at source line 2 (expanded column 17)
---
    | *beginning of file*
  1 | # x = 0x12345678
> 2 | ; [le32 x] 45 asd
      expanded:
      ; 78 56 34 12 45 asd
                      ^ hex byte needs two hex digits
```

```text expected exitcode
1
```
