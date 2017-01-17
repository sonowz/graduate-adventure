
def make_func(function_name):
    if function_name == 'and':
        return and_func
    elif function_name == 'or':
        return or_func
    elif function_name == 'part':
        return part_func


def and_func(*pos):
    def closure_and_func(*args):
        c = True
        for arg in args:
            c = c and arg
        return c
    return closure_and_func


def or_func(*pos):
    def closure_or_func(*args):
        c = False
        for arg in args:
            c = c or arg
        return c
    return closure_or_func


def part_func(*pos):
    def closure_part_func(*args):
        cnt = 0
        for arg in args:
            if arg is True:
                cnt += 1
        return pos[0] <= cnt
    return closure_part_func
