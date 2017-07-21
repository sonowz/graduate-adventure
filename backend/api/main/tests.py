# -*- coding: utf-8 -*-
from django.test import TestCase
from django.conf import settings
import json
import pickle
import os
from api.main.tree import tree_to_json
from core.rule.tree import TreeLoader


class TestTreeToJson(TestCase):
    def setUp(self):
        self.sample_rule = 'sample_cse_2016'
        sugang_list_dir = os.path.join(settings.BASE_DIR, 'test_sample/sugang_list.pickle')
        sample_metadata = {"teps": 2}

        file = open(sugang_list_dir, 'rb')
        self.sample_sugang_list = pickle.load(file)['credit_info']
        self.tree = TreeLoader(self.sample_rule, sample_metadata)
        self.tree.eval_tree(self.sample_sugang_list)

    def test_tree_to_json(self):
        result = json.loads(tree_to_json(self.tree, self.sample_sugang_list))
        self.assertEqual(len(result['liberal_table']), 4)
        for chunk in result['liberal_table']:
            if chunk['semester'] == '미이수':
                self.assertEqual(len(chunk['data']), 4)
                data = str(chunk['data'])
                substr_list = [
                    '외국어',
                    '공학수학 2',
                    '정치와 경제'
                ]
                if not all(x in data for x in substr_list):
                    self.fail()
                exclude_list = [
                    '공학수학 1',
                    '역사와 철학'
                ]
                if any(x in data for x in exclude_list):
                    self.fail()
            elif chunk['semester'] == '2016-1':
                self.assertEqual(len(chunk['data']), 7)
        for chunk in result['major_table']:
            if chunk['semester'] == '미이수':
                self.assertEqual(len(chunk['data']), 4)  # number of main nodes

        liberal_graph = result['point_graph']['liberal']
        self.assertEqual(liberal_graph['req'], 44)
        self.assertEqual(liberal_graph['acq'], 32)
