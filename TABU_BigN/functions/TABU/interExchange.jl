################################ interExchange #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for currentRoutes)
#   currentTruck::Int64                    (Number of current route/truck)
#   customer::Int64                        (Customer number)
#   distanceMatrix::Array{Float64,2}       (Distance from/to each customer)
#   timewindows::Array{Float64,2}          (Timewindow for each customer + depot)
#   tabuQueue::Queue{Int64}                (Queue type from DataStructures pkg)
#   bestObjVal::Float64                    (Current best objective value)
#   demands::Array{Int64,2}                (Demands for each customer)
#   capacity::Int64                        (Capacity of each vehicle)
#   servicetimes::Array{Int64,2}           (Service time at each customer)
# OUTPUT:
#   feasibility::String                    (Either infeasible or feasible)
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for bestRoutes)
#   customers::Array{Int64,1}              (List of customers)
################################################################################
# Performs the inter exchange operation
################################################################################

function interExchange(currentRoutes::Array{Array{Int64,1},1},
currentObjVal::Float64, currentTruck::Int64, customer::Int64,
distanceMatrix::Array{Float64,2}, timewindows::Array{Float64,2},
tabuQueue::Queue{Int64}, bestObjVal::Float64, demands::Array{Int64,2},
capacity::Int64, servicetimes::Array{Int64,2})

    # Initialize
    returnRoute = deepcopy(currentRoutes)
    curRoute = deepcopy(currentRoutes[currentTruck])
    u = findall(x->x==customer,curRoute)[1]
    savings =  Tuple{Float64,Int64,Int64}[]

    # Calculate savings for every swap in every route
    routeNum = 0::Int64
    for othRoute in currentRoutes
        routeNum += 1

        # Check if other route is same as current route
        if othRoute == curRoute
            continue
        else
            # Check every possible swap
            for i in 2:length(othRoute)-1

                # Get indexes to match distanceMatrix
                a0 = curRoute[u-1]
                a1 = curRoute[u]
                a2 = curRoute[u+1]
                b0 = othRoute[i-1]
                b1 = othRoute[i]
                b2 = othRoute[i+1]

                # Calculate savings in distance
                existingArches = distanceMatrix[a0, a1] + distanceMatrix[a1, a2] + distanceMatrix[b0, b1] + distanceMatrix[b1, b2]
                newArches = distanceMatrix[a0, b1] + distanceMatrix[b1, a2] + distanceMatrix[b0, a1] + distanceMatrix[a1, b2]
                saving = existingArches - newArches

                # Push saving, customer swap and routenumber
                push!(savings, (saving, i, routeNum))
            end
        end
    end

    # Sort savings in decreasing order
    savings = sort(savings, by = first, rev = true)

    # Start with best saving and iterate over worsening solutions
    for saving in savings

        # Get route and swap index for customer
        routeNum = saving[3]
        swapIDX = saving[2]
        swapCus = currentRoutes[routeNum][swapIDX]

        # Make copies of two new routes
        tempRoute1 = deepcopy(curRoute)
        tempRoute2 = deepcopy(currentRoutes[routeNum])

        # Make swap
        tempRoute1[u] = swapCus
        tempRoute2[swapIDX] = customer

        # Check demand feasibility for both routes
            # Route 1
        truckCapacity = 0::Int64
        for delivery in tempRoute1
            truckCapacity = truckCapacity + demands[delivery]
        end
        if truckCapacity > capacity
            continue
        end
            # Route 2
        truckCapacity = 0::Int64
        for delivery in tempRoute2
            truckCapacity = truckCapacity + demands[delivery]
        end
        if truckCapacity > capacity
            continue
        end

        # Check time feasibility for both routes
            # Route 1
        servicebegin = 0.0::Float64
        feasibility = "feasible"::String
        for i in 1:length(tempRoute1)-1
            j = tempRoute1[i+1]
            i = tempRoute1[i]

            servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))

            # Check servicetime
            if servicebegin > timewindows[j,2]
                feasibility = "infeasible"::String
                break
            end
        end

        # Try next if first tempRoute1 was not feasible, else check tempRoute2
        if feasibility == "infeasible"
            continue
        elseif feasibility == "feasible"

            # Route 2
            servicebegin = 0.0::Float64
            for i in 1:length(tempRoute2)-1
                j = tempRoute2[i+1]
                i = tempRoute2[i]

                servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))

                # Check servicetime
                if servicebegin > timewindows[j,2]
                    feasibility = "infeasible"::String
                    break
                end
            end

            # If route 2 is infeasible, try next
            if feasibility == "infeasible"
                continue
            elseif feasibility == "feasible"

                # TABU check
                if in(customer, tabuQueue) || in(swapCus, tabuQueue)
                    continue
                end

                # TABU check succeeded, so routes are updated
                returnRoute[currentTruck] = tempRoute1
                returnRoute[routeNum] = tempRoute2

                # Format return for TABU
                customers = [customer, swapCus]

                returnObjVal = currentObjVal - saving[1]

                return feasibility, returnRoute, returnObjVal, customers

            end
        end
    end
    # All relocations failed
    feasibility = "infeasible"::String
    customers = "NaN"::String
    return feasibility, currentRoutes, currentObjVal, customers
end
