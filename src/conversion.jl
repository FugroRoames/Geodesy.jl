
################################
### Identity transformations ###
################################

ECEF(ecef::ECEF, datum) = ecef
LLA(lla::LLA, datum) = lla
ENU(enu::ENU, datum) = enu


###############################
### LLA to ECEF coordinates ###
###############################

function ECEF(lla::LLA, datum::Ellipsoid)
    ϕdeg, λdeg, h = lla.lat, lla.lon, lla.alt
    d = datum

    sinϕ, cosϕ = sind(ϕdeg), cosd(ϕdeg)
    sinλ, cosλ = sind(λdeg), cosd(λdeg)

    N = d.a / sqrt(1 - d.e² * sinϕ^2)  # Radius of curvature (meters)

    x = (N + h) * cosϕ * cosλ
    y = (N + h) * cosϕ * sinλ
    z = (N * (1 - d.e²) + h) * sinϕ

    return ECEF(x, y, z)
end
ECEF(lla::LLA, datum) = ECEF(lla, ellipsoid(datum))


###############################
### ECEF to LLA coordinates ###
###############################

function LLA(ecef::ECEF, datum::Ellipsoid)
    x, y, z = ecef.x, ecef.y, ecef.z
    d = datum

    p = hypot(x, y)
    θ = atan2(z*d.a, p*d.b)
    λ = atan2(y, x)
    ϕ = atan2(z + d.e′² * d.b * sin(θ)^3, p - d.e²*d.a*cos(θ)^3)

    N = d.a / sqrt(1 - d.e² * sin(ϕ)^2)  # Radius of curvature (meters)
    h = p / cos(ϕ) - N

    return LLA(rad2deg(ϕ), rad2deg(λ), h)
end
LLA(ecef::ECEF, datum) = LLA(ecef, ellipsoid(datum))


###############################
### ECEF to ENU coordinates ###
###############################

# Given a reference point for linarization
function ENU(ecef::ECEF, lla_ref::LLA, datum::Ellipsoid)
    ϕdeg, λdeg = lla_ref.lat, lla_ref.lon

    ecef_ref = ECEF(lla_ref, datum)
    ∂x = ecef.x - ecef_ref.x
    ∂y = ecef.y - ecef_ref.y
    ∂z = ecef.z - ecef_ref.z

    # Compute rotation matrix
    sinλ, cosλ = sind(λdeg), cosd(λdeg)
    sinϕ, cosϕ = sind(ϕdeg), cosd(ϕdeg)

    # R = [     -sinλ       cosλ  0.0
    #      -cosλ*sinϕ -sinλ*sinϕ cosϕ
    #       cosλ*cosϕ  sinλ*cosϕ sinϕ]
    #
    # east, north, up = R * [∂x, ∂y, ∂z]
    east  = ∂x * -sinλ      + ∂y * cosλ       + ∂z * 0.0
    north = ∂x * -cosλ*sinϕ + ∂y * -sinλ*sinϕ + ∂z * cosϕ
    up    = ∂x * cosλ*cosϕ  + ∂y * sinλ*cosϕ  + ∂z * sinϕ

    return ENU(east, north, up)
end
ENU(ecef::ECEF, lla_ref::LLA, datum) = ENU(ecef, lla_ref, ellipsoid(datum))

##############################
### LLA to ENU coordinates ###
##############################

# Given a reference point for linarization
function ENU(lla::LLA, lla_ref::LLA, datum::Ellipsoid)
    ecef = ECEF(lla, datum)
    return ENU(ecef, lla_ref, datum)
end
ENU(lla::LLA, lla_ref::LLA, datum) = ENU(lla, lla_ref, ellipsoid(datum))

###################################
### Position to raw coordinates ###
###################################

ECEF(pos::Position) = ECEF(pos.x, pos.datum)
LLA(pos::Position) = LLA(pos.x, pos.datum)

# ENU coordinates take and give reference point
ENU(pos::Position{ENU}) = pos.x
