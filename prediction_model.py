import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sklearn.linear_model as sklm
import sklearn.preprocessing as skp
import sklearn.metrics as skmetric
from imblearn.over_sampling import RandomOverSampler 
import pdb

def train_lr(X_train, y_train):
	print("-----------Training--------------")
	model = sklm.LogisticRegression()
	model.fit(X_train, y_train)
	return model

def predict_lr(model, X_test, y_test):
	print("-----------Predicting--------------")
	pred = model.predict(X_test)
	probs = model.predict_proba(X_test)
	unfunded_prob = probs[:, 1]
	return pred, unfunded_prob

def get_auc_score(y, unfunded_prob):
	print("-----------Evaluating--------------")
	fpr, tpr, thresholds = skmetric.roc_curve(y, unfunded_prob,)
	plt.plot(fpr, tpr, 'k-o')
	plt.ylim(0,1.05)
	plt.yticks(np.arange(0,1.05,0.2))
	plt.title('ROC Curve')
	plt.xlabel('False Positive Rate')
	plt.ylabel('True Positive Rate')
	# plt.show()
	auc_score = skmetric.roc_auc_score(y_true=y==1, y_score=unfunded_prob,)
	return auc_score

def main():
	predictors = ['lgAmount', 'repayment_term', 'repayment_interval', 'description_length', 'use_length','sector', 'video_present', 
	'num_tags', 'sim_desc_classMotivation1', 'sim_desc_classMotivation2', 'sim_desc_classMotivation3', 
	'sim_desc_classMotivation4', 'sim_desc_classMotivation5', 'sim_desc_classMotivation6', 'sim_desc_classMotivation7', 
	'sim_desc_classMotivation8', 'sim_desc_classMotivation9', 'sim_desc_classMotivation10', 'funded_or_not']
	#'sim_use_classMotivation1', 'sim_use_classMotivation2', 'sim_use_classMotivation3', 'sim_use_classMotivation4', 
	#'sim_use_classMotivation5', 'sim_use_classMotivation6', 'sim_use_classMotivation7', 'sim_use_classMotivation8', 
	#'sim_use_classMotivation9', 'sim_use_classMotivation10', 'funded_or_not']

	print("-----------Reading the data--------------")
	# get the training set
	df_train_all = pd.read_csv('AllTrain.csv', encoding='cp1252')
	df_train = df_train_all[predictors].dropna()
	df_funded = df_train[df_train.funded_or_not==0]
	df_unfunded = df_train[df_train.funded_or_not==1]
	df = df_train
	df_funded_sample = df_funded.sample(frac=0.2)
	df = df_funded_sample.append(df_unfunded)
	X_train = df[predictors[:-1]]
	X_train = pd.get_dummies(X_train)
	pdb.set_trace()
	y_train = df[predictors[-1]]
	ros = RandomOverSampler(random_state=42)
	X_train, y_train= ros.fit_sample(X_train, y_train)
	pdb.set_trace()

	# get the validation set
	df_test_all = pd.read_csv('AllValidation.csv', encoding='cp1252')
	df_test = df_test_all[predictors].dropna()
	X_test = df_test[predictors[:-1]]
	X_test = pd.get_dummies(X_test)
	y_test = df_test[predictors[-1]]
	y_list = y_test.tolist()
	n_test = len(y_list)

	# get the results and evaluation
	beta = 2
	model = train_lr(X_train, y_train)
	pred, unfunded_prob = predict_lr(model, X_test, y_test)
	auc_score = get_auc_score(y_test, unfunded_prob)
	print('Predictors: ', predictors)
	print('AUC Score: ', auc_score)
	tp = len([x for x in range(n_test) if pred[x]==1 and y_list[x]==1])
	tn = len([x for x in range(n_test) if pred[x]==0 and y_list[x]==0])
	fp = len([x for x in range(n_test) if pred[x]==1 and y_list[x]==0])
	fn = len([x for x in range(n_test) if pred[x]==0 and y_list[x]==1])
	precision = tp/(tp+fp)
	recall = tp/(tp+fn)
	f1 = 2*precision*recall/(precision+recall)
	f1_beta = (1+beta*beta) * (precision*recall) / (beta*beta*precision + recall)
	print("True Positive: ", tp)
	print("False Positive: ", fp)
	print("True Negative: ", tn)
	print("False Negative: ", fn)
	print("Precision: ", precision)
	print("Recall: ", recall)
	print("F1 Score: ", f1)
	print("F1 Beta Score: ", f1_beta)
	pdb.set_trace()

main()