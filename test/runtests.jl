using Geodesy
using BaseTestNext

################################################
### Helpers for testing approximate equality ###
################################################

macro xy_approx_eq(a, b)
    quote
        @test abs(($(esc(a))).(1) - ($(esc(b))).(1)) < 1e-6 # Displacements to world surface can lead to large-ish cancellation errors, so choose micron level errors
        @test abs(($(esc(a))).(2) - ($(esc(b))).(2)) < 1e-6
    end
end
macro xy_approx_eq_eps(a, b, eps)
    quote
        @test abs(($(esc(a))).(1) - ($(esc(b))).(1)) < $(esc(eps))
        @test abs(($(esc(a))).(2) - ($(esc(b))).(2)) < $(esc(eps))
    end
end

macro xyz_approx_eq(a, b)
    quote
        @test abs(($(esc(a))).(1) - ($(esc(b))).(1)) < 1e-6
        @test abs(($(esc(a))).(2) - ($(esc(b))).(2)) < 1e-6
        @test abs(($(esc(a))).(3) - ($(esc(b))).(3)) < 1e-6
    end
end
macro xyz_approx_eq_eps(a, b, eps)
    quote
        @test abs(($(esc(a))).(1) - ($(esc(b))).(1)) < $(esc(eps))
        @test abs(($(esc(a))).(2) - ($(esc(b))).(2)) < $(esc(eps))
        @test abs(($(esc(a))).(3) - ($(esc(b))).(3)) < $(esc(eps))
    end
end

Base.isapprox{T<:Tuple}(a::T, b::T; kwargs...) = all(ntuple(i->isapprox(a[i],b[i]), length(a)); kwargs...)

@testset "Geodesy" begin

include("points.jl")
include("transverse_mercator.jl")
include("polar_stereographic.jl")
include("utm.jl")
include("transformations.jl")
include("conversion.jl")

end # @testset "Geodesy"
