# Parameterization to compute faster ; from https://github.com/Circuitscape/Circuitscape.jl/issues/236

using Pkg
Pkg.activate(".")
using LinearAlgebra.BLAS
BLAS.set_num_threads(1)

# List all the ini_files from a folder 
searchdir(path,key) = filter(x->occursin(key,x), readdir(path))
ext = "ini"
dir = "/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/raw-data/OmniscapeParamFiles/"
ini_list = dir .* searchdir(dir, ext)

# Create a function that run one ini file 
using Omniscape
function comp(file)
    println(file) # print the name of the ini file
    run_omniscape(file) # compute flow
end


# Run the list of ini files using pmap 
using Distributed # to get the pmap function activated 
pmap(comp, ini_list) # function that parallelize 
