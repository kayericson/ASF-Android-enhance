#hi
curl -s https://api.github.com/repos/JustArchiNET/ArchiSteamFarm/releases/latest \
| grep "browser_download_url.*linux-arm.zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs -n 1 curl -L -O
