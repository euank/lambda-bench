import csv
import glob
import collections

import matplotlib.pyplot as plt
import numpy as np

files = glob.glob("./results-2018-09-14/*/results.csv")

duration_data = {}
f_duration_data = {}
l_duration_data = {}

def process_row_for(sel, data, row):
	fn = row['Function']
	warmth = row['Warmth']
	val = float(row[sel])
	fn = fn.replace("_hello_world", '')
	data.setdefault(warmth, {}).setdefault(fn, []).append(val)
	# data.setdefault(fn + " " + warmth, []).append(val)

for f in files:
	with open(f) as csvfile:
		fdata = csv.DictReader(csvfile)
		for row in fdata:
			process_row_for('Duration', duration_data, row)
			process_row_for('Function_Duration', f_duration_data, row)
			process_row_for('Lambda_Duration', l_duration_data, row)

fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(10, 4))

for ax in axes:
	for loc in ["top", "bottom", "right", "left"]:
		ax.spines[loc].set_visible(False)
	ax.get_xaxis().tick_bottom()  
	ax.get_yaxis().tick_left()  

lang_colors = {
	"crowbar": "#b7410e", # 'Rust'
	"go": "#6ad7e5", # gopher color
	"rust-aws-lambda": "#483C32", # Taupe, a boring color
	"python": '#356f9f', # blue in the python logo
}

for idx, warmth in enumerate(["cold", "warm"]):
	dat = duration_data[warmth]
	# Hide outliers because Go has a single nasty 700ms point which makes the chart
	# scale much worse
	ax = axes[idx]
	bplot = ax.boxplot(dat.values(), labels=dat.keys(), showfliers=False)
	ax.set_ylabel("Execution Duration (s)")
	ax.set_title("Lambda Execution (" + warmth + ")")

	colors = [lang_colors[key] for key in dat.keys()]
	# thanks to https://stackoverflow.com/questions/41997493/python-matplotlib-boxplot-color/41997865#41997865
	for el in ['boxes', 'whiskers', 'fliers', 'medians', 'caps']:
		for i in range(0, len(colors)):
			els = len(bplot[el])
			if els == 0:
				continue
			step = els // len(colors)
			for plotel in range(i * step, (i+1)*step):
				bplot[el][plotel].set(color=colors[i])

plt.savefig('plot.png')
