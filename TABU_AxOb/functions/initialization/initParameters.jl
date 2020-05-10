############################### initParameters ################################
# INPUT:
#   None
# OUTPUT:
#   parameters::Array{Parameters, 1}   (List of structs)
################################################################################
# Combines all parameter-combinations for insertionHeuristic() in a list.
################################################################################

# Parameter constructs
struct Parameters
    mu::Int64
    lambda::Int64
    alpha1::Int64
    alpha2::Int64
    initMethod::String
end

function initParameters()

    # Each parameter combination redefines the construction heuristic
    parameters = [Parameters(1,1,1,0, "earliest"), Parameters(1,2,1,0,
    "earliest"), Parameters(1,1,0,1, "earliest"), Parameters(1,2,0,1,
    "earliest"), Parameters(1,1,1,0, "farthest"), Parameters(1,2,1,0,
    "farthest"), Parameters(1,1,0,1, "farthest"), Parameters(1,2,0,1,
    "farthest")]

    return parameters
end
