#!/bin/sh
## CONFIG
export GAMESCOPE_VERSION=3.11.52.beta2.r0.g2a09fbc-1


# ----- DO NOT MODIFY BELOW THIS LINE -----
pushd ~ >/dev/null
if ! command -v "rwfus" &>/dev/null; then
    echo "Installing rwfus."
    git clone -q https://github.com/ValShaped/rwfus.git
    pushd rwfus >/dev/null
    sudo ./rwfus -iI
    popd >/dev/null
    rm -rf ./rwfus
fi
echo "Extracting gamescope update ${GAMESCOPE_VERSION}...\n"
mkdir gamescope
pushd gamescope
wget -q https://builds.garudalinux.org/repos/chaotic-aur/x86_64/gamescope-git-${GAMESCOPE_VERSION}-x86_64.pkg.tar.zst
sudo tar --use-compress-program=unzstd -xf ./gamescope-git-${GAMESCOPE_VERSION}-x86_64.pkg.tar.zst
echo "Installing gamescope update...\n"
sudo rsync -qa ./usr /opt/rwfus/mount/upper/
echo "Creating uninstall script...\n"

cat << EOF | sudo tee /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall > /dev/null
  #!/bin/sh
  echo "Uninstalling HDRDeck..."
  sudo rm -rv /opt/rwfus/mount/upper/usr
  popd
  echo "Removing entries from .bash_profile"
  sed -i /ENABLE_GAMESCOPE_WSI=1/d' ~/.bash_profile
  sed -i /DXVK_HDR=1/d' ~/.bash_profile
  read -p "Please press enter to reboot."
  sudo reboot
EOF

sudo chmod 555 /opt/rwfus/mount/upper/usr/bin/hdrdeck_uninstall
popd >/dev/null
echo "Cleaning up our extracted gamescope files...\n"
sudo rm -rf ./gamescope
echo "Enabling HDR...\n"
if ! grep -q 'DXVK_HDR' ~/.bash_profile; then
cat << EOF >> ~/.bash_profile
  export ENABLE_GAMESCOPE_WSI=1
  export DXVK_HDR=1
EOF
fi
sudo cp /usr/bin/gamescope-session /opt/rwfus/mount/upper/usr/bin/gamescope-session
sudo sed -i 's/gamescope \\/gamescope --hdr-enabled \\/' /opt/rwfus/mount/upper/usr/bin/gamescope-session
popd >/dev/null
echo "\nTo uninstall please run the command 'hdrdeck_uninstall'\n"
read -p "Please press enter to reboot."
sudo reboot
