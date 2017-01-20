# -*- coding: utf-8 -*-
from django.http.response import HttpResponse
from django.shortcuts import redirect
from rest_framework.views import APIView
from core.crawler import crawl_credit, crawl_major
from core.rule.tree import TreeLoader
from core.rule.util import find_rule
import os
import logging

os.makedirs(os.getcwd() + '/log', exist_ok=True)
logging.basicConfig(filename=os.getcwd() + '/log/loginview.log', level=logging.DEBUG)


def login_page(request):
    logging.debug('Login page request with sessionid: ' + request.session.session_key)
    return HttpResponse("Hello World!")


class LoginRequest(APIView):

    # For debugging purpose :
    #   - Used GET method instead of POST
    #   - Redirect to '/login/test' instead of '/main'
    def get(self, request, *args, **kwargs):
        logging.debug('mySNU login request with sessionid: ' + str(request.session.session_key))
        user_id = request.GET.get('user_id', 'nid')
        password = request.GET.get('password', 'npw')
        sugang_list = crawl_credit(user_id, password)
        if len(sugang_list) == 0:
            logging.error('Crawling failed.')
            return HttpResponse('로그인에 실패했습니다.')

        try:
            rule = self.get_rule(request)
            # tree =
            TreeLoader(rule, sugang_list)
            # do something with 'tree' here
        except IOError:
            logging.error('No such file: ' + rule)
            pass
        except Exception as e:
            logging.error("Couldn't get rule file: " + e.args.msg)
            return HttpResponse(e.args.msg)

        request.session['list'] = sugang_list
        request.session.set_expiry(600)
        logging.debug('Redirecting to /main/...')
        return redirect('/login/test')

    def get_rule(self, request):
        has_major = request.GET.get('major_info', False)
        if has_major:
            try:
                arg = [
                    'double_major',
                    'major',
                    'minor',
                ]
                major_info = {x: request.GET[x] for x in arg}
            except KeyError:
                raise Exception(msg='전공 정보가 없습니다.')
        else:
            user_id = request.GET.get('user_id', 'nid')
            password = request.GET.get('password', 'npw')
            major_info = crawl_major(user_id, password)
        return find_rule(major_info)


def test(request):
    return HttpResponse(str(request.session['list']))
