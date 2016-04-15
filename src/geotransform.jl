"""
   geotransform(crs::CRS, pos::Position)

Returns a `Position` in the new co-ordinate reference system indicated by crs,
performing all necessary co-ordinate transformations and datum shifts.

By default, this function can convert between the built-in co-ordinate types
using the same datum, e.g.

    geotransform(CRS(ECEF, wgs84), Position(lla, wgs84))

will convert an `LLA` position into an `ECEF` equivalent.

This function is intended to be specialized on user-defined co-ordinate and/or
datum types to facilitate a generic transformation mechanism.
"""
function geotransform(crs::CRS, pos::Position)
    error("Transformation from $(CRS(pos)) to $crs not defined")
end

function geotransform{CoordinateType1,CoordinateType2,Datum}(crs::CRS{CoordinateType1,Datum}, pos::Position{CoordinateType2,Datum})
    if crs.datum == pos.datum
        # Co-ordinate systems can perform transformations upon construction
        return Position(CoordinateType1(pos.x, crs.datum), crs.datum)
    else
        error("Transformation from $(CRS(pos)) to $crs not defined")
    end
end

function geotransform{CoordinateType1,CoordinateType2,Datum}(crs::CRS{ENU,Position{CoordinateType1,Datum}}, pos::Position{CoordinateType2,Datum})
    if crs.datum.datum == pos.datum
        Position(ENU(pos.x, crs.datum.x, crs.datum.datum), crs.datum)
    else
        error("Transformation from $(CRS(pos)) to $crs not defined")
    end
end

function geotransform{CoordinateType1,CoordinateType2,Datum}(crs::CRS{CoordinateType1,Datum}, pos::Position{ENU,Position{CoordinateType2,Datum}})
    if pos.datum.datum == crs.datum
        Position(CoordinateType1(pos.x, pos.datum.x, crs.datum), crs.datum)
    else
        error("Transformation from $(CRS(pos)) to $crs not defined")
    end
end

function geotransform{CoordinateType1, CoordinateType2, Datum}(crs::CRS{ENU, Position{CoordinateType1, Datum}}, pos::Position{ENU, Position{CoordinateType2, Datum}})
    if CoordinateType1 == CoordinateType2 && crs.datum == pos.datum
        return pos
    else
        error("Transformation between ENU origins has not been implemented. Use an intermediatary reference frame instead.")
    end
end
