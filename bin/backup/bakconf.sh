#!/bin/bash

# Script to backup important config files from System

HOME='/home/eye/'
#NDIR='/media/roach/backup/'
H=`hostname`
CL="/home/eye/.bak_${H}"
FILESYS='/usr/share/slim/themes/archlinux-me:/usr/share/slim/themes/archlinux-simple:/etc/fstab:/etc/dhcpcd.conf:/etc/pacman.d/mirrorlist:/etc/pacman.conf:/etc/resolv.conf:/etc/locale.conf:/etc/hostname:/etc/localtime:/etc/vconsole.conf:/etc/slim.conf:/etc/ntp.conf:/etc/makepkg.conf:/etc/pacman.d/gnupg/gpg.conf:/etc/clamav/clamd.conf:/etc/clamav/freshclam.conf:/etc/abs.conf:/etc/systemd:/etc/netctl'
FILEHOME='.local/share/applications:.bash*:.config:.mozilla:.conky*:.cups:.fehbg:.fonts:.gtk*:.hplip:.htoprc:.mpd*:.mplayer:.ncmpcpp:.pondus:.purple:.vim*:.xinitrc:.xscreensaver:.themes:.icons:.pulse/client.conf:.zshrc:.zshenv:.omzsh:.zshrc.orig:.functs:.mutt*:.pentadactyl:.pentadactylrc:.Xresources:.xmobarrc:.xmonad:.xmobar:.bitcoin/*dat:.PyBitmessage'
DEST='/tmp/confbak'
DATE=`date +%F`
FL="/tmp/conf-${DATE}_${H}.tar.lzo"

mkdir /tmp/confbak
for FILE in `echo $FILESYS | sed 's/\:/\n/g'`; do sudo cp -av $FILE $DEST; done
for FILE in `echo $FILEHOME | sed 's/\:/\n/g'`; do cp -av $HOME$FILE $DEST; done

comm -23 <(/usr/bin/pacman -Qeq|sort) <(pacman -Qmq|sort) > $DEST/pkglist


sudo tar -cjpf - $DEST | lzop -9 -o $FL
sudo chown eye:users $FL
sudo chmod og-r $FL
sudo rm -rf $DEST

## cleanup old tars

#find /media/backup/conf -mtime +50 -exec rm -rf {} \;

## get filename in cloud folder and replace it
CLFL=$(ls $CL/conf*${H}*bak)
NFL=`echo $FL | sed 's/.*\/\(.*$\)/\1/'`
G="gpg --default-recipient-self"
[[ -f $CLFL ]] || exit 0
if [[ $(stat -c "%Y" $CLFL) -lt $(stat -c "%Y" $FL) ]];then
	rm $CLFL;
	$G -o $CL/${NFL:0:-8}.bak -e $FL;
fi
# finally, copy it to nas
#cp $FL $NDIR
sudo rm $FL
