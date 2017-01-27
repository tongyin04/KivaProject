

import requests
import json
import unittest

# Code for function pretty and requestURL from SI506 lecture.
def pretty(obj):
    return json.dumps(obj, sort_keys=True, indent=2)


#Description - Text
#Status - (T)
#Number of Images - (K)
#Video
#Activity
#Sector - (T)
#Use - (K)
#Location - Country Code - (K)
#Posted Date - (T)
#Partner ID
#Funded Date - (T)
#Bonus Credit Eligibility
#Lender Count
#Loan Amount - (T)
#Repayment Interval
#Repayment Term - (K)
#Delinquency
#Number of Tags - (K)

Loan=[]
LoanDecp=[]
LoanNoImage=[]
LoanVorNot=[]
LoanSector=[]
LoanUse=[]
LoanCy=[]
LoanPostedDate=[]
LoanPartner=[]
LoanFundedDate=[]
LoanBonusCredit=[]
LoanLenderCounter=[]
LoanAmount=[]
LoanRepInterval=[]
LoanRepTerm=[]
LoanDelin=[]
LoanNTag=[]
LoanStatus=[]


for nn in range(1984)[:5]:
    dicOneLoan={}
    ifile=open(str(nn+1) +".json")
    print nn
    try:
        dic = json.loads(ifile.read())
        for n in dic["loans"]:
            Loan.append((n['id'],n['status'],n['sector'],n['posted_date'],n['funded_date'],n['loan_amount'],))#            LoanStatus.append(n['status'])
#            LoanSector.append(n['sector'])
#            LoanPostedDate.append(n['posted_date'])
#            LoanFundedDate.append(n['funded_date'])
#            LoanAmount.append(n['loan_amount'])
            
            
            
            
    except:
        pass
  #  for n in dic["loans"]:
#        dicOneLoan['id'] = n[id]

    ifile.close()
    
ofile=open("Loan.txt",'w')
for n in Loan:
    ofile.write(str(n).strip("(").strip(")").encode("UTF-8")+'\n')
ofile.close()
#
#print LoanStatus









