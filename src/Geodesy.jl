module Geodesy

using FixedSizeArrays
using Compat

export
    # Points
    ECEF,
    ENU,
    LLA,
    LatLon,

    # CRS/Position
    CRS,
    Position,

    # Other types
    Ellipsoid,
    ellipsoid,

    # Constants
    WGS84, wgs84,
    OSGB36, osgb36,
    NAD27, nad27,
    GRS80, grs80,

    # Methods
    geotransform,
    distance


include("points.jl")
include("datums.jl")
include("crs.jl")
include("conversion.jl")
include("geotransform.jl")

# Deprecations errors and warnings
immutable Bounds{T}
    Bounds(x...) = error("Deprecated: Bounds has been removed from Godesy")
end
center{T}(bounds::Bounds{T}) = error("Deprecated: Bounds has been removed from Godesy")
inBounds{T}(loc::T, bounds::Bounds{T}) = error("Deprecated: Bounds has been removed from Godesy")
onBounds{T}(loc::T, bounds::Bounds{T}) = error("Deprecated: Bounds has been removed from Godesy")
boundaryPoint{T}(p1::T, p2::T, bounds::Bounds{T}) = error("Deprecated: Bounds has been removed from Godesy")

function ECEF(x::LLA)
    warn("Deprecation warning: default datum choice `wgs84` deprecated (also note new lower case identifier).")
    ECEF(x, wgs84)
end

function LLA(x::ECEF)
    warn("Deprecation warning: default datum choice `wgs84` deprecated (also note new lower case identifier).")
    LLA(x, wgs84)
end

function ENU(x::Union{LLA,ECEF}, y::LLA)
    warn("Deprecation warning: default datum choice `wgs84` deprecated (also note new lower case identifier).")
    ENU(x, y, wgs84)
end

end # module Geodesy
