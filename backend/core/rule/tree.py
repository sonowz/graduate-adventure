# -*- coding: utf-8 -*-
import yaml
import copy
from core.rule.functions import and_func, make_func, if_func_list
import os
import logging.config
from django.conf import settings
from core.models import Course, Replace

logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')

# http://stackoverflow.com/questions/528281/how-can-i-include-an-yaml-file-inside-another


class Loader(yaml.Loader):
    """YAML Loader class

    Load yaml file recursively
    """
    def __init__(self, stream):
        self._root = os.path.split(stream.name)[0]
        super(Loader, self).__init__(stream)

    def include(self, node):

        # include another yaml file by `!include` directive
        filename = os.path.join(self._root, self.construct_scalar(node))
        with open(filename, 'r') as f:
            return yaml.load(f, Loader)


Loader.add_constructor('!include', Loader.include)


class TreeLoaderException(Exception):
    pass


class TreeLoader(object):
    """Rule tree loader class

    Read rule yaml tree file, and compare with given course list

    Raises:
        TreeLoaderException: any error in loader
    """
    def __init__(self, rule_name, metadata):
        """Constructor of TreeLoader.

        Args:
            rule_name: rule file name in ./rules, excluding extension .yml
            metadata: data of any other information needed evaluating tree
        """
        base_dir = os.path.dirname(os.path.abspath(__file__))

        # Open yaml rule file
        try:
            f = open(os.path.join(base_dir, 'rules', rule_name + '.yml'), 'r', encoding='utf-8')
            self.tree = yaml.load(f, Loader)
            f.close()
        except IOError:
            logger.error('Error opening file: ' + rule_name)
            raise TreeLoaderException()

        # Metadata
        self.metadata = metadata

        self.default_properties = {
            # if this value is True, falsy node will be hidden
            'hide_false': False,

            # [currently acquired credit, required credit for True, sum credit of falsy node or not]
            'credit_info': [0, 0, False],
            'main_node': False,
        }

        # base node is GRADUATE
        self.base_node = TreeNode(None, self.default_properties, self.metadata, and_func(), '!GRADUATE')

        # initiate recursive tree loading procedure
        self.load_tree(self.tree, self.base_node)

    def load_tree(self, current_tree, previous_node):
        """Read rule tree and construct another tree of TreeNode

        When the function finishes, root will be self.base_node

        Args:
            current_tree: currently evaluating tree
            previous_node: current parent node

        Returns:
            None
        """
        for course in current_tree:

            # If course is str, this means it is leaf node, which can be directly evaluated
            if isinstance(course, str):

                # if starts with '$', expand tree with all courses of its named subarea
                if course.startswith('$'):

                    # fetch real name of subarea (excluding '$')
                    subarea = course[1:]

                    # filter with Django model
                    code_list = [item.code for item in Course.objects.filter(subarea=subarea)]
                    code_set = set(code_list)

                    # expand tree
                    for code in code_set:
                        previous_node.add_children(TreeNode(code, self.default_properties, self.metadata))

                # if starts with '@', search with department, category, and year
                elif course.startswith('@'):
                    t = course.split('@')

                    # fetch all data
                    dept, category, year = t[1], t[2], int(t[3])

                    # filter with Django model
                    code_list = [item.code for item in Course.objects.filter(
                        dept=dept,
                        category=category,
                        year=year,
                    )]
                    code_set = set(code_list)

                    # expand tree
                    for code in code_set:
                        previous_node.add_children(TreeNode(code, self.default_properties, self.metadata))

                # if just a course number, expand only one of it
                else:
                    previous_node.add_children(TreeNode(course, self.default_properties, self.metadata))

            # If course is dict, this means it is not a leaf node, which can be recursively evaluated
            elif type(course) is dict:

                # additional argument (maybe used by if_func)
                args = course.get('args', [])

                # hide falsy node or not
                hide_false = course.get('hide_false', False)

                # required credit for evaluated to True
                required_credit = course.get('required_credit', 0)

                # sum credit of falsy node or not
                sum_false = course.get('sum_false', False)
                main_node = course.get('main_node', False)

                # construct property dictionary
                properties = {
                    'hide_false': hide_false,
                    'credit_info': [0, required_credit, sum_false],
                    'main_node': main_node,
                }

                # get evaluator function
                current_func = course['func']

                # if it is 'if_func' family, fetch 'then', which is additional tree dictionary
                if current_func in if_func_list:
                    current_if_func = if_func_list[current_func]

                    # only expand tree if 'if_func' is evaluated to True
                    if current_if_func(*args, **self.metadata):
                        self.load_tree(course['then'], previous_node)

                # if it is not 'if_func' family, just add one node and load it recursively
                else:
                    current_node = TreeNode(None,
                                            properties,
                                            self.metadata,
                                            make_func(current_func)(*args),
                                            course['name'],
                                            )
                    self.load_tree(course['courses'], current_node)

                    # add this node
                    previous_node.add_children(current_node)

    def eval_tree(self, taken_list):
        """Evaluate tree recursively

        Constructor automatically call this function, so it is not needed to be called explicitly.

        Args:
            taken_list: list of taken courses.

        Returns:
            data of self.base_node
        """

        # clone taken_list because it's modified
        self.base_node.eval_children(list(taken_list))
        return self.base_node.data

    def tree_into_str(self):
        """Get tree string of TreeLoader

        Args:
            None

        Returns:
            tree string
        """
        return self.base_node.tree_into_str(0)

    def tree_into_dict(self):
        """Get tree dictionary object of TreeLoader

        Args:
            None

        Returns:
            tree dictionary object
        """
        return self.base_node.tree_into_dict()

    # TODO: Find and return node by name
    def find(self, name):
        return None


class TreeNode(object):
    def __init__(self, data, properties, metadata, func=None, namespace=None, *args):
        """Constructor of TreeNode

        Args:
            data: data of current node. more additional explaination is in below
            properties: dict of property. will be deconstructed
            metadata: data of any other information needed evaluating tree
            func: evaluator function (closure)
            namespace: name which user actually see
            *args: any other additional arguments
        """

        # self.data can contain various types of data.
        # If type of self.data is `None`, it means it is not
        # yet evaluated. Maybe it is not leaf node, which
        # means for being evaluated, all children node
        # should be evaluated.
        # If type of self.data is `Boolean`, it means its
        # evaluation is done.
        # If type of self.data is `str`, it is just a
        # course code number, and it means it is not
        # yet evaluated, and it can be directly evaluated
        # by looking up course taken list.
        self.data = data

        # any other bunch of data...
        self.credit = properties['credit_info'][0]
        self.required_credit = properties['credit_info'][1]
        self.sum_false = properties['credit_info'][2]
        self.hide_false = properties['hide_false']
        self.main_node = properties['main_node']
        self.metadata = metadata
        self.func = func
        self.namespace = namespace

        # maybe this variable will be needed for user-friendly interface
        self.false_reason = ''

        # if str, it is course (more specifically, course code number)
        self.is_course = isinstance(data, str)

        # if course, fetch credit info and namespace
        if self.is_course:
            self.children = []
            try:
                # get information of course by fetching database
                filtered_course = Course.objects.filter(code=self.data)[0]
                self.namespace = filtered_course.title
                self.credit = filtered_course.credit

            # if not found, just set its namespace to '!NOT FOUND'.
            except IndexError:
                self.namespace = '!NOT FOUND'

        # if it is not plain course number, just set children
        else:
            self.children = list(args)

    def __str__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def __repr__(self):
        return '{0} <{1}>'.format(self.namespace, self.data)

    def tree_into_str(self, depth=0, hide=False):
        """Convert tree to tree string

        Args:
            depth: current depth. this will be shown by count of tabs
            hide: boolean about hiding falsy node or not

        Returns:
            tree string
        """
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
        """Convert tree to tree dictionary

        Args:
            hide: boolean about hiding falsy node or not

        Returns:
            tree dictionary object
        """
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
        """Evaluate children recursively

        Evaluate TreeNode and set self.data to its value.
        If children exist, evaluate them all recursively.

        Args:
            taken_list: taken course list

        Returns:
            None
        """

        # First, evaluate all children so that itself can be evaluated directly
        for i, child in enumerate(self.children):
            if isinstance(child, TreeNode):
                child.eval_children(taken_list)

        # If it is not course, which is not course code number, it should be
        # evaluated through `func`, because it is not directly able to be evaluated
        # by looking up course taken list.
        if not self.is_course:

            # logging
            logger.debug('{children} passed through {func}'.format(
                children=str(self.children),
                func=self.func.__name__,
            ))

            # pass through given function, which returns Boolean
            self.data = self.func(*[child_node.data for child_node in self.children], **self.metadata)

            if not self.data:
                self.false_reason = 'function returned false'

            # if `sum_false` is True, just exclude credits of falsy nodes.
            if self.sum_false:
                self.credit = sum([child_node.credit for child_node in self.children])
            else:
                self.credit = sum([child_node.credit for child_node in self.children if child_node.data])

            # if required credit is set, final test for evaluation begins
            if self.required_credit != 0:

                # if not enough, set data to False.
                if self.required_credit > self.credit:
                    self.data = False
                    self.false_reason = 'not enough credit'

            # IMPORTANT PART
            # if this node is evaluated into True, its children nodes which are
            # plain course number should be consumed so that prevents double-evaluated
            # problem.
            if self.data:
                # traverse all children
                for child in self.children:
                    # if a child is course, search taken course list
                    if child.is_course:
                        for i, course in enumerate(taken_list):
                            code = course['code']

                            # if matches, consume it
                            if code == child.data:
                                del taken_list[i]

        # If it is just plain course code number, it can be evaluated by
        # looking up course taken list.
        else:
            is_satisfied = False

            for i, course in enumerate(taken_list):
                # fetch code number of taken course
                code = course['code']

                # If code matches to self.data, it will be evaluated to True
                if code == self.data:
                    logger.debug('{data} returns True'.format(data=self.data))
                    self.data = True
                    is_satisfied = True

                    # Change name to what user actually took
                    self.namespace = course['title']

            # it any of entries of taken_list does not matches,
            # it will be evaluated to False.
            if not is_satisfied:
                logger.debug('{data} returns False'.format(data=self.data))
                self.data = False

                # its credit property should be set to 0 for proper
                # evaluation of required credit of upper nodes.
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
