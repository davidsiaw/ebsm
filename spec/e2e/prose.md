# Prose on a # line is a Ruby error

`#` is live Ruby code, not a comment, so garbage after `#` must fail. (`this is
fine` parses as method calls, which raise NameError at runtime.)

```text file:prose.ebsm
# this is fine
; 41
```

```text command
bundle exec ruby exe/ebsm prose.ebsm
```

```text expected exitcode
1
```
