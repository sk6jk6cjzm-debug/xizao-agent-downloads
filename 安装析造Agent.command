#!/bin/bash
set -euo pipefail
URL='https://github.com/sk6jk6cjzm-debug/xizao-agent-downloads/releases/download/v1.4.0-compact-20261009/Xizao-macOS-arm64-1.4.0-compact-20261009.dmg'
EXPECTED='17e2289819be51d27029ba0a368b66ecedd1a6973ad84070b6c2bbd72123f22d'
CACHE_DIR="${XIZAO_INSTALL_CACHE:-$HOME/Library/Caches/XizaoInstaller}"
INSTALL_DIR="${XIZAO_INSTALL_DIR:-$HOME/Applications}"
DMG="$CACHE_DIR/Xizao_轻量启动版_20261009.dmg"
WORK_DIR=''
MOUNTED=0
cleanup(){
 if [ "$MOUNTED" -eq 1 ]; then /usr/bin/hdiutil detach "$WORK_DIR/mount" -quiet || true; fi
 if [ -n "$WORK_DIR" ]; then /bin/rm -rf "$WORK_DIR"; fi
}
trap cleanup EXIT
trap 'printf "\n安装未完成，请检查网络或退出客户端后重试。\n"; exit 1' ERR
if [ "$(/usr/bin/uname -s)" != 'Darwin' ] || [ "$(/usr/bin/uname -m)" != 'arm64' ]; then
 printf '此安装入口仅支持搭载 M 系列芯片的 Mac。\n'; exit 1
fi
printf '析造 Agent 安装\n首次下载约 148 MB；同一版本下载成功后可复用。\n'
/bin/mkdir -p "$CACHE_DIR" "$INSTALL_DIR"
valid_file(){ [ -f "$DMG" ] && [ "$(/usr/bin/shasum -a 256 "$DMG" | /usr/bin/awk '{print $1}')" = "$EXPECTED" ]; }
if ! valid_file; then
 printf '正在从 GitHub 下载客户端，请等待……\n'
 /usr/bin/curl --fail --location --retry 3 --connect-timeout 20 --progress-bar --output "$DMG.part" "$URL"
 ACTUAL="$(/usr/bin/shasum -a 256 "$DMG.part" | /usr/bin/awk '{print $1}')"
 if [ "$ACTUAL" != "$EXPECTED" ]; then printf '文件校验不一致，请重试。\n'; /bin/rm -f "$DMG.part"; exit 1; fi
 /bin/mv "$DMG.part" "$DMG"
fi
printf '下载文件校验通过。\n'
/usr/bin/hdiutil verify "$DMG" -quiet
if [ "${XIZAO_VERIFY_ONLY:-0}" = '1' ]; then printf '下载和磁盘镜像核验完成。\n'; exit 0; fi
WORK_DIR="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/xizao-install.XXXXXX")"
/bin/mkdir "$WORK_DIR/mount"
/usr/bin/hdiutil attach "$DMG" -readonly -nobrowse -mountpoint "$WORK_DIR/mount" -quiet
MOUNTED=1
SOURCE_APP="$WORK_DIR/mount/析造Agent.app"
/usr/bin/codesign --verify --deep --strict "$SOURCE_APP"
DEST_APP="$INSTALL_DIR/析造Agent.app"
if /bin/ps -axo command= | /usr/bin/grep -F "$DEST_APP/Contents/MacOS/" | /usr/bin/grep -v '/usr/bin/grep' >/dev/null; then
 printf '已有客户端正在运行，请先按 Command + Q 退出，再重新双击安装入口。\n'; exit 1
fi
STAGED_APP="$INSTALL_DIR/.xizao-install-$$.app"
/usr/bin/ditto "$SOURCE_APP" "$STAGED_APP"
/usr/bin/codesign --verify --deep --strict "$STAGED_APP"
if [ -e "$DEST_APP" ]; then /bin/mv "$DEST_APP" "$INSTALL_DIR/析造Agent_旧版_$(/bin/date +%Y%m%d_%H%M%S).app"; fi
/bin/mv "$STAGED_APP" "$DEST_APP"
printf '安装完成。首次使用请在“设置 → 模型配置”中填入自己的 DeepSeek 密钥。\n'
if [ "${XIZAO_INSTALL_NO_LAUNCH:-0}" != '1' ]; then /usr/bin/open "$DEST_APP"; fi
