################################ initFarthest ##################################
# INPUT:
#   distanceMatrix_init::Array{Float64,2} (Infinity in cols indicates visits)
# OUTPUT:
#   distanceMatrix_init::Array{Float64,2} (Infinity in cols indicates visits)
#   customer::Int64                       (Index of chosen customer)
################################################################################
# Finds the unrouted customer farthest away from the depot
################################################################################

function initFarthest(distanceMatrix_init::Array{Float64,2})
    # Matrix with -Inf in column to not visit that customer again
    customer = argmax(distanceMatrix_init[1,:])
    distanceMatrix_init[:, customer] .= -Inf
    return distanceMatrix_init, customer
end
