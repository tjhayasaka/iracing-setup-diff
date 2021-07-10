module SetupView exposing (viewSetupComparisonTable)

import Car
import Dict
import Dom
import Dom.DragDrop as DragDrop
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Global exposing (..)
import Html.Attributes
import Master
import Setup
import Track


type RelativeColumnPosition
    = NotDragged
    | DraggedObject
    | BeforeDraggedObject
    | AfterDraggedObject


type alias RawRow =
    { sectionName : String
    , name : String
    , valueElements : List (Element Msg) -- used to render
    , maybeValues : List (Maybe String) -- used to determine majority or not
    , majorityPs : List Bool
    , isComputed : Bool
    }


type Row
    = SectionHeader String
    | SetupItem RawRow


type alias CookedSetupEntry =
    { sectionName : String, name : String, isComputed : Bool, value : String, valueElement : Element Msg }


type alias CookedSetup =
    { id : String
    , carId : Car.Id
    , trackId : Track.Id
    , name : String
    , entries : List CookedSetupEntry
    }


makeCookedSetup : Setup.Setup -> CookedSetup
makeCookedSetup rawSetup =
    let
        makeValueElement rawElement =
            { sectionName = Setup.entryDirName rawSetup.name
            , name = rawElement.name
            , isComputed = rawElement.isComputed
            , value = rawElement.value
            , valueElement = text rawElement.value
            }

        addMetaEntries : List CookedSetupEntry -> List CookedSetupEntry
        addMetaEntries entries =
            let
                maybeCar =
                    Car.get (Car.Id rawSetup.carId) Master.cars

                carId =
                    Car.stringifiedId maybeCar

                carName =
                    case maybeCar of
                        Nothing ->
                            "---"

                        Just car ->
                            car.shortName

                maybeTrack =
                    Track.get (Track.Id rawSetup.trackId) Master.tracks

                trackId =
                    Track.stringifiedId maybeTrack

                trackName =
                    case maybeTrack of
                        Nothing ->
                            "---"

                        Just track ->
                            track.shortName

                carEntry =
                    { sectionName = "Meta"
                    , name = "Meta / Car"
                    , isComputed = False
                    , value = carName
                    , valueElement = Input.button [] { onPress = Just (CarChanged (Just carId)), label = text carName }
                    }

                trackEntry =
                    { sectionName = "Meta"
                    , name = "Meta / Track"
                    , isComputed = False
                    , value = trackName
                    , valueElement = Input.button [] { onPress = Just (TrackChanged (Just trackId)), label = text trackName }
                    }
            in
            carEntry :: trackEntry :: entries
    in
    { id = rawSetup.id
    , carId = rawSetup.carId
    , trackId = rawSetup.trackId
    , name = rawSetup.name
    , entries = rawSetup.entries |> List.map makeValueElement |> addMetaEntries
    }


getCookedSetupEntry : String -> CookedSetup -> Maybe CookedSetupEntry
getCookedSetupEntry entryName cookedSetup =
    cookedSetup.entries |> List.filter (\entry -> entry.name == entryName) |> List.head


dragDropMessages : DragDrop.Messages Msg Setup.Id DropTargetIdType
dragDropMessages =
    { dragStarted = MoveStarted
    , dropTargetChanged = MoveTargetChanged
    , dragEnded = MoveCanceled
    , dropped = MoveCompleted
    }


viewSetupComparisonTable : DragDrop.State Setup.Id DropTargetIdType -> List Setup.Setup -> Element Msg
viewSetupComparisonTable dragDropState selectedSetups =
    let
        cookedSetups =
            selectedSetups |> List.map makeCookedSetup

        rows =
            tableRows cookedSetups
    in
    viewSetupComparisonTable_ dragDropState cookedSetups rows


viewSetupComparisonTable_ : DragDrop.State Setup.Id DropTargetIdType -> List CookedSetup -> List Row -> Element Msg
viewSetupComparisonTable_ dragDropState setups rows =
    Element.table [ spacing 8 ]
        { data = tableRows setups
        , columns =
            let
                relativeColumnPosition : Setup.Id -> RelativeColumnPosition
                relativeColumnPosition thisId =
                    case DragDrop.currentlyDraggedObject dragDropState of
                        Nothing ->
                            NotDragged

                        Just draggedObjectId ->
                            if draggedObjectId == thisId then
                                DraggedObject

                            else
                                setups
                                    |> List.foldl
                                        (\setup result ->
                                            case result of
                                                NotDragged ->
                                                    if setup.id == draggedObjectId then
                                                        DraggedObject

                                                    else if setup.id == thisId then
                                                        BeforeDraggedObject

                                                    else
                                                        result

                                                DraggedObject ->
                                                    if setup.id == thisId then
                                                        AfterDraggedObject

                                                    else
                                                        result

                                                BeforeDraggedObject ->
                                                    BeforeDraggedObject

                                                AfterDraggedObject ->
                                                    AfterDraggedObject
                                        )
                                        NotDragged

                placeholderAttrib : Setup.Id -> List (Attribute msg)
                placeholderAttrib thisId =
                    case ( DragDrop.isCurrentDropTarget dragDropState (OntoElement thisId), relativeColumnPosition thisId ) of
                        ( _, NotDragged ) ->
                            []

                        ( _, DraggedObject ) ->
                            [ alpha 0.3 ]

                        ( False, _ ) ->
                            []

                        ( True, BeforeDraggedObject ) ->
                            [ Border.color <| rgb255 63 127 127, Border.solid, Border.widthEach { bottom = 0, left = 8, right = 0, top = 0 }, paddingEach { bottom = 0, left = 20, right = 0, top = 0 } ]

                        ( True, AfterDraggedObject ) ->
                            [ Border.color <| rgb255 63 127 127, Border.solid, Border.widthEach { bottom = 0, left = 0, right = 8, top = 0 }, paddingEach { bottom = 0, left = 0, right = 20, top = 0 } ]

                setupColumnHeader_ i setup =
                    layoutWith { options = [ noStaticStyleSheet ] }
                        [ Font.color <| rgb255 255 255 255, Font.size 14 ]
                        (column
                            (placeholderAttrib setup.id ++ [ spacing 4, width fill ])
                            [ text (setup.name |> String.replace " / " "\n/ ")
                            , Input.button [] { onPress = Just (RemoveSetup setup.id), label = text "remove" }
                            ]
                        )

                setupColumnHeaderDD i setup =
                    Dom.element "div"
                        |> DragDrop.makeDraggable dragDropState setup.id dragDropMessages
                        |> DragDrop.makeDroppable dragDropState (OntoElement setup.id) dragDropMessages
                        |> Dom.appendNode (setupColumnHeader_ i setup)
                        |> Dom.render

                setupColumns i setup =
                    { header = html (setupColumnHeaderDD i setup)
                    , width = fill
                    , view =
                        \row ->
                            case row of
                                SetupItem item ->
                                    let
                                        majorityP =
                                            case item.majorityPs |> List.drop i |> List.head of
                                                Nothing ->
                                                    False

                                                Just p ->
                                                    p

                                        majorityAttrs =
                                            case ( majorityP, item.isComputed ) of
                                                ( False, False ) ->
                                                    [ Html.Attributes.style "background-color" "#600" |> htmlAttribute ]

                                                ( False, True ) ->
                                                    [ Html.Attributes.style "background-color" "#300" |> htmlAttribute, Html.Attributes.style "color" "#bbb" |> htmlAttribute ]

                                                ( True, False ) ->
                                                    []

                                                ( True, True ) ->
                                                    [ Html.Attributes.style "color" "#aaa" |> htmlAttribute ]
                                    in
                                    column
                                        (placeholderAttrib setup.id ++ majorityAttrs ++ [ paddingXY 10 0 ])
                                        [ case item.valueElements |> List.drop i |> List.head of
                                            Nothing ->
                                                text "(bug)"

                                            Just element ->
                                                element
                                        ]

                                _ ->
                                    column (placeholderAttrib setup.id) [ text " " ]
                    }

                column0 =
                    { header = none
                    , width = px 200
                    , view =
                        \row ->
                            case row of
                                SectionHeader name ->
                                    let
                                        isFront =
                                            (name == "TIRES / LEFT FRONT") || (name == "TIRES / RIGHT FRONT") || (name == "CHASSIS / LEFT FRONT") || (name == "CHASSIS / RIGHT FRONT")

                                        isRear =
                                            (name == "TIRES / LEFT REAR") || (name == "TIRES / RIGHT REAR") || (name == "CHASSIS / LEFT REAR") || (name == "CHASSIS / RIGHT REAR")

                                        frontRearAttrs =
                                            if isFront then
                                                [ Html.Attributes.style "background-color" "#046" |> htmlAttribute ]

                                            else if isRear then
                                                [ Html.Attributes.style "background-color" "#640" |> htmlAttribute ]

                                            else
                                                []

                                        attrs =
                                            frontRearAttrs
                                    in
                                    column attrs [ text name ]

                                SetupItem item ->
                                    let
                                        isFront =
                                            (item.sectionName == "TIRES / LEFT FRONT") || (item.sectionName == "TIRES / RIGHT FRONT") || (item.sectionName == "CHASSIS / LEFT FRONT") || (item.sectionName == "CHASSIS / RIGHT FRONT")

                                        isRear =
                                            (item.sectionName == "TIRES / LEFT REAR") || (item.sectionName == "TIRES / RIGHT REAR") || (item.sectionName == "CHASSIS / LEFT REAR") || (item.sectionName == "CHASSIS / RIGHT REAR")

                                        frontRearAttrs =
                                            if isFront then
                                                [ Html.Attributes.style "background-color" "#046" |> htmlAttribute ]

                                            else if isRear then
                                                [ Html.Attributes.style "background-color" "#640" |> htmlAttribute ]

                                            else
                                                []

                                        isComputedAttrs =
                                            case item.isComputed of
                                                False ->
                                                    []

                                                True ->
                                                    [ Html.Attributes.style "color" "#aaa" |> htmlAttribute ]

                                        attrs =
                                            frontRearAttrs ++ isComputedAttrs
                                    in
                                    column attrs [ el [ alignRight ] (text item.name) ]
                    }
            in
            column0
                :: List.indexedMap setupColumns setups
        }


splitSections : List RawRow -> List Row
splitSections rows =
    case List.head rows of
        Nothing ->
            []

        Just row ->
            let
                sectionName =
                    Setup.entryDirName row.name
            in
            splitSections_ sectionName rows


splitSections_ : String -> List RawRow -> List Row
splitSections_ sectionName rows =
    let
        sectionRows_ rows_ =
            case rows_ of
                row_ :: restRows_ ->
                    let
                        sectionName_ =
                            Setup.entryDirName row_.name
                    in
                    if sectionName_ /= sectionName then
                        ( [], rows_ )

                    else
                        let
                            ( rows__, restRows__ ) =
                                sectionRows_ restRows_
                        in
                        ( SetupItem { row_ | name = Setup.entryBaseName row_.name } :: rows__
                        , restRows__
                        )

                _ ->
                    ( [], [] )

        ( sectionRows, restRows ) =
            sectionRows_ rows
    in
    SectionHeader sectionName :: sectionRows ++ splitSections restRows


tableRows : List CookedSetup -> List Row
tableRows setups =
    setups |> tableRows_ |> List.map markMajorities |> splitSections


tableRows_ : List CookedSetup -> List RawRow
tableRows_ setups =
    let
        maybeNextEntryName =
            setups |> List.filterMap (\setup -> setup.entries |> List.head |> Maybe.map .name) |> List.head

        maybeIsComputed =
            setups |> List.filterMap (\setup -> setup.entries |> List.head |> Maybe.map .isComputed) |> List.head

        removeEntry entryName setup =
            { setup | entries = setup.entries |> List.filter (\entry -> entry.name /= entryName) }

        removeEntries entryName =
            setups |> List.map (removeEntry entryName)
    in
    case maybeNextEntryName of
        Nothing ->
            []

        Just entryName ->
            let
                entries =
                    setups |> List.map (\setup -> getCookedSetupEntry entryName setup)

                isComputed =
                    maybeIsComputed |> Maybe.withDefault False

                entryValues =
                    entries |> List.map (Maybe.map .value)

                valueElements =
                    entries |> List.map (Maybe.map .valueElement) |> List.map (Maybe.withDefault none)
            in
            { sectionName = Setup.entryDirName entryName
            , name = entryName
            , isComputed = isComputed
            , valueElements = valueElements
            , maybeValues = entryValues
            , majorityPs = []
            }
                :: tableRows_ (removeEntries entryName)


markMajorities : RawRow -> RawRow
markMajorities row =
    let
        entryValues =
            row.maybeValues

        counts =
            entryValues
                |> List.map
                    (\value ->
                        entryValues
                            |> List.foldl
                                (\v a ->
                                    if v == value then
                                        a + 1

                                    else
                                        a
                                )
                                0
                    )

        totalCount =
            List.length row.maybeValues

        majorityPs =
            counts |> List.map (\count -> count > (totalCount // 2))
    in
    { row | majorityPs = majorityPs }
