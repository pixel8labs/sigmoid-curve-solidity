import numpy as np
import json

# Define the sigmoid function
def sigmoid(x, a, b, k, Z):
    return b / (1 + a * np.exp(-k * x)) + Z

# Parameters
Z = 0.1
b = 95
k = 0.1
a = 100

# Generate x values from 0 to 167
x_values = np.linspace(0, 167, 168)
y_values = sigmoid(x_values, a, b, k, Z)

# Compute the cumulative values (integral) of the sigmoid curve
cumulative_values = np.cumsum(y_values)

# Convert to integer values (scale by 1e6 to keep precision, adjust as needed)
scale_factor = 1e6
y_values_int = (y_values * scale_factor).astype(int).tolist()
cumulative_values_int = (cumulative_values * scale_factor).astype(int).tolist()

# Save data to a JSON file
data = {'y': y_values_int, 'cumulative_y': cumulative_values_int}
with open('sigmoid_data_int.json', 'w') as f:
    json.dump(data, f)

print("Sigmoid integer data has been saved to sigmoid_data_int.json")
