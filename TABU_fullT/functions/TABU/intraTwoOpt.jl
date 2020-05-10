################################ intraTwoOpt #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for currentRoutes)
#   currentTruck::Int64                    (Number of current route/truck)
#   customer::Int64                        (Customer number)
#   distanceMatrix::Array{Float64,2}       (Distance from/to each customer)
#   timewindows::Array{Float64,2}          (Timewindow for each customer + depot)
#   tabuQueue::Queue{Array{Array{Int64,1},1}}(Queue type from DataStructures pkg)
#   bestObjVal::Float64                    (Current best objective value)
#   servicetimes::Array{Int64,2}           (Service time at each customer)
# OUTPUT:
#   feasibility::String                    (Either infeasible or feasible)
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for bestRoutes)
#   customers::Array{Int64,1}              (List of customers)
################################################################################
# Performs the intra Two-Opt operation
################################################################################

function intraTwoOpt(currentRoutes::Array{Array{Int64,1},1},
currentObjVal::Float64, currentTruck::Int64, customer::Int64,
distanceMatrix::Array{Float64,2}, timewindows::Array{Float64,2},
tabuQueue::Queue{Array{Array{Int64,1},1}}, bestObjVal::Float64, servicetimes::Array{Int64,2})

    # Initialize
    route = currentRoutes[currentTruck]
    u = findall(x->x==customer,route)[1]
    savings = Tuple{Float64,Int64,Int64}[]

    # Check if route is long enough for swaps
    if length(route) < 5
        feasibility = "infeasible"::String
        customers = "NaN"::String
        return feasibility, currentRoutes, currentObjVal, customers
    end

    # Calculate savings for every possible swap - FORWARD from u
    if u <= length(route)-2
        for i in u+1:length(route)-1

            # Get indexes to match distanceMatrix
            a0 = route[u-1]
            a1 = route[u]
            b0 = route[i]
            b1 = route[i+1]

            # Calculate savings
            existingArches = distanceMatrix[a0, a1] + distanceMatrix[b0, b1]
            newArches = distanceMatrix[a0, b0] + distanceMatrix[a1, b1]
            saving = existingArches - newArches

            # Push value and swap to list
            push!(savings, (saving, u, i))

        end
    end

    # Calculate savings for every possible swap - BACKWARDS from u
    if u >= 3
        for i in 2:u-1

            # Get indexes to match distanceMatrix
            a0 = route[i-1]
            a1 = route[i]
            b0 = route[u]
            b1 = route[u+1]

            # Calculate savings
            existingArches = distanceMatrix[a0, a1] + distanceMatrix[b0, b1]
            newArches = distanceMatrix[a0, b0] + distanceMatrix[a1, b1]
            saving = existingArches - newArches

            # Push value and swap to list
            push!(savings, (saving, i, u))

        end
    end

    # Sort savings
    savings = sort(savings, by = first, rev = true)

    # Start with best saving and iterate over worsening solutions
    for saving in savings

        # Get indices
        i = saving[2]
        u = saving[3]

        # Store customer numbers
        iDX = route[i]
        uDX = route[u]

        # Make temporary route for two-opt-operation
        tempRoute = deepcopy(route)

        # Swap customers
        tempRoute[i] = uDX
        tempRoute[u] = iDX

        # Reverse direction between customers between u and i (u > i always)
        tempRoute[(i+1):(u-1)] = reverse(tempRoute[(i+1):(u-1)])

        # Check feasibility
        servicebegin = 0.0::Float64
        feasibility = "feasible"::String
        for l in 1:length(tempRoute)-1

            j = tempRoute[l+1]
            l = tempRoute[l]

            servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[l] + distanceMatrix[l,j]))

            # Check servicetime
            if servicebegin > timewindows[j,2]
                feasibility = "infeasible"::String
                break
            end
        end

        # Return if check were succesful, else try next
        if feasibility == "infeasible"
            continue
        elseif feasibility == "feasible"

            # Tabu-check
            checkRoutes = deepcopy(currentRoutes)
            checkRoutes[currentTruck] = tempRoute

            if in(checkRoutes, tabuQueue)
                continue
            else
                # Define customers
                customers = [uDX, iDX]

                # TABU check succeeded, so route is chosen.
                currentRoutes[currentTruck] = tempRoute
                currentObjVal = (currentObjVal - saving[1])

                return feasibility, currentRoutes, currentObjVal, customers
            end
        end
    end

    # All relocations failed
    feasibility = "infeasible"::String
    customers = "NaN"::String
    return feasibility, currentRoutes, currentObjVal, customers
end
