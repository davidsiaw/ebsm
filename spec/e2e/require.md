# Requiring a stdlib feature

`#` lines are live Ruby, so `require` works -- pull in any stdlib (or gem)
feature and use it to compute bytes.

Here `require 'digest'` gives us `Digest::SHA1`; we compute the SHA-1 of a
string, slice the first 4 bytes on a # line, and emit them in one go with the
`bytes` helper. Output piped through `od -An -tx1` so the high bytes compare
as text.

```text file:require.ebsm
# require 'digest'
# d = Digest::SHA1.digest("ebsm")
# chunk = d[0, 4]
; [bytes chunk]
```

```text command
bundle exec ruby exe/ebsm require.ebsm | od -An -tx1
```

```text expected stdout
 03 7e 51 3a
```
