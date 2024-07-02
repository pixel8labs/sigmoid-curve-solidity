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
    fiat_values = fiat_values[1:]
    decimals = bonding_curve.getDecimals()
    total_minted = 0 #previous mint amount
    total_injected_fiat = 0
    y_values = []
    x_values = []

    for f in fiat_values:
        bonding_curve.issueTokens(f)
        total_injected_fiat += f
        current_supply = bonding_curve.getTotalSupply()
        
        x_values.append(total_injected_fiat)
        y_values.append(current_supply/decimals)
    
    # Save data to a file
    data = {'x': x_values, 'y': y_values}
    with open('test_data.json', 'w') as f:
        json.dump(data, f)

def main():
    deploy_basic_contract()
