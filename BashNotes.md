# Bash syntax.
## Переменные.
### Создание переменных.
```
[__VAR__]=[__VALUE__]
```

* __VAR__ --- имя создаваемой переменной.
* = --- операция присваивания значения/инициализации
* __VALUE__ --- значение переменной, может быть чем угодно.


### Уничтожание/Сброс переменных.
Для того чтобы уничтожить переменную необходимо выполнить команду __unset__:
```
unset [__VAR__]
```
* __VAR__ --- имя удаляемой переменной.


# Bash useful commands.
### Замена набора строк внутри множества файлом.
```
find . -name "NAME_TEMPLATE" -exec sed -i '' -e 's/OLD_TEMPLATE/NEW_TEMPLATE/g' {} \;
```

### Вывод всех файлов в поддерикториях в порядке убывания их размера.
```
find . -type f -exec ls -S {} +
```

### Diff между содержимом двух папок включая новые файлы.
```
diff -Nur old_folder/ new_folder/
```

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
