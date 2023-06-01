import sys
import csv
import configargparse
import pandas as pd
import numpy as np

def get_pred(row):
    try:
        prediction = pred[(pred['SysName1'] == row['SysName1']) & (pred['SysName2'] == row['SysName2'])]
        prediction = prediction.loc[:, 'Pred'].values[0]
    except:
        prediction = None
    return prediction

if __name__ == '__main__':
    p = configargparse.ArgParser()
    p.add('-c', required=True, help='coverage file',dest='cov')
    p.add('-o', required=True, help='output',dest='out')
    args=p.parse_args()

    with open(args.cov, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        cov = list(reader)

    cov = pd.DataFrame(cov, columns=['SysName1','SysName2','meanCov1','sdCov1','meanCov2','sdCov2','meanInt','sdInt','Distance','Strand1','Strand2','Length1','Length2','LengthInt','KWs','KWp','KWAIs','KWAIp','KWBIs','KWBIp','KWABs','KWABp'])

    with open('mo_ecoli_pred_trim.csv', 'r') as f:
        reader = csv.reader(f)
        pred = list(reader)

    pred = pd.DataFrame(pred)
    pred.columns = pred.iloc[0]
    pred = pred[1:]

    cov['pred'] = cov.apply(get_pred, axis=1)
    cov.loc[(cov['Strand1'] == cov['Strand2']), 'strandMatch'] = 1
    cov['strandMatch'] = cov['strandMatch'].fillna(0)

    cov['KWp'] = cov['KWp'].astype(float)
    cov['KWAIp'] = cov['KWAIp'].astype(float)
    cov['KWBIp'] = cov['KWBIp'].astype(float)
    cov['KWABp'] = cov['KWABp'].astype(float)

    # seen in the original code, it's beeing used for numerical stability assumed,
    # used because there is division by zero when calculating the log
    cov['KWp']+=1e-300
    cov['KWAIp']+=1e-300
    cov['KWBIp']+=1e-300
    cov['KWABp']+=1e-300

    cov['log_KWp'] = np.log(cov['KWp'].astype(float))
    cov['log_KWAIp'] = np.log(cov['KWAIp'].astype(float))
    cov['log_KWBIp'] = np.log(cov['KWBIp'].astype(float))
    cov['log_KWABp'] = np.log(cov['KWABp'].astype(float))

    cov = cov.dropna(subset=['pred'])

    cov.to_csv(args.out, index=False)
