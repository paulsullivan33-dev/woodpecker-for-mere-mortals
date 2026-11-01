"""A tiny invented example program used only as a CI fixture."""


def add(a, b):
    return a + b


def greeting(name):
    return f"Hello, {name}!"


if __name__ == "__main__":
    print(greeting("world"))
    print("2 + 3 =", add(2, 3))
