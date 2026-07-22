# --bsm / -b prints the expanded bsm2 text instead of binary

Useful for debugging ebsm scripting: you see exactly what the templating
produced before bsm2 compiles it to bytes.

```text file:expand.ebsm
# v = 0x12345678
; [le32 v] 41 "ok"
```

```text command
bundle exec ruby exe/ebsm --bsm expand.ebsm
```

```text expected stdout
; 78 56 34 12 41 "ok"
```
