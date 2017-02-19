# -*- coding: utf-8 -*-
from django.http.response import JsonResponse, HttpResponseBadRequest, HttpResponseNotAllowed
from rest_framework.views import APIView
from rest_framework.parsers import FormParser
import json
from api.main.tree import tree_to_json
from core.models import Course


def main_data(request):
    if request.method != 'GET':
        return HttpResponseNotAllowed('GET')
    tree = request.session.get('tree', None)
    if tree is None:
        return HttpResponseBadRequest()
    return JsonResponse(tree_to_json(tree))


class SearchModal(APIView):
    parser_classes = (FormParser,)

    def post(self, request):
        tree = request.session.get('tree', None)
        node_title = request.session.get('node_title', None)
        if tree is None or node_title is None:
            return HttpResponseBadRequest()
        node = tree.find(node_title)
        if node is None:
            return HttpResponseBadRequest()

        convert_list = {
            'title__icontains': 'title',
            'code__contains': 'code',
            'credit': 'credit',
            'category': 'category',
            'area': 'area',
            'subarea': 'subarea',
            'college': 'college',
            'dept': 'dept',
        }
        query_list = {key: request.data.get(value, None) for key, value in convert_list}
        # Delete non-parameter keys from query
        for key, value in query_list:
            if value is None:
                del query_list[key]

        # TODO: add functions to get these variables
        query_list['year'] = '2017'
        query_list['semester'] = '1'

        retrieved = Course.objects.filter(**query_list)
        node.filter_true(retrieved)

        retrieved_list = []
        for item in retrieved:
            course = {value: item.get(value, None) for key, value in convert_list}
            retrieved_list.append(course)
        json_root = {'data': retrieved_list}
        return JsonResponse(json.dumps(json_root))
