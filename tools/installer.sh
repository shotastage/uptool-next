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
    curl -fO https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tar.xz || { echo "Download failed"; exit 1; }
    echo "📦  Extracting archive package..."
    tar -xJf Python-3.12.3.tar.xz > /dev/null 2>&1
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
        cd ./Python-3.12.3/
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
mkdir -p $HOME/.uptx/bin/
mkdir -p $HOME/.uptx/libexec/

mv bin/uptx $HOME/.uptx/bin/uptx
mv uptool.py $HOME/.uptx/libexec/


# Shell Configuration
export_line="export PATH=\"\$HOME/.uptx/bin:\$PATH\""
zshenv_path="$HOME/.zshenv"
zshrc_path="$HOME/.zshrc"

function check_and_append_path() {
  echo "🐚  Adding PATH to default shell configuration..."
  local file_path=$1
  if ! grep -q "\$HOME/.uptx/bin" "$file_path"; then
    echo "" >> "$file_path"
    echo "#### Uptool Path ####" >> "$file_path"
    echo "$export_line" >> "$file_path"
  fi
}

if [ -f "$zshenv_path" ]; then
  check_and_append_path "$zshenv_path"
else
  if [ -f "$zshrc_path" ]; then
    check_and_append_path "$zshrc_path"
  else
    echo "$export_line" > "$zshrc_path"
  fi
fi


# Cleaning
echo "🧹  Cleaning..."
cd || exit
rm -rf .uptx_installation/

# Completed!
echo "🆗  Installation is completed!"
