# TabuSearch
*Implementation of Tabu search for 'Optimization using metaheuristics'*

## This repository contains:

**Six pure Tabu variations:**
* ‘TABU_AxOb’ 
* ‘TABU_Baseline’
* ‘TABU_BigN’
* ‘TABU_fullT’
* ‘TABU_moveIndividual’ (moveEachT in report)
* ‘TABU_movePair’ 

**One extended variation**
* ‘TABU_Extended’

**One comparison folder, ‘Compare’, containing a Jupyter notebook used for data-analysis.**

### Each folder works as a separate program and contains: 
* **‘Data’** - Folder of all 40 data files
* **‘functions’** 
  * *‘initialisation’*  - functions run only once for each file
  * *‘construction’* - functions for construction heuristic
  * *‘helper’* - general functions used throughout the program
  * *’TABU’* - main tabu files, operators and neighbourhood functions. 
* **‘output’** - folder holding function results as .csv files
  * *‘dataframe.csv’* - with detailed results from run done on each file
  * *‘iterationAnalysis.csv’* - iteration analysis results
* **‘main.jl’** - Executable function running Tabu on all 40 files. 
* **‘parameterTuning.jl’** - Executable function tuning parameters for Tabu for 7200 seconds. 
* **‘readme.txt’** - Explanation of the Tabu and how it differs from Baseline. 
