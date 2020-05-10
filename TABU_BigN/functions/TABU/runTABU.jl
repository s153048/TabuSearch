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
    tabuQueue = Queue{Int64}()

    # Start main loop for set time and count number of iterations
    iterations = 1::Int64
    let
        startTime = time_ns()
        while round( (time_ns()-startTime)/1e9,digits=3) < runtime

            # Choose non-TABU customer at random
            truck, customer = randomCustomer(currentRoutes, tabuQueue)

            operatorDecider = [-Inf, -Inf, -Inf, -Inf]

            # Run intraRelocate
            feasibility, newRoutes1, newObjVal1, newCustomers1 =
            intraRelocate(currentRoutes, currentObjVal, truck, customer,
            distanceMatrix, timewindows, servicetimes)

            if feasibility == "feasible"
                operatorDecider[1] = newObjVal1
            end

            # Run intraTwoOpt
            feasibility, newRoutes2, newObjVal2, newCustomers2 =
            intraTwoOpt(currentRoutes, currentObjVal, truck, customer,
            distanceMatrix, timewindows, tabuQueue, bestObjVal, servicetimes)

            if feasibility == "feasible"
                operatorDecider[2] = newObjVal2
            end

            # Run interRelocate
            feasibility, newRoutes3, newObjVal3, newCustomers3 =
            interRelocate(currentRoutes, currentObjVal, truck, customer,
            distanceMatrix, timewindows, bestObjVal, demands, capacity,
            servicetimes)

            if feasibility == "feasible"
                operatorDecider[3] = newObjVal3
            end

            # Run interExchange
            feasibility, newRoutes4, newObjVal4, newCustomers4 =
            interExchange(currentRoutes, currentObjVal, truck, customer,
            distanceMatrix, timewindows, tabuQueue, bestObjVal, demands,
            capacity, servicetimes)

            if feasibility == "feasible"
                operatorDecider[4] = newObjVal4
            end


            # Start over if neighbourhood was not feasible
            if operatorDecider == [-Inf, -Inf, -Inf, -Inf]
                continue
            else
                # Update best neighbourhood
                i = argmax(operatorDecider)
                if i == 1
                    currentRoutes = deepcopy(newRoutes1)
                    currentObjVal = operatorDecider[i]
                    customers = newCustomers1
                elseif i == 2
                    currentRoutes = deepcopy(newRoutes2)
                    currentObjVal = operatorDecider[i]
                    customers = newCustomers2
                elseif i == 3
                    currentRoutes = deepcopy(newRoutes2)
                    currentObjVal = operatorDecider[i]
                    customers = newCustomers2
                elseif i == 4
                    currentRoutes = deepcopy(newRoutes2)
                    currentObjVal = operatorDecider[i]
                    customers = newCustomers2
                end
            end

            # Update tabuQueue
            for customer in customers
                if length(tabuQueue) < k
                    enqueue!(tabuQueue, customer)
                else
                    dequeue!(tabuQueue)
                    enqueue!(tabuQueue, customer)
                end
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
