@testset "CRSs and Positions" begin
    ############
    ### ECEF ###
    ############

    crs_ecef = CRS(ECEF, wgs84)
    pos_ecef = Position(ECEF(1.,2.,3.), wgs84)

    # Some trivial transformations
    @test CRS(pos_ecef) == crs_ecef
    @test Position(ECEF(1.,2.,3.), crs_ecef) == pos_ecef
    @test crs_ecef(ECEF(1.,2.,3.)) == pos_ecef
    @test crs_ecef(1.,2.,3.) == pos_ecef
    @test ECEF(pos_ecef) == ECEF(1.,2.,3.)

    ###########
    ### LLA ###
    ###########

    crs_lla = CRS(LLA, wgs84)
    pos_lla = Position(LLA(1.,2.,3.), wgs84)

    # Some trivial transformations
    @test CRS(pos_lla) == crs_lla
    @test Position(LLA(1.,2.,3.), crs_lla) == pos_lla
    @test crs_lla(LLA(1.,2.,3.)) == pos_lla
    @test crs_lla(1.,2.,3.) == pos_lla
    @test LLA(pos_lla) == LLA(1.,2.,3.)

    ###########
    ### ENU ###
    ###########
    crs_enu = CRS(ENU, pos_lla)
    pos_enu = Position(ENU(2.,3.,4.), pos_lla)

    # Some trivial transformations
    @test CRS(pos_enu) == crs_enu
    @test Position(ENU(2.,3.,4.), crs_enu) == pos_enu
    @test crs_enu(ENU(2.,3.,4.)) == pos_enu
    @test crs_enu(2.,3.,4.) == pos_enu
    @test ENU(pos_enu) == ENU(2.,3.,4.)


end # @testset
