# # scripting with [expr] interpolation

`#` lines run Ruby; `[expr]` on a `;` line interpolates the value.

```text file:interp.ebsm
# name = 'World'
; " [name] "
```

```text command
bundle exec ruby exe/ebsm interp.ebsm
```

```binary expected stdout
20 57 6f 72 6c 64 20
```
