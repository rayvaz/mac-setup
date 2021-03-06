#!/bin/bash

# Logo
LOGO=" __  __               _____      _
|  \/  |             / ____|    | |
| \  / | __ _  ___  | (___   ___| |_ _   _ _ __
| |\/| |/ _\` |/ __|  \___ \ / _ \ __| | | | '_ \\
| |  | | (_| | (__   ____) |  __/ |_| |_| | |_) |
|_|  |_|\__,_|\___| |_____/ \___|\__|\__,_| .__/
                                          | |
                                          |_|"
# Colors
BOLD=$(tput bold)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
DEFAULT=$(tput sgr0)
# New line character
NEW_LINE="\n"
# Horizonal line in cyan color
DIVIDER="${CYAN}${BOLD}------------------------------------------------$DEFAULT"
# Arrows
ARROW="$CYAN$BOLD==>$DEFAULT"
ARROW_GREEN="$GREEN$BOLD==>$DEFAULT"
ARROW_YELLOW="$YELLOW$BOLD==>$DEFAULT"
# Array of available applications that can be installed via Homebrew Cask
AVAILABLE_CASK_APPLICATIONS=(appcleaner background-music cyberduck drawio firefox flux fork google-chrome gpg-suite keepingyouawake keka mamp opera postman sequel-pro skype slack spectacle transmission tunnelblick visual-studio-code vlc)
# Array of available npm packages
AVAILABLE_NPM_PACKAGES=(gulp-cli jest live-server create-react-app)
# Array of available VS Code extensions
AVAILABLE_VSCODE_EXTENSIONS=(CoenraadS.bracket-pair-colorizer PKief.material-icon-theme alefragnani.project-manager christian-kohler.path-intellisense dbaeumer.vscode-eslint formulahendry.auto-rename-tag mrmlnc.vscode-scss msjsdiag.debugger-for-chrome techer.open-in-browser aaron-bond.better-comments kamikillerto.vscode-colorize christian-kohler.npm-intellisense)
# Arrays of applications/packages/extensions selected by user (empty by default)
SELECTED_CASK_APPLICATIONS=()
SELECTED_NPM_PACKAGES=()
SELECTED_VSCODE_EXTENTIONS=()
# Booleans to track if specific programs are already installed
IS_HOMEBREW_INSTALLED=false
IS_MAS_INSTALLED=false
IS_NVM_INSTALLED=false
IS_NODE_INSTALLED=false
IS_VSCODE_INSTALLED=false

clear

# Print logo and description
echo -e "${CYAN}${BOLD}${LOGO}${DEFAULT}${NEW_LINE}"
echo -e "${CYAN}${BOLD}   Front End Web Development Setup for macOS$NEW_LINE"
echo -e "$DIVIDER"
echo "      <https://github.com/appalaszynski>"
echo "  <https://github.com/appalaszynski/mac-setup>"
echo -e "${DIVIDER}${NEW_LINE}"

echo "Welcome to the installer!"
echo -e "First, introduce your password to execute all the commands as super user.$NEW_LINE"

echo -e "${RED}${BOLD}Important:$DEFAULT You can be asked more times for password during the process."
echo -e "Also, make sure that You are logged in to the Mac App Store.$NEW_LINE"

# Prompt user for password
sudo -v

clear

#----------------------------
# Homebrew
#----------------------------

if hash brew 2>/dev/null; then
  IS_HOMEBREW_INSTALLED=true
fi

if $IS_HOMEBREW_INSTALLED; then
  echo "${ARROW_GREEN} Homebrew already installed!"
  echo "${ARROW} Updating Homebrew formulas..."

  brew update
  brew upgrade
else
  read -ep "${ARROW_YELLOW} Install Homebrew? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    IS_HOMEBREW_INSTALLED=true
  fi
fi

#----------------------------
# Git
#----------------------------

if $IS_HOMEBREW_INSTALLED; then
  read -p "${ARROW_YELLOW} Install latest Git version via Homebrew? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Installing Git..."
    brew install git
  fi
fi

#----------------------------
# .gitconfig
#----------------------------

read -p "${ARROW_YELLOW} Configure Git by creating ~/.gitconfig file? [y/n]: "

if [ "$REPLY" == "y" ]; then
  read -p "${ARROW_YELLOW} Please enter Git username: " username
  read -p "${ARROW_YELLOW} Please enter Git e-mail: " email
  read -p "${ARROW_YELLOW} Please enter Git editor: " editor
  echo "${ARROW} Creating ~/.gitconfig file..."
  
  cp .gitconfig ~
  sed -i -e "s/First Last/$username/g" ~/.gitconfig
  sed -i -e "s/email@email.com/$email/g" ~/.gitconfig
  sed -i -e "s/= editor/= $editor/g" ~/.gitconfig
fi

#----------------------------
# .bash_profile
#----------------------------

read -p "${ARROW_YELLOW} Configure bash by creating ~/.bash_profile file? [y/n]: "

if [ "$REPLY" == "y" ]; then
  echo "${ARROW} Creating ~/.bash_profile file..."
  cp .bash_profile ~ 
fi

#----------------------------
# Application bundle
#----------------------------

if $IS_HOMEBREW_INSTALLED; then
  read -p "${ARROW_YELLOW} Install applications via Homebrew Cask? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    for item in "${AVAILABLE_CASK_APPLICATIONS[@]}"; do
      read -ep "${ARROW_YELLOW} Install \"$item\"? [y/n]: "
      if [ "$REPLY" == "y" ]; then
      SELECTED_CASK_APPLICATIONS+=("$item")
      fi
    done  

    if [ ${#SELECTED_CASK_APPLICATIONS[@]} -gt 0 ]; then
      echo "${ARROW} Installing applications via Homebrew Cask..."
      for application in "${SELECTED_CASK_APPLICATIONS[@]}"; do
        brew cask install ${application}
      done
    fi
    
  fi

fi

#----------------------------
# Terminal profile
#----------------------------

read -p "${ARROW_YELLOW} Download Flat Terminal profile? [y/n]: "

if [ "$REPLY" == "y" ]; then
  echo "${ARROW_YELLOW} New Terminal window opened. Click 'Shell' > 'Use settings as default' to use it as default profile."
  open ./Flat.terminal
fi

#----------------------------
# Node Version Manager
#----------------------------

if ! [ -x "$(command -v nvm)" ]; then
  IS_NVM_INSTALLED=true
fi

if $IS_NVM_INSTALLED; then
  echo "${ARROW_GREEN} Node Version Manager already installed!"
else
  read -p "${ARROW_YELLOW} Install nvm (Node Version Manager)? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Installing Node Version Manager..."
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    source ~/.bash_profile

    IS_NVM_INSTALLED=true
  fi
fi

#----------------------------
# Node.js
#----------------------------

if hash node 2>/dev/null; then
  IS_NODE_INSTALLED=true
fi

if $IS_NODE_INSTALLED; then
  echo "${ARROW_GREEN} Node.js already installed!"
else
  if [ $IS_NVM_INSTALLED == true ]; then
    read -p "${ARROW_YELLOW} Install latest LTS version of Node.js? [y/n]: "

    if [ "$REPLY" == "y" ]; then
      echo "${ARROW} Installing Node.js..."
      nvm install --lts

      IS_NODE_INSTALLED=true
    fi
  fi
fi

#----------------------------
# npm packages
#----------------------------

if $IS_NODE_INSTALLED; then
  read -p "${ARROW_YELLOW} Install global npm packages? [y/n]: "

  if [ "$REPLY" == "y" ]; then

    for item in "${AVAILABLE_NPM_PACKAGES[@]}"; do
      read -ep "${ARROW_YELLOW} Install \"$item\"? [y/n]: "
      if [ "$REPLY" == "y" ]; then
      SELECTED_NPM_PACKAGES+=("$item")
      fi
    done  

    if [ ${#SELECTED_NPM_PACKAGES[@]} -gt 0 ]; then
      echo "${ARROW} Installing global npm packages.."
      for application in "${SELECTED_NPM_PACKAGES[@]}"; do
        npm install -g ${application}
      done
    fi

  fi

fi

#----------------------------
# VS Code extensions
#----------------------------

if hash code 2>/dev/null; then
  IS_VSCODE_INSTALLED=true
fi

if $IS_VSCODE_INSTALLED; then
  read -p "${ARROW_YELLOW} Install Visual Studio Code extensions? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    for item in "${AVAILABLE_VSCODE_EXTENSIONS[@]}"; do
      read -ep "${ARROW_YELLOW} Install \"$item\"? [y/n]: "
      if [ "$REPLY" == "y" ]; then
      SELECTED_VSCODE_EXTENSIONS+=("$item")
      fi
    done  

    if [ ${#SELECTED_VSCODE_EXTENSIONS[@]} -gt 0 ]; then
      echo "${ARROW} Installing Visual Studio Code extensions..."
      for application in "${SELECTED_NPM_PACKAGES[@]}"; do
        code --install-extension ${application}
      done
    fi

  fi

fi

#----------------------------
# VS Code settings
#----------------------------

if $IS_VSCODE_INSTALLED; then
  read -p "${ARROW_YELLOW} Configure Visual Studio Code settings? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Configuring Visual Studio Code settings..."
    cp settings.json /Users/${USER}/Library/Application\ Support/Code/User
  fi
fi

#----------------------------
# VS Code snippets
#----------------------------

if $IS_VSCODE_INSTALLED; then
  read -p "${ARROW_YELLOW} Configure Visual Studio Code snippets? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Configuring Visual Studio Code snippets..."
    cp snippets.code-snippets /Users/${USER}/Library/Application\ Support/Code/User/snippets
  fi
fi

#----------------------------
# Spectacle shortcuts
#----------------------------

if [ -d /Applications/Spectacle.app/ ]; then
  IS_SPECTACLE_INSTALLED=true
fi

if $IS_SPECTACLE_INSTALLED; then
  read -p "${ARROW_YELLOW} Configure Spectacle shotrcuts? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    echo "${ARROW} Configuring Spectacle shotrcuts..."
    cp -r spectacle.json ~/Library/Application\ Support/Spectacle/Shortcuts.json 2> /dev/null
  fi
fi

#----------------------------
# Firmware password
#----------------------------

if [[ $(sudo firmwarepasswd -check) =~ "Password Enabled: Yes" ]]; then
  echo "${ARROW_GREEN} Firmware password is already set up!"
else 
  read -p "${ARROW_YELLOW} Set up firmware password? [y/n]: "

  if [ "$REPLY" == "y" ]; then
    sudo firmwarepasswd -setpasswd -setmode command
  fi
fi

#----------------------------
# Computer name
#----------------------------

read -p "${ARROW_YELLOW} Set computer name? [y/n]: "

if [ "$REPLY" == "y" ]; then
  read -p "${ARROW_YELLOW} Please enter computer name: " uservar

  sudo scutil --set ComputerName $uservar
  sudo scutil --set HostName $uservar
  sudo scutil --set LocalHostName $uservar
fi

#----------------------------
# macOS Defaults
#----------------------------

read -p "${ARROW_YELLOW} Configure macOS Defaults? [y/n]: "

if [ "$REPLY" == "y" ]; then
  echo "${ARROW} Configuring macOS Defaults..."
  . ./api/defaults.sh
fi

echo -e "${NEW_LINE}${YELLOW}${BOLD}Note:$DEFAULT Some changes may need system restart to be applied!"
echo -e "${NEW_LINE}${GREEN}${BOLD}Congratulations, installation complete!${DEFUALT}${NEW_LINE}"

exit 1
