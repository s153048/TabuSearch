# TabuSearch
Implementation of Tabu search for 'Optimization using metaheuristics'

This folder contains:

Six pure Tabu variations
	a. ‘AxOb’ 
	b. ‘Baseline’
	c. ‘BigN’
	d. ‘fullT’
	e. ‘moveIndividual’ (moveEachT in report)
	f. ‘movePair’ 

One extended variation
	a. ‘Extended’

One comparison folder, ‘Compare’, containing a Jupyter notebook used for data-analysis.

Each folder works as a separate program and contains: 
	a. ‘Data’ 
		Folder of all 40 data files
	b. ‘functions’ 
		a. ‘initialisation’  - functions run only once for each file
		b. ‘construction’ - functions for construction heuristic
		c. ‘helper’ - general functions used throughout the program
		d. ’TABU’ - main tabu files, operators and neighbourhood functions. 
	c. ‘output’ - folder holding function results as .csv files
		a. ‘dataframe.csv’ - with detailed results from run done on each file
		b. ‘iterationAnalysis.csv’ - iteration analysis results
	d. ‘main.jl’
		Executable function running Tabu on all 40 files. 
	e. ‘parameterTuning.jl’
		Executable function tuning parameters for Tabu for 7200 seconds. 
	f. ‘readme.txt’
		Explanation of the Tabu and how it differs from Baseline. 
