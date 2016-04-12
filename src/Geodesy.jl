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

    # Constants
    WGS84, wgs84,
    OSGB36, osgb36,
    NAD27, nad27,

    # Methods
    geotransform,
    distance


include("points.jl")
include("datums.jl")
include("crs.jl")
include("conversion.jl")
include("geotransform.jl")

end # module Geodesy
