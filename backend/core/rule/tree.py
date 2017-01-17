import yaml
from core.rule.functions import and_func, make_func
import os
import logging

os.makedirs(os.getcwd() + '/log', exist_ok=True)
logging.basicConfig(filename=os.getcwd() + '/log/tree.log', level=logging.INFO)


class TreeLoader(object):
    def __init__(self, rule_name, sugang_list):
        f = open(rule_name, 'r', encoding='utf-8')
        self.tree = yaml.load(f)
        f.close()
        self.sugang_list = sugang_list
        self.base_node = TreeNode(None, and_func())
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node):  # current_tree는 리스트!
        for course in current_tree:
            if isinstance(course, str):
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
        self.is_course = isinstance(data, str)
        if self.is_course:
            self.children = args[0]
        else:
            self.children = list(args)

    def __str__(self):
        return str(self.data)

    def __repr__(self):
        return str(self.data)

    def add_children(self, obj):
        self.children.append(obj)

    def eval_children(self):
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode):
                child.eval_children()
                self.children[i] = child.data

        if self.is_course is False:
            logging.debug('{children} passed through {func}'.format(
                children=str(self.children),
                func=self.func.__name__,
            ))
            self.data = self.func(*self.children)
        else:
            sugang_list = self.children
            is_exists = False
            for i, course in enumerate(sugang_list):
                code = course['code']
                if code == self.data:
                    logging.debug('{data} returns True'.format(data=self.data))
                    self.data = True
                    is_exists = True
                    break
            if not is_exists:
                logging.debug('{data} returns False'.format(data=self.data))
                self.data = False
