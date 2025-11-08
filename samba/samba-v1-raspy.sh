#!/bin/bash
# Variables (puedes parametrizarlas)
USER="pansitodemichi"
PASS="Shudupa222."

# Actualizar e instalar Samba
apt update
apt install -y samba

# Instalar wsddn desde repositorio externo
wget -qO- https://www.gershnik.com/apt-repo/conf/pgp-key.public \
  | gpg --dearmor \
  | tee /usr/share/keyrings/gershnik.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gershnik.gpg] https://www.gershnik.com/apt-repo/ base main" \
  | tee /etc/apt/sources.list.d/wsddn.list >/dev/null
apt update
apt install -y wsddn

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
systemctl restart smbd.service nmbd.service || true
systemctl enable smbd.service nmbd.service || true

# Habilitar wsddn
systemctl restart wsddn.service || true
systemctl enable wsddn.service || true

echo "Configuración completada con éxito."
