# -*- coding: utf-8 -*-
import requests
from bs4 import BeautifulSoup as bs
import xlrd
from .format import search_form
import logging
import logging.config
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('backend')


search_url = 'http://sugang.snu.ac.kr/sugang/cc/cc100.action'
excel_url = 'http://sugang.snu.ac.kr/sugang/cc/cc100excel.action'
semester_name = {
    'U000200001U000300001': '1',
    'U000200001U000300002': 'S',
    'U000200002U000300001': '2',
    'U000200002U000300002': 'W'
}
category_name = {
    '': '전체',
    'A': '교양',
    'B': '전필',
    'C': '전선',
    'D': '일선',
    'E': '교직',
    'F': '논문',
    'G': '대학원',
    'K': '학사'
}


def parse_option_tag(op):
    return {'code': op['value'], 'name': op.text.strip()}


# Assume that only 'General education class(교양)' courses have area & subarea attributes.
def get_areas(year, semester):
    form = search_form(year, semester, 'A')
    search_page = requests.post(search_url, data=form)
    soup = bs(search_page.text, 'html5lib')
    select = soup.find('select', {'name': 'srchOpenUpSbjtFldCd'})
    options = select.find_all('option')
    areas = list(map(parse_option_tag, options))
    return list(filter(lambda area: area['code'] != '', areas))


def get_subareas(year, semester, area):
    form = search_form(year, semester, 'A', area['code'])
    search_page = requests.post(search_url, data=form)
    soup = bs(search_page.text, 'html5lib')
    select = soup.find('select', {'name': 'srchOpenSbjtFldCd'})
    options = select.find_all('option')
    subareas = list(map(parse_option_tag, options))
    return list(filter(lambda subarea: subarea['code'] != '', subareas))


def get_courses(year, semester, category, area, subarea):
    logger.debug('Crawling {year}-{semester} {category}-{area}-{subarea}'.format(
                 year=year,
                 semester=semester_name[semester],
                 category=category_name[category],
                 area="('{code}', '{name}')".format(code=area['code'], name=area['name']),
                 subarea="('{code}', '{name}')".format(code=subarea['code'], name=subarea['name'])
                 ))
    form = search_form(year, semester, category, area['code'], subarea['code'])
    excel = requests.post(excel_url, form)
    excel.raise_for_status()
    if excel.content == b'':
        return []
    try:
        workbook = xlrd.open_workbook(file_contents=excel.content)
    except xlrd.XLRDError:
        logger.error('Cannot open file: maybe this is not accessable semester.')
        return []
    sheet = workbook.sheet_by_index(0)
    res = []
    for row in range(3, sheet.nrows):
        course = {
            'year': year,
            'semester': semester_name[semester],
            'code': sheet.cell_value(row, 5),
            'number': sheet.cell_value(row, 6),
            'title': sheet.cell_value(row, 7),
            'credit': sheet.cell_value(row, 9),
            'category': sheet.cell_value(row, 0),
            'language': sheet.cell_value(row, 19),
            'area': area['name'],
            'subarea': subarea['name'],
            'collage': sheet.cell_value(row, 1),
            'dept': sheet.cell_value(row, 2)
        }
        res.append(course)
    return res


def crawl_years(start, end=None):
    if end is None:
        end = start + 1
    courses = []
    for year in range(start, end):
        for semester in list(semester_name.keys()):
            cs = get_courses(year, semester, '', {'code': '', 'name': ''}, {'code': '', 'name': ''})
            filtered = list(filter(lambda course: course['category'] != '교양', cs))
            courses.extend(filtered)
            areas = get_areas(year, semester)
            for area in areas:
                subareas = get_subareas(year, semester, area)
                for subarea in subareas:
                    cs = get_courses(year, semester, 'A', area, subarea)
                    courses.extend(cs)
    return courses
