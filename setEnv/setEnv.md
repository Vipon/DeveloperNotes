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
