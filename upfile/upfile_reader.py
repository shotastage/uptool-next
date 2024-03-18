import importlib.util
import sys


class UpfileInterpreter:

    def __init__(self, file):
        self.file = file

    def load(self, module_name, filepath):
        spec = importlib.util.spec_from_file_location(module_name, filepath)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        return module

    def exec(self):
        module = self.load("dynamic_module", "path/to/your/module.py")
        module.build()

