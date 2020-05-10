################################### distVal ####################################
# INPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
# OUTPUT:
#   distVal::Float64                      (Total distance of routes)
################################################################################
# Calculates the total distance of all routes
################################################################################

function distVal(truckRoutes, distanceMatrix)

        # Initialize distance
        distance = 0.0::Float64

        # Calculate distance
        for route in truckRoutes
            for i in 1:length(route)-1
                j = i + 1
                iDX = route[i]
                jDX = route[j]
                distance = distance + distanceMatrix[iDX, jDX]
            end
        end

    return distance
end
