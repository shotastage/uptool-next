#!/usr/bin/env bash

PYTHON_BUILD_CACHE="$HOME/.uptx_runtime_backup.tar.xz"


function operating_system {
    if [ "$(uname)" == 'Darwin' ]; then
        OS="macOS"
    elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
        OS="Linux"
    else
        OS="Other"
    fi

    echo "${OS}"
}

function before_preparation {
    if [ "${1}" == "Linux" ]; then
        if ! command -v git >/dev/null 2>&1; then
            sudo apt-get update -y
            sudo apt-get install git -y
        fi
    fi
}


function _download_and_extract {
    curl -fO https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz || { echo "Download failed"; exit 1; }
    echo "📦  Extracting archive package..."
    tar -xJf Python-3.12.2.tar.xz > /dev/null 2>&1
}

function _configure_build {
    echo "🛠️  Configuraing build..."
    ./configure --enable-optimizations --prefix=$HOME/.uptx/runtime/ &> configure.log &
    PID=$!
    while kill -0 $PID 2> /dev/null; do
        echo -n "#"
        sleep 1
    done
    echo
}

function _caching_build {
    tar -cJf $PYTHON_BUILD_CACHE -C $HOME/.uptx/runtime/ .
}

function _build_python {
    echo "🏗️  Building Python runtime for Uptool..."
    make &> make.log &
    PID=$!
    while kill -0 $PID 2> /dev/null; do
        echo -n "#"
        sleep 2
    done
    echo
}

function build_install_python {
    if [ -f "$PYTHON_BUILD_CACHE" ]; then
        mkdir -p $HOME/.uptx/runtime
        tar -xJf $PYTHON_BUILD_CACHE -C $HOME/.uptx/runtime
    else
        _download_and_extract
        cd ./Python-3.12.2/
        _configure_build
        _build_python
        echo "💾  Installing Python runtime for Uptool..."
        make install &> make_install.log &
        PID=$!
        while kill -0 $PID 2> /dev/null; do
            echo -n "#"
            sleep 1
        done
        echo
        _caching_build

        cd ..

    fi
    
    ln -s $HOME/.uptx/runtime/bin/python3 $HOME/.uptx/runtime/bin/python
}

##### Check ######################################################################
if [ -e "${HOME}/.uptx/bin/" ]; then
    echo "👻 UpScripts already installed!"
    exit 1
fi

if [ -e "${HOME}/.uptx_installation" ]; then
    echo "👻  Installation directory already exists!"
    echo "👻  Clean existing directory before starting installation."
    rm -rf "${HOME}/.uptx_installation/"
fi

##### Main #######################################################################
cd "${HOME}" || exit

# Preparation
before_preparation "$(operating_system)"

# Workspace preparation
mkdir .uptx_installation
cd .uptx_installation || exit
git clone https://github.com/shotastage/uptool-next.git

# Download & Build Python Runtime
build_install_python


# Main Install Process
cd uptool-next || exit
mv bin/uptool $HOME/.uptx/bin/uptool


# Shell Configuration
echo "Nothing to do now!"


# Cleaning
echo "🧹  Cleaning..."
cd || exit
rm -rf .uptx_installation/

# Completed!
echo "🆗  Installation is completed!"
