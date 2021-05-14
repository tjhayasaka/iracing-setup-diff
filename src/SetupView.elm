module SetupView exposing (viewSetupComparisonTable)

import Master
import Car
import Track
import Setup
import Dict
import Html.Attributes
import Dom
import Dom.DragDrop as DragDrop
import Global exposing (..)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input

type Row
    = SectionHeader String
    | SetupItem { name : String
                , valueElements : List (Element Msg) -- used to render
                , maybeValues : List (Maybe String) -- used to determine majority or not
                , majorityPs : List Bool }

type alias CookedSetupEntry =
    { name : String, value : String, valueElement : Element Msg }

type alias CookedSetup =
    { id : String
    , carId : Car.Id
    , trackId : Track.Id
    , name : String
    , entries : List CookedSetupEntry
    }

makeCookedSetup rawSetup =
    let
        makeValueElement rawElement = { name = rawElement.name
                                      , value = rawElement.value
                                      , valueElement = text rawElement.value
                                      }
        addMetaEntries entries =
            (
             let
                 maybeCar = Car.get (Car.Id rawSetup.carId) Master.cars
                 carId = Car.stringifiedId maybeCar
                 carName = case maybeCar of
                               Nothing -> "---"
                               Just car -> car.shortName
                 maybeTrack = Track.get (Track.Id rawSetup.trackId) Master.tracks
                 trackId = Track.stringifiedId maybeTrack
                 trackName = case maybeTrack of
                                 Nothing -> "---"
                                 Just track -> track.shortName
                 carEntry = { name = "Meta / Car"
                            , value = carName
                            , valueElement = Input.button [] { onPress = Just (CarChanged carId), label = text carName } }
                 trackEntry = { name = "Meta / Track"
                              , value = trackName
                              , valueElement = Input.button [] { onPress = Just (TrackChanged trackId), label = text trackName } }
             in
                 ( carEntry :: trackEntry :: entries )
            )
    in
        { id = rawSetup.id
        , carId = rawSetup.carId
        , trackId = rawSetup.trackId
        , name = rawSetup.name
        , entries = ( rawSetup.entries |> List.map makeValueElement |> addMetaEntries )
        }

getCookedSetupEntry : String -> CookedSetup -> Maybe CookedSetupEntry
getCookedSetupEntry entryName rawSetup =
    rawSetup.entries |> List.filter (\entry -> entry.name == entryName) |> List.head

dragDropMessages : DragDrop.Messages Msg Setup.Id DropTargetIdType

dragDropMessages =
    { dragStarted = MoveStarted
    , dropTargetChanged = MoveTargetChanged
    , dragEnded = MoveCanceled
    , dropped = MoveCompleted
    }

viewSetupComparisonTable : DragDrop.State Setup.Id DropTargetIdType -> List Setup.Id -> Element Msg
viewSetupComparisonTable dragDropState selectedSetupIds =
    let
        rawSetups = Setup.getMany selectedSetupIds Master.setups
        cookedSetups = rawSetups |> List.map makeCookedSetup
        rows = tableRows cookedSetups
    in
        viewSetupComparisonTable_ dragDropState cookedSetups rows

viewSetupComparisonTable_ : DragDrop.State Setup.Id DropTargetIdType -> List CookedSetup -> List Row -> Element Msg
viewSetupComparisonTable_ dragDropState setups rows =
    Element.table [ spacing 8 ]
    { data = tableRows setups
    , columns =
        let
            setupColumnHeader_ i setup =
                layout [ Font.color <| rgb255 255 255 255, Font.size 14 ]
                    ( column [] [ text setup.name
                                , Input.button [] { onPress = Just (RemoveSetup setup.id), label = text "remove" } ])

            setupColumnHeaderDD i setup =
                ( Dom.element "div"
                |> DragDrop.makeDraggable dragDropState setup.id dragDropMessages
                |> DragDrop.makeDroppable dragDropState (OntoElement setup.id) dragDropMessages
                |> Dom.appendNode (setupColumnHeader_ i setup)
                |> Dom.render
                )

            setupColumns i setup =
                { header = html (setupColumnHeaderDD i setup)
                , width = fill
                , view = \row ->
                         case row of
                             SetupItem item ->
                                 let
                                     majorityP = case item.majorityPs |> List.drop i |> List.head of
                                                     Nothing -> False
                                                     Just p -> p
                                     majorityAttrs = if majorityP then
                                                         []
                                                     else
                                                         [ (Html.Attributes.style "background-color" "#600") |> htmlAttribute ]
                                 in
                                     ( column
                                           ( majorityAttrs ++ [ paddingXY 10 0 ] )
                                           [ case item.valueElements |> List.drop i |> List.head of
                                                 Nothing -> text "(bug)"
                                                 Just element -> element
                                           ] )
                             _ -> none
                }
        in
            { header = none
            , width = px 200
            , view =
                  \row ->
                      case row of
                          SectionHeader name -> text name
                          SetupItem item -> column [] [ el [ alignRight ] ( text item.name ) ]
            } :: (List.indexedMap setupColumns setups)
    }

splitSections rows =
    case List.head rows of
        Nothing -> []
        Just row ->
            let sectionName = Setup.entryDirName row.name
            in splitSections_ sectionName rows

splitSections_ sectionName rows =
    let
        sectionRows_ rows_ =
            ( case rows_ of
                  row_ :: restRows_ ->
                      ( let
                          sectionName_ = Setup.entryDirName row_.name
                        in
                            if sectionName_ /= sectionName then
                                ( [], rows_ )
                            else
                                ( let
                                    ( rows__, restRows__ ) = (sectionRows_ restRows_)
                                    in
                                        ( SetupItem { row_ | name = Setup.entryBaseName row_.name } :: rows__
                                        , restRows__ )
                                )
                      )
                  _ ->
                      ( [], [] )
            )
        ( sectionRows, restRows ) = sectionRows_ rows
    in
        ( SectionHeader sectionName ) :: sectionRows ++ (splitSections restRows)

tableRows setups =
    setups |> tableRows_ |> List.map markMajorities |> splitSections

tableRows_ setups =
    let
        maybeNextEntryName =
            setups |> List.filterMap (\setup -> setup.entries |> List.head |> Maybe.map .name) |> List.head
        removeEntry entryName setup =
            { setup | entries = (setup.entries |> List.filter (\entry -> entry.name /= entryName)) }
        removeEntries entryName =
            setups |> List.map (removeEntry entryName)
    in
        case maybeNextEntryName of
            Nothing -> []
            Just entryName ->
                (
                 let
                    entries = setups |> List.map (\setup -> getCookedSetupEntry entryName setup)
                    entryValues = entries |> List.map (Maybe.map .value)
                    valueElements = entries |> List.map (Maybe.map .valueElement) |> List.map (Maybe.withDefault none)
                 in
                     { name = entryName
                     , valueElements = valueElements
                     , maybeValues = entryValues
                     , majorityPs = [] } :: (tableRows_ (removeEntries entryName))
                )

markMajorities row =
    let
        entryValues = row.maybeValues
        counts = entryValues |> List.map (\value -> entryValues |> List.foldl (\v a -> if v == value then
                                                                                           a + 1
                                                                                       else
                                                                                           a) 0)
        totalCount = List.length row.maybeValues
        majorityPs = counts |> List.map (\count -> count > (totalCount // 2))
    in
        { row | majorityPs = majorityPs }

