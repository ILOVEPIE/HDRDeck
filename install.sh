#!/bin/sh
## CONFIG
export GAMESCOPE_VERSION=3.12.0.r7.gf2e925f-1


# ----- DO NOT MODIFY BELOW THIS LINE -----
pushd ~ >/dev/null
if ! command -v "rwfus" &>/dev/null; then
    echo "Installing rwfus."
    git clone https://github.com/ValShaped/rwfus.git >/dev/null
    pushd rwfus >/dev/null
    sudo ./rwfus -iI
    popd >/dev/null
    rm -rf ./rwfus >/dev/null
fi
echo "Extracting gamescope update..."
mkdir gamescope
pushd gamescope
wget https://builds.garudalinux.org/repos/chaotic-aur/x86_64/gamescope-git-$GAMESCOPE_VERSION-x86_64.pkg.tar.zst >/dev/null
sudo tar --use-compress-program=unzstd -xvf ./gamescope-git-$GAMESCOPE_VERSION-x86_64.pkg.tar.zst >/dev/null
echo
echo "Installing gamescope update..."
sudo rsync -a ./usr /opt/rwfus/mount/upper/ >/dev/null
echo
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
popd >/dev/null
echo
echo "Cleaning up our extracted gamescope files..."
sudo rm -rf ./gamescope
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
popd >/dev/null
echo
echo "To uninstall please run the command \"hdrdeck_uninstall\""
read -p "Please press enter to reboot."
sudo reboot
