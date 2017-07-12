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


class ClientRenderedException(Exception):
    pass


class LoginRequest(APIView):
    parser_classes = (MultiPartParser, FormParser, JSONParser,)

    # For debugging purpose :
    #   - Return sugang_list at success
    def post(self, request, option):
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

            if len(sugang_list) == 0:
                raise ClientRenderedException('이수내역이 존재하지 않습니다.')
            rule = self.get_rule(request)
            try:
                tree = TreeLoader(rule, {}, Course)
                tree.eval_tree(sugang_list)
            except TreeLoaderException:
                return HttpResponseServerError()
            # do something with 'tree' here
        except ClientRenderedException as e:
            logger.error(e.args[0])
            return JsonResponse({'success': False, 'message': e.args[0]})

        request.session['list'] = sugang_list
        # TODO: fix error ( tree is not serializable )
        # request.session['tree'] = tree
        request.session.set_expiry(6000)
        return JsonResponse({'success': True, 'message': request.session['list']})

    def get_rule(self, request):
        has_major = request.data.get('major_info', False)
        if has_major:
            major_info = request.data.get('majors', None)
            if major_info is None:
                raise ClientRenderedException('전공 정보가 없습니다.')
        else:
            user_id = request.data.get('user_id', 'nid')
            password = request.data.get('password', 'npw')
            major_info = mysnu.crawl_major(user_id, password)
        return find_rule(major_info)
