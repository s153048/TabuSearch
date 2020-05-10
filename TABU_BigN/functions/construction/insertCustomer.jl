################################ insertCustomer ################################
# INPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
#   currentTruck::Int64                  (Index of current truck in truckRoutes)
#   serviceStart::Array{Float64,1}       (Lists servicestart-time for customers)
#   waitingTimes::Array{Float64,1}       (List of waitingtimes at customers)
#   customer::Int64                      (Customer to be inserted)
#   Idx::Int64                           (Spot to insert customer at)
#   timewindows::Array{Float64,2}        (Timewindow for customers and depot)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
#   servicetimes::Array{Int64,2}         (Servicetime at each customer)
# OUTPUT:
#   feasibility::String                  (States if insert was feasible)
#   serviceStart_copy::Array{Float64,1}  (Deep copy of original)
#   waitingTimes_copy::Array{Float64,1}  (Deep copy of original)
#   route::Array{Array{Int64,1},1}       (Deep copy of original)
#   serviceStart_jnew::Float64           (new service start time of customer+1)
#   serviceStart_jold::Float64           (old service start time of customer+1)
################################################################################
# Tries to insert customer at a given location in a given route
################################################################################

function insertCustomer(truckRoutes::Array{Array{Int64,1},1}, currentTruck::Int64,
serviceStart::Array{Float64,1}, waitingTimes::Array{Float64,1},
customer::Int64, Idx::Int64, timewindows::Array{Float64,2},
distanceMatrix::Array{Float64,2}, servicetimes::Array{Int64,2})

    # Deepcopy since insert! acts globally
    route = deepcopy(truckRoutes[currentTruck])
    serviceStart_copy = deepcopy(serviceStart)
    waitingTimes_copy = deepcopy(waitingTimes)

    # Insert customer into route
    insert!(route, Idx, customer)
    insert!(serviceStart_copy, Idx, 0)
    insert!(waitingTimes_copy, Idx, 0)

    # Save old serviceStart of customer after the inserted one
    serviceStart_jold = serviceStart_copy[Idx+1]
    # Initialize serviceStart_jnew
    serviceStart_jnew = 0.0::Float64

    # Update time variables for new insert and the customer after it
    for (l, k) = zip(Idx-1:Idx, Idx:Idx+1)

        # Get customer numbers
        i = route[l] # i and l indexes same customer in different arrays
        u = route[k] # similarly for u and k

        # Calculate earliest time allowed to start and arrival time
        e_u = timewindows[u,1]
        a_u = (serviceStart_copy[l] + servicetimes[i] + distanceMatrix[i, u])

        # Check if truck is waiting or not
        if e_u > a_u # Truck arrives before earliest possible time
            waitingTimes_copy[k] = e_u - a_u
            serviceStart_copy[k] = e_u
        else # Truck arrives at, or efter earliest possible time
            waitingTimes_copy[k] = 0
            serviceStart_copy[k] = a_u
        end

        # Save new serviceStart of customer after the inserted one
        if k == Idx+1
            serviceStart_jnew = serviceStart_copy[k]
        end

        # Check time feasibility
        servicebegin = 0.0::Float64
        feasibility = "feasible"::String
        for i in 1:length(route)-1
            j = route[i+1]
            i = route[i]

            servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))

            # Check servicetime
            if servicebegin > timewindows[j,2]
                feasibility = "infeasible"::String
                return feasibility, serviceStart_copy, waitingTimes_copy, route, serviceStart_jnew, serviceStart_jold
            end
        end
    end

    # Update time variables for the rest of the customers in the chain
    if length(route) > 3 # Not needed if length is just 3

        # Calculate general push forward
        PF = serviceStart_jnew - serviceStart_jold

        # Calculate individual PF and update wait- and serviceStart times
        for k in Idx+2:length(route)
            l = route[k]

            # Does PF actually affects serviceStart or just eats waitingTime
            PF_k = PF - waitingTimes_copy[k]

            if PF_k > 0 # PF affects serviceStart
                serviceStart_copy[k] = serviceStart_copy[k] + PF_k
                waitingTimes_copy[k] = 0
            else # PF just eats away the waitingTime
                waitingTimes_copy[k] = -PF_k
            end

            # Check time feasibility
            servicebegin = 0.0::Float64
            feasibility = "feasible"::String
            for i in 1:length(route)-1
                j = route[i+1]
                i = route[i]

                servicebegin = max(timewindows[j,1], (servicebegin + servicetimes[i] + distanceMatrix[i,j]))

                # Check servicetime
                if servicebegin > timewindows[j,2]
                    feasibility = "infeasible"::String
                    return feasibility, serviceStart_copy, waitingTimes_copy, route, serviceStart_jnew, serviceStart_jold
                end
            end
        end
    end
    feasibility = "feasible"::String
    return feasibility, serviceStart_copy, waitingTimes_copy, route, serviceStart_jnew, serviceStart_jold
end
