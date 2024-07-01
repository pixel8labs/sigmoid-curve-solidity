import matplotlib.pyplot as plt
import json
import mplcursors

def plot_data():
    # Load first data set from file

    #with open('sigmoid_data_int.json', 'r') as f:
    with open('sigmoid_data_int.json', 'r') as f:
        data = json.load(f)
    
    x_values = data['cumulative_y']
    y_values = data['x']

    # Plot the data with grid
    fig, ax = plt.subplots()
    ax.plot(x_values, y_values, marker='x')
    ax.set_xlabel('Fiat values injected')
    ax.set_ylabel('Token Supply')
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
