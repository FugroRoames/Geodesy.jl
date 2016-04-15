# ----------------------------------------------------------
# Coordinate reference systems
# ----------------------------------------------------------
"""
A co-ordinate reference system `CRS{CoordinateType, Datum}` represents the
information required to georeference a point in the coordinate system. The
`datum` field may be a singleton instance (e.g. wgs84 of singleton type WGS84)
or a user-defined object containing any information necessary to perform any
intended CRS transformations. Thus, `datum` may also need to include supplementary
information to define the coordinate system as well as the standard geodetic
datum (for example, the georeferenced origin of an ENU frame, which is itself
represented by a `Position` with its own geodetic `datum`).

Positions may be converted into a new CRS using the `geotransform` function:
    geotransform(crs::CRS, position::Position)
"""
immutable CRS{CoordinateType, Datum}
    datum::Datum
end
# ----------------------------------------------------------
# Fully georeferenced positions
# ----------------------------------------------------------
"""
A `Position{CoordinateType, Datum}` includes all the information to
georeference a point by including both the position's coordinates in field `x`,
and the datum (plus other supplementary coordinate system information - see CRS)
in field `datum`.

Positions may be converted into a new CRS using the `geotransform` function:
    geotransform(crs::CRS, position::Position)
"""
immutable Position{CoordinateType, Datum}
    x::CoordinateType
    datum::Datum
end

# ----------------------------------------------------------
# Coordinate reference system methods
# ----------------------------------------------------------
CRS{CoordinateType,Datum}(::Type{CoordinateType}, datum::Datum) = CRS{CoordinateType,Datum}(datum)
function CRS{CoordinateType, Datum}(x::Position{CoordinateType, Datum})
    CRS{CoordinateType, Datum}(x.datum)
end

function Base.show{CoordinateType, Datum}(io::IO, crs::CRS{CoordinateType, Datum})
    print(io, "CRS($CoordinateSystem, datum=$(crs.datum))")
end
# Flatten the output for ENU Positions to make them more readable
function Base.show{Datum <: Position}(io::IO, crs::CRS{ENU, Datum})
    print(io, "CRS(ENU, origin=$(crs.datum.x), datum=$(crs.datum.datum))")
end

# ----------------------------------------------------------
# Fully georeferenced positions methods
# ----------------------------------------------------------
Position{CoordinateType}(x::CoordinateType, crs::CRS{CoordinateType}) = Position(x, crs.datum)
Base.call{CoordinateType}(crs::CRS{CoordinateType}, x::CoordinateType) = Position(x, crs.datum)
Base.call{CoordinateType}(crs::CRS{CoordinateType}, x...) = Position(CoordinateType(x...), crs.datum)

function Base.show{CoordinateType, Datum}(io::IO, pos::Position{CoordinateType, Datum})
    print(io, "Position($(pos.x), datum=$(pos.datum))")
end
# Flatten the output for ENU Positions to make them more readable
function Base.show{Datum <: Position}(io::IO, pos::Position{ENU, Datum})
    print(io, "Position($(pos.x), origin=$(pos.datum.x), datum=$(pos.datum.datum))")
end
