# Настройка окружения
## Переустановка пакетов с одного Linux на другой
### Ubuntu/Debian
На основной ОС надо получить список всех установленных пакетов следующим образом:
```
dpkg --get-selections > pkgList.txt
```
Чтобы установить их на новой нужно выполнить данную последовательность комманд:
```
sudo apt-get install dselect
sudo dpkg --set-selections < pkgList.txt
sudo apt dselect-upgrade
```

## GNOME desktop
### Start up application at the start
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

## Автоматическое монтирование дисков при загрузке
1) Получаем список дисков. Находим интересующий нас. В моём случае это /dev/sdb.
```
sudo fdisk -l 
```

2) Переразбиваем диск (если необходимо).
```
sudo fdisk /dev/sdb
```
* Press __o__ and press Enter (creates a new table)
* Press __n__ and press Enter (creates a new partition)
* Press __p__ and press Enter (makes a primary partition)
* Then press 1 and press Enter (creates it as the 1st partition)
* Finally, press __w__ (this will write any changes to disk)

3) Форматируем диск (если необходимо).
```
sudo mkfs.ext4 /dev/sdb1
```

4) Добавляем диск в список монтируемых при загрузке. Для этого модифицируем файл __fstab__.
```
sudo vim /etc/fstab
```

Добавляем в __fstab__ 
```
#device      mountpoint                fstype  options               dump   fsck

/dev/sdb1    /home/USERNAME/DIRNAME    ext4    defaults,user,exec    0      0
```

* USERNAME - твоё имя пользователся (название твоей домашней папки).
* DIRNAME - папка монтирования. 
* user - разрешает монтировать всем пользователям.
* exec - можно исполнять файлы с примонтированного диска.

5) По дефолту владельцем примонтированного диска будет __root__, а не наш пользователь. Дальше есть парочка вариантов, либо поменять права доступа, либо владельца. Второе мне кажется лучше.
```
sudo chown USERNAME -R ~/DIRNAME/
```
