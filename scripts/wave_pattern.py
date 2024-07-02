import numpy as np
import matplotlib.pyplot as plt

# Parameters
num_points = 500
final_value = 175000

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

# Plotting the sequence and differentials
plt.figure(figsize=(14, 10))

plt.subplot(2, 1, 1)
plt.plot(price)
plt.title('Bullish Token Price Action with Corrective Waves')
plt.xlabel('Data Point')
plt.ylabel('Price')
plt.grid(True)

plt.subplot(2, 1, 2)
plt.plot(differentials, color='orange')
plt.title('Differentials')
plt.xlabel('Data Point')
plt.ylabel('Differential Value')
plt.grid(True)

plt.tight_layout()
plt.show()
