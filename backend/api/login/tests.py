from django.test import TestCase
from django.http.request import HttpRequest, QueryDict
from django.conf import settings
import pickle
import json
import os
from api.login.views import LoginRequest
from api.login.tree import tree_to_table
from core.models import Course
from core.rule.tree import TreeLoader


class DummySession:
    def __init__(self):
        self.session_key = 'somesessionid'


class TestView(TestCase):
    def setUp(self):
        self.req_class = LoginRequest()

    def init_request(self):
        request = HttpRequest()
        request.data = QueryDict().copy()
        request.session = DummySession()
        return request

    def test_login_request(self):
        request = self.init_request()
        request.data['user_id'] = 'dnsdhrj'
        request.data['password'] = '1234'
        response = self.req_class.post(request, 'mysnu')
        json_res = json.loads(response.content.decode())
        self.assertFalse(json_res['success'])
        self.assertEqual(json_res['message'], '로그인에 실패했습니다.')

    def test_file_request(self):
        pass

    def test_get_rule(self):
        request = self.init_request()
        request.data['major_info'] = True
        request.data['majors'] = [
            {
                'type': '주전공',
                'name': '컴퓨터공학전공'
            }
        ]
        major_info, rule = self.req_class.get_rules(request)[0]
        self.assertEqual(rule, 'sample_cse_2016')


class TestTreeToTable(TestCase):
    def setUp(self):
        self.sample_rule = 'sample_cse_2016'
        sugang_list_dir = os.path.join(settings.BASE_DIR, 'test_sample', 'sugang_list.pickle')
        sample_metadata = {"teps": 2}

        file = open(sugang_list_dir, 'rb')
        self.sample_sugang_list = pickle.load(file)['credit_info']
        self.tree = TreeLoader(self.sample_rule, sample_metadata)
        self.tree.eval_tree(self.sample_sugang_list)

    def test_tree_to_table(self):
        result = tree_to_table(self.tree, self.sample_sugang_list)
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
