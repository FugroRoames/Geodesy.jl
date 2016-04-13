# ----------------------------------------------------------
# Coordinate reference systems
# ----------------------------------------------------------
"""
A co-ordinate reference system `CRS{CoordinateSystem, Datum}` represents the
information required to georeference a point in the co-ordinate system. The
`datum` field may be a singleton instance (e.g. wgs84 of singleton type WGS84)
or a user-defined object containing any information necessary to perform any
intended CRS transformations.

Positions may be converted into a new CRS using the `geotransform` function:
    geotransform(crs::CRS, position::Position)
"""
immutable CRS{CoordinateSystem, Datum}
    datum::Datum
end
# ----------------------------------------------------------
# Fully georeferenced positions
# ----------------------------------------------------------
"""
A `Position{CoordinateSystem, Datum}` includes all the information to
georeference a point by including both the position's co-ordinates (in field `x`)
and the datum information (in field `datum`).

Positions may be converted into a new CRS using the `geotransform` function:
    geotransform(crs::CRS, position::Position)
"""
immutable Position{CoordinateSystem, Datum}
    x::CoordinateSystem
    datum::Datum
end

# ----------------------------------------------------------
# Coordinate reference system methods
# ----------------------------------------------------------
CRS{CS,D}(::Type{CS}, datum::D) = CRS{CS,D}(datum)
function CRS{CoordinateSystem, Datum}(x::Position{CoordinateSystem, Datum})
    CRS{CoordinateSystem, Datum}(x.datum)
end

function Base.show{CoordinateSystem, Datum}(io::IO, crs::CRS{CoordinateSystem, Datum})
    print(io, "CRS($CoordinateSystem, datum=$(crs.datum))")
end
# Flatten the output for ENU Positions to make them more readable
function Base.show{Datum <: Position}(io::IO, crs::CRS{ENU, Datum})
    print(io, "CRS(ENU, origin=$(crs.datum.x), datum=$(crs.datum.datum))")
end

# ----------------------------------------------------------
# Fully georeferenced positions methods
# ----------------------------------------------------------
Position{CS}(x::CS, crs::CRS{CS}) = Position(x, crs.datum)
Base.call{CS}(crs::CRS{CS}, x::CS) = Position(x, crs.datum)
Base.call{CS}(crs::CRS{CS}, x...) = Position(CS(x...), crs.datum)

function Base.show{CoordinateSystem, Datum}(io::IO, pos::Position{CoordinateSystem, Datum})
    print(io, "Position($(pos.x), datum=$(pos.datum))")
end
# Flatten the output for ENU Positions to make them more readable
function Base.show{Datum <: Position}(io::IO, pos::Position{ENU, Datum})
    print(io, "Position($(pos.x), origin=$(pos.datum.x), datum=$(pos.datum.datum))")
end
