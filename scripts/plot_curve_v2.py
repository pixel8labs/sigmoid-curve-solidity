import matplotlib.pyplot as plt
import json
import mplcursors

def plot_data():
    # Load first data set from file
    with open('sigmoid_data_int.json', 'r') as f:
        data = json.load(f)
    
    x_values1 = data['cumulative_y']
    y_values1 = data['x']

    # Load second data set from file
    with open('test_data.json', 'r') as f:
        data2 = json.load(f)

    x_values2 = data2['x']
    y_values2 = data2['y']

    # Plot the data with grid
    fig, ax = plt.subplots()
    ax.plot(x_values1, y_values1, label='Dataset 1', marker='o')
    ax.plot(x_values2, y_values2, label='Dataset 2', marker='x')
    ax.set_xlabel('Fiat values injected (Dollar)')
    ax.set_ylabel('KUM Total Supply/Minted')
    ax.set_title('Comparison of Two Datasets')
    ax.grid(True)
    ax.legend()

    # Set plot range based on x_values1 * 2 and y_values1 * 2
    ax.set_xlim(0, max(x_values1) * 2)
    ax.set_ylim(0, max(y_values1) * 2)

    # Add interactive cursor
    cursor = mplcursors.cursor(ax, hover=True)
    @cursor.connect("add")
    def on_add(sel):
        sel.annotation.set(text=f'x: {sel.target[0]}, y: {sel.target[1]}')

    # Show the plot
    plt.show()

def main():
    plot_data()

if __name__ == "__main__":
    main()
