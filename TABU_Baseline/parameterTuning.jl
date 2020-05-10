################################################################################
# Executable file for parameter tuning
################################################################################

######## IMPORT PACKAGES ########

using DataStructures
using Random
using AlgoTuner

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
include("functions/TABU/randomCustomer.jl")
include("functions/TABU/randomOperator.jl")
include("functions/TABU/intraRelocate.jl")
include("functions/TABU/intraTwoOpt.jl")
include("functions/TABU/interRelocate.jl")
include("functions/TABU/interExchange.jl")

################################ parameterTuning ###############################
# INPUT:
#   None
# OUTPUT:
#   None
################################################################################
# Runs the parameter tuning for TABU search and prints best parameters
################################################################################



function parameterTuning()

    ######## FUNCTION FOR ALGOTUNER  ########

    function tuneTABU(seed, instance, runtime, k)

        # Set seed
        Random.seed!(seed)

        # Initialize
        filepath = string("Data/", instance)
        dim = 201
        parameters = initParameters()
        name, vehicles, capacity, coords, demands, timewindows, servicetimes = readInstance(filepath, dim)
        distanceMatrix = getDistanceMatrix(coords, dim)

        # Construction heuristic
        truckRoutes = insertionHeuristic(parameters[5], name, vehicles, capacity, demands, timewindows, servicetimes, distanceMatrix)
        objVal = objectiveValue(truckRoutes, distanceMatrix)

        # Run TABU
        bestRoutes, bestObjVal = runTABU(truckRoutes, objVal, k, runtime, distanceMatrix, timewindows, capacity, demands, vehicles, servicetimes)
        objVal = objectiveValue(bestRoutes, distanceMatrix)

        return objVal
    end

    ######## TUNE PARAMETERS  ########

    # Get objective value for a number of different benchmark files
    benchmark = ["C1_2_1.TXT", "C2_2_1.TXT", "R1_2_1.TXT", "R2_2_1.TXT"]

    bestKnown = Dict{String, Float64}()
    for file in benchmark
        result = bestSolutions(file)
        objVal = objectiveCalc(result[1], result[2])
        bestKnown[file] = objVal
    end

    # Set samplesize and runtime
    samplesize = 3
    runtime = 30
    timelimit = 7200
    # 1 iteration = Instances * runtime * samplesize = 4 x 3 x 30 = 360s x 20 iterations = 7200 seconds (2 hours)

    # Set seed used for each sample
    seedsamples = [1, 2, 3]

    # Setup function format to fit AlgoTuner with gap-calculation

    TABU(seed, instance, k) = (tuneTABU(seed, instance, runtime, k) - bestKnown[instance])/bestKnown[instance]


    # Conduct tuning
    cmd = AlgoTuner.createRuntimeCommand(TABU)
    AlgoTuner.addIntParam(cmd, "k", 5, 100)
    AlgoTuner.tune(cmd,benchmark,timelimit,samplesize,seedsamples, AlgoTuner.ShowAll)

end
