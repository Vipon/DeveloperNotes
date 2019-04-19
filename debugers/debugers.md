# Debugers
| GDB | LLDB|
|--------|-------|
|__Breakpoints__|
| ```break [SYM_NAME/VIRT_ADDR]```|```break set -a [SYM_NAME/VIRT_ADDR]```|
|__BackTrace__|
|```thread apply all bt full```|
|__Print to file__|
|```set logging on```<br>```set logging file gdb_out_file.log```|
|__Display code__|
```layout src```
|__Display registers__|
```info registers [REG_NAME]```
|||