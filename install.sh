#!/bin/sh
## CONFIG
export GAMESCOPE_VERSION=3.11.52.beta2.r0.g2a09fbc-1


# ----- DO NOT MODIFY BELOW THIS LINE -----
pushd ~
if ! command -v "rwfus" &>/dev/null; then
    echo "Installing rwfus."
    git clone https://github.com/ValShaped/rwfus.git
    pushd rwfus
    sudo ./rwfus -iI
    popd
    rm -r rwfus
fi
echo "Extracting gamescope update..."
mkdir gamescope
pushdir gamescope
wget https://builds.garudalinux.org/repos/chaotic-aur/x86_64/gamescope-git-$GAMESCOPE_VERSION-x86_64.pkg.tar.zst
tar --use-compress-program=unzstd -xvf ./gamescope-git-$GAMESCOPE_VERSION-x86_64.pkg.tar.zst
echo "Creating uninstall script..."
sudo echo "#!/bin/sh" > /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "echo Uninstalling HDRDeck..." >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "pushd /opt/rwfus/mount/upper/" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo find ./usr -exec echo sudo rm -r {} + >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "sudo rm ./usr/bin/gamescope-session" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "sudo rm ./usr/bin/hdrdeck_uninstall" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "popd" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "read -p 'Please press enter to reboot.'" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo echo "sudo reboot" >> /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
sudo chmod 555 /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
echo "Installing gamescope update..."
sudo rsync -a ./usr /opt/rwfus/mount/upper/usr
popd
rm -r ./gamescope
echo "Enabling HDR..."
if grep -q 'DXVK_HDR' ~/.bash_profile; then
    echo "export ENABLE_GAMESCOPE_WSI=1" >> .bash_profile
    echo "export DXVK_HDR=1" >> .bash_profile
fi
sudo cp /usr/bin/gamescope-session /opt/rwfus/mount/upper/usr/bin/gamescope-session
sudo sed -i "s/gamescope \\/gamescope --hdr-enabled \\/" /opt/rwfus/mount/upper/usr/bin/gamescope-session
popd
read -p "Please press enter to reboot."
sudo reboot

