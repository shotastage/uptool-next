import runtime_update from updater
import unittest


class TestMyModule(unittest.TestCase):

    def test_add(self):
        self.assertEqual(my_module.add(1, 2), 3)

if __name__ == '__main__':
    unittest.main()
