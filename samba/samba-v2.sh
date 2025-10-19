#!/bin/bash
# Variables (puedes parametrizarlas)
USER="pansitodemichi"
PASS="Shudupa222."

# Actualizar e instalar
apt update
apt install -y samba wsdd

# Crear directorios y permisos
mkdir -p /media/Datos
chmod 0777 /media/Datos

# Configurar smb.conf
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
cat <<EOL >/etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 50
   dns proxy = no
   follow symlinks = yes
   wide links = yes
   force user = $USER

[Datos]
   browseable = yes
   writeable = yes
   path = /media/Datos
EOL

# Crear usuario del sistema sin interacción
adduser --disabled-password --gecos "" $USER
# Establecer contraseña en Linux
echo "$USER:$PASS" | chpasswd

# Crear usuario de Samba, sin pedir input interactivo
echo -e "$PASS\n$PASS" | smbpasswd -a -s $USER

# Reiniciar y habilitar servicios
systemctl restart smbd nmbd wsdd
systemctl enable smbd nmbd wsdd

echo "Configuración completada con éxito."
