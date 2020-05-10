############################### randomOperator #################################
# INPUT:
#   None
# OUTPUT:
#   operator::String    (String of name of random operator chosen)    
################################################################################
# Finds a random route and a random customer non-TABU customer in that route
################################################################################

function randomOperator()

    # Get random integer
    operator = rand(1:4)

    # Choose operator based on integer
    if operator == 1
        operator = "intraRelocate"::String
    elseif operator == 2
        operator = "intraTwoOpt"::String
    elseif operator == 3
        operator = "interRelocate"::String
    else
        operator = "interExchange"::String
    end

    return operator
end
