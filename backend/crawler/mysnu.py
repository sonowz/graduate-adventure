import requests
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
