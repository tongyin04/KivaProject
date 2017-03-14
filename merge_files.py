import json
import pdb
import csv

headings = ['id', 'status', 'sector', 'posted_date', 'funded_date', 'loan_amount', 'partner_id', 'bonus_credit_eligibility', 
			'lender_count', 'activity', 'use', 'repayment_term', 'repayment_interval', 'num_tags', 'num_images', 'video_present', 'country_code', 
			'description']
direct_keys = ['id', 'status', 'sector', 'posted_date', 'funded_date', 'loan_amount', 'partner_id', 
				'bonus_credit_eligibility', 'lender_count', 'activity', 'use']
posts_data = [headings]
loan_count = 0

for file_num in range(1,1985):
	filename = "loans/" + str(file_num) + ".json"
	with open(filename) as f:
		print(file_num)
		# check if file exists
		try:
			data = json.load(f)
		except:
			pass
		for loan in data['loans']:
			loan_count += 1
			post_details = []
			for key in direct_keys:
				post_details.append(loan[key])
			repayment_term = loan['terms']['repayment_term']
			repayment_interval = loan['terms']['repayment_interval']
			num_tags = len(loan['tags'])
			num_images = loan['image']['id']
			video_present = False
			if 'video' in loan and loan['video']!=None:
				video_present = True
			country_code = loan['location']['country_code']
			desc = ''
			try:
				desc = loan['description']['texts']['en']
			except:
				pass
			post_details.extend((repayment_term, repayment_interval, num_tags, num_images, video_present, country_code, desc))
			posts_data.append(post_details)

print("Loan Count:", loan_count)
with open("loans_test.csv", "w", newline='', encoding='utf-8') as csvfile:
	csvwriter = csv.writer(csvfile)
	csvwriter.writerows(posts_data)
