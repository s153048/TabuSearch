################################################################################
# Executable file for running TABU k-sensititivty
################################################################################

######## IMPORT PACKAGES ########

using DataStructures
using Random
using AlgoTuner
using DataFrames
using Plots
using CSV
using DelimitedFiles

######## INCLUDE FUNCTIONS ########

# Initialization functions
include("functions/initialization/initParameters.jl")
include("functions/initialization/readInstance.jl")
include("functions/initialization/getDistanceMatrix.jl")

# Construction heuristic functions
include("functions/construction/insertionHeuristic.jl")
include("functions/construction/initEarliest.jl")
include("functions/construction/initFarthest.jl")
include("functions/construction/getDemandMetList.jl")
include("functions/construction/insertCustomer.jl")

# Helper functions
include("functions/helper/solutionChecker.jl")
include("functions/helper/objectiveValue.jl")
include("functions/helper/distVal.jl")
include("functions/helper/bestSolutions.jl")

# runTABU functions
include("functions/TABU/runTABU.jl")
include("functions/TABU/runTABU_iterationAnalysis.jl")
include("functions/TABU/randomCustomer.jl")
include("functions/TABU/randomOperator.jl")
include("functions/TABU/intraRelocate.jl")
include("functions/TABU/intraTwoOpt.jl")
include("functions/TABU/interRelocate.jl")
include("functions/TABU/interExchange.jl")

##################################### main #####################################
# INPUT:
#   None
# OUTPUT:
#   k_analysis.csv                   (results)
#   iterationAnalysis.csv           (ObjVal vs. iterations analysis)
################################################################################
# Checks k-sensititivty
################################################################################

function kAnalysis()

    # Set seed
    Random.seed!(1234)

    # Construct dataframe to hold results
    df = DataFrame(k = Int64[], bnDist = Float64[], bnVehi = Int64[],
    tabuDist = Float64[], tabuVehi = Int64[], dDist = Float64[], dVehi =
    Int64[], constructDist = Float64[], constructVehi = Int64[], dcDist =
    Float64[], dcVehi = Int64[], iterations = Int64[], successCheck = String[])

    # Initialize iterationAnalysis array
    iA_array = []
    count = 1

    file = "R1_2_4.TXT"
    params = [10, 20, 30, 40, 50, 60, 70, 75, 80, 90, 100]

    for k in params

        # Initialize
        filepath = string("data/", file)
        dim = 201
        parameters = initParameters()
        name, vehicles, capacity, coords, demands, timewindows, servicetimes =
        readInstance(filepath, dim)
        distanceMatrix = getDistanceMatrix(coords, dim)

        # Construction heuristic
        truckRoutes = insertionHeuristic(parameters[6], name, vehicles,
        capacity, demands, timewindows, servicetimes, distanceMatrix)
        objVal = objectiveValue(truckRoutes, distanceMatrix)

        # Define TABU variables
        runtime = 120

        bestRoutes, bestObjVal, iterations =
        runTABU(truckRoutes, objVal, k, runtime,
        distanceMatrix, timewindows, capacity, demands, vehicles,
        servicetimes)
        objVal = objectiveValue(bestRoutes, distanceMatrix)

        # Get output values for storage
        bnDist, bnVehi = bestSolutions(file)
        tabuDist = distVal(bestRoutes, distanceMatrix)
        tabuVehi = length(bestRoutes)
        dDist = bnDist - tabuDist
        dVehi = bnVehi - tabuVehi
        constructDist = distVal(truckRoutes, distanceMatrix)
        constructVehi = length(truckRoutes)
        dcDist = constructDist - tabuDist
        dcVehi = constructVehi - tabuVehi
        successCheck = solutionChecker(bestRoutes, distanceMatrix, capacity,
        demands, vehicles, timewindows, servicetimes)

        push!(df, (k, bnDist, bnVehi, tabuDist, tabuVehi, dDist, dVehi,
        constructDist, constructVehi, dcDist, dcVehi, iterations, successCheck))
        println("K: ", count, "/11")
        count += 1
    end
    # Print dataframe
    println(df)

    # Write data to CSV file
    CSV.write("output/k_analysis.csv", df)
end
