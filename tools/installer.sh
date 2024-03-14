#!/usr/bin/env bash


function operating_system {
    if [ "$(uname)" == 'Darwin' ]; then
        OS="macOS"
    elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
        OS="Linux"
    else
        OS="Other"
    fi

    echo $OS
}

function before_preparation {
    if [ ${1} = "Linux" ]; then
        if type git > /dev/null 2>&1; then
            :
        else
            sudo apt-get update -y
            sudo apt-get install git -y
        fi
    fi
}


##### Check ######################################################################
if [ -e $HOME/.uptx/bin/ ]; then
    echo "👻 UpScripts already installed!"
    exit 1
fi


if [ -e $HOME/.uptx_installation ]; then
    echo "👻  Installation directory already exists!"
    echo "👻  Clean existing directory before starting installation."
    rm -rf $HOME/.uptx_installation/
fi



##### Main #######################################################################
cd $HOME
cd $HOME

# Prepatation
before_preparation $(operating_system)


# Workspace preparation
mkdir .uptx_installation
cd .uptx_installation
git clone https://github.com/shotastage/uptool-next.git



# Main Install Process
cd uptool-next
echo Nothing to do now!

# Shell Configuration
echo Nothing to do now!


# Cleaning
echo "🧹  Cleaning..."
cd
rm -rf .uptx_installation/

# Completed!
echo "🆗  Installation is completed!"
