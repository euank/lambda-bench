FILES=$(shell find . -mindepth 2 -maxdepth 2 -type f -name "*.csv")

./merged.csv: $(FILES)
	xsv cat rows $(FILES) > merged.csv
