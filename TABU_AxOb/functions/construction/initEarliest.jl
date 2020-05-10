################################ initEarliest ##################################
# INPUT:
#   timewindows_init::Array{Float64,2}    (Infinity in cols indicates visits)
# OUTPUT:
#   timewindows_init::Array{Float64,2}    (Infinity in cols indicates visits)
#   customer::Int64                       (Index of chosen customer)
################################################################################
# Finds the unrouted customer with the earliest start of service
################################################################################

function initEarliest(timewindows_init::Array{Float64,2})
    # Matrix with +Inf in row to not visit that customer again
    customer = argmin(timewindows_init[:,1])
    timewindows_init[customer] = Inf
    return timewindows_init, customer
end
