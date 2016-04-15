# Geodesy

*Making georeferenced and local surveying easy*

[![Build Status](https://travis-ci.org/JuliaGeo/Geodesy.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/Geodesy.jl)
[![Coverage Status](http://img.shields.io/coveralls/JuliaGeo/Geodesy.jl.svg)](https://coveralls.io/r/JuliaGeo/Geodesy.jl)

The `Geodesy` package defines an interface for local and geodetic transformations
between coordinate reference systems, and implements some common geodetic
coordinates and datums based on elliptical models of the world.


### Terminology and design goals

![Coordinate Reference systems](http://www.crs-geo.eu/SharedDocs/Bilder/CRS/schema-crs-datum-cs,property=default.gif)
[www.crs-geo.eu](http://www.crs-geo.eu/nn_124224/crseu/EN/CRS__Overview/definition-crs__node.html).

[View the above as a data structure](http://i.stack.imgur.com/aeS8k.png)

The above images gives a quick picture of the components of the coordinate reference systems used in geodesy, with the data structure link showing the data structure used by the EPSG authority for the WGS84 (GPS) coordinate reference system as shown on the [EPSG website](http://www.epsg-registry.org/)).

The `Geodesy` package implements these components as Julia types for coordinates, datums, abstract coordinate reference *systems* and fully georeferenced `Position`s. Following this, `Geodesy` coordinate types (such as "earth centered, earth fixed" `ECEF`, "longitude-latitude-altitude" `LLA`, and "east-north-up" `ENU`) are raw data formats and do **not** have knowledge of relevant datum. They require supplemental information to perform coordinate transformations, but are appropriate storage containers for managing and performing calculations on large numbers of points assumed to be in the same CRS.

While the term "datum" originally referred to a measurement procedure for determining the coordinates of points, here we mean something slightly different. Pragmatically, the datum provides the necessary information to perform any required coordinate/datum transformations, and it can be an instance of any Julia type. The datum may, for example, indicate a particular elliptical model of the earth, allowing one to convert between latitude/longitude to a Cartesian frame. Or it might indicate the the `Position` of the origin of an `ENU` frame, allowing one to return to a geocentric coordinate when required. `Geodesy` provides two additional types to wrap the combined coordinates and datum for convenience and extensibility.

A `CRS` (coordinate reference system) is a concrete Julia type providing both the datum and the coordinate *format* used, while the related `Position` type includes this information plus the numerical coordinate *data*. This allows us to transform a `Position` into a new `CRS` with ease via the `geotransform` function:

``` julia
    geotransform(new_crs::CRS, position::Position) # -> new_position::Position
```

The interface is designed to be extended in many ways, and allows for:

  * User-defined types for storing coordinates (of arbitrary dimension)
  * User-defined datums (which may either be zero-cost Julia singletons or contain real data to assist in performing transformations)
  * More complex world positioning and datums, such as wrappers for the UTM projections and datum transformations provided by the `Proj4.jl` package.
  * Engineering datums and complex, highly dynamic datums.

### Coordinate Types

The below types are included in `Geodesy` by default.

1. `LLA`   - [(Geodetic) latitude](https://en.wikipedia.org/wiki/Latitude#Geodetic_and_geocentric_latitudes), longitude, altitude coordinate.

2. `LatLon`    - [(Geodetic) latitude](https://en.wikipedia.org/wiki/Latitude#Geodetic_and_geocentric_latitudes) and longitude coordinate to be on the ellipsoid's surface

3. `ECEF`  - Cartesian coordinate with `x` towards the prime meridian, `z` towards the north pole and `y` towards the equator such that (`x`,`y`,`z`) is a right-handed coordinate system.  Note that ECEF has a [meaning beyond a Cartesian coordinate system](https://en.wikipedia.org/wiki/ECEF), however it is used in this package to mean only a Cartesian coordinate system with origin at the ellipsoid's center.  

The last type is a relative position to some unspecified origin (which we would
interpret as being part of the datum — it is our "peg in the ground", so to speak).

4. `ENU`   - East North Up position in the local coordinate frame.

These types can be used to perform transformations to new coordinate systems by
including extra information about the datum. For example, to convert from `LLA`
to `ECEF`, a constructor is provided, `ECEF(lla::LLA, datum)`. Note that the
base `Geodesy` coordinate system types only "understands" the datum's ellipsoid.
A discussion on datums vs ellipsoids is given below. Some common
ellipsoidal datums are provided as the exported (singleton) constants `wgs84`,
`grs80`, `osgb36` and `nad27`, and custom ellipse's can also be used via the
`Ellipsoid` type. During the transformation, angles are presumed to be in
degrees and lengths in meters.

```julia
lla = LLA(-27.468937, 153.023628, 0.0) # City Hall, Brisbane, Australia
ecef = ECEF(lla, wgs84) # Cartesian coordinates from centre of earth using the common WGS 84 datum
```

Conversion to and from ENU types requires both the origin and datum.
```julia
lla_origin = LLA(-27.468937, 153.023628, 0.0) # City Hall, Brisbane, Australia
lla = LLA(-27.465933, 153.025900, 0.0) # Central Station, Brisbane, Australia
enu = ENU(lla, lla_origin, wgs84) # East, north, up distances between City Hall and Central Station
```

### Datum types

Datums can be implemented as any Julia type. Often, this may be a simple singleton
type like `wgs84 = WGS84()`, which via multiple dispatch allows us to define
the coordinate transformations above. However, some datums may contain data
which may only be determined at run time, such as an `ENU` frame where the
origin is not known at compile time.

In the Geodesy package, you can overload the `ellipsoid` function to provide the
reference ellipsoid of your datum. Or you could extend the conversion methods to
your new datum type as required.

#### Datums vs Ellipsoids

Typical geodetic datums contain more information than just the reference ellipsoid; they also contain the information to map a fixed point on the Earth's surface to a point on the ellipsoid.  Two different datums can use the same ellipsoid, but have a different origin and/or orientation relative to a set of points on the Earth's surface because they use different mappings from the ellipsoid to the Earth's surface.  For example, the _WGS84 datum_ ([EPSG6326](https://epsg.io/6326-datum) as used by GPS systems) and the _Vietnam2000 datum+ ([EPSG4756](https://epsg.io/4756-5194)) both use the _WGS84 ellipsoid_ ([EPSG7030](https://epsg.io/7030-ellipsoid)) but will have a different coordinate for the same place on Earth (e.g. Ho Chi Minh City), because the ellipsoids have been aligned relative to the Earth in different ways.

Comparing points in two different datums requires knowing the transformation to align the ellipses. However, this information is not provided within the `Geodesy` package (see the `Proj4.jl` package for this functionality over a wide range of geodetic datums).

### The `CRS` type — coordinate reference systems

Coordinate reference system types `CRS{CoordinateType, Datum}(datum::Datum)` have knowledge of both the coordinate *type* `CoordinateType` and the `datum` which is required to map a known `Position` on the Earth to a set of coordinates within the `CRS`. Note that `datum` is an instance of type `Datum` and may or may not contain real data in memory. An example of a zero-byte datum is `wgs84 = WGS84()`.

Examples of some `CRS`s are:

```julia
# An ECEF coordinate reference system based on the WGS 84 datum
CRS(ECEF, wgs84) == CRS{ECEF, WGS84}(wgs84)

# An LLA coordinate reference system based on the OSGB 36 datum
CRS(LLA, osgb36) == CRS{LLA, OSGB36}(osgb36)

# An ENU coordinate reference system centred on City Hall, Brisbane, Australia
CRS(ENU, Position(LLA(-27.468937, 153.023628, 0.0), grs80))
```

Note the third case, where the datum is a `Position` (introduced below) and
indicates a fully georeferenced origin, which would be required for transforming
points into a different `CRS`. The first two examples will take 0 bytes of memory,
while the third will use 24 bytes (three `Float64`s).

### The `Position` type — a point in a coordinate reference system

The `Position{CoordinateType, Datum}(x::CoordinateType, datum::Datum)` type includes both the coordinates
of a point `x` in the as a `CoordinateType`, and an instance of the `datum` similar to
the `CRS` type above.

Several constructor patterns for `Position` are defined:
```julia
# Central Station, Brisbane, Australia in CRS(LLA, wgs84)
Position(LLA(-27.465933, 153.025900, 0.0), wgs84)

# Central Station, Brisbane, Australia in CRS(ECEF, wgs84)
crs_ecef = CRS(ECEF, wgs84)
Position(crs_ecef, ECEF(-5.047163822270044e6,2.568785235597603e6,-2.92412130167394e6))

# Central Station, Brisbane, Australia in ENU CRS with origin at City Hall
crs_enu = CRS(ENU, Position(LLA(-27.468937, 153.023628, 0.0), grs80))
pos_enu = crs_enu(224.57025825199167,332.8739429179584,-0.01267685832033294)
# lowers to: crs_enu(ENU(224.57025825199167,332.8739429179584,-0.01267685832033294))
```

Once again, the first two examples explicitly store three `Float64`s, while the
third stores six `Float64`s. For efficient operations on many points sharing
the same ENU origin, it may be more efficient to process the data in raw `ENU`
type and use the `Position` type to facilitate input and output transformations
with `geotransform()`.

### Transformations via `geotransform()`

The `geotransform(crs::CRS, pos::Position)` function automatically converts
a position to the new coordinate reference system `crs`.

```julia
pos_lla = Position(LLA(-27.465933, 153.025900, 0.0), wgs84)
crs_ecef = CRS(ECEF, wgs84)
pos_ecef = geoconvert(crs_ecef, pos_lla)
```

This function generalizes nicely to arbitrarily complex datums for input and
output. The `geoconvert` function can be easily specialized for new types so
that users may define custom transformations.

Additionally, the coordinate type constructors (`LLA`, `ECEF`, etc) are
available to use as a low-level interface. Where it make sense, it may be best
to implement the conversions in these type constructors and direct
`geotransform` to use these, so the user may choose between the low-level and
high-level interfaces.
