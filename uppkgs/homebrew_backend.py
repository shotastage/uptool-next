import platform
import subprocess
from uppkg import UptxPkg

def homebrew_install(pkg_name):
    if platform.system().lower() != "darwin":
        print("This script can only be run on macOS.")
        return

    if subprocess.run(["which", "brew"], capture_output=True).returncode != 0:
        print("Homebrew is not installed. Please install Homebrew first.")
        return

    result = subprocess.run(["brew", "list"], capture_output=True, text=True)
    if pkg_name in result.stdout.split():
        print(f"{pkg_name} is already installed.")
    else:
        print(f"Installing {pkg_name}...")
        subprocess.run(["brew", "update"])
        subprocess.run(["brew", "install", pkg_name])
        print(f"{pkg_name} has been installed.")


class HomebrewBackend(UptxPkg):
    
    def install(self):
        homebrew_install(self.name)
