################################### runTABU ####################################
# INPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   objVal::Float64                      (Objective value for truckRoutes)
#   k::Any                               (Length of TABU-list)
#   runtime::Int64                       (Running time in seconds)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
#   timewindows::Array{Float64,2}        (Timewindow for each customer + depot)
#   capacity::Int64                      (Capacity of each vehicle)
#   demands::Array{Int64,2}              (Demands for each customer)
#   vehicles::Int64                      (Number of vehicles available)
#   servicetimes::Array{Int64,2}         (Service time at each customer)
# OUTPUT:
#   bestRoutes::Array{Array{Int64,1},1}  (List of list of each truck's route)
#   bestObjVal::Float64                  (Objective value for bestRoutes)
################################################################################
# Executes the TABU-search until time-limit has been reached
################################################################################

function runTABU(truckRoutes::Array{Array{Int64,1},1}, objValue::Float64,
k::Any, runtime::Int64, distanceMatrix::Array{Float64,2},
timewindows::Array{Float64,2}, capacity::Int64, demands::Array{Int64,2},
vehicles::Int64, servicetimes::Array{Int64,2})

    # Set current best known solution
    bestRoutes = deepcopy(truckRoutes)
    bestObjVal = deepcopy(objValue)
    currentRoutes = deepcopy(truckRoutes)
    currentObjVal = deepcopy(objValue)

    # Initialize TABU queue
    tabuQueue = Queue{Array{Array{Int64,1},1}}()

    # Start main loop for set time and count number of iterations
    iterations = 1::Int64
    let
        startTime = time_ns()
        while round( (time_ns()-startTime)/1e9,digits=3) < runtime

            # Choose non-TABU customer at random and random operator
            truck, customer = randomCustomer(currentRoutes)
            operator = randomOperator()

            # Update neighbourhood
            if operator == "intraRelocate"

                # Run operator
                feasibility, currentRoutes, currentObjVal, customers =
                intraRelocate(currentRoutes, currentObjVal, truck, customer,
                distanceMatrix, timewindows, servicetimes, tabuQueue)

            elseif operator == "intraTwoOpt"

                # Run operator
                feasibility, currentRoutes, currentObjVal, customers =
                intraTwoOpt(currentRoutes, currentObjVal, truck, customer,
                distanceMatrix, timewindows, tabuQueue, bestObjVal, servicetimes)

            elseif operator == "interRelocate"

                # Run operator
                feasibility, currentRoutes, currentObjVal, customers =
                interRelocate(currentRoutes, currentObjVal, truck, customer,
                distanceMatrix, timewindows, bestObjVal, demands, capacity,
                servicetimes, tabuQueue)

            elseif operator == "interExchange"

                # Run operator
                feasibility, currentRoutes, currentObjVal, customers =
                interExchange(currentRoutes, currentObjVal, truck, customer,
                distanceMatrix, timewindows, tabuQueue, bestObjVal, demands,
                capacity, servicetimes)

            end

            # Start over if neighbourhood was not feasible
            if feasibility == "infeasible"
                continue
            end

            # Update tabuQueue
            if length(tabuQueue) < k
                enqueue!(tabuQueue, currentRoutes)
            else
                dequeue!(tabuQueue)
                enqueue!(tabuQueue, currentRoutes)
            end

            # If new solution is better, update
            if currentObjVal < bestObjVal
                bestRoutes = deepcopy(currentRoutes)
                bestObjVal = deepcopy(currentObjVal)
            end

            iterations += 1
        end
        #println("iterations: ", iterations)
    end
    return bestRoutes, bestObjVal, iterations
end
