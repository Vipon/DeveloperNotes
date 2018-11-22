## Clang.
### Flags.
 * -dM --- генерирует список доступных макроопределений **#define **
 * -E --- прекратить компиляцию после этапа препроцессора.
 * -x --- спецификация языка программирования. Если ничего не указано, то тип языка определяется по расширению файла.

### Get list of predefined macrosses.
```
clang -dM -E -x c /dev/null
```

# Debugers
| GDB | LLDB|
|--------|-------|
|__Breakpoints__|
| ```break [SYM_NAME/VIRT_ADDR]```|```break set -a [SYM_NAME/VIRT_ADDR]```|
|__BackTrace__|
|```thread apply all bt full```|
|__Print to file__|
|```set logging on```<br>```set logging file gdb_out_file.log```|
|__Display source code__|
|||

# Hardware analysis.
### Get short information about disks.
```
sudo lshw -short -C disk
```
### Get info about RAM.
```
sudo lshw -short -C memory
```

### Get info about CPU.
```
lcpu
```
```
cat /proc/cpuinfo
```

# GNOME desktop.
### Start up application at the start.
```
cd ~/.config/autostart/

touch YOUR_PROGRAM.desktop
echo "[Desktop Entry]
Name=YOUR_PROGRAM
Comment=Comments
Exec=PATH_TO_APP
Icon=PATH_TO_ICON
Terminal=false
Type=Application
StartupNotify=false
X-GNOME-Autostart-enabled=true" > YOUR_PROGRAM.desktop
```
