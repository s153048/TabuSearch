############################### solutionChecker ################################
# INPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
#   capacity::Int64                      (Capacity of each vehicle)
#   demands::Array{Int64,2}              (Demands for each customer)
#   vehicles::Int64                      (Number of vehicles available)
#   timewindows::Array{Float64,2}        (Timewindow for customers and depot)
#   servicetimes::Array{Int64,2}         (Service time at each customer)
# OUTPUT:
#   result::String                       ("Succes" or "fail" + error message)
################################################################################
# Checks if truckRoutes violates constraints as defined by project description
################################################################################

function solutionChecker(truckRoutes::Array{Array{Int64,1},1},
distanceMatrix::Array{Float64,2}, capacity::Int64, demands::Array{Int64,2},
vehicles::Int64, timewindows::Array{Float64,2}, servicetimes::Array{Int64,2})

    ## CHECK 1 ##
    # Check if too many vehicles have been used
    if length(truckRoutes) > vehicles
        result = "FAILED: Too many vehicles used"::String
        return result
    end

    ## CHECK 2 ##
    # Check if demands and truck capacity are ok
    for route in truckRoutes
        truckCapacity = 0::Int64
        for customer in route
            truckCapacity = truckCapacity + demands[customer]
        end
        if truckCapacity > capacity
            result = "FAILED: Truck capacity exceeded"::String
            return result
        end
    end

    ## CHECK 3 ##
    # Check if services begin after the deadlines
    for route in truckRoutes
        servicebegin = 0::Int64
        for i in 1:length(route)-1
            j = route[i+1]
            i = route[i]
            servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))
            if servicebegin > timewindows[j,2]
                result = "FAILED: Timewindow deadline exceeded"::String
                return result
            end
        end
    end

    ## CHECK 4 ##
    # Check if truck starts and ends at depot, and only visits depot twice
    for route in truckRoutes
        depotVisits = 0::Int64
        for customer in route
            if customer == 1
                depotVisits += 1
            end
        end
        if depotVisits > 2 || route[1] != 1 || route[end] != 1
            result = "FAILED: route did not start/end with depot OR depot visits > 2"::String
            return result
        end
    end

    ## CHECK 5 ##
    # Check if all customers have been visited
    customerCheck = collect(1:1:201)
    for route in truckRoutes
        for customer in route
            filter!(e->e!=customer,customerCheck)
        end
    end
    if customerCheck != []
        result = "FAILED: Vehicles did not visit all customers"::String
        return result
    end

    ## CHECK 6 ##
    # Check if all customers have been visited once only
    for route in truckRoutes
        if length(unique(route)) != length(route)-1
            result = "FAILED: Some customer was visited more than once"::String
            return result
        end
    end

    result = "SUCCESS"::String
    return result
end
