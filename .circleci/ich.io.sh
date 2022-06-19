#!/usr/bin/env bash

cd build/


#### INSTALL BUTLER
# -L follows redirects
# -O specifies output name
curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler.zip
# GNU unzip tends to not set the executable bit even though it's set in the .zip
chmod +x butler
# just a sanity check run (and also helpful in case you're sharing CI logs)
./butler -V
####

butler push release/windows.zip mattffly/unborn:win
butler push release/linux.zip mattffly/unborn:linux
butler push release/macos.zip mattffly/unborn:mac
butler push release/android.zip mattffly/unborn:android
butler push release/html5.zip mattffly/unborn:html

rm ../assets/Music/*.import
butler push ../assets/Music/ mattffly/unborn:soundtrack
