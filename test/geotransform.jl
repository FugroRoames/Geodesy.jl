@testset "geotransform" begin
    # Define some consistent values
    lla = Position(LLA(42.3673, -71.0960, 0), wgs84)
    lla_ref = Position(LLA(42.36299, -71.09183, 0), wgs84)
    ecef = Position(ECEF(1529073.1560519305, -4465040.019013103, 4275835.339260309), wgs84)
    enu = Position(ENU(-343.493749083977, 478.764855466788, -0.027242885224325164), lla_ref)

    crs_lla = CRS(LLA, wgs84)
    crs_ecef = CRS(ECEF, wgs84)
    crs_enu = CRS(ENU, lla_ref)

    # Identity transforms (should be exact)
    @test geotransform(crs_ecef, ecef) == ecef
    @test geotransform(crs_lla, lla) == lla
    @test geotransform(crs_enu, enu) == enu

    # ECEF <-> LLA
    ecef_new = geotransform(crs_ecef, lla)
    @xyz_approx_eq ecef_new.x ecef.x

    lla_new = geotransform(crs_lla, ecef)
    @xyz_approx_eq lla_new.x lla.x

    # LLA <-> ENU
    enu_new = geotransform(crs_enu, lla)
    @xyz_approx_eq enu_new.x enu.x
    @xyz_approx_eq enu_new.datum.x enu.datum.x

    lla_new = geotransform(crs_lla, enu)
    @xyz_approx_eq lla_new.x lla.x

    # ECEF <-> ENU
    enu_new = geotransform(crs_enu, ecef)
    @xyz_approx_eq enu_new.x enu.x
    @xyz_approx_eq enu_new.datum.x enu.datum.x

    ecef_new = geotransform(crs_ecef, enu)
    @xyz_approx_eq ecef_new.x ecef.x
end
