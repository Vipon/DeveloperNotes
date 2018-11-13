# Bash useful commands
### Замена набора строк внутри множества файлом
```
find . -name "NAME_TEMPLATE" -exec sed -i '' -e 's/OLD_TEMPLATE/NEW_TEMPLATE/g' {} \;
```

### Вывод всех файлов в поддерикториях в порядке убывания их размера
```
find . -type f -exec ls -S {} +
```

### Diff между содержимом двух папок включая новые файлы
```
diff -Nur old_folder/ new_folder/
```

## GDB
### BackTrace
```
thread apply all bt full
```

### Print to file
```
set logging on
set logging file gdb_out_file.log
```

## Hardware analysis
### Get short information about disks
```
sudo lshw -short -C disk
```

### Get info about CPU
```
lcpu
```