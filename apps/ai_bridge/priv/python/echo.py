def ping(msg):
    # ErlPort sends Elixir binaries as Python bytes
    if isinstance(msg, (bytes, bytearray)):
        msg = msg.decode("utf-8")
    return f"PONG: {msg}"
