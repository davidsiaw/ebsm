# A helper composed with literal bytes on the same line

```text file:compose.ebsm
# v = 0x12345678
; [le32 v] 41 "ok"
```

```text command
bundle exec ruby exe/ebsm compose.ebsm
```

```binary expected stdout
78 56 34 12 41 6f 6b
```
