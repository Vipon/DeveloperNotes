# Настройка окружения
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
