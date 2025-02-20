

class UpScripter:
    def __init__(self, script):
        self.script = script

    def run(self):
        self.script.run()
        return self.script
