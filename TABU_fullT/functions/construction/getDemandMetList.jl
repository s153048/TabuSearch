############################### getDemandMetList ###############################
# INPUT:
#   unroutedCustomers::Array{Int64,1}   (List of unrouted customers)
#   currentCapacity::Int64              (Current capacity left in truck)
#   demands::Array{Int64,2}             (Demands for each customer)
# OUTPUT:
#   demandMetCustomers::Array{Int64,1}  (Customers with demand <= capacity)
################################################################################
# Finds which unrouted customers can be served with capacity left in truck
################################################################################

function getDemandMetList(unroutedCustomers::Array{Int64,1},
currentCapacity::Int64, demands::Array{Int64,2})

    # Create array to hold customers with met demand
    demandMetCustomers = Int64[]

    # if demand of customer is > current capacity, then delete it
    for customer in unroutedCustomers
        if demands[customer] <= currentCapacity
            push!(demandMetCustomers, customer)
        end
    end

    return demandMetCustomers
end
