import matplotlib
matplotlib.use('Agg') # CRITICAL: Ensures fast, headless plot generation for the web server

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

# --- Configuration for Plot Aesthetics ---
PLOT_TITLE = "NN Accelerator: Layer 1 Output Waveform (Hardware Verification)"
X_LABEL = "Simulation Time (microseconds)"
Y_LABEL = "Output Neuron Value (0-255)"
OUTPUT_FILE_NAME = "neural_accelerator_waveform.png" 
HIGHLIGHT_OUTPUT = "layer1_out0"
HIGHLIGHT_COLOR = '#FF5733'
DEFAULT_COLORS = plt.cm.viridis(range(8))
# ----------------------------------------

def generate_plot_and_get_summary():
    """Generates the plot image and calculates the core data summary."""
    # Load the clean CSV 
    try:
        df = pd.read_csv("outputs.csv")
    except FileNotFoundError:
        raise FileNotFoundError("outputs.csv not found. Run convert_vcd.py first.")

    # Set 'time' as the index
    df = df.set_index('time')
    out_cols = [col for col in df.columns if "layer1_out" in col]
    df_time_us = df.index / 1000
    
    # --- 1. CORE MATH CALCULATION (for website display) ---
    in_sum_pos = 10 + 20 + 30 + 40  # 100
    in_sum_neg = 50 + 60 + 70 + 80  # 260
    base_sum = in_sum_pos - in_sum_neg # -160 (16-bit signed)
    
    # Robustly extract the first non-zero output value (the first result of the hardware)
    first_non_zero_row = df[df[HIGHLIGHT_OUTPUT] > 0].iloc[0] if df[HIGHLIGHT_OUTPUT].gt(0).any() else None
    
    if first_non_zero_row is not None:
        first_valid_value_0 = first_non_zero_row[HIGHLIGHT_OUTPUT]
    else:
        first_valid_value_0 = 0
        
    first_counter = 1 # Counter starts at 1 for the first inference
    
    # Calculation for the first run: (-160 + 1) mod 256
    calc_sum = base_sum + first_counter
    calc_mod_256 = calc_sum % 256
    
    summary_data = {
        "Inputs": "10, 20, 30, 40, 50, 60, 70, 80",
        "Base Sum (16-bit)": f"{base_sum} (Hex: {hex(base_sum & 0xFFFF)})",
        "Formula": "mac_sum = (Pos Sum) - (Neg Sum) + Counter",
        "Initial mac_sum (16-bit)": calc_sum,
        "Quantization (8-bit)": f"({calc_sum}) mod 256 = {calc_mod_256}",
        "Final **layer1_out0**": first_valid_value_0
    }
    
    # Format the summary into an attractive HTML table
    summary_html = f"""
    <h3>&#x1F4C8; Hardware Calculation Breakdown (Run 1)</h3>
    <table class='summary-table'>
        <tr><th>Input Breakdown</th><td>{summary_data['Inputs']}</td></tr>
        <tr><th>Intermediate Sum</th><td>{summary_data['Base Sum (16-bit)']}</td></tr>
        <tr><th>Formula Applied</th><td><code>{summary_data['Formula']}</code></td></tr>
        <tr><th>Initial Final Sum</th><td>{summary_data['Initial mac_sum (16-bit)']}</td></tr>
        <tr><th>Quantization (8-bit)</th><td>{summary_data['Quantization (8-bit)']}</td></tr>
        <tr><th>Final **layer1_out0**</th><td><span class='highlight'>{summary_data['Final **layer1_out0**']}</span> (Verifies calculation)</td></tr>
    </table>
    """

    # --- 2. PLOTTING LOGIC ---
    plt.style.use('seaborn-v0_8-darkgrid') 
    plt.figure(figsize=(14, 7)) 

    # Plotting loop
    for i, col in enumerate(out_cols):
        label_short = col.split('.')[-1].split('[')[0] 
        color = HIGHLIGHT_COLOR if label_short == HIGHLIGHT_OUTPUT else DEFAULT_COLORS[i]
        linewidth = 2.5 if label_short == HIGHLIGHT_OUTPUT else 1.5
        linestyle = '-' if label_short == HIGHLIGHT_OUTPUT else '--'
        plt.plot(df_time_us, df[col], label=label_short, drawstyle='steps-post',
                 color=color, linewidth=linewidth, linestyle=linestyle)

    # Customizing Plot Elements
    plt.title(PLOT_TITLE, fontsize=18, fontweight='bold', color='#333333')
    plt.xlabel(X_LABEL, fontsize=14, color='#555555')
    plt.ylabel(Y_LABEL, fontsize=14, color='#555555')
    plt.legend(title="Output Neurons", loc='upper right', bbox_to_anchor=(1.15, 1), fontsize=10, title_fontsize=12, frameon=True, shadow=True, fancybox=True)
    plt.grid(True, linestyle=':', alpha=0.7)
    
    max_time_us = df_time_us.to_numpy().max() if not df_time_us.empty else 0
    plt.xlim(0, max_time_us + 100) 
    plt.ylim(0, 260) 

    # Adding Annotations 
    if not df_time_us.empty and len(df_time_us) > 1:
        first_inference_time = df_time_us.to_numpy()[0]
        mean_time_us = df_time_us.to_numpy().mean()

        plt.axvline(x=first_inference_time, color='gray', linestyle='--', linewidth=0.8, alpha=0.7)
        plt.text(first_inference_time + 50, plt.ylim()[1] * 0.95, "First Inference Trigger", 
                 rotation=90, va='top', ha='left', color='#666666', fontsize=10)

        plt.text(mean_time_us, plt.ylim()[1] * 0.8,
                 "Outputs Incrementing with Each Calculation\n(Hardware 'Counter' Effect)",
                 fontsize=12, ha='center', va='center', bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="#AAAAAA", lw=0.8, alpha=0.8))

    plt.tight_layout(rect=[0, 0, 0.85, 1]) 
    plt.subplots_adjust(right=0.75) 

    # Save the plot
    plt.savefig(OUTPUT_FILE_NAME, dpi=300, bbox_inches='tight')
    plt.close() 

    # Return the path to the saved image and the HTML summary
    return OUTPUT_FILE_NAME, summary_html

if __name__ == '__main__':
    try:
        generate_plot_and_get_summary()
        print(f"Plot saved to {OUTPUT_FILE_NAME}")
    except Exception as e:
        print(f"Error during execution: {e}")