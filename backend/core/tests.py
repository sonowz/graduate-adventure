# -*- coding: utf-8 -*-
from django.test import TestCase
from django.conf import settings
import pickle
import os
from core.models import Course
from core.rule.tree import TreeLoader, TreeNode, TreeLoaderException


class TestParser(TestCase):
    pass


class TestRuleTree(TestCase):
    def setUp(self):
        self.sample_rule = 'sample_cse_2016'
        sugang_list_dir = os.path.join(settings.BASE_DIR, 'testing/sugang_list.pickle')

        file = open(sugang_list_dir, 'rb')
        self.sample_sugang_list = pickle.load(file)['credit_info']

    def test_tree_creation(self):
        self.assertRaises(TreeLoaderException, TreeLoader, 'non_existing_rule', None, Course)

        tree = TreeLoader(self.sample_rule, {}, Course)
        for child in tree.base_node.children:
            if child.namespace == '전공':
                break
        else:
            self.fail()
        node_count = self.tree_count(tree.base_node)
        self.assertGreater(node_count, 10)

    def tree_count(self, node):
        node_count = 1
        for i, child in enumerate(node.children):
            if isinstance(child, TreeNode):
                node_count += self.tree_count(child)
        return node_count

    def test_tree_evaluation(self):
        tree = TreeLoader(self.sample_rule, {}, Course)
        tree.eval_tree(self.sample_sugang_list)
        self.recur_tree_evaluation(tree.base_node)

    # Currently doing simple tests because no course db is imported
    def recur_tree_evaluation(self, node):
        if node.namespace == '!GRADUATE':
            self.assertFalse(node.data)
        elif node.namespace == '과학적 사고 및 표현':
            self.assertFalse(node.data)
        elif node.namespace == '수량적 분석과 추론':
            self.assertFalse(node.data)
        elif node.namespace == '컴퓨터와 정보활용':
            self.assertTrue(node.data)

        for i, child in enumerate(node.children):
            if isinstance(child, TreeNode):
                self.recur_tree_evaluation(child)
