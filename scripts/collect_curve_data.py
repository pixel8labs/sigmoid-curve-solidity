from brownie import accounts, BondingCurve, Sigmoid
import json
import numpy as np

def fibonacci_sequence(n):
    fib_seq = [0, 1]
    while len(fib_seq) < n:
        fib_seq.append(fib_seq[-1] + fib_seq[-2])
    return fib_seq[1:n]

def generate_bullish_price_action(num_points, final_value):
    # Generate an upward trend with some corrective waves
    np.random.seed(42)
    corrections = np.random.randn(num_points) + 0.5
    price = np.cumsum(corrections)  # cumulative sum of corrections

    # Normalize the sequence to reach the final value
    price = price - price.min()  # shift to start at 0
    price = price / price.max() * final_value  # scale to reach final_value

    # Round the normalized price to integers
    price = np.round(price).astype(int)

    # Calculate differentials
    differentials = np.diff(price)
    return differentials

def deploy_basic_contract():
    account = accounts[0]
    Sigmoid.deploy({"from": account})
    bonding_curve = BondingCurve.deploy({"from": account})
    
    #fiat_values = fibonacci_sequence(200) #use fibo sequence for minting token amount
    data_points = 500
    max_fiat_value = 175000
    fiat_values = generate_bullish_price_action(data_points, max_fiat_value)  # Generate the wave pattern
    fiat_values = fiat_values * 1e6 #price is scaled by 10^6

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
    x_values = [int(x) for x in x_values]
    y_values = [int(y) for y in y_values]

    data = {'x': x_values, 'y': y_values}
    print(data)
    with open('test_data.json', 'w') as d:
        json.dump(data, d)

def main():
    deploy_basic_contract()
