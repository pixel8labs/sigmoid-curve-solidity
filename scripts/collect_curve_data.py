from brownie import accounts, BondingCurve
import json

def deploy_basic_contract(inflection_point, inflection_price):
    account = accounts[0]
    bonding_curve = BondingCurve.deploy(inflection_point, inflection_price,{"from": account})

    bonding_curve.mint(1)
    # Generate data for plotting
    x_values = list(range(1, 200))
    y_values = []
    for x in x_values:
        bonding_curve.mint(1)
        price = bonding_curve.getPrice()
        y_values.append(price)
    
    # Save data to a file
    data = {'x': x_values, 'y': y_values}
    with open('data.json', 'w') as f:
        json.dump(data, f)

def main():
    inflection_point = int(input("Enter the inflection point: "))
    inflection_price = int(input("Enter the inflection price: "))
    deploy_basic_contract(inflection_point, inflection_price)
