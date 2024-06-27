import matplotlib.pyplot as plt
import json
import mplcursors

def plot_data():
    # Load first data set from file
    with open('base_fibo.json', 'r') as f:
        data1 = json.load(f)
    
    x_values1 = data1['x']
    y_values1 = data1['y']

    # Load second data set from file
    with open('fibo_data.json', 'r') as f:
        data2 = json.load(f)

    x_values2 = data2['x']
    y_values2 = data2['y']

    # Plot the data with grid
    fig, ax = plt.subplots()
    ax.plot(x_values1, y_values1, label='Dataset 1', marker='o')
    ax.plot(x_values2, y_values2, label='Dataset 2', marker='x')
    ax.set_xlabel('Supply of KUM Token')
    ax.set_ylabel('Price of KUM')
    ax.set_title('Comparison of Two Datasets')
    ax.grid(True)
    ax.legend()

    # Add interactive cursor
    cursor = mplcursors.cursor(ax, hover=True)
    @cursor.connect("add")
    def on_add(sel):
        sel.annotation.set(text=f'x: {sel.target[0]}, y: {sel.target[1]}')

    # Show the plot
    plt.show()

def main():
    plot_data()
