#!/bin/bash
rhost=$1
keyfile1="/var/tmp/mirrorlist.msys"
keyfile2="/etc/pacman.d/mirrorlist.msys"

if [ "${rhost}x" = "x" ]; then
  echo "[!] empty argument."
  exit
fi

ret=`echo $rhost | egrep "^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|[a-z][-.a-z0-9]{0,255}):?[0-9]{0,5}$" | wc -l`

if [ "$ret" -eq 1 ]; then
  echo "[*] operation start."
else
  echo "[!] invalid argument."
  exit
fi

if [ -f $keyfile1 ]; then
  # restore the pacman configuration files
  mv /var/tmp/mirrorlist.* /etc/pacman.d/
  if [ -f $keyfile2 -a ! -f $keyfile1 ]; then
    echo "[+] restore operation is successful."
  else
    echo "[!] restore operation is fail."
  fi
  echo '########' $keyfile2 '########'
  cat $keyfile2
else
  echo "[+] backup operation is start."
  # backup the pacman configuration files
  cp -p /etc/pacman.d/mirror* /var/tmp
  if [ -f $keyfile2 -a -f $keyfile1 ]; then
    echo "[+] backup operation is successful."
  else
    echo "[!] backup operation is fail."
    exit
  fi

  echo "[+] replace configuration operation is start."

  # change the configuration for msys
  msys_arch=`set | grep 'MSYSTEM_CARCH=x86_64' | wc -l`
  if [ $msys_arch -eq 1 ]; then
    sed -i.bak -e "/^Server/d" -e "/^\#\# msys2.org/a Server = http:\/\/${rhost}\/msys/x86_64" /etc/pacman.d/mirrorlist.msys
  else
    sed -i.bak -e "/^Server/d" -e "/^\#\# msys2.org/a Server = http:\/\/${rhost}\/msys/i1686" /etc/pacman.d/mirrorlist.msys
  fi
  ret=`grep "$1" $keyfile2 | wc -l`
  if [ $ret -eq 1 ]; then
    echo "[+] replace operation is successful."
  else
    echo "[!] replace operation is fail."
  fi
  echo '########' $keyfile2 '########'
  cat $keyfile2
fi
exit
