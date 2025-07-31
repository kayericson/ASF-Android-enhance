# asf directory
cd /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/home/noroot/asf
# create plugins if it doesn't exist
mkdir -p plugins
# download  the latest ASFEnhance.zip using parsing
curl -s https://api.github.com/repos/chr233/ASFEnhance/releases/latest \
  | grep browser_download_url \
  | grep ASFEnhance.zip \
  | cut -d '"' -f 4 \
  | xargs wget
unzip ASFEnhance.zip -d plugins
# delete zip
rm ASFEnhance.zip
