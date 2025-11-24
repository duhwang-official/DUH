include("../DUH_Makie_Utils/DUH_Makie_Utils.jl")

using GLMakie, Makie
using .DUH_Makie_Utils

using Dates

x = collect( Date(2020,10,14):Date(2022,3,4) );
y = cumsum( randn( length(x) ) )

scatterlines!(x,y)