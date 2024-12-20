import numpy as np
import json

# Define the sigmoid function
def sigmoid(x, a, b, k, Z):
    return b / (1 + a * np.exp(-k * x)) + Z

def main():
    # Parameters
    Z = 0.1
    b = 6000
    k = 0.099
    a = 30000
    
    max_supply = 1000 #1000 KUM tokens
    # Generate x values from 0 to max_supply
    x_values = np.linspace(0, max_supply-1, max_supply)
    y_values = sigmoid(x_values, a, b, k, Z)

    # Compute the cumulative values (integral) of the sigmoid curve
    # y_values[0] = 0 #overwrite the first value
    cumulative_values = np.cumsum(y_values)

    # Convert to integer values (scale by 1e6 to keep precision, adjust as needed)
    scale_factor = 1e6
    x_values = np.linspace(0, max_supply-1, max_supply).astype(int).tolist()
    y_values_int = (y_values * scale_factor).astype(np.int64).tolist()
    cumulative_values_int = (cumulative_values * scale_factor).astype(np.int64).tolist()

    # Save data to a JSON file
    data = {'x':x_values, 'y': y_values_int, 'cumulative_y': cumulative_values_int}
    with open('sigmoid_data_int.json', 'w') as f:
        json.dump(data, f)

    print("Sigmoid integer data has been saved to sigmoid_data_int.json")

if __name__ == "__main__":
    main()