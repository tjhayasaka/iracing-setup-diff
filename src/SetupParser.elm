module SetupParser exposing (parseAppendSetupFiles)

import Car
import Dict exposing (fromList)
import Global exposing (..)
import Html.Parser
import Json.Decode exposing (Decoder, Error, decodeString, errorToString, field, list, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Master
import Regex
import Result exposing (andThen)
import Setup
import SetupEntryParser
import Track


type SetupOrIgnored
    = Setup_ { basename : String, filename : String, setupHtml : String }
    | Ignored { basename : String, filename : String, what : String }
    | Error_ { basename : String, filename : String, what : String }


getCarId : List Html.Parser.Node -> Result String Int
getCarId bodyChildren =
    case bodyChildren of
        _ :: (Html.Parser.Element "h2" _ h2Children) :: _ ->
            case h2Children of
                (Html.Parser.Text _) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Text text) :: _ ->
                    -- text = " \r\n\t\t\tdirtsprint winged 410 setup: AAAA-tjh-2020\\tjh-lakeland_dirt-qualify"
                    let
                        cleanup0 =
                            Maybe.withDefault Regex.never <| Regex.fromString "^ \u{000D}\n\t\t\t"

                        cleanup1 =
                            Maybe.withDefault Regex.never <| Regex.fromString " setup: .*$"

                        fix0 =
                            Maybe.withDefault Regex.never <| Regex.fromString "^dirtsprint "

                        shortName =
                            text |> Regex.replaceAtMost 1 cleanup0 (\_ -> "") |> Regex.replaceAtMost 1 cleanup1 (\_ -> "") |> Regex.replaceAtMost 1 fix0 (\_ -> "dirtsprint/")

                        maybeCar =
                            Car.get (Car.ShortName shortName) Master.cars
                    in
                    case maybeCar of
                        Nothing ->
                            Err ("failed to find car: '" ++ shortName ++ "'")

                        Just car ->
                            Ok car.id

                _ ->
                    Ok 0

        _ ->
            Ok 0


getTrackId : List Html.Parser.Node -> String -> Result String Int
getTrackId bodyChildren setupName =
    case bodyChildren of
        _ :: (Html.Parser.Element "h2" _ h2Children) :: _ ->
            case h2Children of
                (Html.Parser.Text _) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Text _) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Text text) :: _ ->
                    -- text = " \r\n\t\t\ttrack: bristol dirt"
                    let
                        baselineRx =
                            Maybe.withDefault Regex.never <| Regex.fromStringWith { caseInsensitive = True, multiline = False } "baseline"

                        cleanup0 =
                            Maybe.withDefault Regex.never <| Regex.fromString "^ \u{000D}\n\t\t\ttrack: "

                        fix0 =
                            Maybe.withDefault Regex.never <| Regex.fromString " dirt$"

                        shortName =
                            case Regex.find baselineRx setupName of
                                [] ->
                                    text |> Regex.replaceAtMost 1 cleanup0 (\_ -> "") |> Regex.replaceAtMost 1 fix0 (\_ -> "_dirt")

                                _ ->
                                    "baseline"

                        maybeTrack =
                            Track.get (Track.ShortName shortName) Master.tracks
                    in
                    case maybeTrack of
                        Nothing ->
                            Err ("failed to find track: '" ++ shortName ++ "'")

                        Just track ->
                            Ok track.id

                _ ->
                    Ok 0

        _ ->
            Ok 0


getSetupName : String -> String
getSetupName filename =
    let
        cleanup0 =
            Maybe.withDefault Regex.never <| Regex.fromString "^[^/]*/"

        cleanup1 =
            Maybe.withDefault Regex.never <| Regex.fromString "[.]htm"

        fix0 =
            Maybe.withDefault Regex.never <| Regex.fromString "/"
    in
    filename |> Regex.replaceAtMost 1 cleanup0 (\_ -> "") |> Regex.replaceAtMost 1 cleanup1 (\_ -> "") |> Regex.replace fix0 (\_ -> " / ")


makeSetupId : Int -> Int -> String -> String
makeSetupId carId trackId setupName =
    String.fromInt carId ++ "-" ++ String.fromInt trackId ++ "-" ++ setupName


parseSetupHtml : String -> String -> Result String Setup.Setup
parseSetupHtml filename setupHtml =
    let
        setupHtml_ =
            String.replace "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" "" setupHtml
    in
    case Html.Parser.run setupHtml_ of
        Err _ ->
            Err "failed to parse exported setup html"

        Ok parsedHtml ->
            let
                setupName =
                    getSetupName filename
            in
            case parsedHtml of
                _ :: (Html.Parser.Element "html" [] htmlChildren) :: [] ->
                    case htmlChildren of
                        _ :: (Html.Parser.Element "head" [] _) :: _ :: (Html.Parser.Element "body" [] bodyChildren) :: _ ->
                            getCarId bodyChildren
                                |> andThen
                                    (\carId ->
                                        getTrackId bodyChildren setupName
                                            |> andThen
                                                (\trackId ->
                                                    SetupEntryParser.parseSetupEntries bodyChildren
                                                        |> andThen
                                                            (\entries ->
                                                                Ok { id = makeSetupId carId trackId filename, carId = carId, trackId = trackId, name = setupName, entries = entries }
                                                            )
                                                )
                                    )

                        _ ->
                            Err "failed to parse exported setup html: couldn't find <head> and <body> at expected location"

                _ ->
                    Err "failed to parse exported setup html: couldn't find <html> at expected location"


decodeJson : String -> Result Error (List SetupOrIgnored)
decodeJson json =
    let
        setupDecoder =
            let
                cons a0 a1 a2 =
                    Setup_ { basename = a0, filename = a1, setupHtml = a2 }
            in
            field "exportedSetupFile"
                (succeed cons
                    |> required "basename" string
                    |> required "filename" string
                    |> required "setupHtml" string
                )

        ignoredDecoder =
            let
                cons a0 a1 a2 =
                    Ignored { basename = a0, filename = a1, what = a2 }
            in
            field "ignored"
                (succeed cons
                    |> required "basename" string
                    |> required "filename" string
                    |> required "what" string
                )

        errorDecoder =
            let
                cons a0 a1 a2 =
                    Error_ { basename = a0, filename = a1, what = a2 }
            in
            field "error"
                (succeed cons
                    |> required "basename" string
                    |> required "filename" string
                    |> required "what" string
                )

        rawDecoder =
            oneOf [ setupDecoder, ignoredDecoder, errorDecoder ]
    in
    decodeString (list rawDecoder) json


parseAppendSetupFiles_ : Model -> List SetupOrIgnored -> Model
parseAppendSetupFiles_ model setupOrIgnoredList =
    let
        processOne setupOrIgnored ctx =
            let
                appendMessage message ctx__ =
                    if model.messagesTruncated then
                        ctx__

                    else
                        { ctx__ | messages = message :: ctx__.messages }

                ctx_ =
                    case setupOrIgnored of
                        Setup_ s ->
                            case parseSetupHtml s.filename s.setupHtml of
                                Err error ->
                                    { ctx | numErrors = ctx.numErrors + 1 } |> appendMessage ("ERROR: " ++ s.filename ++ ": " ++ error)

                                Ok setup ->
                                    { ctx | numSetups = ctx.numSetups + 1, setups = setup :: ctx.setups }

                        Ignored i ->
                            if i.what == "" then
                                { ctx | numIgnored = ctx.numIgnored + 1 }

                            else
                                { ctx | numIgnored = ctx.numIgnored + 1 } |> appendMessage ("ignored (" ++ i.what ++ "): " ++ i.filename)

                        Error_ e ->
                            { ctx | numErrors = ctx.numErrors + 1 } |> appendMessage ("ERROR: " ++ e.filename ++ ": " ++ e.what)
            in
            { ctx_ | numFiles = ctx_.numFiles + 1 }

        result =
            List.foldl processOne { setups = [], numFiles = 0, numSetups = 0, numIgnored = 0, numErrors = 0, messages = [] } setupOrIgnoredList

        toDictEntry item =
            ( item.id, item )

        setupsToAppend =
            Dict.fromList (List.map toDictEntry result.setups)

        allSetups =
            Dict.union setupsToAppend model.setups

        numSetups =
            model.numSetups + result.numSetups

        numIgnored =
            model.numIgnored + result.numIgnored

        numErrors =
            model.numErrors + result.numErrors

        numFiles =
            numSetups + numIgnored + numErrors
    in
    { model
        | numSetups = numSetups
        , numIgnored = numIgnored
        , numErrors = numErrors
        , setups = allSetups
    }
        |> appendMessagesToModel (List.reverse result.messages)


parseAppendSetupFiles : Model -> String -> Model
parseAppendSetupFiles model json =
    case decodeJson json of
        Err error ->
            { model | messages = model.messages ++ "internal application error: fail to decode json: " ++ errorToString error ++ "\n" }

        Ok setupOrIgnoredList ->
            parseAppendSetupFiles_ model setupOrIgnoredList
