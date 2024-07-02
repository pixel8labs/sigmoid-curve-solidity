import numpy as np
import matplotlib.pyplot as plt
import json

def generate_bullish_wave_data(num_points,final_value):
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
    fiat_value = np.diff(price)

    # Plotting the sequence and differentials
    plt.figure(figsize=(14, 10))

    plt.subplot(2, 1, 1)
    plt.plot(price)
    plt.title('Bullish Token Price Action with Corrective Waves')
    plt.xlabel('Data Point')
    plt.ylabel('Total injected fiat/dollar values')
    plt.grid(True)

    plt.subplot(2, 1, 2)
    plt.plot(fiat_value, color='orange')
    plt.title('Fiat values injected (Burn / Mint)')
    plt.xlabel('Data Point')
    plt.ylabel('Fiat value')
    plt.grid(True)

    plt.tight_layout()
    plt.show()

    # Save data to a JSON file
    fiat_value = [int(x) for x in fiat_value]
    data = {'fiat_values':fiat_value}
    with open('fiat_value.json', 'w') as f:
        json.dump(data, f)

    print("Sigmoid integer data has been saved to sigmoid_data_int.json")

def main():
    # Parameters
    num_points = 500
    final_value = 175000

    generate_bullish_wave_data(num_points,final_value)
