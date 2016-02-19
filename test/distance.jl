using Geodesy
using Geodesy: ED50
using Base.Test

@test_approx_eq distance(ENU(1, 1, 1), ENU(2, 2, 2)) sqrt(3)
@test_approx_eq distance(ECEF(1, 1, 1), ECEF(3, 3, 3)) sqrt(12)
let lla = LLA(1, 2, 3)
    @test_throws MethodError distance(lla, lla)
end

randLLA() = LLA{WGS84}((rand() - .5) * 360,
				       (rand() - .5) * 180,
                       (rand() - .5) * 18_000)

# Test ECEF/ENU distance equivalence

for _ = 1:1_000
    lla1 = randLLA()
    lla2 = randLLA()

    enu1a = ENU(lla1, lla1)
    enu2a = ENU(lla2, lla1)

    ecef1a = ECEF(lla1)
    ecef2a = ECEF(lla2)

    @test_approx_eq distance(enu1a, enu2a) distance(ecef1a, ecef2a)
end

# Test WGS84 data
# Source: http://geographiclib.sourceforge.net/1.1/geodesic.html

for (lat1, lon1, azi1, lat2, lon2, azi2, s12, a12, m12, area) in [
    # random
    (13.34131310843, 0, 64.893732588321, 27.167030166114807887, 81.147882318022755456, 98.180388726997955923, 8484008.9511816, 76.426044312192519403, 6185338.0042860860151, 23494817394476.983874),
    (29.35936791137, 0, 3.562776653705, 67.931453540325162437, 170.572112180718477742, 171.729063831994540061, 9188093.1894032, 82.602801498601116, 6334987.8142568269251, 119120891536718.654989),
    (17.365583427331, 0, 106.832754755529, -23.719740766843660611, 143.94225684272702158, 86.009322008401023546, 16216991.9060447, 146.134657498478139171, 3545186.5038365272107, -14695430107490.419363),
    (48.225427017676, 0, 119.239152833356, 4.900279381681411244, 49.439329609674356182, 144.230393300911335776, 6700530.0165299, 60.344013877711501923, 5530443.3028408957319, 17653442365603.374915),

    # nearly antipodal
    (38.310693597209, 0, 13.055421665051, -37.99474655739563392, 179.800407280950849166, 167.00176496813340991, 19966877.947874, 179.675966711820268126, 75499.3174931018213, 109009980753799.724835),
    (22.977144517038, 0, 122.603891541977, -23.169021570280095852, 179.206837703954580828, 57.523483269982844513, 19944201.7818916, 179.644110241838873311, 55984.8030212716797, -45965171372686.893463),
    (32.617903598529, 0, 117.001691155741, -32.783714078432253875, 179.160224074954599178, 63.207164700860993621, 19944331.9513927, 179.633995938746164263, 50407.0843857503313, -38005514593031.257346),
    (36.25014491329, 0, 104.397824516396, -36.265811672674164215, 179.452719450823176582, 75.646812747826007655, 19976387.5305775, 179.936961729692998254, 9702.9269601585606, -20311056951502.674737),

    # short distances
    (7.512857811123, 0, 19.179996654393, 7.512970768929170776, .0000393712808054, 19.180001802174479956, 13.2265639, .000119209131652008, 13.2265638999905, 3630790.473767),
    (60.577316649216, 0, 51.477685773428, 60.581278059486801371, .010115459170752622, 51.486496706339778805, 708.7627697, .006372099166879661, 708.7627682463562, 6235117278.20435),
    (25.004926378698, 0, 111.712849557686, 25.004832186058303729, .000259567207005928, 111.712959275561025562, 28.203346, .000254055203171289, 28.2033459999077, 77441164.466799),
    (84.118481951125, 0, 94.447662813765, 84.118029655588002885, .056382918243493123, 94.503748905242322208, 647.3047293, .005815043081559776, 647.3047281960948, 39730883653.342566),

    # one end near pole
    (89.99441357489, 0, 108.409374600533, 67.187701448774233223, 71.578016303409870693, 179.986321804301608569, 2546481.7111054, 22.879378547944501141, 2479770.9556252980024, 50706854674009.113617),
    (89.993683218483, 0, 137.249500453314, -8.627003845730393534, 42.751125116580170258, 179.995648792331395129, 10955444.4092702, 98.593858084909860974, 6306522.9078558324466, 30282404215629.211912),
    (89.992173317056, 0, 13.90689177244, 27.740193102384975039, 166.092112190149224805, 179.997869019139657646, 6933163.6633116, 62.346626656988626695, 5649575.4547274351368, 117662908002758.730672),
    (89.99100400556, 0, 21.35479737404, -33.934802175065847398, 158.647383210433154775, 179.996042526461038959, 13759331.1308878, 123.854141018333117523, 5296783.2872557291945, 112385332108250.260572),

    # ends near opposite poles
    (89.997595195216, 0, 179.619593949157, -89.993757086836343885, .526939485610036088, 179.853466395429310428, 20002965.5687943, 179.991323264018997889, 965.8895184347734, 165680964874.397503),
    (89.995765698917, 0, 153.12232383545, -89.996211465670864213, 176.527666913598374567, 30.349989028255825932, 20003874.7682409, 179.999490741949810376, 56.690601014786, -86974926782513.13143),
    (89.993659799817, 0, 116.603332371716, -89.994016930268323357, 134.74824745276636986, 108.648360077793119385, 20003400.6490436, 179.995231659367964821, 530.80913864348, -5635497067621.528193),
    (89.990644140796, 0, 30.46588676412, -89.989017576528539514, 175.124277494839408787, 154.40978557307445724, 20003725.8286419, 179.998152796509465907, 205.6313961813705, 87804891390950.526562),

    # nearly meridional
    (64.715000600285, 0, 179.996224985326, 8.300822939700970608, .003170819821410212, 179.99836617721385843, 6261642.7021158, 56.367229161264380247, 5301555.0052719458082, 1513999906.274607),
    (9.942453894759, 0, 179.997872956141, -83.118967952518969703, .017659335996671428, 179.982568934704861551, 10332922.954675, 93.005823560078472002, 6365254.4421798373908, -10836007339.812858),
    (35.084724228461, 0, 179.999375888592, -17.59161194552863581, .000517914072294356, 179.999463803115894174, 5829774.6537315, 52.5305200980786251, 5046870.9808586923786, 62063370.750408),
    (74.869415682946, 0, .003912050298, 50.158127543633727267, 179.994997645955753609, 179.998404330082463559, 6133133.7314448, 55.115697853366717881, 5235493.1516311444341, 127512500697476.134139),

    # nearly equatorial
    (.000781908619, 0, 89.996315754589, .00113877572073136, 5.579164251062796394, 89.996409342160800773, 621069.7246462, 5.597933071232296147, 620082.0999033472963, 66003372.470098),
    (.00359314356, 0, 89.996052792958, -.003009733334200574, 171.458850316526555958, 90.004405319663036586, 19086711.9083442, 172.035653279020831801, 880771.6586722240014, 5890685275.699263),
    (.004051952929, 0, 90.00047847819, -.000831645030925742, 94.684815255707904411, 90.00398124980729247, 10540265.4251863, 95.003343523917344558, 6332530.6112875111861, 2470357284.501839),
    (.003167017824, 0, 90.000698533704, .002970767627028171, 11.153642898368961157, 90.001297854876781738, 1241617.8463507, 11.191164740509070739, 1233738.0764828187615, 422675979.680255),

    # running between vertices
    (77.168961116231, 0, 90, -77.168961116231, 179.865654057283834783, 90.000000000000000002, 20002265.499854625753, 180, .0000000000001, .000002),
    (68.172063421589, 0, 90, -68.172063421589, 179.775116649629150722, 90.000000000000000001, 19999263.6453246101296, 180, .0000000000001, .000001),
    (72.350857979384, 0, 90, -72.350857979384, 179.816605713764011176, 90.000000000000000003, 20000827.0495409551884, 179.999999999999999999, .0000000000001, .000002),
    (47.474134062996, 0, 90, -47.474134062996, 179.591518711643492433, 90, 19988532.7238678314003, 180, 0, 0),

    # ending close to vertices
    (24.04314613745, 0, 90.045671956752, -24.043146137492923579, 179.448625072251282743, 89.954328067136969735, 19975879.31117, 179.999999946272898281, .0416508759595, -64468770242.133552),
    (43.407004212773, 0, 90.041907806109, -43.407004212805402022, 179.561037570819915051, 89.958092235644803931, 19986149.3817786, 179.999999955708889468, .0239608044566, -59236521272.663064),
    (60.893175111551, 0, 90.030887879944, -60.893175111602473374, 179.705866045884665835, 89.969112291280908219, 19995946.5267377, 179.99999990435001247, .0152818050346, -43716837097.405323),
    (57.297318482011, 0, 90.006736496503, -57.297318482011214432, 179.673356341455815136, 89.993263506332003021, 19994084.1111944, 179.999999998173649615, .000475461712, -9532089026.025471)
]
    p1 = LL{WGS84}(lon1, lat1)
    p2 = LL{WGS84}(lon2, lat2)

    try
        vi = Geodesy.vicentys_inverse(p1, p2)
        @test abs(vi[1] - s12) < 1e-4
    catch e
        @test contains(e.msg, "antipodal")
        @test 179 < abs(lon2 - lon1) < 181
    end
end

# Test data over the Hayford ellipsoid, "exact" distances this time
# Source: http://geographiclib.sourceforge.net/1.1/geodesic.html

function todec(x)
    r = match(r"^([\-0-9]+)d([0-9]+)'([0-9\.]+)$", x)
    Geodesy.dms2decimal(map(float, r.captures)...)
end
function testvals(t)
    lat1, lat2, dlon, azi1, azi2, s12 = t
    todec(lat1), todec(lat2), todec(dlon), todec(azi1), todec(azi2), float(s12)
end

for t in [
    ("37d19'54.95367" ,"26d07'42.83946"  ,"41d28'35.50729" ,"95d27'59.63088905553491" ,"118d05'58.96160858886728","4085966.7025902201825" )
    ("35d16'11.24862" ,"67d22'14.77638"  ,"137d47'28.31435","15d44'23.74849770324814" ,"144d55'39.92147266777383","8084823.8382961415712" )
    ("1d00'00"        ,"-0d59'53.83076"  ,"179d17'48.02997","88d59'59.99897053696689" ,"91d00'06.11835637659787" ,"19959999.9998034962728")
    ("1d00'00"        ,"1d01'15.18952"   ,"179d46'17.84244","4d59'59.9999565312182"   ,"174d59'59.88480004914149","19780006.5587880182731")
    ("41d41'45.88"    ,"-41d41'46.20"    ,"179d59'59.44"   ,"179d58'49.16247860972594","0d01'10.83761892414861"  ,"20004566.7228054132931")
    ("0d00'00"        ,"0d00'00"         ,"179d41'49.78063","30d00'00.00002084815889" ,"149d59'59.99997915184111","19996147.416826781925" )
    ("30d00'00"       ,"-30d00'00"       ,"179d40'00"      ,"39d24'51.80601183179472" ,"140d35'08.19398816820528","19994364.6068583984182")
    ("60d00'00"       ,"-59d59'00"       ,"179d50'00"      ,"29d11'51.07006518417487" ,"150d49'06.86792886226858","20000433.9629039632049")
    ("30d00'00"       ,"-29d50'00"       ,"179d48'00"      ,"16d02'28.33895348073478" ,"163d59'10.33689436714454","19983420.1535833515076")
    ("30d00'00"       ,"-29d55'00"       ,"179d48'00"      ,"18d38'12.55689701007199" ,"161d22'45.43724069005652","19992241.7634404403113")
    ("34d28'44.76421" ,"-34d28'44.76421" ,"179d30'00"      ,"89d59'59.78608904242135" ,"90d00'00.21391095757865" ,"19981603.2781440234735")
    ("0d00'00"        ,"0d00'00"         ,"179d23'38.18182","89d59'51.5863776476884"  ,"90d00'08.4136223523116"  ,"19970827.8695289752144")
    ("34d28'44.764213","-34d28'44.764213","179d30'00"      ,"90d00'00.00000000479721" ,"90d00'00.00000000479721" ,"19981603.2781440234735")
    ("56d41'58.297496","-56d41'58.297496","179d40'00"      ,"90d00'00.0000006754891"  ,"90d00'00.0000006754891"  ,"19994364.6068583984183")
    ("29d45'00"       ,"29d45'00.23848"  ,"0d00'00.25626"  ,"43d09'29.0634310812721"  ,"43d09'29.19059165112047" ,"10.0665488514951"      )
    ("41d41'45.88"    ,"41d41'46.2"      ,"0d00'00.56"     ,"52d40'39.39067110974434" ,"52d40'39.76317180931766" ,"16.2839750636094"      )
    ("46d00'00"       ,"46d00'01"        ,"0d00'01.816"    ,"51d41'11.54166708300919" ,"51d41'12.8479912183896"  ,"49.8037586266135"      )
    ("40d00'00"       ,"40d00'02"        ,"0d00'04.75"     ,"61d18'00.21784992705284" ,"61d18'03.27110871411274" ,"128.4581417556041"     )
    ("38d00'00"       ,"38d00'04.765"    ,"0d00'05.554"    ,"42d41'10.35602545797828" ,"42d41'13.77545984493403" ,"199.8717376568129"     )
    ("30d00'00"       ,"37d53'32.46584"  ,"116d19'16.68843","45d00'00.00000438165649" ,"129d08'12.32600911217221","10002499.999860115911" )
    ("30d19'54.95367" ,"-30d11'50.15681" ,"179d58'17.84244","2d23'52.10812966032674"  ,"177d36'19.67010864697937","19989590.5480170316779")
    ("0d39'49.12586"  ,"-0d45'14.13112"  ,"179d58'17.84244","177d39'39.01010365081902","2d20'21.15303599834387"  ,"19994529.4454322340309")
    ("0d00'54.95367"  ,"0d00'42.83946"   ,"179d28'17.84244","54d08'27.73161935117439" ,"125d51'32.27232710890937","19977290.7711390609949")
    ("40d00'00"       ,"-40d00'05.75932" ,"179d55'15.59578","170d15'10.8812277902834" ,"9d44'49.94565915545135"  ,"20003827.8511392345191")
    ("37d00'00"       ,"28d15'36.69535"  ,"2d37'39.52918"  ,"164d59'59.99997936397788","166d25'16.2593819478948" ,"1000000.0001515200393" )
    ("38d30'45"       ,"-35d25'35"       ,"179d45'00"      ,"3d22'19.5694402667547"   ,"176d45'41.43721792855263","19661438.0251956080829")
    ("60d00'00"       ,"-60d00'00"       ,"179d41'47"      ,"90d00'00.00891264563132" ,"90d00'00.00891264563132" ,"19996104.3689008382234")
]
    lat1, lat2, dlon, azi1, azi2, s12 = testvals(t)

    p1 = LL{ED50}(0, lat1)
    p2 = LL{ED50}(dlon, lat2)

    try
        vi = Geodesy.vicentys_inverse(p1, p2)
        @test abs(vi[1] - s12) < 1e-4
    catch e
        @test contains(e.msg, "antipodal")
        @test 179 < dlon < 181
    end
end
