import yaml
from core.rule.functions import and_func, make_func, if_func
import os
import logging

os.makedirs(os.getcwd() + '/log', exist_ok=True)
logging.basicConfig(filename=os.getcwd() + '/log/tree.log', level=logging.INFO)


class TreeLoader(object):
    def __init__(self, rule_name, sugang_list, metadata):
        f = open(os.getcwd() + '/rules/' + rule_name + '.yml', 'r', encoding='utf-8')
        self.tree = yaml.load(f)
        f.close()
        self.sugang_list = sugang_list
        self.metadata = metadata
        self.base_node = TreeNode(None, and_func(), '!GRADUATE', self.metadata)
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node):
        for course in current_tree:
            if isinstance(course, str):
                previous_node.add_children(TreeNode(course, None, self.metadata, None, self.sugang_list))
            elif type(course) is dict:
                args = course.get('args', [])
                current_func = course['func']
                if current_func == 'if':
                    if not if_func(*args, **self.metadata):
                        continue
                    self.load_tree(course['then'], previous_node)
                else:
                    current_node = TreeNode(None,
                                            make_func(current_func)(*args),
                                            course['name'],
                                            self.metadata)
                    self.load_tree(course['courses'], current_node)
                    previous_node.add_children(current_node)

    def eval_tree(self):
        self.base_node.eval_children()
        return self.base_node.data

    def tree_into_str(self):
        return self.base_node.tree_into_str(0)

    def tree_into_dict(self):
        return self.base_node.tree_into_dict()


class TreeNode(object):
    def __init__(self, data, func, namespace, metadata, *args):
        self.data = data
        self.func = func
        self.namespace = namespace
        self.metadata = metadata
        self.is_course = isinstance(data, str)
        if self.is_course:
            self.children = args[0]
            self.namespace = self.data  # 임시방편
        else:
            self.children = list(args)

    def __str__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def __repr__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def tree_into_str(self, depth=0):
        current_str = '    ' * depth + '{0} <{1}>'.format(self.namespace, self.data) + '\n'
        if self.is_course:
            return current_str
        for child in self.children:
            current_str += child.tree_into_str(depth + 1)
        return current_str

    def tree_into_dict(self):
        current_list = {'name': self.namespace, 'data': self.data, 'is_course': self.is_course}
        if self.is_course:
            return current_list
        current_list['child'] = []
        for child in self.children:
            current_list['child'].append(child.tree_into_dict())
        return current_list

    def add_children(self, obj):
        self.children.append(obj)

    def eval_children(self):
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode):
                child.eval_children()

        if self.is_course is False:
            logging.debug('{children} passed through {func}'.format(
                children=str(self.children),
                func=self.func.__name__,
            ))
            self.data = self.func(*[child_node.data for child_node in self.children], **self.metadata)
        else:
            sugang_list = self.children
            is_satisfied = False
            for i, course in enumerate(sugang_list):
                code = course['code']
                if code == self.data:
                    logging.debug('{data} returns True'.format(data=self.data))
                    self.data = True
                    is_satisfied = True
                    break
            if not is_satisfied:
                logging.debug('{data} returns False'.format(data=self.data))
                self.data = False
