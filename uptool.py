import argparse

def main():
    parser = argparse.ArgumentParser(description='Uptool command line interface.')

    # actions: install,
    parser.add_argument('install', help='The action to perform (e.g., install, remove).')

    # options: --force
    parser.add_argument('--force', action='store_true', help='Force the action.')

    # targets:
    parser.add_argument('targets', nargs='+', help='The targets for the action.')

    args = parser.parse_args()

    print(f"Action: {args.action}")
    if args.force:
        print("Option: --force")
    print(f"Targets: {args.targets}")

if __name__ == "__main__":
    main()
