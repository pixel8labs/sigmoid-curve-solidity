import matplotlib.pyplot as plt
import json
import mplcursors

def plot_data():
    # Load first data set from file
    with open('sigmoid_v2.json', 'r') as f:
        data = json.load(f)
    
    x_values = data['x']
    y_values = data['y']

    # Plot the data with grid
    fig, ax = plt.subplots()
    ax.plot(x_values, y_values, marker='x')
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
