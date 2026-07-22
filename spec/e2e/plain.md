# Plain bsm2 passthrough

A `;` line with no templating is just bsm2 data; `exe/ebsm` should emit exactly
those bytes.

```text file:plain.ebsm
; 48 65 6c 6c 6f
```

```text command
bundle exec ruby exe/ebsm plain.ebsm
```

```binary expected stdout
48 65 6c 6c 6f
```
