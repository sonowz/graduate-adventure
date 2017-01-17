import yaml
from core.rule.functions import *


class TreeLoader(object):
    def __init__(self, rule_name, sugang_list):
        f = open(rule_name, 'r', encoding='utf-8')
        self.tree = yaml.load(f)
        f.close()
        self.sugang_list = sugang_list
        self.base_node = TreeNode(None, and_func())
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node): # current_tree는 리스트!
        for course in current_tree:
            if type(course) is str:
                previous_node.add_children(TreeNode(course, None, self.sugang_list))
            elif type(course) is dict:
                args = course.get('args', [])
                current_node = TreeNode(None, make_func(course['func'])(*args))
                self.load_tree(course['courses'], current_node)
                previous_node.add_children(current_node)

    def eval_tree(self):
        self.base_node.eval_children()
        return self.base_node.data


class TreeNode(object):
    def __init__(self, data, func, *args):
        self.data = data
        self.func = func
        self.is_course = False
        if type(data) is str:
            self.is_course = True
        if self.is_course is False:
            self.children = list(args)
        else:
            self.children = args[0]

    def __str__(self):
        return str(self.data)

    def __repr__(self):
        return str(self.data)

    def add_children(self, obj):
        self.children.append(obj)

    def eval_children(self):
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode) is True:
                child.eval_children()
                self.children[i] = child.data

        if self.is_course is False:
            print(self.func.__name__, '을 통해 ', str(self.children))
            self.data = self.func(*self.children)
        else:
            sugang_list = self.children
            is_exists = False
            for i, course in enumerate(sugang_list):
                code = course['code']
                if code == self.data:
                    print(str(self.data) + ' 수강함. True')
                    self.data = True
                    # del sugang_list[i]
                    is_exists = True
                    break
            if is_exists is False:
                print(str(self.data) + ' 수강하지 않음. False')
                self.data = False
