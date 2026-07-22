# # control flow around ; data lines

`# if` / `# else` / `# end` selects which `;` line is emitted.

```text file:branch.ebsm
# if false
; 41
# else
; 42
# end
```

```text command
bundle exec ruby exe/ebsm branch.ebsm
```

```binary expected stdout
42
```
