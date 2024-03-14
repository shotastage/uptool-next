import argparse

def main():
    parser = argparse.ArgumentParser(description='Add two numbers.')

    parser.add_argument('--number1', type=int, help='The first number', required=True)
    parser.add_argument('--number2', type=int, help='The second number', required=True)

    args = parser.parse_args()

    result = args.number1 + args.number2

    print(f"The sum of {args.number1} and {args.number2} is {result}.")

if __name__ == "__main__":
    main()
