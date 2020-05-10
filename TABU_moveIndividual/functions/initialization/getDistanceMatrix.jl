############################## getDistanceMatrix ###############################
# INPUT:
#   coords::Array{Int64,2}              (Relative path to file)
#   dim::Int64                          (Number of customers + depot in file)
# OUTPUT:
#   distanceMatrix::Array{Float64,2}    (Distance from/to each customer)
################################################################################
# Computers distances between each customer as 'Straight-line' distance
################################################################################

function getDistanceMatrix(coords::Array{Int64, 2},dim::Int64)
    distanceMatrix = zeros(Float64,dim,dim)
    for i in 1:dim
       for j in 1:dim
            if i!=j
                distanceMatrix[i,j]=round(sqrt((coords[i,1]-coords[j,1])^2+(coords[i,2]-coords[j,2])^2),digits=2)
            end
        end
    end
    return distanceMatrix
end
