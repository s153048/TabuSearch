############################### randomCustomer #################################
# INPUT:
#   currentRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   tabuQueue::Queue{Int64}                (Queue type from DataStructures pkg)
# OUTPUT:
#   truck::Int64                           (Route number of customer)
#   customer::Int64                        (Customer number)
################################################################################
# Finds a random route and a random customer non-TABU customer in that route
################################################################################

function randomCustomer(currentRoutes::Array{Array{Int64,1},1}, tabuQueue::Queue{Int64})

    # Choose a random truck and customer
    truck = rand(1:length(currentRoutes))
    route = currentRoutes[truck]
    customer = route[rand(2:length(route)-1)]

    # If customer is tabu, keep generating until it is not
    while in(customer, tabuQueue)
        truck = rand(1:length(currentRoutes))
        route = currentRoutes[truck]
        customer = route[rand(2:length(route)-1)]
    end

    return truck, customer
end
