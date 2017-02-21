# -*- coding: utf-8 -*-
import yaml
import copy
from core.rule.functions import and_func, make_func, if_func_list
import os
import logging.config
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')

# http://stackoverflow.com/questions/528281/how-can-i-include-an-yaml-file-inside-another


class Loader(yaml.Loader):
    def __init__(self, stream):
        self._root = os.path.split(stream.name)[0]
        super(Loader, self).__init__(stream)

    def include(self, node):
        filename = os.path.join(self._root, self.construct_scalar(node))
        with open(filename, 'r') as f:
            return yaml.load(f, Loader)


Loader.add_constructor('!include', Loader.include)


class TreeLoaderException(Exception):
    pass


class TreeLoader(object):
    def __init__(self, rule_name, metadata, course_model):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        try:
            f = open(os.path.join(base_dir, 'rules', rule_name + '.yml'), 'r', encoding='utf-8')
            self.tree = yaml.load(f, Loader)
            f.close()
        except IOError:
            logger.error('Error opening file: ' + rule_name)
            raise TreeLoaderException()
        self.metadata = metadata
        self.course_model = course_model
        self.default_properties = {
            'course_model': self.course_model,
            'hide_false': False,
            'credit_info': [0, 0, False],
        }
        self.base_node = TreeNode(None, self.default_properties, self.metadata, and_func(), '!GRADUATE')
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node):
        for course in current_tree:
            if isinstance(course, str):
                if course.startswith('$'):
                    subarea = course[1:]
                    code_list = [item.code for item in self.course_model.objects.filter(subarea=subarea)]
                    code_set = set(code_list)
                    for code in code_set:
                        previous_node.add_children(TreeNode(code, self.default_properties, self.metadata))
                elif course.startswith('@'):
                    t = course.split('@')
                    dept, category, year = t[1], t[2], int(t[3])
                    code_list = [item.code for item in self.course_model.objects.filter(
                        dept=dept,
                        category=category,
                        year=year,
                    )]
                    code_set = set(code_list)
                    for code in code_set:
                        previous_node.add_children(TreeNode(code, self.default_properties, self.metadata))
                else:
                    previous_node.add_children(TreeNode(course, self.default_properties, self.metadata))
            elif type(course) is dict:
                args = course.get('args', [])
                hide_false = course.get('hide_false', False)
                required_credit = course.get('required_credit', 0)
                sum_false = course.get('sum_false', False)

                properties = {
                    'course_model': self.course_model,
                    'hide_false': hide_false,
                    'credit_info': [0, required_credit, sum_false],
                }

                current_func = course['func']
                if current_func in if_func_list:
                    current_if_func = if_func_list[current_func]
                    if current_if_func(*args, **self.metadata):
                        self.load_tree(course['then'], previous_node)
                else:
                    current_node = TreeNode(None,
                                            properties,
                                            self.metadata,
                                            make_func(current_func)(*args),
                                            course['name'],
                                            )
                    self.load_tree(course['courses'], current_node)
                    previous_node.add_children(current_node)

    def eval_tree(self, taken_list):
        self.base_node.eval_children(taken_list)
        return self.base_node.data

    def tree_into_str(self):
        return self.base_node.tree_into_str(0)

    def tree_into_dict(self):
        return self.base_node.tree_into_dict()

    # TODO: Find and return node by name
    def find(self, name):
        return None


class TreeNode(object):
    def __init__(self, data, properties, metadata, func=None, namespace=None, *args):
        self.data = data
        self.credit = properties['credit_info'][0]
        self.required_credit = properties['credit_info'][1]
        self.sum_false = properties['credit_info'][2]
        self.hide_false = properties['hide_false']
        self.metadata = metadata
        self.func = func
        self.namespace = namespace
        self.false_reason = ''
        self.is_course = isinstance(data, str)
        if self.is_course:
            self.children = []
            try:
                filtered_course = properties['course_model'].objects.filter(code=self.data)[0]
                self.namespace = filtered_course.title
                self.credit = filtered_course.credit
            except IndexError:
                self.namespace = '!NOT FOUND'
        else:
            self.children = list(args)

    def __str__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def __repr__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def tree_into_str(self, depth=0, hide=False):
        if hide and not self.data:
            return None
        current_str = '    ' * depth + '{0} <{1}>, {2} ({3})\n'.format(
            self.namespace,
            self.data,
            self.credit,
            self.false_reason)
        if self.is_course:
            return current_str
        for child in self.children:
            new_str = child.tree_into_str(depth + 1, self.hide_false)
            if new_str is not None:
                current_str += new_str
        return current_str

    def tree_into_dict(self, hide=False):
        if hide and not self.data:
            return None
        current_list = {
            'name': self.namespace,
            'data': self.data,
            'is_course': self.is_course,
            'false_reason': self.false_reason,
        }
        if self.is_course:
            return current_list
        current_list['child'] = []
        for child in self.children:
            new_dict = child.tree_into_dict(self.hide_false)
            if new_dict is not None:
                current_list['child'].append(new_dict)
        return current_list

    def add_children(self, obj):
        self.children.append(obj)

    def eval_children(self, taken_list):
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode):
                child.eval_children(taken_list)

        if not self.is_course:
            logger.debug('{children} passed through {func}'.format(
                children=str(self.children),
                func=self.func.__name__,
            ))
            self.data = self.func(*[child_node.data for child_node in self.children], **self.metadata)
            if not self.data:
                self.false_reason = 'function returned false'
            if self.sum_false:
                self.credit = sum([child_node.credit for child_node in self.children])
            else:
                self.credit = sum([child_node.credit for child_node in self.children if child_node.data])
            if self.required_credit != 0:
                if self.required_credit > self.credit:
                    self.data = False
                    self.false_reason = 'not enough credit'
        else:
            is_satisfied = False
            for i, course in enumerate(taken_list):
                code = course['code']
                if code == self.data:
                    logger.debug('{data} returns True'.format(data=self.data))
                    self.data = True
                    is_satisfied = True
                    self.namespace = course['title']  # Change name to what user actually took
                    del taken_list[i]
                    break
            if not is_satisfied:
                logger.debug('{data} returns False'.format(data=self.data))
                self.data = False
                self.credit = 0

    def filter_true(self, queryset):
        return [x for x in queryset if self._filter_true_evaluate(x)]

    def _filter_true_evaluate(self, course):
        # TODO: add functions to get 'year' and 'semester
        sugang_list = {
            'year': '2017',
            'semester': '1',
            'grade': 'A+',
            'code': course['code'],
            'number': course['number'],
            'title': course['title'],
            'credit': course['credit'],
            'category': course['category']
        }
        test_node = copy.deepcopy(self)
        test_node.eval_children(sugang_list)
        return copy.deepcopy(test_node.data)  # Let 'test_node' garbage collected
