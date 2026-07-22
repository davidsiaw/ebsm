# The greeting example

Builds a binary "greeting packet" end-to-end and checks the full packet bytes.

Layout: "EBSM" magic, le16 version, le16 count, then per string le32 length
followed by the raw bytes.

Plain lines are the only real comments -- bsm2 ignores them.
# lines below are LIVE RUBY, not comments.
; lines below are LIVE DATA, not comments.

```text file:greeting.ebsm
Build a tiny binary "greeting packet":

    offset  field          type      value
    0       magic          4 bytes   "EBSM"
    4       version        le16      1
    6       count          le16      number of strings
    8       payloads       repeated  le32 length + raw bytes per string

Plain lines like these are the ONLY real comments -- bsm2 ignores them.
The # lines below are LIVE RUBY, not comments.
The ; lines below are LIVE DATA, not comments.

# magic = "EBSM"
# version = 1
# payloads = ["Hello", "World", "!"]

; "EBSM" [le16 version] [le16 payloads.length]

# payloads.each do |s|
; [le32 s.length] "[s]"
# end
```

```text command
bundle exec ruby exe/ebsm greeting.ebsm
```

```binary expected stdout
45 42 53 4d 01 00 03 00 05 00 00 00 48 65 6c 6c 6f 05 00 00 00 57 6f 72 6c 64 01 00 00 00 21
```
