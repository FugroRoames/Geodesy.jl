# Geodesy

[![Build Status](https://travis-ci.org/JuliaGeo/Geodesy.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/Geodesy.jl)
[![Coverage Status](http://img.shields.io/coveralls/JuliaGeo/Geodesy.jl.svg)](https://coveralls.io/r/JuliaGeo/Geodesy.jl)

The `Geodesy` package defines an interface for local and geodetic transformations
between coordinate reference systems, and implements some common geodetic
coordinates based on elliptical models of the world.


### Terminology

![Coordinate Reference systems](http://www.crs-geo.eu/SharedDocs/Bilder/CRS/schema-crs-datum-cs,property=default.gif)
[www.crs-geo.eu](http://www.crs-geo.eu/nn_124224/crseu/EN/CRS__Overview/definition-crs__node.html).

[View the above as a data structure](http://i.stack.imgur.com/aeS8k.png)

The above images gives a quick picture of the components of the coordinate reference systems used in geodesy, with the data structure link showing the data structure used by the EPSG authority for the WGS84 (GPS) coordinate reference system as shown on the [EPSG website](http://www.epsg-registry.org/)).

This Geodesy package is intended for use with the "Coordinate System" subtypes shown above. Following this Geodesy position types do not have full datum knowledge (e.g. where the coordinate system's origin is relative to the Earth), only the reference ellipsoid required to perform the coordindate system transforms.  Transforms defined in this package convert between coordinate systems (e.g. longitude latitude height -> cartesian etc), although a coordinate reference system type is currently provided to facilitate importing and exporting data.


### "Coordinate System" Types

The below types are parameterised by a reference datum. Note that the coordinate system types only "understands" the datum's ellipse; however using a datum type as a parameter is a convenient way to get the reference ellipse while also stopping direct comparison of points from different datums (that may use the same ellipse).  A discussion on datums vs ellipses is given later in this readme.

Some common ellipses and datums are provided, and custom ellipse's can also be used. For a list of all predefined datums, use `Geodesy.get_datums()`

1. `LLA`   - Longitude, [(geodetic) latitude](https://en.wikipedia.org/wiki/Latitude#Geodetic_and_geocentric_latitudes), altitude coordinate

2. `LL`    - Longitude, [(geodetic) latitude](https://en.wikipedia.org/wiki/Latitude#Geodetic_and_geocentric_latitudes) coordinate to be on the ellipse's surface

3. `ECEF`  - Cartesian coordinate.  Note that ECEF has a [meaning beyong a Cartesian coordinate system](https://en.wikipedia.org/wiki/ECEF), however it is used in this package to mean only a Cartesian coordinate system with origin equal to the ellipse's center.  

The below type is parameterized by an `LL` point which determines the origin and axis directions of the local coordinate system.  The `LL` parameter can be omitted from the template and passed to function seperately if desired.

4. `ENU`   - East North Up position in the local coordinate frame.


### "Coordinate **Reference** System" Types

Coordinate reference sytem types have knowledge of the datum which is required to map a known point on the Earth to a position in the coordinate system. The [Proj4 package](https://github.com/FugroRoames/Proj4.jl) is currently used as a backend to allow transforming to / from / between "Coordinate _Reference_ Systems".

The below type is parameterised by a [spatial reference ID (SRID)](https://en.wikipedia.org/wiki/SRID). Note that SRIDs are used to describe more than just coordinate reference systems, so take care when selecting a suitable SRID.

1. `CRS` - The coordinate _reference_ system point type.  This type should be used for operations that require knowledge of the datum, e.g. swapping between datums. Transformations involving this type are perfromed by Proj4 as a full understanding of coordinate reference systems is outside the scope of this package. It's left to the user to correctly interpret the fields of this type as different SRIDs use different coordinate systems ([lat, long, height] / [x, y, z] / [false east, false north, height] / etc).

**Roadmap note**: Coordinate reference system types should be migrated to backend packages (Proj4 etc), with the Geodesy package providing common interface methods for them (functions to overload etc).  This change would mean Proj4 depends on Geodesy instead of Geodesy depending on Proj4 matching Geodesy being a "low level" package.  This also allows different backend packages to have their own coordinate reference system type.


#### Datums vs Ellipsoids

Datums contain more information than just the reference ellipse, they also contain the information to map a fixed point on the Earth's surface to a point on the ellipse.  Two different datums can use the same ellipse, but have a different origin and / or orientation relative to a set of points on the Earth's surface because they use different mappings from the ellipse to the Earth's surface.  For example, the _WGS84 datum_ ([EPSG6326](https://epsg.io/6326-datum) as used by GPS systems) and the _Vietnam2000 datum+ ([EPSG4756](https://epsg.io/4756-5194)) both use the _WGS84 ellipsoid_ ([EPSG7030](https://epsg.io/7030-ellipsoid)) but will have a different coordinate for the same place on Earth (e.g. Ho Chi Minh City), because the ellipses have been aligned relative to the Earth in different ways.  In the Geodesy package,

Comparing points in two different datums requires knowing the transformation to align the ellipses.  This information is only known for the "coordinate _reference_ system" (`CRS`) type.



### Transformations vs Conversions

1. `geotransform` is used for value modifying transformations, e.g.:
```julia
    lla_wgs84 = LLA{WGS84}(0.0,0.0,0.0)
    geotransform(ECEF, lla_wgs84) # = ECEF{WGS84}(6.378137e6,0.0,0.0)
```


2. `convert` is used for value preserving transformations, e.g. change the position's type to include the coordinate reference system:
```julia
    lla_wgs84 = LLA{WGS84}(0.0,0.0,0.0)  # position in the LLA coordinate system using the WGS84 reference ellipsoid.  Note multiple datums use the WGS84 ellipse.
    lla_wgs84_srid = SRID(LLA{WGS84})    # define the coordinate reference system for the WGS84 datum with LLA coordinate system

    # the position is the same!    
    convert(CRS{lla_wgs84_srid}, lla_wgs84) # = CRS{EPSG4326}(0.0,0.0,0.0)    
```
`convert` will / should not change values!

Type constructors are overloaded to use the `geotransform` function where applicable
