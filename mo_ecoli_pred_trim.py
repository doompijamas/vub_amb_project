import csv
import pandas as pd

with open('mo_ecoli_pred.csv', 'r') as f:
    reader = csv.reader(f, delimiter="\t")
    pred = list(reader)

pred = pd.DataFrame(pred)
pred.columns = pred.iloc[0]
pred = pred[1:]
pred = pred[['SysName1', 'SysName2', 'bOp']]
pred['Pred'] = pred['bOp'].map({'TRUE': 1, 'FALSE': 0})
pred = pred.drop(['bOp'], axis=1)
pred.to_csv('mo_ecoli_pred_trim.csv', index=False)
