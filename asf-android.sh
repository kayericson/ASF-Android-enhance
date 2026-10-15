# Information script
clear
echo "╭━━━┳━━━┳━━━╮╱╭━━━╮╱╱╱╱╭╮╱╱╱╱╱╱╱╭╮"
echo "┃╭━╮┃╭━╮┃╭━━╯╱┃╭━╮┃╱╱╱╱┃┃╱╱╱╱╱╱╱┃┃"
echo "┃┃╱┃┃╰━━┫╰━━╮╱┃┃╱┃┣━╮╭━╯┣━┳━━┳┳━╯┃"
echo "┃╰━╯┣━━╮┃╭━┳┻━┫╰━╯┃╭╮┫╭╮┃╭┫╭╮┣┫╭╮┃"
echo "┃╭━╮┃╰━╯┃┃╱╰━━┫╭━╮┃┃┃┃╰╯┃┃┃╰╯┃┃╰╯┃"
echo "╰╯╱╰┻━━━┻╯╱╱╱╱╰╯╱╰┻╯╰┻━━┻╯╰━━┻┻━━╯"
echo "      github: sevcator/ASF-Android"
echo ""
echo "ArchiSteamFarm in Android Device"
echo ""

# Check if script is runned in Termux
if [ -n "$TERMUX_VERSION" ]; then
   echo "Executed in Termux $TERMUX_VERSION"
else
   echo "This script only for Termux!"
   exit
fi

# Update pkg
pkg update -y -o Dpkg::Options::="--force-confnew"

# Installing packages
pkg install proot-distro unzip -y

# Installing Ubuntu
proot-distro install ubuntu

# Installing requirements for ArchiSteamFarm
proot-distro login ubuntu -- bash -c 'apt update -y && apt upgrade -y && apt install libicu-dev mono-runtime unzip curl -y'

# Create a user noroot
proot-distro login ubuntu -- bash -c 'useradd -m noroot'

# Configure Autostart & motd
echo 'if telnet "127.0.0.1" "1337" </dev/null 2>&1 | grep -q "Connected"; then' >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo '  echo "Server is running. ASF will not again run..." && echo ""' >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo 'else' >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo '  echo "Server not running!" && echo "Running ASF..." && echo "" && echo "If you want use other session Termux" && echo "please wait when ipc server starts" && echo "and make new session"' >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo "proot-distro login ubuntu --user noroot --fix-low-ports -- bash -c 'export DOTNET_GCHeapHardLimit=1C0000000 && /home/noroot/asf/ArchiSteamFarm'" >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo 'fi' >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo "Welcome to Termux!" > /data/data/com.termux/files/usr/etc/motd
echo " " >> /data/data/com.termux/files/usr/etc/motd

# Run a command inside Ubuntu (paths are resolved by proot-distro itself, not hardcoded)
ubuntu_run() {
  proot-distro login ubuntu -- bash -c "$@"
}

# Detect architecture
arch=$(dpkg --print-architecture)

case "$arch" in
  arm|armhf)     ASF_ZIP="ASF-linux-arm.zip" ;;
  arm64|aarch64) ASF_ZIP="ASF-linux-arm64.zip" ;;
  *)
    clear
    echo "Unknown architecture. Please install ArchiSteamFarm manually."
    echo "Your architecture: $arch. Please report this on GitHub Issues."
    echo ""
    exit 1
    ;;
esac

# Download ASF, IPC config and ASFEnhance inside Ubuntu
echo "⬇️ Downloading ArchiSteamFarm and ASFEnhance..."
if ! ubuntu_run '
  set -e
  mkdir -p /home/noroot/asf/config /home/noroot/asf/plugins/ASFEnhance
  cd /home/noroot/asf
  curl -fL "https://github.com/JustArchiNET/ArchiSteamFarm/releases/latest/download/$1" -o asf.zip
  unzip -o asf.zip
  rm asf.zip
  curl -fL https://github.com/sevcator/ASF-Android/raw/main/IPC.config -o config/IPC.config
  curl -fL https://github.com/chr233/ASFEnhance/releases/latest/download/ASFEnhance.zip -o ASFEnhance.zip
  unzip -o ASFEnhance.zip -d plugins/ASFEnhance
  rm ASFEnhance.zip
  chown -R noroot:noroot /home/noroot/asf
' _ "$ASF_ZIP"; then
  echo "❌ Failed to download or unzip ASF / ASFEnhance"
  exit 1
fi

clear
echo "╭━━━┳━━━┳━━━╮╱╭━━━╮╱╱╱╱╭╮╱╱╱╱╱╱╱╭╮"
echo "┃╭━╮┃╭━╮┃╭━━╯╱┃╭━╮┃╱╱╱╱┃┃╱╱╱╱╱╱╱┃┃"
echo "┃┃╱┃┃╰━━┫╰━━╮╱┃┃╱┃┣━╮╭━╯┣━┳━━┳┳━╯┃"
echo "┃╰━╯┣━━╮┃╭━┳┻━┫╰━╯┃╭╮┫╭╮┃╭┫╭╮┣┫╭╮┃"
echo "┃╭━╮┃╰━╯┃┃╱╰━━┫╭━╮┃┃┃┃╰╯┃┃┃╰╯┃┃╰╯┃"
echo "╰╯╱╰┻━━━┻╯╱╱╱╱╰╯╱╰┻╯╰┻━━┻╯╰━━┻┻━━╯"
echo "      github: sevcator/ASF-Android"
echo ""
echo "ArchiSteamFarm in Android Device"
echo ""
echo "All right!"
echo ""

###############################################################################
# Move to ASF directory and download / unzip config.zip provided by user
# User can type "skip" to bypass config download and extraction
###############################################################################

echo
echo "=== Final configuration setup ==="
echo
echo "You can provide a direct download link to your config.zip file."
echo "If you want to skip this step, type: skip"
echo

while true; do
    read -rp "Config ZIP URL (or 'skip'): " config_link

    # Skip configuration step
    if [ "$config_link" = "skip" ]; then
        echo "Skipping config download and extraction."
        break
    fi

    # Empty input check
    if [ -z "$config_link" ]; then
        echo "Input cannot be empty. Please enter a valid link or type 'skip'."
        echo
        continue
    fi

    echo "Downloading config.zip..."
    # Download and unzip inside Ubuntu, always saved as config.zip
    if ubuntu_run '
        set -e
        cd /home/noroot/asf
        curl -fL "$1" -o config.zip
        unzip -o config.zip
        rm config.zip
        chown -R noroot:noroot /home/noroot/asf
    ' _ "$config_link"; then
        break
    else
        ubuntu_run 'rm -f /home/noroot/asf/config.zip'
        echo "Download failed. Please check the link and try again, or type 'skip'."
        echo
    fi
done

echo
echo "Everything is ready!"
echo "ASF installation is complete."
