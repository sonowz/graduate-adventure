# -*- coding: utf-8 -*-
from django.http.response import HttpResponseServerError, JsonResponse
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from crawler import mysnu
from core.models import Course
from core.parser import parse_credit
from core.rule.tree import TreeLoader, TreeLoaderException
from core.rule.util import find_rule
import logging.config


logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')


class LoginException(Exception):
    pass


class LoginRequest(APIView):
    parser_classes = (MultiPartParser, FormParser, JSONParser,)

    # For debugging purpose :
    #   - Return taken_list at success
    def post(self, request, option):
        try:
            if option == 'mysnu':
                logger.debug('mySNU login request with sessionid: ' + str(request.session.session_key))

                user_id = request.data.get('user_id', 'nid')
                password = request.data.get('password', 'npw')

                taken_list = mysnu.crawl_credit(user_id, password)

                if taken_list is None:
                    raise LoginException('로그인에 실패했습니다.')

            elif option == 'file':
                logger.debug('File login request with sessionid: ' + str(request.session.session_key))
                request.data['major_info'] = True
                filename = request.data.get('filename', 'nofile')
                file = request.data.get(filename, None)
                if file is None:
                    raise LoginException('파일이 올바르지 않습니다.')
                text = file.read().decode('euc-kr', errors='ignore')
                file.close()
                taken_list = parse_credit(text)

            else:
                raise LoginException('접근 경로가 잘못되었습니다.')

            if not taken_list:
                raise LoginException('이수내역이 존재하지 않습니다.')

            rule = self.get_rule(request)

            try:
                tree = TreeLoader(rule, {}, Course)
                tree.eval_tree(taken_list)

            except TreeLoaderException:
                return HttpResponseServerError()

            # do something with 'tree' here

        except LoginException as e:
            logger.error(e.args[0])
            return JsonResponse({'success': False, 'message': e.args[0]})

        request.session['list'] = taken_list
        # TODO: fix error ( tree is not serializable )
        # request.session['tree'] = tree

        request.session.set_expiry(6000)

        return JsonResponse({'success': True, 'message': request.session['list']})

    def get_rule(self, request):
        has_major = request.data.get('major_info', False)

        if has_major:
            try:
                arg = ['double_major', 'major', 'minor']
                major_info = {x: request.data[x] for x in arg}

            except KeyError:
                raise LoginException('전공 정보가 없습니다.')
        else:
            user_id = request.data.get('user_id', 'nid')
            password = request.data.get('password', 'npw')
            major_info = mysnu.crawl_major(user_id, password)

        return find_rule(major_info)
