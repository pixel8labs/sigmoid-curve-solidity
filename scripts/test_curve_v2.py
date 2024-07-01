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
    fiat_values = fibonacci_sequence(200) #use fibo sequence for minting token amount

    decimals = bonding_curve.getDecimals()
    total_minted = 0 #previous mint amount
    y_values = []
    x_values = []

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
