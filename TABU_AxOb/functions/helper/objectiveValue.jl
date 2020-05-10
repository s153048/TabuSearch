################################ objectiveValue ################################
# INPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
# OUTPUT:
#   objVal::Float64                      (Objective value for truckRoutes)
################################################################################
# Calculates some defined objective value for a list of routes
################################################################################

function objectiveValue(truckRoutes::Array{Array{Int64,1},1},
distanceMatrix::Array{Float64,2})

    # Initialize distance
    distance = 0.0::Float64

    # Initialize route length array
    routes = Int64[]

    # Calculate distance and append route lengths
    for route in truckRoutes
        val = length(route)^3
        push!(routes, val)
        for i in 1:length(route)-1
            j = i + 1
            iDX = route[i]
            jDX = route[j]
            distance = distance + distanceMatrix[iDX, jDX]
        end
    end

    # Get objective value as...
    objVal = distance - sum(routes)

    return objVal
end
