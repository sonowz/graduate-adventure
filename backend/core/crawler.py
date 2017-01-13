import mechanicalsoup


def crawl_course(username, password):
    br = mechanicalsoup.Browser()
    login_page = br.get('http://my.snu.ac.kr/mysnu/portal/MS010/MAIN')
    login_form = login_page.soup.select('#LoginForm')[0]
    login_form.select('#si_id')[0]['value'] = username
    login_form.select('#si_pwd')[0]['value'] = password
    redirect_page = br.submit(login_form, login_page.url)
    redirect_form = redirect_page.soup.select('form')[0]
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
    grade_list = br.post('https://shine.snu.ac.kr/uni/uni/scor/mrtr/findTabCumlMrksYyShtmClsfTtInq02.action',
                         params={'cscLocale': 'ko_KR', 'strPgmCd': 'S030302'},
                         headers=headers,
                         json={"SUN": {"strSchyy": "2015", "strShtmFg": "U000200001",
                                       "strDetaShtmFg": "U000300001", "strBdegrSystemFg": "U000100001",
                                       "strFlag": "all"}}
                         ).json()['GRD_SCOR401']

    semester_serial = {
        '1학기': '1',
        '2학기': '2',
        '여름학기': 'S',
        '겨울학기': 'W',
    }

    for i, item in enumerate(grade_list):
        item['shtmDetaShtm'] = semester_serial[item['shtmDetaShtm']]
        grade_list[i] = item

    rename_list = {
        'schyy': 'year',
        'shtmDetaShtm': 'semester',
        'sbjtNm': 'title',
        'sbjtCd': 'subject_code',
        'ltNo': 'lecture_no',
        'acqPnt': 'credit',
        'mrksGrdCd': 'grade',
        'cptnSubmattFgCdNm': 'category',
    }

    new_grade_list = []

    for item in grade_list:
        processed_item = {rename_list[x]: item[x] for x in rename_list.keys()}
        new_grade_list.append(processed_item)

    return new_grade_list
