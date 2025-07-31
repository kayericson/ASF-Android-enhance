#!/data/data/com.termux/files/usr/bin/bash

# Fetch the latest release JSON and extract ASFEnhance.zip URL
URL=$(curl -s https://api.github.com/repos/chr233/ASFEnhance/releases/latest \
  | grep browser_download_url \
  | grep ASFEnhance.zip \
  | cut -d '"' -f 4)

# Exit if URL is empty
if [ -z "$URL" ]; then
  echo "❌ Could not find ASFEnhance.zip URL"
  exit 1
fi

# Download using curl
echo "⬇️ Downloading ASFEnhance.zip..."
curl -L "$URL" -o ASFEnhance.zip

# Create plugin directory if needed
echo "📁 Creating ./ASF/plugins directory..."
mkdir -p ./ASF/plugins

# Unzip using built-in unzip
echo "📦 Unzipping into ./ASF/plugins..."
unzip -o ASFEnhance.zip -d ./ASF/plugins

# Optional cleanup
echo "🧹 Cleaning up..."
rm ASFEnhance.zip

echo "✅ Done! ASFEnhance is installed in ./ASF/plugins"
