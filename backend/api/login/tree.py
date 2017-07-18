# -*- coding: utf-8 -*-
import json


# Tooltips will try not to exceed this
TOOLTIP_MAX_LINE = 20


def tree_to_table(tree, sugang_list):
    table = {
        'major': [],
        'liberal': []
    }
    sugang_dict = {x['title']: x for x in sugang_list}  # use dictionary for performance
    graph_nodes = _extract_nodes(tree.base_node, sugang_dict, table)
    _add_uncounted_courses(sugang_dict, table)
    json_dict = dict()
    json_dict['major_table'] = table['major']
    json_dict['liberal_table'] = table['liberal']
    json_dict['point_graph'] = _build_graph(graph_nodes)
    return json_dict


# Build course table, while returning nodes used in graph section
def _extract_nodes(node, sugang_dict, table, state=None):
    if state is None:
        state = {
            'category': 'UNDEFINED',
            'main_node': node
        }

    category_list = {
        '전필': 'required',
        '전선': 'elective',
        '교양': 'liberal'
    }
    if node.namespace in category_list.keys():
        state['category'] = category_list[node.namespace]
    if node.main_node:
        state['main_node'] = node

    if node.is_course and node.data is True:  # courses already taken
        data = {
            'title': node.namespace,
            'category': state['category'],
            'tooltip': state['main_node'].namespace
        }
        semester = _get_semester(node, sugang_dict)
    elif node.main_node and node.data is False:  # not satisfied main nodes
        data = {
            'title': node.namespace,
            'category': state['category'],
            'tooltip': '\n'.join(_list_courses(node))
        }
        semester = '미이수'

    if 'data' in dir():
        if state['category'] == 'liberal':  # Decide which table to insert
            _insert_entry(table['liberal'], semester, data)
        else:
            _insert_entry(table['major'], semester, data)

    graph_nodes_list = ['전필', '전선', '교양']
    graph_nodes = []
    if node.namespace in graph_nodes_list:
        graph_nodes.append(node)
    for child in node.children:
        graph_nodes.extend(_extract_nodes(child, sugang_dict, table, state))
    return graph_nodes


def _build_graph(nodes):
    ret = dict()
    req_sum, acq_sum = 0, 0
    convert_list = {
        '전필': 'major_required',
        '전선': 'major_elective',
        '교양': 'liberal'
    }
    for node in nodes:
        ret[convert_list[node.namespace]] = {
            'req': node.required_credit,
            'acq': node.credit
        }
        req_sum += node.required_credit
        acq_sum += node.credit

    ret['total'] = {
        'req': req_sum,
        'acq': acq_sum
    }
    return ret


def _list_courses(node):
    leafs = _get_leafs(node, 9999)
    if len(leafs) > TOOLTIP_MAX_LINE:
        # Set max_depth to reduce number of nodes
        max_depth = 0
        for leaf in leafs:
            max_depth = max(max_depth, leaf.depth)
        while max_depth > 0:
            max_depth -= 1
            leafs = _get_leafs(node, max_depth)
            if len(leafs) <= TOOLTIP_MAX_LINE:
                break
    return [node.namespace for node in leafs if node.data is False]


def _get_leafs(node, max_depth, depth=0):
    if depth >= max_depth or len(node.children) == 0:
        node.depth = depth
        return [node]
    leafs = []
    for child in node.children:
        leafs.extend(_get_leafs(child, max_depth, depth + 1))
    return leafs


def _get_semester(node, sugang_dict):
    course = sugang_dict.get(node.namespace, None)
    if course is None:
        return 'ERROR'
    course['counted'] = True  # for _add_uncounted_courses()
    return str(course['year']) + '-' + course['semester']


def _add_uncounted_courses(sugang_dict, table):
    for course in sugang_dict.values():
        if not course.get('counted', False):
            data = {
                'title': course['title'],
                'category': 'free',
                'tooltip': ''
            }
            semester = str(course['year']) + '-' + course['semester']
            # TODO: check cases where courses belong to 'major'
            _insert_entry(table['liberal'], semester, data)


def _insert_entry(table, semester, data):
    for entry in table:
        if entry['semester'] == semester:
            entry['data'].append(data)
            break
    else:
        table.append({
            'semester': semester,
            'data': [data]
        })
