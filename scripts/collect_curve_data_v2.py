from brownie import accounts, BondingCurveV2, SigmoidV2
import json
import matplotlib.pyplot as plt

def fetch_sigmoid_values(contract):
    y_values = []
    x_values = []
    num_values = 168  # Adjust as needed (total number of sigmoid values)

    # Retrieve sigmoid values from the contract
    for i in range(num_values):
        value = contract.getSigmoidValue(i)
        x_values.append(i)
        y_values.append(value)

    # Save data to a file
    data = {'x': x_values, 'y': y_values}
    with open('sigmoid_v2.json', 'w') as f:
        json.dump(data, f)

def deploy_and_save():
    # Connect to Brownie and deploy contract
    account = accounts[0]
    # Deploy the SigmoidV2 library
    sigmoidv2 = SigmoidV2.deploy({"from": account})
    contract = BondingCurveV2.deploy({"from": account})
    print(f"Contract deployed at address: {contract.address}")

    # Fetch and save sigmoid values
    sigmoid_values = fetch_sigmoid_values(contract)

def main():
    inflection_point = 1500   # Example inflection point
    inflection_price = 102500000000000000   # Example inflection price
    deploy_and_save()

