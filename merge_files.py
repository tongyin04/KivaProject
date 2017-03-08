import json
import pdb
import csv

headings = ['id', 'status', 'sector', 'posted_date', 'funded_date', 'loan_amount', 'partner_id', 'bonus_credit_eligibility', 
			'lender_count', 'repayment_term', 'repayment_interval', 'num_tags', 'num_images', 'video_present', 'country_code']
direct_keys = ['id', 'status', 'sector', 'posted_date', 'funded_date', 'loan_amount', 'partner_id', 'bonus_credit_eligibility', 'lender_count']
posts_data = [headings]

for file_num in range(1,1949):
	filename = "loans/" + str(file_num) + ".json"
	with open(filename) as f:
		print(file_num)
		try:
			data = json.load(f)
		except:
			pass
		# print(type(data['loans']))
		for loan in data['loans']:
			post_details = []
			for key in direct_keys:
				post_details.append(loan[key])
			repayment_term = loan['terms']['repayment_term']
			repayment_interval = loan['terms']['repayment_interval']
			num_tags = len(loan['tags'])
			num_images = 0
			if 'image' in loan:
				num_images = len(loan['image'])/2
			video_present = False
			if 'video' in loan and loan['video']!=None:
				video_present = True
			# pdb.set_trace()
			desc = ''
			# if 'en' in loan['description']['languages'].values():
			try:
				desc = loan['description']['texts']['en']
			except:
				pass
			country_code = loan['location']['country_code']
			post_details.extend((repayment_term, repayment_interval, num_tags, num_images, video_present, country_code))
			posts_data.append(post_details)

with open("loans_test.csv", "w", newline='') as csvfile:
	csvwriter = csv.writer(csvfile)
	csvwriter.writerows(posts_data)
