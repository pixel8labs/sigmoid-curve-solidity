import matplotlib.pyplot as plt
import json

def plot_data():
    # Load data from file
    with open('data.json', 'r') as f:
        data = json.load(f)
    
    x_values = data['x']
    y_values = data['y']

    # Plot the data
    plt.plot(x_values, y_values)
    plt.xlabel('x')
    plt.ylabel('Sigmoid(x)')
    plt.title('Sigmoid Curve')
    plt.show()

def main():
    plot_data()