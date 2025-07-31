#!/data/data/com.termux/files/usr/bin/bash

# Download latest ASFEnhance.zip URL
URL=$(curl -s https://api.github.com/repos/chr233/ASFEnhance/releases/latest \
  | grep browser_download_url \
  | grep ASFEnhance.zip \
  | cut -d '"' -f 4)

# Exit if URL not found
if [ -z "$URL" ]; then
  echo "❌ Could not find ASFEnhance.zip URL"
  exit 1
fi

# Download the file
echo "⬇️ Downloading ASFEnhance.zip..."
wget -q --show-progress "$URL" -O ASFEnhance.zip

# Create plugin directory
echo "📁 Creating ./ASF/plugins directory..."
mkdir -p ./ASF/plugins

# Unzip to the right folder
echo "📦 Unzipping into ./ASF/plugins..."
unzip -o ASFEnhance.zip -d ./ASF/plugins

# Optional cleanup
echo "🧹 Cleaning up..."
rm ASFEnhance.zip

echo "✅ Done! ASFEnhance is installed in ./ASF/plugins"
