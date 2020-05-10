############################### randomCustomer #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
# OUTPUT:
#   truck::Int64                           (Route number of customer)
#   customer::Int64                        (Customer number)
################################################################################
# Finds a random route and a random customer
################################################################################

function randomCustomer(currentRoutes::Array{Array{Int64,1},1})

    # Choose a random truck and customer
    truck = rand(1:length(currentRoutes))
    route = currentRoutes[truck]
    customer = route[rand(2:length(route)-1)]

    return truck, customer
end
