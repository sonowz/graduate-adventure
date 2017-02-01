# -*- coding: utf-8 -*-
from django.http.response import HttpResponse, JsonResponse
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from crawler import mysnu
from core.parser import parse_credit
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
    parser_classes = (MultiPartParser, FormParser,)

    # For debugging purpose :
    #   - Return sugang_list at success
    def post(self, request, option, *args, **kwargs):
        try:
            if option == 'mysnu':
                logger.debug('mySNU login request with sessionid: ' + str(request.session.session_key))
                user_id = request.data.get('user_id', 'nid')
                password = request.data.get('password', 'npw')
                sugang_list = mysnu.crawl_credit(user_id, password)
                if sugang_list is None:
                    raise ClientRenderedException('로그인에 실패했습니다.')
            else:  # option == 'file':
                logger.debug('File login request with sessionid: ' + str(request.session.session_key))
                request.data['major_info'] = True
                filename = request.data.get('filename', 'nofile')
                file = request.data.get(filename, None)
                if file is None:
                    raise ClientRenderedException('파일이 올바르지 않습니다.')
                text = file.read()
                file.close()
                text = text.decode('euc-kr', errors='ignore')
                sugang_list = parse_credit(text)

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
            return JsonResponse({'success': False, 'message': e.args[0]})

        request.session['list'] = sugang_list
        request.session.set_expiry(600)
        return JsonResponse({'success': True, 'message': str(request.session['list'])})

    def get_rule(self, request):
        has_major = request.data.get('major_info', False)
        if has_major:
            try:
                arg = [
                    'double_major',
                    'major',
                    'minor',
                ]
                major_info = {x: request.data[x] for x in arg}
            except KeyError:
                raise ClientRenderedException('전공 정보가 없습니다.')
        else:
            user_id = request.data.get('user_id', 'nid')
            password = request.data.get('password', 'npw')
            major_info = mysnu.crawl_major(user_id, password)
        return find_rule(major_info)
