################################################################################
# Executable file for running TABU on all benchmark files
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
#   dataframe.csv                   (Results for all benchmarks)
#   iterationAnalysis.csv           (ObjVal vs. iterations analysis)
################################################################################
# Runs TABU on all benchmark files. Writes data analysis and results to files
################################################################################

function main()

    # Set seed
    Random.seed!(1234)

    # Construct dataframe to hold results
    df = DataFrame(Filename = String[], bnDist = Float64[], bnVehi = Int64[],
    tabuDist = Float64[], tabuVehi = Int64[], dDist = Float64[], dVehi =
    Int64[], constructDist = Float64[], constructVehi = Int64[], dcDist =
    Float64[], dcVehi = Int64[], iterations = Int64[], successCheck = String[])

    # Initialize iterationAnalysis array
    iA_array = []
    count = 1

    files = readdir("data/")
    for file in files

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
        k = 54
        T = 79
        runtime = 120

        # Always analyse ObjVal vs. Interations for file "R1_2_4"
        if file == "R1_2_4.TXT"
            bestRoutes, bestObjVal, iA_array, iterations =
            runTABU_iterationAnalysis(truckRoutes, objVal, k, runtime,
            distanceMatrix, timewindows, capacity, demands, vehicles,
            servicetimes, T)
            objVal = objectiveValue(bestRoutes, distanceMatrix)
        else
            bestRoutes, bestObjVal, iterations = runTABU(truckRoutes, objVal, k,
            runtime, distanceMatrix, timewindows, capacity, demands, vehicles,
            servicetimes, T)
            objVal = objectiveValue(bestRoutes, distanceMatrix)
        end

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

        push!(df, (file, bnDist, bnVehi, tabuDist, tabuVehi, dDist, dVehi,
        constructDist, constructVehi, dcDist, dcVehi, iterations, successCheck))
        println("File: ", count, "/40")
        count += 1

    end

    # Print dataframe
    println(df)

    # Write data to CSV file
    CSV.write("output/dataframe2.csv", df)
    writedlm("output/iterationAnalysis2.csv", iA_array, ',')
end
