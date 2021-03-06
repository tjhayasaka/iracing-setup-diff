module Setup exposing
    ( Id
    , Setup
    , SetupEntry
    , entryBaseName
    , entryDirName
    , filterByCar
    , filterByCarTrack
    , filterByTrack
    , get
    , getEntryValue
    , getMany
    )

import Car exposing (Id)
import Dict exposing (Dict)
import Track exposing (Id)


type alias Id =
    String


type alias SetupEntry =
    { name : String, value : String, isComputed : Bool }


type alias Setup =
    { id : String
    , carId : Car.Id
    , trackId : Track.Id
    , name : String
    , entries : List SetupEntry
    }


get : Id -> Dict Id Setup -> Maybe Setup
get id setups =
    Dict.get id setups


getMany : List Id -> Dict Id Setup -> List Setup
getMany ids setups =
    ids |> List.filterMap (\id -> get id setups)


filterByCar : Maybe Car.Car -> List Setup -> List Setup
filterByCar maybeCar setups =
    let
        matchCar setup =
            case maybeCar of
                Nothing ->
                    True

                Just car ->
                    car.id == setup.carId
    in
    List.filter matchCar setups


filterByTrack : Maybe Track.Track -> List Setup -> List Setup
filterByTrack maybeTrack setups =
    let
        matchTrack setup =
            case maybeTrack of
                Nothing ->
                    True

                Just track ->
                    track.id == setup.trackId
    in
    List.filter matchTrack setups


filterByCarTrack : Maybe Car.Car -> Maybe Track.Track -> String -> Dict Id Setup -> List Setup
filterByCarTrack maybeCar maybeTrack nameFilterText setups =
    let
        matchCar setup =
            case maybeCar of
                Nothing ->
                    True

                Just car ->
                    car.id == setup.carId

        matchTrack setup =
            case maybeTrack of
                Nothing ->
                    True

                Just track ->
                    track.id == setup.trackId

        matchNameFilter setup =
            let
                setupName =
                    String.toLower setup.name

                words =
                    String.split " " (String.toLower nameFilterText)

                matchWord word =
                    String.contains word setupName
            in
            List.all matchWord words

        matchAll setup =
            matchCar setup && matchTrack setup && matchNameFilter setup
    in
    Dict.values setups |> List.filter matchAll


getEntryValue : String -> Setup -> Maybe String
getEntryValue name setup =
    setup.entries |> List.filter (\entry -> entry.name == name) |> List.head |> Maybe.map .value


entryDirName : String -> String
entryDirName entryName =
    String.split " / " entryName |> List.reverse |> List.tail |> Maybe.withDefault [] |> List.reverse |> String.join " / "


entryBaseName : String -> String
entryBaseName entryName =
    String.split " / " entryName |> List.reverse |> List.head |> Maybe.withDefault "???"
