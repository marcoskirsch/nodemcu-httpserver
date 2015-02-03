import argparse
import base64

# Load this source file and strip the header.
initial_data = 'Marcos'

encoded_data = base64.b64encode(initial_data)

num_initial = len(initial_data)
print encoded_data
