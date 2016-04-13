
###################
### Point Types ###
###################

"""
Latitude, longitude, and alititude co-ordinate system.
(Note: assumes degrees not radians)
"""
immutable LLA
    lat::Float64
    lon::Float64
    alt::Float64
end
LLA(lat, lon) = LLA(lat, lon, 0.0)

function Base.show(io::IO, lla::LLA)
    # Avoid any confusion regarding order of latitude and longitude
    print(io, "LLA(lat=$(lla.lat), lon=$(lla.lon), alt=$(lla.alt))")
end


"""
Latitude and longitude co-ordinates.
(Note: assumes degrees not radians)
"""
immutable LatLon
    lat::Float64
    lon::Float64
end
LatLon(lla::LLA) = LatLon(lla.lat, lla.lon)

function Base.show(io::IO, ll::LatLon)
    # Avoid any confusion regarding order of latitude and longitude
    print(io, "LatLon(lat=$(ll.lat), lon=$(ll.lon))")
end


"""
Point in Earth-Centered-Earth-Fixed (ECEF) coordinates.
Global cartesian coordinate system rotating with the Earth.
"""
immutable ECEF # <: FixedVectorNoTuple{3,Float64}
    x::Float64
    y::Float64
    z::Float64
end

function Base.show(io::IO, ecef::ECEF)
    print(io, "ECEF(x=$(ecef.x), y=$(ecef.y), z=$(ecef.z))")
end


"""
Point in East-North-Up (ENU) coordinates. Local cartesian coordinate system,
linearized about a reference point.
"""
immutable ENU # <: FixedVectorNoTuple{3,Float64}
    e::Float64
    n::Float64
    u::Float64
end
ENU(x, y) = ENU(x, y, 0.0)

function Base.show(io::IO, enu::ENU)
    print(io, "ENU(e=$(enu.e), n=$(enu.n), u=$(enu.u))")
end

### distance
# Point translators
distance(a::ENU, b::ENU) = distance(a.e, a.n, a.u,
                                    b.e, b.n, b.u)

distance(a::ECEF, b::ECEF) = distance(a.x, a.y, a.z,
                                      b.x, b.y, b.z)

function distance(x1, y1, z1, x2, y2, z2)
    return sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end
