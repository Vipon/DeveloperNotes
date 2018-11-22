# Полезные команды bash.
## Замена набора строк внутри множества файлом
```
find . -name "NAME_TEMPLATE" -exec sed -i '' -e 's/OLD_TEMPLATE/NEW_TEMPLATE/g' {} \;
```


## Вывод всех файлов в поддерикториях в порядке убывания их размера
```
find . -type f -exec ls -S {} +
```


## Diff между содержимом двух папок включая новые файлы
```
diff -Nur old_folder/ new_folder/
```


## Отслеживание обновления файла
```
tail -f [FILE_NAME] | less
```


## Hardware analysis.
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