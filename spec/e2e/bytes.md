# The bytes helper emits a whole string or array in one call

`bytes` takes a String (its raw bytes) or an Array of Integers and emits each
as a hex pair, separated by spaces. Useful for dumping a run of bytes without
calling `byte` for each one.

## A literal string

```text file:bytes_str.ebsm
; [bytes "Hello"]
```

```text command
bundle exec ruby exe/ebsm bytes_str.ebsm
```

```binary expected stdout
48 65 6c 6c 6f
```

## An array of integers assigned on a # line

The array must be assigned on a # line because `[` can't appear inside a [...]
interpolation.

```text file:bytes_arr.ebsm
# a = [0x48, 0x65, 0x6c, 0x6c, 0x6f]
; [bytes a]
```

```text command
bundle exec ruby exe/ebsm bytes_arr.ebsm
```

```binary expected stdout
48 65 6c 6c 6f
```
