import urllib.request

def runtime_update(version: str):
    url = f"https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz"
    file_name = f"Python-{version}.tar.xz"
    urllib.request.urlretrieve(url, file_name)
