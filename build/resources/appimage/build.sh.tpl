#!/usr/bin/env bash
set -e


name="<%= name %>"
version="<%= version %>"
arch="<%= arch %>"
source="<%= dirinput %>"
dest="<%= diroutput %>/<%= filename %>"
apprun="<%= appimagekit %>/<%= apprun %>"
appimagetool="<%= appimagekit %>/<%= appimagetool %>"

# ----

tempdir=$(mktemp -d) && trap "rm -rf ${tempdir}" EXIT || exit 255
cd "${tempdir}"

appdir="${tempdir}/${name}.AppDir"
installdir="${appdir}/opt/${name}/"

# ----

# create AppImage AppDir
mkdir "${appdir}"

# copy root AppRun
install -m777 "${apprun}" "${appdir}/AppRun"

# copy app contents
mkdir -p "${installdir}"
cp -a "${source}/." "${installdir}/"

# create custom start script and unset PYTHONHOME env var
mkdir -p "${appdir}/usr/bin/"
cat > "${appdir}/usr/bin/${name}" <<EOF
#!/usr/bin/env bash
SELF=\$(readlink -f "\$0")
HERE=\${SELF%/*}

unset PYTHONHOME
"\${HERE}"/../../opt/${name}/${name} "\$@"
EOF
chmod +x "${appdir}/usr/bin/${name}"

# copy licenses
install -Dm644 \
  -t "${appdir}/usr/share/licenses/${name}/" \
  "${installdir}/LICENSE.txt" \
  "${installdir}/credits.html"

# copy icons
for res in 16 32 48 64 128 256; do
  install -Dm644 \
    "${installdir}/icons/icon-${res}.png" \
    "${appdir}/usr/share/icons/hicolor/${res}x${res}/apps/${name}.png"
done

# symlink root AppImage icons
for link in "${appdir}/.DirIcon" "${appdir}/${name}.png"; do
  ln -sr "${appdir}/usr/share/icons/hicolor/256x256/apps/${name}.png" "${link}"
done

# create desktop file
mkdir -p "${appdir}/usr/share/applications/"
cat > "${appdir}/usr/share/applications/${name}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Streamlink Twitch GUI
GenericName=Twitch.tv browser for Streamlink
Comment=Browse Twitch.tv and watch streams in your videoplayer of choice
Keywords=streamlink;twitch;
Categories=AudioVideo;Network;
Exec=${name}
Icon=${name}
EOF

# symlink root AppImage desktop file
ln -sr "${appdir}/usr/share/applications/${name}.desktop" "${appdir}/${name}.desktop"

# remove unneeded stuff
rm -r "${installdir}/"{{add,remove}-menuitem.sh,LICENSE.txt,credits.html,icons/}

# ----

# build AppImage
(
  set -x
  ARCH="${arch}" VERSION="${version}" "${appimagetool}" \
    --verbose \
    --comp gzip \
    --no-appstream \
    "${appdir}" \
    "${dest}"
)
chmod +x "${dest}"