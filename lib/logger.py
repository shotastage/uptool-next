import logging

def setup_logger(name='terminal_logger', level=logging.DEBUG):
    # Create a custom logger
    logger = logging.getLogger(name)

    # Set the default log level
    logger.setLevel(level)

    # Create handlers
    console_handler = logging.StreamHandler()

    # Set the log level for the handler
    console_handler.setLevel(level)

    # Create formatters and add it to handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)

    # Add handlers to the logger
    logger.addHandler(console_handler)
    
    return logger
