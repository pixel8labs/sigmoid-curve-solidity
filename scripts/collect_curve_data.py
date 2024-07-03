from brownie import accounts, BondingCurve, Sigmoid
import json
import numpy as np

def fibonacci_sequence(n):
    fib_seq = [0, 1]
    while len(fib_seq) < n:
        fib_seq.append(fib_seq[-1] + fib_seq[-2])
    return fib_seq[1:n]

def deploy_basic_contract():
    account = accounts[0]
    Sigmoid.deploy({"from": account})
    bonding_curve = BondingCurve.deploy({"from": account})
    
    # Load first data set from file
    with open('fiat_value.json', 'r') as f:
        data = json.load(f)
    
    fiat_values = [x * 1e6 for x in data['fiat_values']]  # Scale up by 10^6
    #fiat_values = fibonacci_sequence(200) #use fibo sequence for minting token amount

    total_injected_fiat = 0
    decimals = bonding_curve.getDecimals()
    y_values = []
    x_values = []

    for f in fiat_values:
        amount = abs(f)
        total_injected_fiat += f
        print("Total injected fiat = ", total_injected_fiat/1e6, "f = ", f/1e6, "supply = ",bonding_curve.getTotalSupply()/decimals)
        if f > 0: #positive values = mint
            bonding_curve.issueTokens(amount)
        elif f < 0: #negative values = burn
            bonding_curve.redeemTokens(amount)
        else: # skip zero value
            continue
        current_supply = bonding_curve.getTotalSupply()
        x_values.append(total_injected_fiat)
        y_values.append(current_supply / decimals)
    
    # Save data to a file

    # Convert to native Python types
    x_values = [float(x) for x in x_values]
    y_values = [float(y) for y in y_values]

    data = {'x': x_values, 'y': y_values}
    with open('test_data.json', 'w') as d:
        json.dump(data, d)

def main():
    deploy_basic_contract()
