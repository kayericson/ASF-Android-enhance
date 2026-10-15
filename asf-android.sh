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
proot-distro login ubuntu -- bash -c 'apt update -y && apt upgrade -y && apt install libicu-dev mono-runtime -y'

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

# ASF folder inside Ubuntu rootfs
ASF_DIR=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/home/noroot/asf

# Creating a folder for ASF and IPC config
mkdir -p "$ASF_DIR/config"
curl -fL https://github.com/sevcator/ASF-Android/raw/main/IPC.config -o "$ASF_DIR/config/IPC.config"

# Downloading ArchiSteamFarm
# Direct "latest/download" links are used instead of the GitHub API (API has a 60 req/hour limit per IP)
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

echo "⬇️ Downloading $ASF_ZIP..."
if ! curl -fL "https://github.com/JustArchiNET/ArchiSteamFarm/releases/latest/download/$ASF_ZIP" -o "$ASF_DIR/$ASF_ZIP"; then
  echo "❌ Failed to download $ASF_ZIP"
  exit 1
fi
unzip -o "$ASF_DIR/$ASF_ZIP" -d "$ASF_DIR"
rm "$ASF_DIR/$ASF_ZIP"

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

cd "$ASF_DIR"

# Downloading ASFEnhance plugin
echo "⬇️ Downloading ASFEnhance.zip..."
if ! curl -fL "https://github.com/chr233/ASFEnhance/releases/latest/download/ASFEnhance.zip" -o ASFEnhance.zip; then
  echo "❌ Failed to download ASFEnhance.zip"
  exit 1
fi

echo "📦 Unzipping into ./plugins/ASFEnhance..."
mkdir -p plugins/ASFEnhance
unzip -o ASFEnhance.zip -d plugins/ASFEnhance

echo "🧹 Cleaning up..."
rm ASFEnhance.zip

echo "✅ Done! ASFEnhance is installed in ./asf/plugins/ASFEnhance"
###############################################################################
# Move to ASF directory and download / unzip config.zip provided by user
# User can type "skip" to bypass config download and extraction
###############################################################################

echo
echo "=== Final configuration setup ==="
echo "Changing directory to ASF installation folder..."
cd "$ASF_DIR" || {
    echo "Error: Failed to change to ASF directory."
    exit 1
}

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
    # Always save as config.zip, whatever the file name in the link is
    if curl -fL "$config_link" -o config.zip; then
        echo "Unzipping config.zip..."
        unzip -o config.zip
        rm config.zip
        break
    else
        rm -f config.zip
        echo "Download failed. Please check the link and try again, or type 'skip'."
        echo
    fi
done

echo
echo "Everything is ready!"
echo "ASF installation is complete."
