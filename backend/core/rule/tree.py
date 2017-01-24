# -*- coding: utf-8 -*-
import yaml
from core.rule.functions import and_func, make_func, if_func, if_not_func, if_greater_func, if_less_func
import os
import logging.config
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')


class TreeLoader(object):
    def __init__(self, rule_name, sugang_list, metadata, course_model):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        f = open(os.path.join(base_dir, 'rules', rule_name + '.yml'), 'r', encoding='utf-8')
        self.tree = yaml.load(f)
        f.close()
        self.sugang_list = sugang_list
        self.metadata = metadata
        self.course_model = course_model
        self.base_node = TreeNode(None, and_func(), '!GRADUATE', self.metadata, course_model,
                                  [0, 0, False], False, False)
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node):
        for course in current_tree:
            if isinstance(course, str):
                if course.startswith('$'):
                    subarea = course[1:]
                    subarea_code_list = [item.code for item in self.course_model.objects.filter(subarea=subarea)]
                    code_set = set(subarea_code_list)
                    for code in code_set:
                        previous_node.add_children(
                            TreeNode(code, None, None, self.metadata, self.course_model,
                                     [0, 0, False], False, False, self.sugang_list))
                else:
                    previous_node.add_children(
                        TreeNode(course, None, None, self.metadata, self.course_model,
                                 [0, 0, False], False, False, self.sugang_list))
            elif type(course) is dict:
                args = course.get('args', [])
                hide_false = course.get('hide_false', False)
                required_credit = course.get('required_credit', 0)
                sum_false = course.get('sum_false', False)
                delete_used = course.get('delete_used', False)
                current_func = course['func']
                if current_func == 'if':
                    if not if_func(*args, **self.metadata):
                        continue
                    self.load_tree(course['then'], previous_node)
                elif current_func == 'if_not':
                    if not if_not_func(*args, **self.metadata):
                        continue
                    self.load_tree(course['then'], previous_node)
                elif current_func == 'if_greater':
                    if not if_greater_func(*args, **self.metadata):
                        continue
                    self.load_tree(course['then'], previous_node)
                elif current_func == 'if_less':
                    if not if_less_func(*args, **self.metadata):
                        continue
                    self.load_tree(course['then'], previous_node)
                else:
                    current_node = TreeNode(None,
                                            make_func(current_func)(*args),
                                            course['name'],
                                            self.metadata,
                                            self.course_model,
                                            [0, required_credit, sum_false],
                                            hide_false,
                                            delete_used)
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
    def __init__(self, data, func, namespace, metadata, course_model,
                 credit_info, hide_false=False, delete_used=False, *args):
        self.data = data
        self.func = func
        self.namespace = namespace
        self.metadata = metadata
        self.credit = credit_info[0]
        self.required_credit = credit_info[1]
        self.sum_false = credit_info[2]
        self.hide_false = hide_false
        self.delete_used = delete_used
        self.false_reason = ''
        self.is_course = isinstance(data, str)
        if self.is_course:
            self.children = args[0]
            try:
                filtered_course = course_model.objects.filter(code=self.data)[0]
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

    def eval_children(self, delete_used=False):
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode):
                child.eval_children(self.delete_used)
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
            sugang_list = self.children
            is_satisfied = False
            for i, course in enumerate(sugang_list):
                code = course['code']
                if code == self.data:
                    logger.debug('{data} returns True'.format(data=self.data))
                    self.data = True
                    is_satisfied = True
                    if delete_used:
                        del sugang_list[i]
                    break
            if not is_satisfied:
                logger.debug('{data} returns False'.format(data=self.data))
                self.data = False
                self.credit = 0
