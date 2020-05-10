################################ readInstance ##################################
# INPUT:
#   filepath::String                (Relative path to file)
#   dim::Int64                      (Number of customers + depot in file)
# OUTPUT:
#   name::String                    (Name of the file)
#   vehicles::Int64                 (Number of vehicles available)
#   capacity::Int64                 (Capacity of each vehicle)
#   coords::Array{Int64,2}          (Coordinates of each customer and depot)
#   demands::Array{Int64,2}         (Demands for each customer)
#   timewindows::Array{Float64,2}   (Timewindow for each customer and depot)
#   servicetimes::Array{Int64,2}    (Service time at each customer)
################################################################################
# Reads the VRPTW standard files with dim = number of customers + 1 (depot)
################################################################################

function readInstance(filepath::String, dim::Int64)

    # Open file for reading
    file = open(filepath)
    # Read and store filename
    name = String(split(readline(file))[1])

    # Skip lines
    readline(file);readline(file);readline(file)

    # Read number of vehicles and capacity
    data = readline(file)
    vehicles = parse(Int64, split(data)[1])
    capacity = parse(Int64, split(data)[2])

    # Skip lines
    readline(file);readline(file);readline(file);readline(file)

    # Store data in separate arrays
    coords = zeros(Int64,dim,2)
    demands = zeros(Int64, dim, 1)
    timewindows = zeros(Float64, dim, 2)
    servicetimes = zeros(Int64, dim, 1)

    # Read and store all data
    for i = 1:dim
        data = parse.(Int64,split(readline(file)))
        coords[i,:] = data[2:3]
        demands[i] = data[4]
        timewindows[i,:] = data[5:6]
        servicetimes[i] = data[7]
    end

    # Close file and return data
    close(file)
    return name, vehicles, capacity, coords, demands, timewindows, servicetimes
end
