module Car exposing (Car, Id, Idish(..), get, stringifiedId)

import Dict exposing (Dict)


type alias Id =
    Int


type Idish
    = Id Id
    | IdString String
    | ShortName String


type alias Car =
    { id : Id
    , shortName : String
    , longName : String
    }


stringifiedId : Maybe Car -> String
stringifiedId maybeCar =
    case maybeCar of
        Nothing ->
            ""

        Just car ->
            String.fromInt car.id


getById : Id -> Dict Id Car -> Maybe Car
getById id cars =
    Dict.get id cars


getByIdString : String -> Dict Id Car -> Maybe Car
getByIdString idString cars =
    case String.toInt idString of
        Nothing ->
            Nothing

        Just id ->
            getById id cars


getByShortName : String -> Dict Id Car -> Maybe Car
getByShortName shortName cars =
    let
        hasShortName shortName_ car =
            shortName_ == car.shortName
    in
    cars |> Dict.values |> List.filter (hasShortName shortName) |> List.head


get : Idish -> Dict Id Car -> Maybe Car
get idish cars =
    case idish of
        ShortName name ->
            getByShortName name cars

        IdString idString ->
            getByIdString idString cars

        Id id ->
            getById id cars
