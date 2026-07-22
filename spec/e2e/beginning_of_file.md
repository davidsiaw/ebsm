# A *beginning of file* marker fills missing context above line 1

When the error is on or near the first line, there are fewer than 2 source
lines above it. Instead of showing fewer context lines, ebsm shows a single
`*beginning of file*` marker so the context block keeps a consistent shape
and the pipes still align.

## Error on line 1

```text file:bof_line1.ebsm
; 45 asd
```

```text command
bundle exec ruby exe/ebsm bof_line1.ebsm
```

```text expected stderr
EBSM: error at source line 1 (column 5)
---
    | *beginning of file*
> 1 | ; 45 asd
          ^ hex byte needs two hex digits
```

```text expected exitcode
1
```

## Error on line 2 (one real line above + the marker)

```text file:bof_line2.ebsm
some line
; 45 asd
```

```text command
bundle exec ruby exe/ebsm bof_line2.ebsm
```

```text expected stderr
EBSM: error at source line 2 (column 5)
---
    | *beginning of file*
  1 | some line
> 2 | ; 45 asd
          ^ hex byte needs two hex digits
```

```text expected exitcode
1
```
