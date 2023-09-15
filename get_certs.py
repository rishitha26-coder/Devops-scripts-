#!/usr/local/bin/python3
import sys,getopt

import boto3
import texttable
from openpyxl import Workbook
from openpyxl.styles import NamedStyle

wb = Workbook()
sheet = wb.active 

org = 'mogo'
moka_accounts = {
    'mogo-ca-dev': 'moka-mogotrade-dev',
    'moka-bi': 'moka-bi',
    'moka-ca-dev': 'moka-ca-dev',
    'moka-ca-production': 'moka-ca-production',
    'moka-ca-qa': 'moka-ca-qa',
    'moka-ca-staging': 'moka-ca-staging',
    'moka-fr-production': 'moka-fr-production',
    'moka-fr-qa': 'moka-fr-qa',
    'moka-fr-staging': 'moka-fr-staging',
    'moka-identity': 'moka-identity',
    'moka-master': 'moka-master',
    'moka-local': 'moka-local',
    'moka-logging': 'moka-logging',
    'moka-sandbox-dramier': 'moka-sandbox-dramier',
    'moka-sandbox-jdupre' : 'moka-sandbox-jdupre',
    'moka-sandbox-vveysset': 'moka-sandbox-vveysset',
    'moka-security': 'moka-security',
    'moka-shared': 'moka-shared'
}

mogo_accounts = {
    'mogo-cre': 'mogo-cre',
    'mogo-devops': 'mogo-devops',
    'qjtrader-nonprod': 'qjtrader-nonprod', 
    'mogo-test': 'mogo-dev', 
    'mogo-sec': 'mogo-sec', 
    'mogo-soa-staging': 'mogo-soa-staging', 
    'mogo-vpn': 'mogo-vpn', 
    'mogo-soa-qa': 'mogo-soa-qa', 
    'mogo-soa-nonprod': 'mogo-soa-nonprod', 
    'mogo-soa-prod': 'mogo-soa-prod', 
    'mogo-primary': 'mogo',
    'mogo-keyspaces': 'mogo-keyspaces', 
    'mogo-eks': 'mogo-eks',
    'mogo-audit': 'mogo-audit',
    'mogo-logs': 'mogo-logs',
    'qjtrader-prod': 'qjtrader-prod', 
}

# all acm regions possible
regions = [
    "us-east-2",
    "us-east-1",
    "us-west-1",
    "us-west-2",
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-northeast-3",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ca-central-1",
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "sa-east-1"
]


def get_for_account(profile_name, region):
    print("Fetching data for "+ profile_name+" in region "+region)
    _session = boto3.Session(region_name=region, profile_name=profile_name)
    try:
        resp = _session.client('acm').list_certificates(
            CertificateStatuses=[
                'PENDING_VALIDATION', 'ISSUED', 'INACTIVE', 'EXPIRED', 'VALIDATION_TIMED_OUT', 'REVOKED', 'FAILED'
            ],
            MaxItems=500)
        certs = resp.get('CertificateSummaryList')
    except:
        return None,_session
    return certs, _session

def get_cert_info(session,arn):
    resp = session.client('acm').describe_certificate(CertificateArn=arn)
    return resp.get('Certificate')
    

def main(argv):
    try:
        opts, args = getopt.getopt(argv,"ho:",["organization="])
    except getopt.GetoptError:
      print ('./get_certs.py -o <organization>')
      sys.exit(2)
    for opt, arg in opts:
      if opt == '-h':
         print ('./get_certs.py -o <organization>')
         print("organization accepts [moka] or [mogo]")
         sys.exit()
      elif opt in ("-o", "--organization"):
         org = arg
    denied_by_policy = []
    column_rows = []
    accounts = mogo_accounts
    if org == "moka":
        accounts = moka_accounts
    for env, profile in accounts.items():
        for region in regions:
            resp,session = get_for_account(profile, region)
            if resp:
                resp = [cert for cert in resp if cert]
                if resp:
                    for cert_info in resp:
                        cert_details = get_cert_info(session,cert_info.get('CertificateArn'))
                        used_by = ''
                        emails = ''
                        expiry_date = ''
                        if cert_details.get('NotAfter'):
                            expiry_date = cert_details.get('NotAfter').strftime("%m/%d/%Y")
                        if cert_details.get('InUseBy') and len(cert_details.get('InUseBy')) > 0:
                                used_by = ','.join(cert_details.get('InUseBy'))
                        if cert_details['DomainValidationOptions'][0].get('ValidationEmails') and len(cert_details['DomainValidationOptions'][0].get('ValidationEmails')) > 0:
                                emails = ','.join(cert_details['DomainValidationOptions'][0].get('ValidationEmails'))
                        column_rows.append([env, region, cert_info.get('CertificateArn'),cert_info.get('DomainName'),cert_details.get('Type'),cert_details['DomainValidationOptions'][0].get('ValidationMethod'),cert_details.get('DomainValidationOptions')[0].get('ValidationStatus'),used_by,expiry_date,cert_details.get('RenewalEligibility'),emails])
            else:
                denied_by_policy.append({
                    'region': region,
                    'profile': profile
                })

    # format and print table
    table = texttable.Texttable( max_width=0)
    headers = ['Profile', 'Region', "ARN","DomainName","Type","ValidationMethod","ValidationStatus","UsedBy","Expiry","RenewalEligibility","ValidationEmails"]
    table.header(headers)
    table.add_rows(rows=column_rows, header=False)
    table.set_cols_align(['c' for name in headers])
    print(table.draw())
    sheet.append(headers)
    for row in column_rows:
        print(row)
        sheet.append(row)
    date_style = NamedStyle(name='datetime', number_format='DD/MM/YYYY')
    for row in sheet[2:sheet.max_row]:  # skip the header
        cell = row[8]             # column I
        cell.style = date_style
    filename_val = "acms-" + org +".xlsx"
    wb.save(filename=filename_val)

if __name__ == '__main__':
    main(sys.argv[1:])