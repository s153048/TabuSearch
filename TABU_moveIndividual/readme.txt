
movePair TABU

#*# Tabulist type:
	Moves are stored in tabu list, when two customers are moved at same time they are stored independently of eachother
## Neighbourhood:
	Random non-tabu customer. Random operator.  Choose best feasible move out of all combinations in operator.
## Objective function:
	distance x vehicles
## Parameters after tuning:
	Tabu list length -> k = 76

#*# - Indicates change from "Baseline"
