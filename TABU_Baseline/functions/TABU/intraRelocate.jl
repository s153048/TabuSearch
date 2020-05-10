################################ intraRelocate #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for truckRoutes)
#   currentTruck::Int64                    (Number of current route/truck)
#   customer::Int64                        (Customer number)
#   distanceMatrix::Array{Float64,2}       (Distance from/to each customer)
#   timewindows::Array{Float64,2}          (Timewindow for each customer + depot)
#   servicetimes::Array{Int64,2}           (Service time at each customer)
# OUTPUT:
#   feasibility::String                    (Either infeasible or feasible)
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentObjVal::Float64                 (Objective value for bestRoutes)
#   customers::Array{Int64,1}              (List of customers)
################################################################################
# Performs the intra relocate operation
################################################################################

function intraRelocate(currentRoutes::Array{Array{Int64,1},1},
currentObjVal::Float64 , currentTruck::Int64 , customer::Int64,
distanceMatrix::Array{Float64,2} , timewindows::Array{Float64,2},
servicetimes::Array{Int64,2})

    # Initialize
    route = currentRoutes[currentTruck]
    u = findall(x->x==customer,route)[1]
    savings = Tuple{Float64,Int64}[]

    # Calculate savings for every insertion spot
    for i in 1:length(route)-1
        j = i+1

        # Skip iteration if insert is same as current position
        if j == u
            continue
        end
        if i == u
            continue
        end

        # Get indexes to match distanceMatrix
        iDX = route[i]
        uDX = route[u]
        jDX = route[j]

        # Calculate savings in route length at that spot
        existingArches = distanceMatrix[route[u-1], uDX] + distanceMatrix[uDX, route[u+1]] + distanceMatrix[iDX, jDX]
        newArches = distanceMatrix[route[u-1], route[u+1]] + distanceMatrix[iDX, uDX] + distanceMatrix[uDX, jDX]
        saving = existingArches - newArches

        # Push value and insertion spot to list
        push!(savings, (saving, j))
    end

    # Sort savings
    savings = sort(savings, by = first, rev = true)

    # Start with best saving and iterate over worsening solutions
    for saving in savings
        # Make relocation but keep old route
        tempRoute = deepcopy(route)
        deleteat!(tempRoute, u)

        # Delete shiftes index, this makes sure index is right
        if saving[2] > u
            insert!(tempRoute, saving[2]-1, route[u])
        else
            insert!(tempRoute, saving[2], route[u])
        end

        # Check feasibility
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

            # Format returns to fit runTABU
            currentRoutes[currentTruck] = tempRoute
            customers = [customer]
            currentObjVal = currentObjVal - saving[1]

            return feasibility, currentRoutes, currentObjVal, customers
        end
    end

    # All relocations failed
    feasibility = "infeasible"::String
    customers = "NaN"::String
    return feasibility, currentRoutes, currentObjVal, customers
end
