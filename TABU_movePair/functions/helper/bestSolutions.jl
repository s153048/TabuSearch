################################ bestSolutions #################################
# INPUT:
#   file::String        (Name of benchmark file)
# OUTPUT:
#   distance::Float64   (Total distance in best known routes)
#   vehicles::Int64     (Total vehicles in best known routes)
################################################################################
# Returns distances and vehicles from best known routes of benchmark files
################################################################################

function bestSolutions(file::String)
    if file == "C1_2_1.TXT"
        return 2704.57::Float64, 20::Int64
    elseif file == "C1_2_2.TXT"
        return 2917.89::Float64, 18::Int64
    elseif file == "C1_2_3.TXT"
        return 2707.35::Float64, 18::Int64
    elseif file == "C1_2_4.TXT"
        return 2643.31::Float64, 18::Int64
    elseif file == "C1_2_5.TXT"
        return 2702.05::Float64, 20::Int64
    elseif file == "C1_2_6.TXT"
        return 2701.04::Float64, 20::Int64
    elseif file == "C1_2_7.TXT"
        return 2701.04::Float64, 20::Int64
    elseif file == "C1_2_8.TXT"
        return 2775.48::Float64, 19::Int64
    elseif file == "C1_2_9.TXT"
        return 2687.83::Float64, 18::Int64
    elseif file == "C1_2_10.TXT"
        return 2643.51::Float64, 18::Int64
    elseif file == "C2_2_1.TXT"
        return 1931.44::Float64, 6::Int64
    elseif file == "C2_2_2.TXT"
        return 1863.16::Float64, 6::Int64
    elseif file == "C2_2_3.TXT"
        return 1775.08::Float64, 6::Int64
    elseif file == "C2_2_4.TXT"
        return 1703.43::Float64, 6::Int64
    elseif file == "C2_2_5.TXT"
        return 1878.85::Float64, 6::Int64
    elseif file == "C2_2_6.TXT"
        return 1857.35::Float64, 6::Int64
    elseif file == "C2_2_7.TXT"
        return 1849.46::Float64, 6::Int64
    elseif file == "C2_2_8.TXT"
        return 1820.53::Float64, 6::Int64
    elseif file == "C2_2_9.TXT"
        return 1830.05::Float64, 6::Int64
    elseif file == "C2_2_10.TXT"
        return 1806.58::Float64, 6::Int64
    elseif file == "R1_2_1.TXT"
        return 4784.11::Float64, 20::Int64
    elseif file == "R1_2_2.TXT"
        return 4039.86::Float64, 18::Int64
    elseif file == "R1_2_3.TXT"
        return 3381.96::Float64, 18::Int64
    elseif file == "R1_2_4.TXT"
        return 3057.81::Float64, 18::Int64
    elseif file == "R1_2_5.TXT"
        return 4107.86::Float64, 18::Int64
    elseif file == "R1_2_6.TXT"
        return 3583.14::Float64, 18::Int64
    elseif file == "R1_2_7.TXT"
        return 3150.11::Float64, 18::Int64
    elseif file == "R1_2_8.TXT"
        return 2951.99::Float64, 18::Int64
    elseif file == "R1_2_9.TXT"
        return 3760.58::Float64, 18::Int64
    elseif file == "R1_2_10.TXT"
        return 3301.18::Float64, 18::Int64
    elseif file == "R2_2_1.TXT"
        return 4483.16::Float64, 4::Int64
    elseif file == "R2_2_2.TXT"
        return 3621.20::Float64, 4::Int64
    elseif file == "R2_2_3.TXT"
        return 2880.62::Float64, 4::Int64
    elseif file == "R2_2_4.TXT"
        return 1981.29::Float64, 4::Int64
    elseif file == "R2_2_5.TXT"
        return 3366.79::Float64, 4::Int64
    elseif file == "R2_2_6.TXT"
        return 2913.03::Float64, 4::Int64
    elseif file == "R2_2_7.TXT"
        return 2451.14::Float64, 4::Int64
    elseif file == "R2_2_8.TXT"
        return 1849.87::Float64, 4::Int64
    elseif file == "R2_2_9.TXT"
        return 3092.04::Float64, 4::Int64
    elseif file == "R2_2_10.TXT"
        return 2654.97::Float64, 4::Int64
    end
end
