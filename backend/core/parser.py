# <mySNU encoding representation> : <real encoding>
# - ANSI : euc-kr
# - unicode : utf-16_le


def parse_credit(text):
    semester_name = {
        'U000200001U000300001': '1',
        'U000200001U000300002': 'S',
        'U000200002U000300001': '2',
        'U000200002U000300002': 'W',
    }
    lines = text.split('\n')[:-1]
    columns = []
    infos = []
    for line in lines:
        line = line.split('\t')
        if len(columns) != len(line):
            columns = line
            continue
        dic = to_dict(columns, line)

        # 26 : course taking info
        # 13 : semester info
        # 9 : total info
        if 'SBJT_CD' in dic:
            taking_info = {
                'year': int(dic['SCHYY']),
                'semester': semester_name[dic['SHTM_FG'] + dic['DETA_SHTM_FG']],
                'code': dic['SBJT_CD'],
                'number': dic['LT_NO'],
                'title': dic['SBJT_NM'],
                'credit': int(dic['ACQ_PNT']),
                'grade': dic['MRKS_GRD_CD'],
                'category': dic['CPTN_SUBMATT_FG_CD_NM']
            }
            infos.append(taking_info)
    return infos


def to_dict(columns, row):
    assert len(columns) == len(row)
    dic = {}
    for column, content in zip(columns, row):
        dic[column] = content
    return dic
