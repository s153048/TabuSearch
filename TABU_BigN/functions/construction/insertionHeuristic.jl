############################## insertionHeuristic ##############################
# INPUT:
#   parameters::Parameters     (Parameters redefining the heuristic)
#   name::String                         (Name of the file)
#   vehicles::Int64                      (Number of vehicles available)
#   capacity::Int64                      (Capacity of each vehicle)
#   demands::Array{Int64,2}              (Demands for each customer)
#   timewindows::Array{Float64,2}        (Timewindow for customers and depot)
#   servicetimes::Array{Int64,2}         (Service time at each customer)
#   distanceMatrix::Array{Float64,2}     (Distance from/to each customer)
# OUTPUT:
#   truckRoutes::Array{Array{Int64,1},1} (List of list of each truck's route)
################################################################################
# Computes Solomon's I1 insertion heuristic based on chosen parameters
################################################################################

function insertionHeuristic(parameters::Parameters, name::String,
vehicles::Int64, capacity::Int64, demands::Array{Int64,2},
timewindows::Array{Float64,2}, servicetimes::Array{Int64,2},
distanceMatrix::Array{Float64,2})

    # Array of array with each row being a truck holding that trucks route
    truckRoutes = Array{Int64,1}[]
    currentTruck = 0::Int64

    # Get initMethod
    initMethod = parameters.initMethod

    # Array to distinguish unrouted customers
    unroutedCustomers = collect(2:1:201)

    # +/- Inf indicating depot is already visited, is input to init functions
    distanceMatrix_init = deepcopy(distanceMatrix)
    timewindows_init = deepcopy(timewindows)
    distanceMatrix_init[:,1] .= -Inf::Float64
    timewindows_init[1] = Inf::Float64

    # Initializes new trucks until all customers are assigned
    while unroutedCustomers != []

        # Start a new truck
        push!(truckRoutes, [1, 1])
        serviceStart = zeros(Float64, 2)
        waitingTimes = zeros(Float64, 2)
        currentTruck += 1::Int64
        currentCapacity = capacity

        # Select first customer and update matrix
        if initMethod == "farthest"
            distanceMatrix_init, customer = initFarthest(distanceMatrix_init)
        elseif initMethod == "earliest"
            timewindows_init, customer = initEarliest(timewindows_init)
        end

        #NB - This part here contains redundant/unsatisfactory code
        # Insert customer (first customer is always feasible)
        feasibility, serviceStart, waitingTimes, truckRoutes[currentTruck],
        serviceStart_jnew, serviceStart_jold = insertCustomer(truckRoutes,
        currentTruck, serviceStart, waitingTimes, customer, 2::Int64,
        timewindows, distanceMatrix, servicetimes)

        # Filter out customer and update capacity
        filter!(e->e!=customer,unroutedCustomers)
        currentCapacity = currentCapacity - demands[customer]

        # Get list of unrouted customers with demand <= capacity
        demandMetCustomers = getDemandMetList(unroutedCustomers,
        currentCapacity, demands)

        # Tries to assign customers as long as capacity exists
        while demandMetCustomers != []
            # Array holds criteria values and insertion spots for each customer
            c1Array = []
            k = 0::Int64

            # Loop over customers and find best feasible insertion spot
            for uDX in demandMetCustomers
                k += 1
                # Loop over insertion spots
                for i in 1:length(truckRoutes[currentTruck])-1
                    j = i+1

                    # Get indexes for readability
                    iDX = truckRoutes[currentTruck][i]
                    jDX = truckRoutes[currentTruck][j]

                    # Insert customer
                    feasibility, serviceStart_new, waitingTimes_new, route_new,
                    serviceStart_jnew, serviceStart_jold =
                    insertCustomer(truckRoutes, currentTruck, serviceStart,
                    waitingTimes, uDX, j, timewindows, distanceMatrix, servicetimes)

                    # If insert is feasible continue calculations
                    if feasibility == "feasible"

                        # Calcualte i1 and i2
                        i1 = distanceMatrix[iDX, uDX] + distanceMatrix[uDX, jDX]
                        - parameters.mu * distanceMatrix[iDX, jDX]
                        i2 = serviceStart_jnew - serviceStart_jold

                        # Calculate c1
                        c1 = parameters.alpha1 * i1 + parameters.alpha2 * i2

                        # Always push the first
                        if length(c1Array) < k
                            push!(c1Array, (c1, uDX, j))
                        # If new c1 insert is smaller than previous, replace
                        elseif c1 < c1Array[k][1]
                            c1Array[k] = (c1, uDX, j)
                        end

                    # Else push bad values if non has been pushed and move on
                    elseif feasibility == "infeasible"
                        if length(c1Array) < k
                            push!(c1Array, (Inf, Inf, Inf))
                        end
                    end
                end
            end

            #NB! Redundant code - should be combined with c1Array part for speed
            # Calculate C2 values
            c2Array = c1Array
            for i in 1:length(c2Array)
                # Define customer for readability
                customer = c2Array[i][2]
                if customer != Inf
                    # Calculate C2 values
                    c2Array[i] = ((parameters.lambda *
                    distanceMatrix[1,customer] - c1Array[i][1]), c1Array[i][2],
                    c1Array[i][3])
                else
                    # Work around because of bad implementation
                    c2Array[i] = (-Inf, -Inf, -Inf)
                end
            end

            # Sort array
            c2Array = sort(c2Array, by = first, rev = true)

            # Extract customer and update
            customer = c2Array[1][2]
            Idx = c2Array[1][3]

            # If this happens, it means there are no more feasible customers
            if customer == -Inf
                break
            end

            #NB! redundant code again, bad implementation
            feasibility, serviceStart, waitingTimes, route_new,
            serviceStart_jnew, serviceStart_jold = insertCustomer(truckRoutes,
            currentTruck, serviceStart, waitingTimes, customer, Idx,
            timewindows, distanceMatrix, servicetimes)

            truckRoutes[currentTruck] = route_new
            currentCapacity = currentCapacity - demands[customer]
            filter!(e->e!=customer,unroutedCustomers)

            if initMethod == "farthest"
                distanceMatrix_init[:, customer] .= -Inf::Float64
            elseif initMethod == "earliest"
                timewindows_init[customer] = Inf::Float64
            end

            demandMetCustomers = getDemandMetList(unroutedCustomers,
            currentCapacity, demands)
        end
    end
    return truckRoutes
end
