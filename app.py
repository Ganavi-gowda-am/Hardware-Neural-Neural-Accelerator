from flask import Flask, render_template, send_file
import os 
from dashboard_plot import generate_plot_and_get_summary

app = Flask(__name__)

@app.route('/')
def index():
    # 1. Regenerate the plot image and get the calculation summary
    try:
        plot_image_path, summary_html = generate_plot_and_get_summary()
    except Exception as e:
        # Handle cases where CSV is missing or plotting fails
        error_msg = f"Error generating plot: {e}"
        print(error_msg)
        return render_template('index.html', plot_generated=False, error_msg=error_msg)

    # 2. Render the HTML template
    return render_template('index.html', 
                           plot_generated=True,
                           summary_html=summary_html)

@app.route('/plot')
def plot_image():
    # Serve the generated plot image
    return send_file(os.path.join(os.getcwd(), 'neural_accelerator_waveform.png'), mimetype='image/png')

if __name__ == '__main__':
    # Initial plot generation check 
    print("Starting Plot Generation...")
    try:
        generate_plot_and_get_summary() 
    except Exception as e:
        print(f"Initial plot generation failed: {e}. Starting server anyway.")
        
    app.run(debug=True)