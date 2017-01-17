import mechanicalsoup
import logging
import os


os.makedirs(os.getcwd() + '/log', exist_ok=True)
logging.basicConfig(filename=os.getcwd() + '/log/crawler.log', level=logging.INFO)


def crawl_credit(username, password):
    br = mechanicalsoup.Browser()
    login_page = br.get('http://my.snu.ac.kr/mysnu/portal/MS010/MAIN')
    login_page.raise_for_status()
    login_form = login_page.soup.select('#LoginForm')[0]
    login_form.select('#si_id')[0]['value'] = username
    login_form.select('#si_pwd')[0]['value'] = password
    redirect_page = br.submit(login_form, login_page.url)
    try:
        redirect_form = redirect_page.soup.select('form')[0]
    except IndexError:
        logging.error('Invalid account information. Could not login')
        return []
    br.submit(redirect_form, 'http://sso.snu.ac.kr/nls3/fcs')
    br.get('https://shine.snu.ac.kr/com/ssoLoginForSWAction.action')
    headers = {
        'Host': 'shine.snu.ac.kr',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Origin': 'https://shine.snu.ac.kr',
        'X-Requested-With': 'XMLHttpRequest',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64)'
                      ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36',
        'Content-Type': 'application/extJs+sua; charset=UTF-8',
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4',
    }
    grade_response = br.post('https://shine.snu.ac.kr/uni/uni/scor/mrtr/findTabCumlMrksYyShtmClsfTtInq02.action',
                             params={'cscLocale': 'ko_KR', 'strPgmCd': 'S030302'},
                             headers=headers,
                             json={"SUN": {"strSchyy": "2015", "strShtmFg": "U000200001",
                                           "strDetaShtmFg": "U000300001", "strBdegrSystemFg": "U000100001",
                                           "strFlag": "all"}}
                             )
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
