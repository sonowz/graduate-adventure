import json
import getpass
import logging.config
from . import mysnu
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)


def crawl():
    userid = input('mySNU userid: ')
    password = getpass.getpass('mySNU password: ')
    session = mysnu.login(userid, password)
    if session is None:  # Fail to login
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
        same_courses = json.loads(same_res.text)['GRD_COUR102']
        same = [{'code': c['sbjtCd'], 'group': c['sameSubstGrpNo']} for c in same_courses]

        replace_res = s.post(replace_url, params=params, headers=headers, data=json.dumps(payload))
        replace_courses = json.loads(replace_res.text)['GRD_COUR102']
        replace = [{'code_from': c['sbjtCd'], 'code_to': c['substSbjtCd']} for c in replace_courses]
        return {'same': same, 'replace': replace}
