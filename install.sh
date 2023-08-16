#!/bin/sh
pushd ~ >/dev/null
if ! command -v "rwfus" &>/dev/null; then
    echo "Installing rwfus."
    git clone https://github.com/ValShaped/rwfus.git >/dev/null
    pushd rwfus >/dev/null
    sudo ./rwfus -iI
    popd >/dev/null
    rm -rf ./rwfus >/dev/null
fi
echo "Building gamescope update..."
git clone https://aur.archlinux.org/gamescope-git.git
pushd gamescope-git
sudo mkdir /opt/rwfus/mount/etc/ 2> /dev/null
sudo sed -i "s/SigLevel *= Required DatabaseOptional/SigLevel = Never/" /etc/pacman.conf
sudo pacman -S fakeroot autoconf automake bison debugedit flex gcc m4 make patch 
sudo pacman -S glibc vulkan-headers linux-api-headers wayland libxcb libx11 xorgproto libdrm pixman systemd libglvnd libinput mesa libxkbcommon xcb-util-renderutil xcb-util-errors xcb-util-wm libcap libxmu libxtst libxcomposite libxi libxfixes libxdamage libxrender libxres libxext libxxf86vm sdl2 seatd pipewire
makepkg -src
sudo pacman -R fakeroot autoconf automake bison debugedit flex gcc m4 make patch
find /opt/rwfus/mount/upper/usr -type f -exec echo sudo rm -r {} + 
mkdir tmp
pushd tmp
sudo tar --use-compress-program=unzstd -xvf ../gamescope-git-*-x86_64.pkg.tar.zst >/dev/null
echo
echo "Installing gamescope update..."
sudo rsync -a ./usr /opt/rwfus/mount/upper/ >/dev/null
popd
popd
echo "Creating uninstall script..."
sudo sh -c 'echo "#!/bin/sh" > /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "echo Uninstalling HDRDeck..." >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "pushd /opt/rwfus/mount/upper/" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'find ./usr -type f -exec echo sudo rm -r {} + >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "sudo rm ./usr/bin/gamescope-session" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "sudo rm ./usr/bin/hdrdeck_uninstall" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "popd" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "read -p \"Please press enter to reboot.\"" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo sh -c 'echo "sudo reboot" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall'
sudo chmod 555 /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
echo
echo "Cleaning up our extracted gamescope files..."
sudo rm -rf ./gamescope-git
echo
echo "Enabling HDR..."
if ! grep -q 'DXVK_HDR' ~/.bash_profile; then
    echo "export ENABLE_GAMESCOPE_WSI=1" >> ~/.bash_profile
    echo "export ENABLE_GAMESCOPE_WSI=1" >> ~/.profile
    echo "export DXVK_HDR=1" >> ~/.bash_profile
    echo "export DXVK_HDR=1" >> ~/.profile
fi
sudo cp /usr/bin/gamescope-session /opt/rwfus/mount/upper/usr/bin/gamescope-session
sudo sed -i 's/gamescope \\/gamescope --hdr-enabled \\/' /opt/rwfus/mount/upper/usr/bin/gamescope-session
echo
echo "To uninstall please run the command \"hdrdeck_uninstall\""
read -p "Please press enter to reboot."
sudo reboot
