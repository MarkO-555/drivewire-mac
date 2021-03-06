#!/bin/bash -v
# After Integration Run Script
# Called by the Xcode Bot
if [ -z "$XCS_ARCHIVE" ]; then
    echo "XCS_ARCHIVE is not set -- aborting"
    exit 1
fi  
marketingVersion="1.0.${XCS_INTEGRATION_NUMBER}"
pushd "${XCS_ARCHIVE}/Products/Applications"
zip -yr /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}.zip "DriveWire.app"
scp /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}.zip administrator@downloads.tandycolorcomputer.com:/Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com
popd
#zip -yr /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}_dSYMs.zip dSYMs
#scp /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}_dSYMs.zip administrator@downloads.tandycolorcomputer.com:/Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com

# Setup variables to be used in sed
scp administrator@tandycolorcomputer.com:DriveWire_dsa_priv.pem /tmp
signature=`scripts/sign_update.rb /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}.zip /tmp/DriveWire_dsa_priv.pem | tr -d '\n'`
releaseDate=`date '+%a, %d %b %Y %T %z'`
length=`stat -f "%z" /tmp/DriveWire_${XCS_INTEGRATION_NUMBER}.zip`

sed -e "s?__BUNDLEVERSION__?${XCS_INTEGRATION_NUMBER}?" DriveWireAppcast.xml | sed -e "s!__SIGNATURE__!$signature!" | sed -e "s?__LENGTH__?$length?" | sed -e "s?__VERSION__?$marketingVersion?" | sed -e "s?__RELEASEDATE__?$releaseDate?" > /tmp/DriveWireAppcast.xml

# copy changelog
git config --global user.email "boisy.pitre@tee-boy.com"
git config --global user.name "Boisy Pitre"
git log --pretty=format:"<li>%s</li>" `git describe --tags --abbrev=0`..HEAD > /tmp/DriveWire_ChangeLog.html
scp /tmp/DriveWire_ChangeLog.html administrator@downloads.tandycolorcomputer.com:/Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com

# tag this latest build
git tag -a "$marketingVersion-${XCS_INTEGRATION_NUMBER}" -m "$marketingVersion-${XCS_INTEGRATION_NUMBER}"
git push --follow-tags

# copy appcast
scp /tmp/DriveWireAppcast.xml administrator@downloads.tandycolorcomputer.com:/Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com

# soft link
ssh -l administrator downloads.tandycolorcomputer.com "cd /Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com; rm DriveWire.zip; ln -s DriveWire_${XCS_INTEGRATION_NUMBER}.zip DriveWire.zip"

#ssh -l administrator downloads.tandycolorcomputer.com "cd /Library/Server/Web/Data/Sites/downloads.tandycolorcomputer.com; rm DriveWire_dSYMs.zip; ln -s DriveWire_${XCS_INTEGRATION_NUMBER}_dSYMs.zip DriveWire_dSYMs.zip"
