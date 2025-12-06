from vcdvcd import VCDVCD
import csv
import bisect # Used for efficient searching in sorted lists

# --- Configuration ---
VCD_FILE = "outputs.vcd"
OUTPUT_CSV = "outputs.csv"

VCD_KEY_TO_NAME = {
    '-': "layer1_out0", 
    '5': "layer1_out1", 
    '=': "layer1_out2", 
    'E': "layer1_out3", 
    'M': "layer1_out4", 
    'U': "layer1_out5", 
    ']': "layer1_out6", 
    'e': "layer1_out7", 
}
# ---------------------

print(f"Loading VCD file: {VCD_FILE}")

# Load the VCD file
vcd = VCDVCD(VCD_FILE)

# --- 1. Prepare Signal Data and Gather ALL Timestamps ---
signal_data = {}
all_timestamps = set()

for vcd_key, display_name in VCD_KEY_TO_NAME.items():
    if vcd_key in vcd.data:
        tv_list = vcd.data[vcd_key].tv
        signal_data[vcd_key] = {
            'display_name': display_name,
            'tv': tv_list
        }
        # Add ALL timestamps from this signal's history to the master set
        for t, v in tv_list:
            all_timestamps.add(t)
    
if not signal_data:
    print("ERROR: No Layer 1 output signals found using the specified VCD keys.")
    exit()

# Sort the unique timestamps
timestamps = sorted(list(all_timestamps))

print(f"Found {len(VCD_KEY_TO_NAME)} signals ({', '.join(VCD_KEY_TO_NAME.values())}) and {len(timestamps)} total unique timestamps for plotting.")

# --- 2. Function to get the last value at a specific time (from previous fix) ---
def get_last_value_at_time(signal_tv_list, target_time):
    times = [t for t, v in signal_tv_list]
    idx = bisect.bisect_right(times, target_time) - 1
    
    if idx < 0:
        return '0' 
    
    return signal_tv_list[idx][1] # [1] is the value (binary string)

# --- 3. Write CSV ---
with open(OUTPUT_CSV, "w", newline="") as f:
    writer = csv.writer(f)
    header = ["time"] + list(VCD_KEY_TO_NAME.values())
    writer.writerow(header)

    # For each required output time (t)
    for t in timestamps:
        row = [t]
        for vcd_key in VCD_KEY_TO_NAME.keys():
            signal_entry = signal_data.get(vcd_key)
            
            value_int = 0 # Default to 0
            if signal_entry:
                # Get the binary string value
                value_bin = get_last_value_at_time(signal_entry['tv'], t)
                
                try:
                    # Convert binary string to integer
                    value_int = int(value_bin, 2)
                except ValueError:
                    # Handles 'x' or 'z' values
                    value_int = 0 
            
            row.append(value_int)
        
        writer.writerow(row)

print(f"\n✔ Conversion complete! Clean CSV exported successfully to → {OUTPUT_CSV}")
print("Ready to run dashboard_plot.py")