# A non-Integer is rejected with a source-context diagnostic

```text file:nonint.ebsm
; [le32 "hi"]
```

```text command
bundle exec ruby exe/ebsm nonint.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 3)
---
    | *beginning of file*
> 1 | ; [le32 "hi"]
        ^~~~~~~~~~~ "hi" is not an Integer
```

```text expected exitcode
1
```
