import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sklearn.metrics as skmetric
import pdb

f1 = "unfunded_prob.csv"
f2 = "ytest.csv"
df_unfunded_prob = pd.read_csv(f1)
unfunded_prob = np.array(df_unfunded_prob).flatten()
df_y_test = pd.read_csv(f2)
y_test = np.array(df_y_test).flatten()
# pdb.set_trace()
fpr, tpr, thresholds = skmetric.roc_curve(y_test, unfunded_prob,)
plt.plot(fpr, tpr, 'k-o')
plt.ylim(0,1.05)
plt.yticks(np.arange(0,1.05,0.2))
plt.title('ROC Curve')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.show()

auc = skmetric.roc_auc_score(y_true=y_test==1, y_score=unfunded_prob,)
print("Area Under the Curve: ", auc)