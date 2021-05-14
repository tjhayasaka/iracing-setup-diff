module Track exposing (Id, Idish(..), Track, stringifiedId, get)

import Dict exposing (Dict)

type alias Id = Int

type Idish
    = Id Id
    | IdString String
    | ShortName String

type alias Track =
    { id : Id
    , shortName : String
    , longName : String
    }

stringifiedId : Maybe Track -> String
stringifiedId maybeTrack =
    case maybeTrack of
        Nothing -> ""
        Just track -> String.fromInt track.id

getById : Id -> Dict Id Track -> Maybe Track
getById id tracks =
    Dict.get id tracks

getByIdString : String -> Dict Id Track -> Maybe Track
getByIdString idString tracks =
    case String.toInt idString of
        Nothing -> Nothing
        Just id -> getById id tracks

getByShortName : String -> Dict Id Track -> Maybe Track
getByShortName shortName tracks =
    let
        hasShortName shortName_ track =
            shortName_ ==track.shortName
    in
        tracks |> Dict.values |> List.filter (hasShortName shortName) |> List.head

get : Idish -> Dict Id Track -> Maybe Track
get idish tracks =
    case idish of
        ShortName name -> getByShortName name tracks
        IdString idString -> getByIdString idString tracks
        Id id -> getById id tracks
