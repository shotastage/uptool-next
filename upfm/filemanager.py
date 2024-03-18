import os

# Basic file manager commands
def cd(to: str):
    os.chdir(to)

def mkdir(name: str):
    os.mkdir(name)

def rmdir(name: str):
    os.rmdir(name)


class UptSafeFileSystem():
    def __init__(self) -> None:
        pass
