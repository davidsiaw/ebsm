# A Ruby error inside [expr] is caught and reported with an arrow

If the expression in a [...] bracket raises a Ruby error (here `bytes` gets a
Float, which has no `to_a`), ebsm wraps it as an Ebsm::Error so it gets the
same source-context diagnostic instead of a raw backtrace. The message
includes the original error class.

```text file:ruby_error.ebsm
; [bytes 1.2]
```

```text command
bundle exec ruby exe/ebsm ruby_error.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 3)
---
    | *beginning of file*
> 1 | ; [bytes 1.2]
        ^~~~~~~~~~~ undefined method 'to_a' for an instance of Float (NoMethodError)
```

```text expected exitcode
1
```
