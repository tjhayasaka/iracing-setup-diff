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
        [ { id = 80, shortName = "dirtsprint/winged 305", longName = "Dirt Sprint Car - 305" }
        , { id = 85, shortName = "dirtsprint/winged 360", longName = "Dirt Sprint Car - 360" }
        , { id = 86, shortName = "dirtsprint/winged 410", longName = "Dirt Sprint Car - 410" }
        , { id = 87, shortName = "dirtsprint/nonwinged 360", longName = "Dirt Sprint Car - 360 Non-Winged" }
        , { id = 89, shortName = "dirtsprint/nonwinged 410", longName = "Dirt Sprint Car - 410 Non-Winged" }
        , { id = 96, shortName = "dirtmidget", longName = "Dirt Midget" }
        ]


tracks : Dict Track.Id Track.Track
tracks =
    toDict
        [ { id = -1, shortName = "baseline", longName = "<baseline>" }
        , { id = 275, shortName = "lakeland_dirt", longName = "USA International Speedway" }
        , { id = 273, shortName = "eldora", longName = "Eldora Speedway" }
        , { id = 274, shortName = "williamsgrove", longName = "Williams Grove Speedway" }
        , { id = 279, shortName = "volusia", longName = "Volusia Speedway Park" }
        , { id = 287, shortName = "bristol_dirt", longName = "Bristol Motor Speedway - Dirt" }
        , { id = 288, shortName = "lanier_dirt", longName = "Lanier National Speedway - Dirt" }
        , { id = 303, shortName = "limaland", longName = "Limaland Motorsports Park" }
        , { id = 305, shortName = "knoxville", longName = "Knoxville Raceway" }
        , { id = 314, shortName = "charlottedirt", longName = "The Dirt Track at Charlotte" }
        , { id = 320, shortName = "kokomo", longName = "Kokomo Speedway" }
        , { id = 331, shortName = "chilibowl", longName = "Chili Bowl" }
        , { id = 344, shortName = "fairbury", longName = "Fairbury Speedway" }
        , { id = 351, shortName = "lernerville", longName = "Lernerville Speedway" }
        , { id = 373, shortName = "weedsport", longName = "Weedsport Speedway" }
        , { id = 387, shortName = "cedarlake", longName = "Cedar Lake Speedway" }
        ]
