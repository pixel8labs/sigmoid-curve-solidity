from brownie import accounts, BondingCurve, Sigmoid
import json
import numpy as np

def fibonacci_sequence(n):
    fib_seq = [0, 1]
    while len(fib_seq) < n:
        fib_seq.append(fib_seq[-1] + fib_seq[-2])
    return fib_seq[:n]

def deploy_basic_contract():
    account = accounts[0]
    Sigmoid.deploy({"from": account})
    bonding_curve = BondingCurve.deploy({"from": account})
    #f = fibonacci_sequence(100) #use fibo sequence for minting token amount
    #f = f[1:24] #skip the zero value
    decimals = bonding_curve.getDecimals()
    total_minted = 0 #previous mint amount
    y_values = []
    x_values = []
    # for m in list(range(1, 200)):
    #for m in np.linspace(1, 28657, 200).tolist():

    # Load first data set from file
    with open('sigmoid_data_int.json', 'r') as f:
        data = json.load(f)
    
    fiat_values = data['y']

    for f in fiat_values:
        bonding_curve.issueTokens(f)
        
        current_supply = bonding_curve.getTotalSupply()
        y_values.append(f/1000000.0)
        x_values.append(current_supply/decimals)
    
    # Save data to a file
    data = {'x': x_values, 'y': y_values}
    with open('data.json', 'w') as f:
        json.dump(data, f)

def main():
    deploy_basic_contract()
