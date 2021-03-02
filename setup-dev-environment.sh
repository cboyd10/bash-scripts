#!/bin/bash

# Install curl
sudo apt-get install -y curl

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version

# Install Java
sdk install java

# Install Gradle
sdk install gradle

# Install Maven
sdk install maven

# Install node|npm
curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
npm --version

# Install SQL Developer
sudo unzip sqldeveloper-*-no-jre.zip -d /opt/
sudo chmod +x /opt/sqldeveloper/sqldeveloper.sh

# Set up SQL Developer Launcher
mkdir -p ~/.local/share/icons/hicolor/128x128/apps
cp sqldeveloper_icon.png ~/.local/share/icons/hicolor/128x128/apps/sqldeveloper_icon.png
cat > ~/.local/share/applications/sqldeveloper.desktop << EOT
[Desktop Entry]
Version=1.0
Name=SQL Developer
Comment=SQL Developer Launcher
Exec=/opt/sqldeveloper/sqldeveloper.sh
Icon=sqldeveloper_icon.png
Terminal=false
Type=Application
Categories=Application
EOT
chmod +x ~/.local/share/applications/sqldeveloper.desktop

# Install Slack
sudo snap install slack --classic

# Install Teams
sudo snap install teams --classic

# Install IntelliJ
sudo snap install intellij-idea-ultimate --classic --edge

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ~/Downloads/google-chrome-stable_current_amd64.deb
sudo apt install ~/Downloads/google-chrome-stable_current_amd64.deb

# Install Cisco AnyConnect
./anyconnect-install.sh
