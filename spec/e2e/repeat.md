# Repeating bytes for padding

`repeat` emits +count+ copies of a byte as space-separated hex pairs. Useful
for padding a structure out to a fixed size or block boundary.

```text file:repeat.ebsm
; [repeat 0x00, 16]
```

```text command
bundle exec ruby exe/ebsm repeat.ebsm
```

```binary expected stdout
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

## Padding a header to a 16-byte boundary

A 4-byte magic followed by a 2-byte length, then zero-padded out to 16 bytes.
The pad count is computed on a # line so the header size lives in one place.

```text file:padding.ebsm
# magic = "EBSM"
# length = 0x0001
# header_size = 4 + 2
# pad = 16 - header_size
; [bytes magic] [be16 length] [repeat 0x00, pad]
```

```text command
bundle exec ruby exe/ebsm padding.ebsm
```

```binary expected stdout
45 42 53 4d 00 01 00 00 00 00 00 00 00 00 00 00
```
