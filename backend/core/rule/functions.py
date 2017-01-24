
def make_func(function_name, **kwargs):
    if function_name == 'and':
        return and_func
    elif function_name == 'or':
        return or_func
    elif function_name == 'part':
        return part_func
    else:
        return void_func


def void_func(*pos):
    def closure_void_func(*args, **kwargs):
        return True
    return closure_void_func


def and_func(*pos):
    def closure_and_func(*args, **kwargs):
        return all(args)
    return closure_and_func


def or_func(*pos):
    def closure_or_func(*args, **kwargs):
        return any(args)
    return closure_or_func


def part_func(*pos):
    def closure_part_func(*args, **kwargs):
        return pos[0] <= args.count(True)
    return closure_part_func


def if_func(*pos, **metadata):
    try:
        meta = metadata[pos[0]]
        arg = pos[1]
    except KeyError:
        return False
    return meta == arg


def if_not_func(*pos, **metadata):
    try:
        meta = metadata[pos[0]]
        arg = pos[1]
    except KeyError:
        return False
    return meta != arg


def if_greater_func(*pos, **metadata):
    try:
        meta = metadata[pos[0]]
        arg = pos[1]
    except KeyError:
        return False
    return meta <= arg


def if_less_func(*pos, **metadata):
    try:
        meta = metadata[pos[0]]
        arg = pos[1]
    except KeyError:
        return False
    return meta >= arg
