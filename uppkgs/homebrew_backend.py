import platform, os

def homebrew_install(pkg_name):
    os_name = platform.system().lower()
    if os_name not in ("darwin"):
        print("This script can only be run on macOS.")

    os.system("brew update")
    os.system("brew install "+ pkg_name)
