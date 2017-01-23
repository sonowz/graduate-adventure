# -*- coding: utf-8 -*-
from django.http.response import HttpResponse
from django.shortcuts import redirect
from django.conf import settings
from rest_framework.views import APIView
from core.crawler import crawl_credit, crawl_major
from core.rule.tree import TreeLoader
from core.rule.util import find_rule
import logging.config


logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')


class ClientRenderedException(Exception):
    pass


def login_page(request):
    logger.debug('Login page request with sessionid: ' + request.session.session_key)
    return HttpResponse("Hello World!")


class LoginRequest(APIView):

    # For debugging purpose :
    #   - Used GET method instead of POST
    #   - Return sugang_list instead of redirecting to '/main'
    def get(self, request, *args, **kwargs):
        logger.debug('mySNU login request with sessionid: ' + str(request.session.session_key))
        user_id = request.GET.get('user_id', 'nid')
        password = request.GET.get('password', 'npw')

        try:
            sugang_list = crawl_credit(user_id, password)
            if len(sugang_list) == 0:
                raise ClientRenderedException('로그인에 실패했습니다.')
            rule = self.get_rule(request)
            # tree =
            TreeLoader(rule, sugang_list, [])
            # do something with 'tree' here
        # IOError should be handled within 'TreeLoader' later
        except IOError:
            logger.error('No such file: ' + rule)
            pass
        except ClientRenderedException as e:
            logger.error(e.args[0])
            return HttpResponse(e.args[0])

        request.session['list'] = sugang_list
        request.session.set_expiry(600)
        return HttpResponse(str(request.session['list']))

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
                raise ClientRenderedException('전공 정보가 없습니다.')
        else:
            user_id = request.GET.get('user_id', 'nid')
            password = request.GET.get('password', 'npw')
            major_info = crawl_major(user_id, password)
        return find_rule(major_info)
