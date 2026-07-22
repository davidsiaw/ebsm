# An error on a later line reports the correct source line with context

The bad ; line is on source line 3. The diagnostic shows 2 lines of context
above and the correct source line number.

```text file:multiline_error.ebsm
some prose here
# x = 1
; 45 asd
```

```text command
bundle exec ruby exe/ebsm multiline_error.ebsm
```

```text expected stderr
EBSM: error at source line 3 (column 5)
---
  1 | some prose here
  2 | # x = 1
> 3 | ; 45 asd
          ^ hex byte needs two hex digits
```

```text expected exitcode
1
```
