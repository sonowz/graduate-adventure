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
from api.login.tree import tree_to_table
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
                try:
                    taken_list = parse_credit(text)

                except Exception as e:
                    logger.error(e.args[0])
                    raise LoginException('수강 정보가 올바르지 않습니다.')

            else:
                raise LoginException('접근 경로가 잘못되었습니다.')

            if not taken_list:
                raise LoginException('이수내역이 존재하지 않습니다.')

            rules = self.get_rules(request)

            try:
                # TODO: metadata should be set on here
                tables = []
                for major, rule in rules:
                    tree = TreeLoader(rule, {})
                    tree.eval_tree(taken_list)
                    tables.append({
                        'name': major['name'],
                        'type': major['type'],
                        'data': tree_to_table(tree, taken_list)
                    })

            except TreeLoaderException:
                return HttpResponseServerError()

        except LoginException as e:
            logger.error(e.args[0])
            return JsonResponse({'success': False, 'message': e.args[0]})

        # 'tree' cannot be serialized, so store 'tables' instead
        request.session['list'] = taken_list
        request.session['tables'] = tables

        request.session.set_expiry(6000)

        return JsonResponse({'success': True, 'message': request.session['list']})

    # returns list of (major_info, corresponding_rule_file)
    def get_rules(self, request):
        has_major = request.data.get('major_info', False)

        if has_major:
            major_info = request.data.get('majors', None)
            if major_info is None:
                raise LoginException('전공 정보가 없습니다.')
        else:
            user_id = request.data.get('user_id', 'nid')
            password = request.data.get('password', 'npw')
            major_info = mysnu.crawl_major(user_id, password)

        return [find_rule(item) for item in major_info]
