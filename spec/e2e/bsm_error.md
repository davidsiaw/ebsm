# A bsm2-stage error is reported against the original source line

When the expanded text has a bsm2 lexer error (here a hex byte with non-hex
chars), the exe formats it with a source-context diagnostic and the correct
source line number -- not the expanded text's line number, which differs
because # scripting lines vanish and ; loops unroll.

```text file:bad_hex.ebsm
; 45 asd
```

```text command
bundle exec ruby exe/ebsm bad_hex.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 5)
---
    | *beginning of file*
> 1 | ; 45 asd
          ^ hex byte needs two hex digits
```

```text expected exitcode
1
```

## The source line is correct even after # lines and loops

The bad ; line is on source line 6. A naive expanded-text line number would
report 5 (the # lines vanish), but ebsm tracks the original source line.

```text file:bad_hex_multi.ebsm
# bytes = %w[48 65 6c]
# bytes.each do |b|
; [b]
# end
some prose
; 45 asd
```

```text command
bundle exec ruby exe/ebsm bad_hex_multi.ebsm
```

```text expected stderr
EBSM: error at source line 6 (column 5)
---
  4 | # end
  5 | some prose
> 6 | ; 45 asd
          ^ hex byte needs two hex digits
```

```text expected exitcode
1
```
