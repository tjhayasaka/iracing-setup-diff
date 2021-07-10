module Master exposing (cars, tracks)

import Car
import Dict exposing (Dict)
import Setup
import Track


toDictEntry item =
    ( item.id, item )


toDict items =
    Dict.fromList (List.map toDictEntry items)


cars : Dict Car.Id Car.Car
cars =
    toDict
        [ { id = 24, shortName = "stockcars2 chevy", longName = "ARCA Menards Chevrolet Impala" }
        , { id = 64, shortName = "astonmartin dbr9", longName = "Aston Martin DBR9 GT1" }
        , { id = 76, shortName = "audi90gto", longName = "Audi 90 GTO" }
        , { id = 98, shortName = "audir18", longName = "Audi R18" }
        , { id = 73, shortName = "audir8gt3", longName = "Audi R8 LMS" }
        , { id = 112, shortName = "audirs3lms", longName = "Audi RS 3 LMS" }
        , { id = 132, shortName = "bmwm4gt3", longName = "BMW M4 GT3" }
        , { id = 122, shortName = "bmwm4gt4", longName = "BMW M4 GT4" }
        , { id = 109, shortName = "bmwm8gte", longName = "BMW M8 GTE" }
        , { id = 41, shortName = "cadillacctsvr", longName = "Cadillac CTS-V Racecar" }
        , { id = 26, shortName = "c6r", longName = "Chevrolet Corvette C6.R GT1" }
        , { id = 70, shortName = "c7vettedp", longName = "Chevrolet Corvette C7 Daytona Prototype" }
        , { id = 127, shortName = "c8rvettegte", longName = "Chevrolet Corvette C8.R GTE" }
        , { id = 12, shortName = "latemodel", longName = "Chevrolet Monte Carlo SS" }
        , { id = 106, shortName = "dallaraf3", longName = "Dallara F3" }
        , { id = 99, shortName = "dallarair18", longName = "Dallara IR18" }
        , { id = 128, shortName = "dallarap217", longName = "Dallara P217" }
        , { id = 129, shortName = "dallarair01", longName = "Dallara iR-01" }
        , { id = 134, shortName = "dirtmodified 358", longName = "Dirt 358 Modified" }
        , { id = 131, shortName = "dirtmodified bigblock", longName = "Dirt Big Block Modified" }
        , { id = 78, shortName = "dirtlatemodel 350", longName = "Dirt Late Model - Limited" }
        , { id = 83, shortName = "dirtlatemodel 358", longName = "Dirt Late Model - Pro" }
        , { id = 84, shortName = "dirtlatemodel 438", longName = "Dirt Late Model - Super" }
        , { id = 82, shortName = "legends dirtford34c", longName = "Dirt Legends Ford '34 Coupe" }
        , { id = 96, shortName = "dirtmidget", longName = "Dirt Midget" }
        , { id = 80, shortName = "dirtsprint winged 305", longName = "Dirt Sprint Car - 305" }
        , { id = 85, shortName = "dirtsprint winged 360", longName = "Dirt Sprint Car - 360" }
        , { id = 87, shortName = "dirtsprint nonwinged 360", longName = "Dirt Sprint Car - 360 Non-Winged" }
        , { id = 86, shortName = "dirtsprint winged 410", longName = "Dirt Sprint Car - 410" }
        , { id = 89, shortName = "dirtsprint nonwinged 410", longName = "Dirt Sprint Car - 410 Non-Winged" }
        , { id = 79, shortName = "dirtstreetstock", longName = "Dirt Street Stock" }
        , { id = 95, shortName = "dirtumpmod", longName = "Dirt UMP Modified" }
        , { id = 94, shortName = "ferrari488gt3", longName = "Ferrari 488 GT3" }
        , { id = 93, shortName = "ferrari488gte", longName = "Ferrari 488 GTE" }
        , { id = 81, shortName = "fordfiestarswrc", longName = "Ford Fiesta RS WRC" }
        , { id = 40, shortName = "fordgt", longName = "Ford GT GT2/GT3" }
        , { id = 59, shortName = "fordgt gt3", longName = "Ford GT GT3" }
        , { id = 92, shortName = "fordgt2017", longName = "Ford GTE" }
        , { id = 30, shortName = "fr500s", longName = "Ford Mustang FR500S" }
        , { id = 74, shortName = "formularenault20", longName = "Formula Renault 2.0" }
        , { id = 105, shortName = "formularenault35", longName = "Formula Renault 3.5" }
        , { id = 142, shortName = "formulavee", longName = "Formula Vee" }
        , { id = 67, shortName = "mx5 mx52016", longName = "Global Mazda MX-5 Cup" }
        , { id = 39, shortName = "hpdarx01c", longName = "HPD ARX-01c" }
        , { id = 120, shortName = "indypropm18", longName = "Indy Pro 2000 PM-18" }
        , { id = 44, shortName = "kiaoptima", longName = "Kia Optima" }
        , { id = 133, shortName = "lamborghinievogt3", longName = "Lamborghini Huracán GT3 EVO" }
        , { id = 5, shortName = "legends ford34c", longName = "Legends Ford '34 Coupe" }
        , { id = 11, shortName = "legends ford34c rookie", longName = "Legends Ford '34 Coupe - Rookie" }
        , { id = 42, shortName = "lotus49", longName = "Lotus 49" }
        , { id = 25, shortName = "lotus79", longName = "Lotus 79" }
        , { id = 113, shortName = "protrucks pro2lite", longName = "Lucas Oil Off Road Pro 2 Lite" }
        , { id = 104, shortName = "protrucks pro2truck", longName = "Lucas Oil Off Road Pro 2 Truck" }
        , { id = 107, shortName = "protrucks pro4truck", longName = "Lucas Oil Off Road Pro 4 Truck" }
        , { id = 135, shortName = "mclaren570sgt4", longName = "McLaren 570S GT4" }
        , { id = 43, shortName = "mclarenmp4", longName = "McLaren MP4-12C GT3" }
        , { id = 71, shortName = "mclarenmp430", longName = "McLaren MP4-30" }
        , { id = 72, shortName = "mercedesamggt3", longName = "Mercedes AMG GT3" }
        , { id = 31, shortName = "skmodified tour", longName = "Modified - NASCAR Whelen Tour" }
        , { id = 2, shortName = "skmodified", longName = "Modified - SK" }
        , { id = 124, shortName = "stockcars chevymontecarlo87", longName = "NASCAR Chevrolet Monte Carlo - 1987" }
        , { id = 103, shortName = "stockcars camarozl12018", longName = "NASCAR Cup Series Chevrolet Camaro ZL1" }
        , { id = 110, shortName = "stockcars fordmustang2019", longName = "NASCAR Cup Series Ford Mustang" }
        , { id = 139, shortName = "stockcars chevycamarozl12022", longName = "NASCAR Cup Series Next Gen Chevrolet Camaro ZL1" }
        , { id = 140, shortName = "stockcars fordmustang2022", longName = "NASCAR Cup Series Next Gen Ford Mustang" }
        , { id = 141, shortName = "stockcars toyotacamry2022", longName = "NASCAR Cup Series Next Gen Toyota Camry" }
        , { id = 56, shortName = "stockcars toyotacamry", longName = "NASCAR Cup Series Toyota Camry" }
        , { id = 125, shortName = "stockcars fordthunderbird87", longName = "NASCAR Ford Thunderbird - 1987" }
        , { id = 111, shortName = "trucks silverado2019", longName = "NASCAR Gander Outdoors Chevrolet Silverado" }
        , { id = 123, shortName = "trucks fordf150", longName = "NASCAR Gander Outdoors Ford F150" }
        , { id = 62, shortName = "trucks tundra2015", longName = "NASCAR Gander Outdoors Toyota Tundra" }
        , { id = 63, shortName = "trucks silverado2015", longName = "NASCAR Trucks Series Chevrolet Silverado - 2018" }
        , { id = 114, shortName = "stockcars2 camaro2019", longName = "NASCAR XFINITY Chevrolet Camaro" }
        , { id = 115, shortName = "stockcars2 mustang2019", longName = "NASCAR XFINITY Ford Mustang" }
        , { id = 116, shortName = "stockcars2 supra2019", longName = "NASCAR XFINITY Toyota Supra" }
        , { id = 77, shortName = "nissangtpzxt", longName = "Nissan GTP ZX-T" }
        , { id = 3, shortName = "solstice", longName = "Pontiac Solstice" }
        , { id = 10, shortName = "solstice rookie", longName = "Pontiac Solstice - Rookie" }
        , { id = 119, shortName = "porsche718gt4", longName = "Porsche 718 Cayman GT4 Clubsport MR" }
        , { id = 88, shortName = "porsche911cup", longName = "Porsche 911 GT3 Cup (991)" }
        , { id = 137, shortName = "porsche911rgt3", longName = "Porsche 911 GT3 R" }
        , { id = 102, shortName = "porsche991rsr", longName = "Porsche 911 RSR" }
        , { id = 100, shortName = "porsche919", longName = "Porsche 919" }
        , { id = 13, shortName = "radical sr8", longName = "Radical SR8" }
        , { id = 48, shortName = "rufrt12r awd", longName = "Ruf RT 12R AWD" }
        , { id = 52, shortName = "rufrt12r track cspec", longName = "Ruf RT 12R C-Spec" }
        , { id = 49, shortName = "rufrt12r rwd", longName = "Ruf RT 12R RWD" }
        , { id = 50, shortName = "rufrt12r track", longName = "Ruf RT 12R Track" }
        , { id = 23, shortName = "specracer", longName = "SCCA Spec Racer Ford" }
        , { id = 18, shortName = "silvercrown", longName = "Silver Crown" }
        , { id = 1, shortName = "rt2000", longName = "Skip Barber Formula 2000" }
        , { id = 37, shortName = "sprint", longName = "Sprint Car" }
        , { id = 36, shortName = "streetstock", longName = "Street Stock" }
        , { id = 101, shortName = "subaruwrxsti", longName = "Subaru WRX STI" }
        , { id = 54, shortName = "superlatemodel", longName = "Super Late Model" }
        , { id = 118, shortName = "v8supercars fordmustanggt", longName = "Supercars Ford Mustang GT" }
        , { id = 117, shortName = "v8supercars holden2019", longName = "Supercars Holden ZB Commodore" }
        , { id = 121, shortName = "usf2000usf17", longName = "USF 2000" }
        , { id = 91, shortName = "vwbeetlegrc", longName = "VW Beetle" }
        , { id = 138, shortName = "vwbeetlegrc lite", longName = "VW Beetle - Lite" }
        , { id = 27, shortName = "jettatdi", longName = "VW Jetta TDI Cup" }
        , { id = 33, shortName = "williamsfw31", longName = "Williams-Toyota FW31" }
        , { id = 55, shortName = "bmwz4gt3", longName = "[Legacy] BMW Z4 GT3" }
        , { id = 57, shortName = "dallaradw12", longName = "[Legacy] Dallara DW12" }
        , { id = 29, shortName = "dallara", longName = "[Legacy] Indycar Dallara - 2009" }
        , { id = 34, shortName = "mx5 cup", longName = "[Legacy] Mazda MX-5 Cup - 2010" }
        , { id = 35, shortName = "mx5 roadster", longName = "[Legacy] Mazda MX-5 Roadster - 2010" }
        , { id = 22, shortName = "stockcars impala", longName = "[Legacy] NASCAR Cup Chevrolet Impala COT - 2009" }
        , { id = 45, shortName = "stockcars chevyss", longName = "[Legacy] NASCAR Cup Chevrolet SS - 2013" }
        , { id = 46, shortName = "stockcars fordfusion", longName = "[Legacy] NASCAR Cup Ford Fusion - 2016" }
        , { id = 38, shortName = "stockcars2 chevy cot", longName = "[Legacy] NASCAR Nationwide Chevrolet Impala - 2012" }
        , { id = 20, shortName = "trucks silverado", longName = "[Legacy] NASCAR Truck Chevrolet Silverado - 2008" }
        , { id = 58, shortName = "stockcars2 nwcamaro2014", longName = "[Legacy] NASCAR Xfinity Chevrolet Camaro - 2014" }
        , { id = 51, shortName = "stockcars2 nwford2013", longName = "[Legacy] NASCAR Xfinity Ford Mustang - 2016" }
        , { id = 69, shortName = "stockcars2 camry2015", longName = "[Legacy] NASCAR Xfinity Toyota Camry - 2015" }
        , { id = 4, shortName = "formulamazda", longName = "[Legacy] Pro Mazda" }
        , { id = 21, shortName = "rileydp", longName = "[Legacy] Riley MkXX Daytona Prototype - 2008" }
        , { id = 61, shortName = "v8supercars ford2014", longName = "[Legacy] V8 Supercar Ford FG Falcon - 2014" }
        , { id = 28, shortName = "fordv8sc", longName = "[Legacy] V8 Supercar Ford Falcon - 2009" }
        , { id = 60, shortName = "v8supercars holden2014", longName = "[Legacy] V8 Supercar Holden VF Commodore - 2014" }
        ]


tracks : Dict Track.Id Track.Track
tracks =
    toDict
        [ { id = -1, shortName = "baseline", longName = "<baseline>" }
        , { id = 52, shortName = "atlanta legends oval", longName = "Atlanta Motor Speedway - Legends Oval" }
        , { id = 53, shortName = "atlanta oval", longName = "Atlanta Motor Speedway - Oval" }
        , { id = 323, shortName = "atlanta rallycross long", longName = "Atlanta Motor Speedway - Rallycross Long" }
        , { id = 322, shortName = "atlanta rallycross short", longName = "Atlanta Motor Speedway - Rallycross Short" }
        , { id = 51, shortName = "atlanta roadcourse", longName = "Atlanta Motor Speedway - Road Course" }
        , { id = 226, shortName = "auto club speedway competition", longName = "Auto Club Speedway - Competition" } -- can't find package of pkgid '151'
        , { id = 228, shortName = "auto club speedway interior", longName = "Auto Club Speedway - Interior" } -- can't find package of pkgid '151'
        , { id = 227, shortName = "auto club speedway moto", longName = "Auto Club Speedway - Moto" } -- can't find package of pkgid '151'
        , { id = 225, shortName = "auto club speedway oval", longName = "Auto Club Speedway - Oval" } -- can't find package of pkgid '151'
        , { id = 266, shortName = "autodromo internazionale enzo e dino ferrari grand prix", longName = "Autodromo Internazionale Enzo e Dino Ferrari - Grand Prix" } -- can't find package of pkgid '197'
        , { id = 267, shortName = "autodromo internazionale enzo e dino ferrari moto", longName = "Autodromo Internazionale Enzo e Dino Ferrari - Moto" } -- can't find package of pkgid '197'
        , { id = 247, shortName = "autodromo nazionale monza combined", longName = "Autodromo Nazionale Monza - Combined" } -- can't find package of pkgid '172'
        , { id = 240, shortName = "autodromo nazionale monza combined without chicanes", longName = "Autodromo Nazionale Monza - Combined without chicanes" } -- can't find package of pkgid '172'
        , { id = 246, shortName = "autodromo nazionale monza combined without first chicane", longName = "Autodromo Nazionale Monza - Combined without first chicane" } -- can't find package of pkgid '172'
        , { id = 242, shortName = "autodromo nazionale monza gp without chicanes", longName = "Autodromo Nazionale Monza - GP without chicanes" } -- can't find package of pkgid '172'
        , { id = 244, shortName = "autodromo nazionale monza gp without first chicane", longName = "Autodromo Nazionale Monza - GP without first chicane" } -- can't find package of pkgid '172'
        , { id = 239, shortName = "autodromo nazionale monza grand prix", longName = "Autodromo Nazionale Monza - Grand Prix" } -- can't find package of pkgid '172'
        , { id = 241, shortName = "autodromo nazionale monza junior", longName = "Autodromo Nazionale Monza - Junior" } -- can't find package of pkgid '172'
        , { id = 245, shortName = "autodromo nazionale monza oval - left turning", longName = "Autodromo Nazionale Monza - Oval - Left turning" } -- can't find package of pkgid '172'
        , { id = 243, shortName = "autodromo nazionale monza oval - right turning", longName = "Autodromo Nazionale Monza - Oval - Right turning" } -- can't find package of pkgid '172'
        , { id = 212, shortName = "autódromo josé carlos pace grand prix", longName = "Autódromo José Carlos Pace - Grand Prix" } -- can't find package of pkgid '134'
        , { id = 213, shortName = "autódromo josé carlos pace moto", longName = "Autódromo José Carlos Pace - Moto" } -- can't find package of pkgid '134'
        , { id = 46, shortName = "barber motorsports park full course", longName = "Barber Motorsports Park - Full Course" } -- can't find package of pkgid '33'
        , { id = 99, shortName = "barber motorsports park short a", longName = "Barber Motorsports Park - Short A" } -- can't find package of pkgid '33'
        , { id = 100, shortName = "barber motorsports park short b", longName = "Barber Motorsports Park - Short B" } -- can't find package of pkgid '33'
        , { id = 396, shortName = "barkriver", longName = "Bark River International Raceway" }
        , { id = 145, shortName = "brandshatch grand prix", longName = "Brands Hatch Circuit - Grand Prix" }
        , { id = 146, shortName = "brandshatch indy", longName = "Brands Hatch Circuit - Indy" }
        , { id = 290, shortName = "brandshatch rallycross", longName = "Brands Hatch Circuit - Rallycross" }
        , { id = 287, shortName = "bristol dirt", longName = "Bristol Motor Speedway - Dirt" }
        , { id = 101, shortName = "bristol dual pit roads", longName = "Bristol Motor Speedway - Dual Pit Roads" }
        , { id = 365, shortName = "bristol single pit roads", longName = "Bristol Motor Speedway - Single Pit Roads" }
        , { id = 144, shortName = "canadian tire motorsports park", longName = "Canadian Tire Motorsports Park" } -- can't find package of pkgid '90'
        , { id = 387, shortName = "cedarlake", longName = "Cedar Lake Speedway" }
        , { id = 143, shortName = "skidpad", longName = "Centripetal Circuit" }
        , { id = 335, shortName = "charlotte_2018 legends oval - 2018", longName = "Charlotte Motor Speedway - Legends Oval - 2018" }
        , { id = 336, shortName = "charlotte_2018 legends rc long - 2018", longName = "Charlotte Motor Speedway - Legends RC Long - 2018" }
        , { id = 337, shortName = "charlotte_2018 legends rc medium - 2018", longName = "Charlotte Motor Speedway - Legends RC Medium - 2018" }
        , { id = 338, shortName = "charlotte_2018 legends rc short - 2018", longName = "Charlotte Motor Speedway - Legends RC Short - 2018" }
        , { id = 339, shortName = "charlotte_2018 oval - 2018", longName = "Charlotte Motor Speedway - Oval - 2018" }
        , { id = 385, shortName = "charlotte 2018 2019 rallycrosslong", longName = "Charlotte Motor Speedway - Rallycross" }
        , { id = 350, shortName = "charlotte_2018 roval", longName = "Charlotte Motor Speedway - Roval" }
        , { id = 330, shortName = "charlotte_2018 roval - 2018", longName = "Charlotte Motor Speedway - Roval - 2018" }
        , { id = 340, shortName = "charlotte_2018 roval long - 2018", longName = "Charlotte Motor Speedway - Roval Long - 2018" }
        , { id = 405, shortName = "chicago", longName = "Chicago Street Circuit" }
        , { id = 123, shortName = "chicagoland speedway", longName = "Chicagoland Speedway" } -- can't find package of pkgid '65'
        , { id = 331, shortName = "chilibowl", longName = "Chili Bowl" }
        , { id = 218, shortName = "circuit gilles villeneuve", longName = "Circuit Gilles Villeneuve" } -- can't find package of pkgid '145'
        , { id = 147, shortName = "circuit park zandvoort chicane", longName = "Circuit Park Zandvoort - Chicane" } -- can't find package of pkgid '92'
        , { id = 148, shortName = "circuit park zandvoort club", longName = "Circuit Park Zandvoort - Club" } -- can't find package of pkgid '92'
        , { id = 149, shortName = "circuit park zandvoort grand prix", longName = "Circuit Park Zandvoort - Grand Prix" } -- can't find package of pkgid '92'
        , { id = 150, shortName = "circuit park zandvoort national", longName = "Circuit Park Zandvoort - National" } -- can't find package of pkgid '92'
        , { id = 151, shortName = "circuit park zandvoort oostelijk", longName = "Circuit Park Zandvoort - Oostelijk" } -- can't find package of pkgid '92'
        , { id = 200, shortName = "circuit zolder alternate", longName = "Circuit Zolder - Alternate" } -- can't find package of pkgid '124'
        , { id = 199, shortName = "circuit zolder grand prix", longName = "Circuit Zolder - Grand Prix" } -- can't find package of pkgid '124'
        , { id = 347, shortName = "barcelona club", longName = "Circuit de Barcelona Catalunya - Club" }
        , { id = 345, shortName = "barcelona grand prix", longName = "Circuit de Barcelona Catalunya - Grand Prix" }
        , { id = 349, shortName = "barcelona historic", longName = "Circuit de Barcelona Catalunya - Historic" }
        , { id = 348, shortName = "barcelona moto", longName = "Circuit de Barcelona Catalunya - Moto" }
        , { id = 346, shortName = "barcelona national", longName = "Circuit de Barcelona Catalunya - National" }
        , { id = 386, shortName = "barcelona rallycross", longName = "Circuit de Barcelona-Catalunya - Rallycross" }
        , { id = 164, shortName = "circuit de spa-francorchamps classic pits", longName = "Circuit de Spa-Francorchamps - Classic Pits" } -- can't find package of pkgid '103'
        , { id = 165, shortName = "circuit de spa-francorchamps endurance", longName = "Circuit de Spa-Francorchamps - Endurance" } -- can't find package of pkgid '103'
        , { id = 163, shortName = "circuit de spa-francorchamps grand prix pits", longName = "Circuit de Spa-Francorchamps - Grand Prix Pits" } -- can't find package of pkgid '103'
        , { id = 268, shortName = "circuit des 24 heures du mans 24 heures du mans", longName = "Circuit des 24 Heures du Mans - 24 Heures du Mans" } -- can't find package of pkgid '204'
        , { id = 269, shortName = "circuit des 24 heures du mans historic", longName = "Circuit des 24 Heures du Mans - Historic" } -- can't find package of pkgid '204'
        , { id = 230, shortName = "circuit of the americas east", longName = "Circuit of the Americas - East" } -- can't find package of pkgid '154'
        , { id = 229, shortName = "circuit of the americas grand prix", longName = "Circuit of the Americas - Grand Prix" } -- can't find package of pkgid '154'
        , { id = 231, shortName = "circuit of the americas west", longName = "Circuit of the Americas - West" } -- can't find package of pkgid '154'
        , { id = 15, shortName = "concordhalf", longName = "Concord Speedway" }
        , { id = 382, shortName = "crandon full", longName = "Crandon International Raceway - Full" }
        , { id = 383, shortName = "crandon short", longName = "Crandon International Raceway - Short" }
        , { id = 115, shortName = "darlington raceway", longName = "Darlington Raceway" } -- can't find package of pkgid '59'
        , { id = 193, shortName = "daytona international speedway moto", longName = "Daytona International Speedway - Moto" } -- can't find package of pkgid '120'
        , { id = 381, shortName = "daytona international speedway nascar road", longName = "Daytona International Speedway - NASCAR Road" } -- can't find package of pkgid '120'
        , { id = 191, shortName = "daytona international speedway oval", longName = "Daytona International Speedway - Oval" } -- can't find package of pkgid '120'
        , { id = 192, shortName = "daytona international speedway road course", longName = "Daytona International Speedway - Road Course" } -- can't find package of pkgid '120'
        , { id = 194, shortName = "daytona international speedway short", longName = "Daytona International Speedway - Short" } -- can't find package of pkgid '120'
        , { id = 319, shortName = "detroit grand prix at belle isle belle isle", longName = "Detroit Grand Prix at Belle Isle - Belle Isle" } -- can't find package of pkgid '259'
        , { id = 233, shortName = "donington park racing circuit grand prix", longName = "Donington Park Racing Circuit - Grand Prix" } -- can't find package of pkgid '162'
        , { id = 234, shortName = "donington park racing circuit national", longName = "Donington Park Racing Circuit - National" } -- can't find package of pkgid '162'
        , { id = 162, shortName = "dover international speedway", longName = "Dover International Speedway" } -- can't find package of pkgid '100'
        , { id = 273, shortName = "eldora", longName = "Eldora Speedway" }
        , { id = 344, shortName = "fairbury", longName = "Fairbury Speedway" }
        , { id = 248, shortName = "five flags speedway", longName = "Five Flags Speedway" } -- can't find package of pkgid '180'
        , { id = 390, shortName = "hockenheimring baden-württemberg grand prix", longName = "Hockenheimring Baden-Württemberg - Grand Prix" } -- can't find package of pkgid '350'
        , { id = 391, shortName = "hockenheimring baden-württemberg national a", longName = "Hockenheimring Baden-Württemberg - National A" } -- can't find package of pkgid '350'
        , { id = 392, shortName = "hockenheimring baden-württemberg national b", longName = "Hockenheimring Baden-Württemberg - National B" } -- can't find package of pkgid '350'
        , { id = 395, shortName = "hockenheimring baden-württemberg outer", longName = "Hockenheimring Baden-Württemberg - Outer" } -- can't find package of pkgid '350'
        , { id = 393, shortName = "hockenheimring baden-württemberg short a", longName = "Hockenheimring Baden-Württemberg - Short A" } -- can't find package of pkgid '350'
        , { id = 394, shortName = "hockenheimring baden-württemberg short b", longName = "Hockenheimring Baden-Württemberg - Short B" } -- can't find package of pkgid '350'
        , { id = 362, shortName = "homestead miami speedway indycar oval", longName = "Homestead Miami Speedway - IndyCar Oval" } -- can't find package of pkgid '5'
        , { id = 20, shortName = "homestead miami speedway oval", longName = "Homestead Miami Speedway - Oval" } -- can't find package of pkgid '5'
        , { id = 21, shortName = "homestead miami speedway road course a", longName = "Homestead Miami Speedway - Road Course A" } -- can't find package of pkgid '5'
        , { id = 22, shortName = "homestead miami speedway road course b", longName = "Homestead Miami Speedway - Road Course B" } -- can't find package of pkgid '5'
        , { id = 384, shortName = "iracing superspeedway", longName = "IRacing Superspeedway" } -- can't find package of pkgid '341'
        , { id = 135, shortName = "indianapolis motor speedway bike", longName = "Indianapolis Motor Speedway - Bike" } -- can't find package of pkgid '73'
        , { id = 178, shortName = "indianapolis motor speedway indycar oval", longName = "Indianapolis Motor Speedway - IndyCar Oval" } -- can't find package of pkgid '73'
        , { id = 133, shortName = "indianapolis motor speedway oval", longName = "Indianapolis Motor Speedway - Oval" } -- can't find package of pkgid '73'
        , { id = 134, shortName = "indianapolis motor speedway road course", longName = "Indianapolis Motor Speedway - Road Course" } -- can't find package of pkgid '73'
        , { id = 172, shortName = "iowa infield legends", longName = "Iowa Speedway - Infield Legends" }
        , { id = 171, shortName = "iowa legends", longName = "Iowa Speedway - Legends" }
        , { id = 169, shortName = "iowa oval", longName = "Iowa Speedway - Oval" }
        , { id = 295, shortName = "iowa rallycross", longName = "Iowa Speedway - Rallycross" }
        , { id = 170, shortName = "iowa road course", longName = "Iowa Speedway - Road Course" }
        , { id = 217, shortName = "irwindale speedway figure eight", longName = "Irwindale Speedway - Figure Eight" } -- can't find package of pkgid '6'
        , { id = 388, shortName = "irwindale speedway figure eight jump", longName = "Irwindale Speedway - Figure Eight Jump" } -- can't find package of pkgid '6'
        , { id = 19, shortName = "irwindale speedway inner", longName = "Irwindale Speedway - Inner" } -- can't find package of pkgid '6'
        , { id = 23, shortName = "irwindale speedway outer", longName = "Irwindale Speedway - Outer" } -- can't find package of pkgid '6'
        , { id = 30, shortName = "irwindale speedway outer - inner", longName = "Irwindale Speedway - Outer - Inner" } -- can't find package of pkgid '6'
        , { id = 216, shortName = "kansas speedway infield road course", longName = "Kansas Speedway - Infield Road Course" } -- can't find package of pkgid '142'
        , { id = 214, shortName = "kansas speedway oval", longName = "Kansas Speedway - Oval" } -- can't find package of pkgid '142'
        , { id = 215, shortName = "kansas speedway road course", longName = "Kansas Speedway - Road Course" } -- can't find package of pkgid '142'
        , { id = 371, shortName = "kentucky speedway oval", longName = "Kentucky Speedway - Oval" } -- can't find package of pkgid '319'
        , { id = 305, shortName = "knoxville", longName = "Knoxville Raceway" }
        , { id = 320, shortName = "kokomo", longName = "Kokomo Speedway" }
        , { id = 201, shortName = "langley", longName = "Langley Speedway" }
        , { id = 17, shortName = "lanier asphalt", longName = "Lanier National Speedway - Asphalt" }
        , { id = 288, shortName = "lanier dirt", longName = "Lanier National Speedway - Dirt" }
        , { id = 113, shortName = "las vegas motor speedway infield legends oval", longName = "Las Vegas Motor Speedway - Infield Legends Oval" } -- can't find package of pkgid '54'
        , { id = 110, shortName = "las vegas motor speedway legends oval", longName = "Las Vegas Motor Speedway - Legends Oval" } -- can't find package of pkgid '54'
        , { id = 103, shortName = "las vegas motor speedway oval", longName = "Las Vegas Motor Speedway - Oval" } -- can't find package of pkgid '54'
        , { id = 114, shortName = "las vegas motor speedway road course combined", longName = "Las Vegas Motor Speedway - Road Course Combined" } -- can't find package of pkgid '54'
        , { id = 111, shortName = "las vegas motor speedway road course long", longName = "Las Vegas Motor Speedway - Road Course Long" } -- can't find package of pkgid '54'
        , { id = 112, shortName = "las vegas motor speedway road course short", longName = "Las Vegas Motor Speedway - Road Course Short" } -- can't find package of pkgid '54'
        , { id = 351, shortName = "lernerville", longName = "Lernerville Speedway" }
        , { id = 303, shortName = "limaland", longName = "Limaland Motorsports Park" }
        , { id = 354, shortName = "limerock_2019 chicanes", longName = "Lime Rock Park - Chicanes" }
        , { id = 352, shortName = "limerock_2019 classic", longName = "Lime Rock Park - Classic" }
        , { id = 353, shortName = "limerock_2019 grand prix", longName = "Lime Rock Park - Grand Prix" }
        , { id = 355, shortName = "limerock_2019 west bend chicane", longName = "Lime Rock Park - West Bend Chicane" }
        , { id = 179, shortName = "long beach street circuit", longName = "Long Beach Street Circuit" } -- can't find package of pkgid '116'
        , { id = 232, shortName = "irp oval", longName = "Lucas Oil Raceway - Oval" }
        , { id = 304, shortName = "irp rallycross", longName = "Lucas Oil Raceway - Rallycross" }
        , { id = 359, shortName = "lankebanen club", longName = "Lånkebanen (Hell RX) - Club" }
        , { id = 358, shortName = "lankebanen hell rallycross", longName = "Lånkebanen (Hell RX) - Hell Rallycross" }
        , { id = 360, shortName = "lankebanen rallycross short", longName = "Lånkebanen (Hell RX) - Rallycross Short" }
        , { id = 363, shortName = "lankebanen road long", longName = "Lånkebanen (Hell RX) - Road Long" }
        , { id = 361, shortName = "lankebanen road short", longName = "Lånkebanen (Hell RX) - Road Short" }
        , { id = 33, shortName = "martinsville speedway", longName = "Martinsville Speedway" } -- can't find package of pkgid '26'
        , { id = 276, shortName = "michigan international speedway", longName = "Michigan International Speedway" } -- can't find package of pkgid '224'
        , { id = 157, shortName = "mid-ohio sports car course alt oval", longName = "Mid-Ohio Sports Car Course - Alt Oval" } -- can't find package of pkgid '96'
        , { id = 154, shortName = "mid-ohio sports car course chicane", longName = "Mid-Ohio Sports Car Course - Chicane" } -- can't find package of pkgid '96'
        , { id = 153, shortName = "mid-ohio sports car course full course", longName = "Mid-Ohio Sports Car Course - Full Course" } -- can't find package of pkgid '96'
        , { id = 156, shortName = "mid-ohio sports car course oval", longName = "Mid-Ohio Sports Car Course - Oval" } -- can't find package of pkgid '96'
        , { id = 155, shortName = "mid-ohio sports car course short", longName = "Mid-Ohio Sports Car Course - Short" } -- can't find package of pkgid '96'
        , { id = 219, shortName = "bathurst", longName = "Mount Panorama Circuit" }
        , { id = 286, shortName = "myrtle beach speedway", longName = "Myrtle Beach Speedway" } -- can't find package of pkgid '240'
        , { id = 380, shortName = "nashville fairgrounds speedway mini", longName = "Nashville Fairgrounds Speedway - Mini" } -- can't find package of pkgid '331'
        , { id = 374, shortName = "nashville fairgrounds speedway oval", longName = "Nashville Fairgrounds Speedway - Oval" } -- can't find package of pkgid '331'
        , { id = 400, shortName = "nashville superspeedway", longName = "Nashville Superspeedway" } -- can't find package of pkgid '353'
        , { id = 222, shortName = "new hampshire motor speedway legends", longName = "New Hampshire Motor Speedway - Legends" } -- can't find package of pkgid '72'
        , { id = 131, shortName = "new hampshire motor speedway oval", longName = "New Hampshire Motor Speedway - Oval" } -- can't find package of pkgid '72'
        , { id = 129, shortName = "new hampshire motor speedway road course", longName = "New Hampshire Motor Speedway - Road Course" } -- can't find package of pkgid '72'
        , { id = 130, shortName = "new hampshire motor speedway road course with north oval", longName = "New Hampshire Motor Speedway - Road Course with North Oval" } -- can't find package of pkgid '72'
        , { id = 132, shortName = "new hampshire motor speedway road course with south oval", longName = "New Hampshire Motor Speedway - Road Course with South Oval" } -- can't find package of pkgid '72'
        , { id = 220, shortName = "new jersey motorsports park thunderbolt", longName = "New Jersey Motorsports Park - Thunderbolt" } -- can't find package of pkgid '147'
        , { id = 221, shortName = "new jersey motorsports park thunderbolt w/both chicanes", longName = "New Jersey Motorsports Park - Thunderbolt w/both chicanes" } -- can't find package of pkgid '147'
        , { id = 223, shortName = "new jersey motorsports park thunderbolt w/first chicane", longName = "New Jersey Motorsports Park - Thunderbolt w/first chicane" } -- can't find package of pkgid '147'
        , { id = 224, shortName = "new jersey motorsports park thunderbolt w/second chicane", longName = "New Jersey Motorsports Park - Thunderbolt w/second chicane" } -- can't find package of pkgid '147'
        , { id = 190, shortName = "new smyrna speedway", longName = "New Smyrna Speedway" } -- can't find package of pkgid '119'
        , { id = 366, shortName = "north wilkesboro speedway 1987", longName = "North Wilkesboro Speedway - 1987" } -- can't find package of pkgid '312'
        , { id = 252, shortName = "nürburgring combined gesamtstrecke 24h", longName = "Nürburgring Combined - Gesamtstrecke 24h" } -- can't find package of pkgid '186'
        , { id = 264, shortName = "nürburgring combined gesamtstrecke long", longName = "Nürburgring Combined - Gesamtstrecke Long" } -- can't find package of pkgid '186'
        , { id = 263, shortName = "nürburgring combined gesamtstrecke short w/out arena", longName = "Nürburgring Combined - Gesamtstrecke Short w/out Arena" } -- can't find package of pkgid '186'
        , { id = 262, shortName = "nürburgring combined gesamtstrecke vln", longName = "Nürburgring Combined - Gesamtstrecke VLN" } -- can't find package of pkgid '186'
        , { id = 255, shortName = "nürburgring grand-prix-strecke bes/wec", longName = "Nürburgring Grand-Prix-Strecke - BES/WEC" } -- can't find package of pkgid '185'
        , { id = 250, shortName = "nürburgring grand-prix-strecke grand prix", longName = "Nürburgring Grand-Prix-Strecke - Grand Prix" } -- can't find package of pkgid '185'
        , { id = 257, shortName = "nürburgring grand-prix-strecke grand prix w/out arena", longName = "Nürburgring Grand-Prix-Strecke - Grand Prix w/out Arena" } -- can't find package of pkgid '185'
        , { id = 260, shortName = "nürburgring grand-prix-strecke kurzanbindung w/out arena", longName = "Nürburgring Grand-Prix-Strecke - Kurzanbindung w/out Arena" } -- can't find package of pkgid '185'
        , { id = 261, shortName = "nürburgring grand-prix-strecke müllenbachschleife", longName = "Nürburgring Grand-Prix-Strecke - Müllenbachschleife" } -- can't find package of pkgid '185'
        , { id = 259, shortName = "nürburgring grand-prix-strecke sprintstrecke", longName = "Nürburgring Grand-Prix-Strecke - Sprintstrecke" } -- can't find package of pkgid '185'
        , { id = 249, shortName = "nurburgring_nordschleife industriefahrten", longName = "Nürburgring Nordschleife - Industriefahrten" }
        , { id = 253, shortName = "nurburgring nordschleifetourist", longName = "Nürburgring Nordschleife - Touristenfahrten" }
        , { id = 166, shortName = "okayama full course", longName = "Okayama International Circuit - Full Course" }
        , { id = 167, shortName = "okayama short", longName = "Okayama International Circuit - Short" }
        , { id = 202, shortName = "oran grand prix", longName = "Oran Park Raceway - Grand Prix" }
        , { id = 211, shortName = "oran moto", longName = "Oran Park Raceway - Moto" }
        , { id = 207, shortName = "oran north", longName = "Oran Park Raceway - North" }
        , { id = 209, shortName = "oran north a", longName = "Oran Park Raceway - North A" }
        , { id = 210, shortName = "oran north b", longName = "Oran Park Raceway - North B" }
        , { id = 208, shortName = "oran south", longName = "Oran Park Raceway - South" }
        , { id = 181, shortName = "oulton fosters", longName = "Oulton Park Circuit - Fosters" }
        , { id = 186, shortName = "oulton fosters w/hislop", longName = "Oulton Park Circuit - Fosters w/Hislop" }
        , { id = 180, shortName = "oulton international", longName = "Oulton Park Circuit - International" }
        , { id = 185, shortName = "oulton intl w/no chicanes", longName = "Oulton Park Circuit - Intl w/no Chicanes" }
        , { id = 184, shortName = "oulton intl w/out brittens", longName = "Oulton Park Circuit - Intl w/out Brittens" }
        , { id = 183, shortName = "oulton intl w/out hislop", longName = "Oulton Park Circuit - Intl w/out Hislop" }
        , { id = 182, shortName = "oulton island", longName = "Oulton Park Circuit - Island" }
        , { id = 187, shortName = "oulton island historic", longName = "Oulton Park Circuit - Island Historic" }
        , { id = 12, shortName = "oxford", longName = "Oxford Plains Speedway" }
        , { id = 152, shortName = "phillip island circuit", longName = "Phillip Island Circuit" } -- can't find package of pkgid '93'
        , { id = 235, shortName = "phoenix raceway oval", longName = "Phoenix Raceway - Oval" } -- can't find package of pkgid '163'
        , { id = 236, shortName = "phoenix raceway oval w/open dogleg", longName = "Phoenix Raceway - Oval w/open dogleg" } -- can't find package of pkgid '163'
        , { id = 277, shortName = "pocono raceway", longName = "Pocono Raceway" } -- can't find package of pkgid '225'
        , { id = 403, shortName = "red bull ring grand prix", longName = "Red Bull Ring - Grand Prix" } -- can't find package of pkgid '362'
        , { id = 404, shortName = "red bull ring national", longName = "Red Bull Ring - National" } -- can't find package of pkgid '362'
        , { id = 407, shortName = "red bull ring north", longName = "Red Bull Ring - North" } -- can't find package of pkgid '362'
        , { id = 31, shortName = "richmond raceway", longName = "Richmond Raceway" } -- can't find package of pkgid '23'
        , { id = 50, shortName = "road america bend", longName = "Road America - Bend" } -- can't find package of pkgid '11'
        , { id = 18, shortName = "road america full course", longName = "Road America - Full Course" } -- can't find package of pkgid '11'
        , { id = 126, shortName = "road atlanta club", longName = "Road Atlanta - Club" } -- can't find package of pkgid '67'
        , { id = 127, shortName = "road atlanta full course", longName = "Road Atlanta - Full Course" } -- can't find package of pkgid '67'
        , { id = 128, shortName = "road atlanta short", longName = "Road Atlanta - Short" } -- can't find package of pkgid '67'
        , { id = 205, shortName = "rockingham speedway infield road course", longName = "Rockingham Speedway - Infield Road Course" } -- can't find package of pkgid '129'
        , { id = 203, shortName = "rockingham speedway oval", longName = "Rockingham Speedway - Oval" } -- can't find package of pkgid '129'
        , { id = 204, shortName = "rockingham speedway road course", longName = "Rockingham Speedway - Road Course" } -- can't find package of pkgid '129'
        , { id = 206, shortName = "rockingham speedway short road course", longName = "Rockingham Speedway - Short Road Course" } -- can't find package of pkgid '129'
        , { id = 97, shortName = "sebring international raceway club", longName = "Sebring International Raceway - Club" } -- can't find package of pkgid '40'
        , { id = 95, shortName = "sebring international raceway international", longName = "Sebring International Raceway - International" } -- can't find package of pkgid '40'
        , { id = 96, shortName = "sebring international raceway modified", longName = "Sebring International Raceway - Modified" } -- can't find package of pkgid '40'
        , { id = 341, shortName = "silverstone circuit grand prix", longName = "Silverstone Circuit - Grand Prix" } -- can't find package of pkgid '282'
        , { id = 342, shortName = "silverstone circuit international", longName = "Silverstone Circuit - International" } -- can't find package of pkgid '282'
        , { id = 343, shortName = "silverstone circuit national", longName = "Silverstone Circuit - National" } -- can't find package of pkgid '282'
        , { id = 299, shortName = "snetterton circuit 100", longName = "Snetterton Circuit - 100" } -- can't find package of pkgid '247'
        , { id = 298, shortName = "snetterton circuit 200", longName = "Snetterton Circuit - 200" } -- can't find package of pkgid '247'
        , { id = 297, shortName = "snetterton circuit 300", longName = "Snetterton Circuit - 300" } -- can't find package of pkgid '247'
        , { id = 98, shortName = "sonoma cup", longName = "Sonoma Raceway - Cup" }
        , { id = 48, shortName = "sonoma cup historic", longName = "Sonoma Raceway - Cup Historic" }
        , { id = 102, shortName = "sonoma indycar 2008-2011", longName = "Sonoma Raceway - IndyCar 2008-2011" }
        , { id = 397, shortName = "sonoma indycar 2012-2018", longName = "Sonoma Raceway - IndyCar 2012-2018" }
        , { id = 49, shortName = "sonoma indycar pre-2008", longName = "Sonoma Raceway - IndyCar pre-2008" }
        , { id = 312, shortName = "sonoma rallycross", longName = "Sonoma Raceway - Rallycross" }
        , { id = 14, shortName = "southboston", longName = "South Boston Speedway" }
        , { id = 256, shortName = "southernnational", longName = "Southern National Motorsports Park" }
        , { id = 11, shortName = "stafford motor speedway full course", longName = "Stafford Motor Speedway - Full Course" } -- can't find package of pkgid '12'
        , { id = 8, shortName = "summit jefferson circuit", longName = "Summit Point Raceway - Jefferson Circuit" }
        , { id = 142, shortName = "summit jefferson reverse", longName = "Summit Point Raceway - Jefferson Reverse" }
        , { id = 159, shortName = "summit school", longName = "Summit Point Raceway - School" }
        , { id = 24, shortName = "summit short", longName = "Summit Point Raceway - Short" }
        , { id = 9, shortName = "summit summit point raceway", longName = "Summit Point Raceway - Summit Point Raceway" }
        , { id = 174, shortName = "suzuka international racing course east", longName = "Suzuka International Racing Course - East" } -- can't find package of pkgid '114'
        , { id = 168, shortName = "suzuka international racing course grand prix", longName = "Suzuka International Racing Course - Grand Prix" } -- can't find package of pkgid '114'
        , { id = 173, shortName = "suzuka international racing course moto", longName = "Suzuka International Racing Course - Moto" } -- can't find package of pkgid '114'
        , { id = 175, shortName = "suzuka international racing course west", longName = "Suzuka International Racing Course - West" } -- can't find package of pkgid '114'
        , { id = 176, shortName = "suzuka international racing course west w/chicane", longName = "Suzuka International Racing Course - West w/chicane" } -- can't find package of pkgid '114'
        , { id = 116, shortName = "talladega superspeedway", longName = "Talladega Superspeedway" } -- can't find package of pkgid '60'
        , { id = 364, shortName = "texas motor speedway legends oval", longName = "Texas Motor Speedway - Legends Oval" } -- can't find package of pkgid '310'
        , { id = 357, shortName = "texas motor speedway oval", longName = "Texas Motor Speedway - Oval" } -- can't find package of pkgid '310'
        , { id = 271, shortName = "the bullring", longName = "The Bullring" } -- can't find package of pkgid '211'
        , { id = 314, shortName = "charlottedirt", longName = "The Dirt Track at Charlotte" }
        , { id = 94, shortName = "the milwaukee mile", longName = "The Milwaukee Mile" } -- can't find package of pkgid '41'
        , { id = 161, shortName = "thompson oval", longName = "Thompson Speedway Motorsports Park - Oval" }
        , { id = 329, shortName = "tsukuba 1000 chicane", longName = "Tsukuba Circuit - 1000 Chicane" }
        , { id = 327, shortName = "tsukuba 1000 full", longName = "Tsukuba Circuit - 1000 Full" }
        , { id = 333, shortName = "tsukuba 1000 full reverse", longName = "Tsukuba Circuit - 1000 Full Reverse" }
        , { id = 328, shortName = "tsukuba 1000 outer", longName = "Tsukuba Circuit - 1000 Outer" }
        , { id = 324, shortName = "tsukuba 2000 full", longName = "Tsukuba Circuit - 2000 Full" }
        , { id = 325, shortName = "tsukuba 2000 moto", longName = "Tsukuba Circuit - 2000 Moto" }
        , { id = 326, shortName = "tsukuba 2000 short", longName = "Tsukuba Circuit - 2000 Short" }
        , { id = 196, shortName = "twin ring motegi east", longName = "Twin Ring Motegi - East" } -- can't find package of pkgid '123'
        , { id = 195, shortName = "twin ring motegi grand prix", longName = "Twin Ring Motegi - Grand Prix" } -- can't find package of pkgid '123'
        , { id = 198, shortName = "twin ring motegi oval", longName = "Twin Ring Motegi - Oval" } -- can't find package of pkgid '123'
        , { id = 197, shortName = "twin ring motegi west", longName = "Twin Ring Motegi - West" } -- can't find package of pkgid '123'
        , { id = 16, shortName = "lakeland asphalt", longName = "USA International Speedway - Asphalt" }
        , { id = 275, shortName = "lakeland dirt", longName = "USA International Speedway - Dirt" }
        , { id = 2, shortName = "virginia international raceway full course", longName = "Virginia International Raceway - Full Course" } -- can't find package of pkgid '14'
        , { id = 6, shortName = "virginia international raceway grand east", longName = "Virginia International Raceway - Grand East" } -- can't find package of pkgid '14'
        , { id = 5, shortName = "virginia international raceway grand west", longName = "Virginia International Raceway - Grand West" } -- can't find package of pkgid '14'
        , { id = 4, shortName = "virginia international raceway north", longName = "Virginia International Raceway - North" } -- can't find package of pkgid '14'
        , { id = 3, shortName = "virginia international raceway patriot", longName = "Virginia International Raceway - Patriot" } -- can't find package of pkgid '14'
        , { id = 141, shortName = "virginia international raceway patriot reverse", longName = "Virginia International Raceway - Patriot Reverse" } -- can't find package of pkgid '14'
        , { id = 7, shortName = "virginia international raceway south", longName = "Virginia International Raceway - South" } -- can't find package of pkgid '14'
        , { id = 279, shortName = "volusia", longName = "Volusia Speedway Park" }
        , { id = 107, shortName = "watkins glen international boot", longName = "Watkins Glen International - Boot" } -- can't find package of pkgid '56'
        , { id = 109, shortName = "watkins glen international classic", longName = "Watkins Glen International - Classic" } -- can't find package of pkgid '56'
        , { id = 108, shortName = "watkins glen international classic boot", longName = "Watkins Glen International - Classic Boot" } -- can't find package of pkgid '56'
        , { id = 106, shortName = "watkins glen international cup", longName = "Watkins Glen International - Cup" } -- can't find package of pkgid '56'
        , { id = 47, shortName = "lagunaseca full course", longName = "WeatherTech Raceway at Laguna Seca - Full Course" }
        , { id = 158, shortName = "lagunaseca school", longName = "WeatherTech Raceway at Laguna Seca - School" }
        , { id = 373, shortName = "weedsport", longName = "Weedsport Speedway" }
        , { id = 334, shortName = "wildhorse", longName = "Wild Horse Pass Motorsports Park" }
        , { id = 332, shortName = "wildwest", longName = "Wild West Motorsports Park" }
        , { id = 274, shortName = "williamsgrove", longName = "Williams Grove Speedway" }
        , { id = 237, shortName = "world wide technology raceway oval", longName = "World Wide Technology Raceway - Oval" } -- can't find package of pkgid '169'
        , { id = 238, shortName = "world wide technology raceway road course", longName = "World Wide Technology Raceway - Road Course" } -- can't find package of pkgid '169'
        , { id = 38, shortName = "charlotte infield road course", longName = "[Legacy] Charlotte Motor Speedway - 2008 - Infield Road Course" }
        , { id = 39, shortName = "charlotte legends oval", longName = "[Legacy] Charlotte Motor Speedway - 2008 - Legends Oval" }
        , { id = 40, shortName = "charlotte oval", longName = "[Legacy] Charlotte Motor Speedway - 2008 - Oval" }
        , { id = 37, shortName = "charlotte road course", longName = "[Legacy] Charlotte Motor Speedway - 2008 - Road Course" }
        , { id = 28, shortName = "daytona moto", longName = "[Legacy] Daytona International Speedway - 2008 - Moto" }
        , { id = 27, shortName = "daytona oval", longName = "[Legacy] Daytona International Speedway - 2008 - Oval" }
        , { id = 293, shortName = "daytona rallycross long", longName = "[Legacy] Daytona International Speedway - 2008 - Rallycross Long" }
        , { id = 296, shortName = "daytona rallycross short", longName = "[Legacy] Daytona International Speedway - 2008 - Rallycross Short" }
        , { id = 26, shortName = "daytona road course", longName = "[Legacy] Daytona International Speedway - 2008 - Road Course" }
        , { id = 29, shortName = "daytona short", longName = "[Legacy] Daytona International Speedway - 2008 - Short" }
        , { id = 189, shortName = "[legacy] kentucky speedway - 2011 legends", longName = "[Legacy] Kentucky Speedway - 2011 - Legends" } -- can't find package of pkgid '118'
        , { id = 188, shortName = "[legacy] kentucky speedway - 2011 oval", longName = "[Legacy] Kentucky Speedway - 2011 - Oval" } -- can't find package of pkgid '118'
        , { id = 34, shortName = "limerock chicane", longName = "[Legacy] Lime Rock Park - 2008 - Chicane" }
        , { id = 1, shortName = "limerock full course", longName = "[Legacy] Lime Rock Park - 2008 - Full Course" }
        , { id = 160, shortName = "limerock school", longName = "[Legacy] Lime Rock Park - 2008 - School" }
        , { id = 124, shortName = "michigan", longName = "[Legacy] Michigan International Speedway - 2009" }
        , { id = 104, shortName = "phoenix oval", longName = "[Legacy] Phoenix Raceway - 2008 - Oval" }
        , { id = 306, shortName = "phoenix rallycross", longName = "[Legacy] Phoenix Raceway - 2008 - Rallycross" }
        , { id = 105, shortName = "phoenix road course", longName = "[Legacy] Phoenix Raceway - 2008 - Road Course" }
        , { id = 137, shortName = "pocono east", longName = "[Legacy] Pocono Raceway - 2009 - East" }
        , { id = 140, shortName = "pocono international", longName = "[Legacy] Pocono Raceway - 2009 - International" }
        , { id = 139, shortName = "pocono north", longName = "[Legacy] Pocono Raceway - 2009 - North" }
        , { id = 136, shortName = "pocono oval", longName = "[Legacy] Pocono Raceway - 2009 - Oval" }
        , { id = 138, shortName = "pocono south", longName = "[Legacy] Pocono Raceway - 2009 - South" }
        , { id = 41, shortName = "silverstone grand prix", longName = "[Legacy] Silverstone Circuit - 2008 - Grand Prix" }
        , { id = 42, shortName = "silverstone historical grand prix", longName = "[Legacy] Silverstone Circuit - 2008 - Historical Grand Prix" }
        , { id = 43, shortName = "silverstone international", longName = "[Legacy] Silverstone Circuit - 2008 - International" }
        , { id = 44, shortName = "silverstone national", longName = "[Legacy] Silverstone Circuit - 2008 - National" }
        , { id = 45, shortName = "silverstone southern", longName = "[Legacy] Silverstone Circuit - 2008 - Southern" }
        , { id = 120, shortName = "texas legends oval", longName = "[Legacy] Texas Motor Speedway - 2009 - Legends Oval" }
        , { id = 121, shortName = "texas oval", longName = "[Legacy] Texas Motor Speedway - 2009 - Oval" }
        , { id = 122, shortName = "texas road course combined", longName = "[Legacy] Texas Motor Speedway - 2009 - Road Course Combined" }
        , { id = 117, shortName = "texas road course long", longName = "[Legacy] Texas Motor Speedway - 2009 - Road Course Long" }
        , { id = 118, shortName = "texas road course short a", longName = "[Legacy] Texas Motor Speedway - 2009 - Road Course Short A" }
        , { id = 119, shortName = "texas road course short b", longName = "[Legacy] Texas Motor Speedway - 2009 - Road Course Short B" }
        ]
