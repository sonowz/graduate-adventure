import requests
import json
from bs4 import BeautifulSoup
import logging.config
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)


def login(userid, password):
    # return None if the login fails
    # return an instance of requests.Session() if the login succeeds
    logger = logging.getLogger('backend')
    with requests.session() as s:
        data = {
            'si_id': userid,
            'si_pwd': password
        }
        res = s.post('https://sso.snu.ac.kr/safeidentity/modules/auth_idpwd', data=data)
        soup = BeautifulSoup(res.text, 'html5lib')
        try:
            data = {i['name']: i['value'] for i in soup.find('form').find_all('input')}
        except AttributeError:
            logger.error('Fail to login mySNU: Invalid password')
            return None
        res = s.post('https://sso.snu.ac.kr/nls3/fcs', data=data)
        soup = BeautifulSoup(res.text, 'html5lib')
        fonts = soup.find_all('font')
        if len(fonts) == 2:
            res_code = fonts[1].text.strip()
            if res_code == '5402':
                logger.error('Fail to login mySNU: Id does not exist')
                return None
            elif res_code != '2800':
                logger.error('Fail to login mySNU: Unexpected page code')
                return None

        s.get('https://shine.snu.ac.kr/com/ssoLoginForSWAction.action')
        return s


def crawl_credit(userid, password):
    session = login(userid, password)
    if session is None:
        return None
    with session as s:
        url = 'https://shine.snu.ac.kr/uni/uni/scor/mrtr/findTabCumlMrksYyShtmClsfTtInq02.action'
        params = {'cscLocale': 'ko_KR', 'strPgmCd': 'S030302'}
        headers = {'Content-Type': 'application/extJs+sua; charset=UTF-8'}
        payload = {
            "SUN": {
                "strSchyy": "2015",
                "strShtmFg": "U000200001",
                "strDetaShtmFg": "U000300001",
                "strBdegrSystemFg": "U000100001",
                "strFlag": "all"
            }
        }
        grade_response = s.post(url, params=params, headers=headers, data=json.dumps(payload))
        grade_response.raise_for_status()
        grade_list = grade_response.json()['GRD_SCOR401']

        semester_name = {
            'U000200001U000300001': '1',
            'U000200001U000300002': 'S',
            'U000200002U000300001': '2',
            'U000200002U000300002': 'W',
        }

        def refine(raw):
            return {
                'year': int(raw['schyy']),
                'semester': semester_name[raw['shtmFg'] + raw['detaShtmFg']],
                'code': raw['sbjtCd'],
                'number': raw['ltNo'],
                'title': raw['sbjtNm'],
                'credit': raw['acqPnt'],
                'grade': raw['mrksGrdCd'],
                'category': raw['cptnSubmattFgCdNm']
            }

    return [refine(raw) for raw in grade_list]


def crawl_major(userid, password):
    session = login(userid, password)
    if session is None:
        return None
    with session as s:
        url = 'https://shine.snu.ac.kr/uni/uni/port/stup/findMyMjInfo.action'
        params = {'cscLocale': 'ko_KR', 'strPgmCd': 'S010101'}
        headers = {'Content-Type': 'application/extJs+sua; charset=UTF-8'}
        res = s.post(url, params=params, headers=headers)
    # TODO: modify info for backend API
    return res.json()['GRD_SREG524']


def crawl_replace_course(userid, password):
    session = login(userid, password)
    if session is None:
        return None
    with session as s:
        same_url = 'https://shine.snu.ac.kr/uni/uni/cour/curr/findSameSubstSbjtInqStd.action'
        replace_url = 'https://shine.snu.ac.kr/uni/uni/cour/curr/findSameSubstSbjtInqStdList.action'
        params = {'cscLocale': 'ko_KR', 'strPgmCd': 'S030205'}
        headers = {'Content-Type': 'application/extJs+sua; charset=UTF-8'}
        payload = {
            "SNU": {
                "strSameSubstGrpFg": "",
                "rowStatus": "insert",
                "strDetaBussCd": "A0071",
                "strSchyy": "2016",
                "strShtmFg": "U000200002",
                "strDetaShtmFg": "U000300002",
                "strShtmDetaShtmFg": "U000200002U000300002",
                "strBdegrSystemFg": "U000100001",
                "strSbjtCd": "",
                "strSbjtNm": ""
            }
        }
        same_res = s.post(same_url, params=params, headers=headers, data=json.dumps(payload))
        same_courses = same_res.json()['GRD_COUR102']
        sames = [{'code': c['sbjtCd'], 'group': c['sameSubstGrpNo']} for c in same_courses]

        replaces = []
        group_by = {}
        for same in sames:
            if same['group'] in group_by:
                group_by[same['group']].append(same['code'])
            else:
                group_by[same['group']] = [same['code']]

        for _, v in group_by.items():
            num = len(v)
            for i in range(num):
                for j in range(i):
                    replaces.append({'from_code': v[i], 'to_code': v[j]})

        replace_res = s.post(replace_url, params=params, headers=headers, data=json.dumps(payload))
        replace_courses = replace_res.json()['GRD_COUR102']
        replaces.extend([{'from_code': c['sbjtCd'], 'to_code': c['substSbjtCd']} for c in replace_courses])
    return replaces
