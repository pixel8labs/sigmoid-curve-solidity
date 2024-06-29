from brownie import accounts, BondingCurve
import json
import numpy as np

def fibonacci_sequence(n):
    fib_seq = [0, 1]
    while len(fib_seq) < n:
        fib_seq.append(fib_seq[-1] + fib_seq[-2])
    return fib_seq[:n]

def deploy_basic_contract(inflection_point, inflection_price):
    account = accounts[0]
    bonding_curve = BondingCurve.deploy(inflection_point, inflection_price,{"from": account})

    f = fibonacci_sequence(100) #use fibo sequence for minting token amount
    f = f[1:24] #skip the zero value
    
    total_minted = 0 #previous mint amount
    y_values = []
    x_values = []
    # for m in list(range(1, 200)):
    #for m in np.linspace(1, 28657, 200).tolist():
    for m in f:
        bonding_curve.mint(m)
        total_price = bonding_curve.getPrice()
        avg_price =  total_price / m
        price_index = total_minted + (total_minted + m) / 2
        y_values.append(avg_price)
        x_values.append(price_index)
        total_minted += m
    
    # Save data to a file
    data = {'x': x_values, 'y': y_values}
    with open('base_fibo.json', 'w') as f:
        json.dump(data, f)

def main():
    inflection_point = 50       #int(input("Enter the inflection point: "))
    inflection_price = 10000000 #int(input("Enter the inflection price: "))
    deploy_basic_contract(inflection_point, inflection_price)
