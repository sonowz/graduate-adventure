from django.test import TestCase
from django.http.request import HttpRequest, QueryDict
import json
from api.login.views import LoginRequest


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
        request.data['majors'] = [
            {
                'type': '주전공',
                'field': '컴퓨터공학전공'
            }
        ]
        response = self.req_class.get_rule(request)
        self.assertEqual(response, 'sample_cse_2016')
