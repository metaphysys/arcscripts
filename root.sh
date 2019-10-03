#!/bin/bash

# Variables
keys=es
chr=chroot.sh
boot=/dev/sda1
root=/dev/sda2
swap=/dev/sda3

'''
    Formato y administración de discos.
    Esta función presupone el siguiente particionado de disco:
    
        boot /dev/sda1	  /boot	  150MB	*Bootable
        root /dev/sda2	  /	  –
        # home /dev/sdaX	  /home	  - 
        swap /dev/sda3	  /swap	  2GB	* Type: Linux Swap / Solaris

    Se puede obtener con el comando cfdisk antes de ejecutar el script.
    !Función pendiente de automatizar.
'''
function adminDiscos {
    mkfs.ext2 $boot
    mkfs.ext4 $root
    mkswap $swap
    swapon $swap
    mount $root /mnt
    mkdir /mnt/boot
    mount $boot /mnt/boot
}

'''
    Instalación base del sistema operativo y generación del fstab.
    !Pendiente de extraer los paquetes para una mayor escala y abtracción.
'''
function instalacionBase {
    pacstrap /mnt base base-devel grub-bios networkmanager xf86-input-synaptics
    genfstab -U -p /mnt >> /mnt/etc/fstab
}

'''
    Acceso a jaula chroot de carpeta root del sistema (/mnt)
'''
function jaulaChroot {
    cp $chr /mnt
    chmod +x /mnt/$chr
    arch-chroot /mnt ./$chr
    umount /mnt/boot
    umount /mnt
}

# Guión
loadkeys $keys
adminDiscos
conexion=false
while [  $conexion = false ]; do
    if ping -c1 google.com &> /dev/null; then
	echo "Conexión correcta";
	conexion=true;
    else
	wifi-menu;
    fi
done
instalacionBase
jaulaChroot
reboot