#!/usr/bin/env bash

set -euo pipefail

PYTHON_BUILD_CACHE="$HOME/.uptx_runtime_backup.tar.xz"

function operating_system {
    case "$(uname -s)" in
        Darwin)
            echo "macOS"
            ;;
        Linux)
            echo "Linux"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

function before_preparation {
    local os="$1"
    if [ "$os" == "Linux" ]; then
        if ! command -v git >/dev/null 2>&1; then
            if command -v apt-get >/dev/null 2>&1; then
                echo "Installing git using apt-get..."
                sudo apt-get update -y
                sudo apt-get install git -y
            elif command -v yum >/dev/null 2>&1; then
                echo "Installing git using yum..."
                sudo yum install git -y
            else
                echo "Package manager not supported. Please install git manually."
                exit 1
            fi
        fi
    elif [ "$os" == "macOS" ]; then
        if ! command -v git >/dev/null 2>&1; then
            echo "Please install git using Xcode Command Line Tools."
            exit 1
        fi
    fi
}

function _download_and_extract {
    local tarball="Python-3.12.6.tar.xz"
    if [ ! -f "$tarball" ]; then
        echo "📥 Downloading Python source code..."
        curl -fLO "https://www.python.org/ftp/python/3.12.6/$tarball"
    else
        echo "📦 Tarball already exists. Skipping download."
    fi
    echo "📦 Extracting archive package..."
    tar -xJf "$tarball" > /dev/null 2>&1
}

function _configure_build {
    echo "🛠️  Configuring build..."
    ./configure --enable-optimizations --prefix="$HOME/.uptx/runtime/" &> configure.log
}

function _build_python {
    echo "🏗️  Building Python runtime for Uptool..."
    make -j "$(nproc)" &> make.log
}

function _caching_build {
    echo "💾  Caching Python build..."
    tar -cJf "$PYTHON_BUILD_CACHE" -C "$HOME/.uptx/runtime/" .
}

function build_install_python {
    if [ -f "$PYTHON_BUILD_CACHE" ]; then
        echo "📦  Using cached Python build..."
        mkdir -p "$HOME/.uptx/runtime"
        tar -xJf "$PYTHON_BUILD_CACHE" -C "$HOME/.uptx/runtime"
    else
        _download_and_extract
        cd "Python-3.12.6"
        _configure_build
        _build_python
        echo "💾  Installing Python runtime for Uptool..."
        make install &> make_install.log
        _caching_build
        cd ..
    fi

    ln -sf "$HOME/.uptx/runtime/bin/python3" "$HOME/.uptx/runtime/bin/python"
}

function add_path_to_shell_config {
    local shell_name
    shell_name="$(basename "$SHELL")"
    local config_file

    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            config_file="$HOME/.profile"
            ;;
    esac

    local export_line='export PATH="$HOME/.uptx/bin:$PATH"'

    if [ -f "$config_file" ]; then
        if ! grep -q '\$HOME/.uptx/bin' "$config_file"; then
            echo "" >> "$config_file"
            echo "#### Uptool Path ####" >> "$config_file"
            echo "$export_line" >> "$config_file"
            echo "🐚  PATH added to $config_file"
        else
            echo "🐚  PATH already exists in $config_file"
        fi
    else
        echo "🐚  Creating $config_file and adding PATH..."
        echo "#### Uptool Path ####" >> "$config_file"
        echo "$export_line" >> "$config_file"
    fi
}

##### Check ######################################################################
if [ -e "${HOME}/.uptx/bin/" ]; then
    echo "👻 UpScripts already installed!"
    exit 1
fi

if [ -e "${HOME}/.uptx_installation" ]; then
    echo "👻  Installation directory already exists!"
    echo "👻  Removing existing installation directory..."
    rm -rf "${HOME}/.uptx_installation/"
fi

##### Main #######################################################################
cd "${HOME}" || exit

# Preparation
os="$(operating_system)"
before_preparation "$os"

# Workspace preparation
mkdir -p ".uptx_installation"
cd ".uptx_installation" || exit
git clone https://github.com/shotastage/uptool-next.git

# Download & Build Python Runtime
build_install_python

# Main Install Process
cd uptool-next || exit
mkdir -p "$HOME/.uptx/bin/"
mkdir -p "$HOME/.uptx/libexec/"

mv bin/uptx "$HOME/.uptx/bin/uptx"
mv uptool.py "$HOME/.uptx/libexec/"

# Shell Configuration
add_path_to_shell_config

# Cleaning
echo "🧹  Cleaning..."
cd || exit
rm -rf ".uptx_installation/"

# Completed!
echo "🆗  Installation is completed!"
