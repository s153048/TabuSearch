################################ interRelocate #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for currentRoutes)
#   currentTruck::Int64                    (Number of current route/truck)
#   customer::Int64                        (Customer number)
#   distanceMatrix::Array{Float64,2}       (Distance from/to each customer)
#   timewindows::Array{Float64,2}          (Timewindow for each customer + depot)
#   bestObjVal::Float64                    (Current best objective value)
#   demands::Array{Int64,2}                (Demands for each customer)
#   capacity::Int64                        (Capacity of each vehicle)
#   servicetimes::Array{Int64,2}           (Service time at each customer)
#   tabuQueue::Queue{Int64}                (Queue type from DataStructures pkg)
# OUTPUT:
#   feasibility::String                    (Either infeasible or feasible)
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for bestRoutes)
#   customers::Array{Int64,1}              (List of customers)
################################################################################
# Performs the inter relocate operation
################################################################################

function interRelocate(currentRoutes::Array{Array{Int64,1},1},
currentObjVal::Float64 , currentTruck::Int64, customer::Int64,
distanceMatrix::Array{Float64,2}, timewindows::Array{Float64,2},
bestObjVal::Float64, demands::Array{Int64,2}, capacity::Int64,
servicetimes::Array{Int64,2}, tabuQueue::Queue{Tuple})

    # Initialize
    curRoute = currentRoutes[currentTruck]
    u = findall(x->x==customer,curRoute)[1]
    savings =  Tuple{Float64,Int64,Int64}[]

    # Calculate savings for every insertion in every route
    routeNum = 0::Int64
    for newRoute in currentRoutes
        routeNum += 1

        # Check if route is current route
        if newRoute == curRoute
            continue
        else

            # Check every possible insertion spot
            for i in 1:length(newRoute)-1
                j = i+1

                # Get indexes to match distanceMatrix
                iDX = newRoute[i]
                uDX = curRoute[u]
                jDX = newRoute[j]

                # Calculate savings in distance
                existingArches = distanceMatrix[curRoute[u-1], uDX] + distanceMatrix[uDX, curRoute[u+1]] + distanceMatrix[iDX, jDX]
                newArches = distanceMatrix[curRoute[u-1], curRoute[u+1]] + distanceMatrix[iDX, uDX] + distanceMatrix[uDX, jDX]
                saving = existingArches - newArches

                # Push saving, insertion spot and routenumber
                push!(savings, (saving, j, routeNum))
            end
        end
    end

    # Sort savings in decreasing order
    savings = sort(savings, by = first, rev = true)

    # Start with best saving and iterate over worsening solutions
    for saving in savings

        # Get route and insertion spot for customer
        routeNum = saving[3]
        insertID = saving[2]

        # Make relocation to new temporary route
        tempRoute = deepcopy(currentRoutes[routeNum])
        insert!(tempRoute, insertID, customer)

        # Check demand feasibility
        truckCapacity = 0::Int64
        for delivery in tempRoute
            truckCapacity = truckCapacity + demands[delivery]
        end
        if truckCapacity > capacity
            continue
        end

        # Check time feasibility
        servicebegin = 0.0::Float64
        feasibility = "feasible"::String
        for i in 1:length(tempRoute)-1
            j = tempRoute[i+1]
            i = tempRoute[i]

            servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))

            # Check servicetime
            if servicebegin > timewindows[j,2]
                feasibility = "infeasible"::String
                break
            end
        end

        # Return if move is feasible, else try next
        if feasibility == "infeasible"
            continue
        elseif feasibility == "feasible"

            # Check if current move is TABU
            move = (customer, routeNum, insertID)
            if in(move, tabuQueue)
                continue
            else
                # Update routes
                currentRoutes[routeNum] = tempRoute
                deleteat!(currentRoutes[currentTruck], u)

                # Store new tabuMove
                tabuMove = (customer, currentTruck, u)

                # Disband route if it has only 2 sites left (2x depot)
                if length(currentRoutes[currentTruck]) == 2
                    truckSave = currentObjVal/length(currentRoutes)
                    deleteat!(currentRoutes, currentTruck)
                else
                    truckSave = 0::Int64
                end

                currentObjVal = currentObjVal - saving[1] - truckSave

                return feasibility, currentRoutes, currentObjVal, tabuMove
            end
        end
    end

    # All relocations failed
    feasibility = "infeasible"::String
    tabuMove = "NaN"::String
    return feasibility, currentRoutes, currentObjVal, tabuMove
end
