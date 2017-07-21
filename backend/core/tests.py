# -*- coding: utf-8 -*-
from django.test import TestCase
from django.conf import settings
import pickle
import os
from core.rule.tree import TreeLoader, TreeNode, TreeLoaderException


class TestParser(TestCase):
    pass


# Tests might be modified if rules are changed
class TestRuleTree(TestCase):

    def setUp(self):
        self.sample_rule = 'sample_cse_2016'
        sugang_list_dir = os.path.join(settings.BASE_DIR, 'test_sample/sugang_list.pickle')

        file = open(sugang_list_dir, 'rb')
        self.sample_sugang_list = pickle.load(file)['credit_info']

    def test_tree_creation(self):
        self.assertRaises(TreeLoaderException, TreeLoader, 'non_existing_rule', None)

        tree = TreeLoader(self.sample_rule, {})
        node_count = self.recur_node_count(tree.base_node)
        self.assertEqual(node_count, 340)  # print(node_count) to get proper value
        tree_str = tree.tree_into_str()
        substr_list = [
            '!NOT FOUND',
            '역사와 철학 한문원전읽기',
            '화학생물공학개론',
            '창의적통합설계2'
        ]
        if not all(x in tree_str for x in substr_list):
            self.fail()

    def recur_node_count(self, node):
        if node.namespace == '문화와 예술':
            self.assertEqual(len(node.children), 41)
        node_count = 1
        for i, child in enumerate(node.children):
            if isinstance(child, TreeNode):
                node_count += self.recur_node_count(child)
        return node_count

    def test_tree_evaluation(self):
        sample_metadata = {"teps": 2}
        tree = TreeLoader(self.sample_rule, sample_metadata)
        tree.eval_tree(self.sample_sugang_list)
        self.recur_tree_evaluation(tree.base_node)
        tree_str = tree.tree_into_str()
        substr_list = [
            '대학영어 2: 글쓰기',
            '화학 1',
            '화학실험 2',
            '논리학'
        ]
        if not all(x in tree_str for x in substr_list):
            self.fail()
        if '!NOT FOUND' in tree_str:
            self.fail()

    # Tests might be modified if rules are changed
    def recur_tree_evaluation(self, node):
        if node.namespace == '!GRADUATE':
            self.assertFalse(node.data)
        elif node.namespace == '외국어':
            self.assertEqual(node.credit, 2)
        elif node.namespace == '과학적 사고 및 표현':
            self.assertFalse(node.data)
            self.assertEqual(node.credit, 8)
        elif node.namespace == '역사와 철학':
            self.assertTrue(node.data)
        elif node.namespace == '전공':
            self.assertEqual(node.credit, 0)

        for i, child in enumerate(node.children):
            if isinstance(child, TreeNode):
                self.recur_tree_evaluation(child)
