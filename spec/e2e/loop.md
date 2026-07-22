# A # loop emitting one ; line per element

```text file:loop.ebsm
# %w[48 65 6c 6c 6f].each do |b|
; [b]
# end
```

```text command
bundle exec ruby exe/ebsm loop.ebsm
```

```binary expected stdout
48 65 6c 6c 6f
```
