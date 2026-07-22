# Line-number padding aligns the pipes for 2-digit line numbers

When the error line is 10 or above, the context line numbers are right-padded
so the `|` pipes line up across all shown lines and the arrow stays aligned.

```text file:two_digit.ebsm
line 1
line 2
line 3
line 4
line 5
line 6
line 7
line 8
line 9
line 10
; 45 asd
```

```text command
bundle exec ruby exe/ebsm two_digit.ebsm
```

```text expected stderr
EBSM: error at source line 11 (column 5)
---
   9 | line 9
  10 | line 10
> 11 | ; 45 asd
           ^ hex byte needs two hex digits
```

```text expected exitcode
1
```
