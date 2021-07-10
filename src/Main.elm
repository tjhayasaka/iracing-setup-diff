port module Main exposing (main)

import Browser
import Car
import Dict
import Dom.DragDrop as DragDrop
import Dropdown
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy
import Global exposing (..)
import Html
import Html.Attributes
import Html.Events
import Html.Parser
import Html.Parser.Util
import Json.Decode
import List.Extra
import Master
import Setup
import SetupParser
import SetupView
import Svg
import Svg.Attributes
import Task
import Track


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


nextMsg : (arg -> Msg) -> arg -> Cmd Msg
nextMsg msg arg =
    Task.perform msg (Task.succeed arg)



-- PORTS


port progress : (Int -> msg) -> Sub msg


port reload : (() -> msg) -> Sub msg


port showInstructionsDialog : (() -> msg) -> Sub msg


port openSetupDirectoryChooser : () -> Cmd msg


port getDefaultSetupDirectory : () -> Cmd msg


port doneGetDefaultSetupDirectory : (String -> msg) -> Sub msg


port doneGetDefaultSetupDirectoryError : (String -> msg) -> Sub msg


port getStoredSetupDirectory : () -> Cmd msg


port doneSetStoredSetupDirectory : (String -> msg) -> Sub msg


port doneGetStoredSetupDirectory : (String -> msg) -> Sub msg


port doneGetStoredSetupDirectoryError : (String -> msg) -> Sub msg


port getSetupDirectory : ( String, String ) -> Cmd msg


port doneGetSetupDirectory : (String -> msg) -> Sub msg


port readExportedSetupFiles : String -> Cmd msg


port startedReadExportedSetupFiles : (Int -> msg) -> Sub msg


port partialResultReadExportedSetupFiles : (( Int, String ) -> msg) -> Sub msg


port doneReadExportedSetupFiles : (Int -> msg) -> Sub msg


port cancelReadExportedSetupFiles : Int -> Cmd msg


port doneCancelReadExportedSetupFiles : (Int -> msg) -> Sub msg



-- INIT


init : () -> ( Model, Cmd Msg )
init () =
    ( Global.initialModel, nextMsg Reload () )



-- UPDATE


addSetup setupId model =
    { model | selectedSetupIds = List.append model.selectedSetupIds [ setupId ] }


removeSetup setupId model =
    let
        survivorP id =
            setupId /= id
    in
    { model | selectedSetupIds = List.filter survivorP model.selectedSetupIds }


toggleSetup setupId model =
    let
        model0 =
            removeSetup setupId model
    in
    if model0 == model then
        addSetup setupId model

    else
        model0


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoMessage ->
            ( model, Cmd.none )

        Reload () ->
            ( { model | statusText = "reloading...", messages = "", messagesSize = 0, messagesTruncated = False }, getDefaultSetupDirectory () )

        Progress _ ->
            ( model, Cmd.none )

        OpenSetupDirectryChooser () ->
            ( { model | showInstructionsDialog = False }, openSetupDirectoryChooser () )

        DoneGetDefaultSetupDirectory defaultSetupDirectory ->
            ( { model | defaultSetupDirectory = defaultSetupDirectory }, getStoredSetupDirectory () )

        DoneGetDefaultSetupDirectoryError message ->
            let
                fallback =
                    "<failed to determine default setup directory>"
            in
            ( { model
                | messages = model.messages ++ message ++ "\n"
                , defaultSetupDirectory = fallback
              }
            , getStoredSetupDirectory ()
            )

        DoneSetStoredSetupDirectory storedSetupDirectory ->
            ( { model | storedSetupDirectory = Just storedSetupDirectory, messages = "Updated stored exported setup directory: new value = '" ++ storedSetupDirectory ++ "'\n", messagesSize = 0, messagesTruncated = False }, getSetupDirectory ( model.defaultSetupDirectory, storedSetupDirectory ) )

        DoneGetStoredSetupDirectory storedSetupDirectory ->
            ( { model | storedSetupDirectory = Just storedSetupDirectory }, getSetupDirectory ( model.defaultSetupDirectory, storedSetupDirectory ) )

        DoneGetStoredSetupDirectoryError message ->
            ( { model
                | messages = model.messages ++ message ++ "\n"
                , storedSetupDirectory = Nothing
              }
            , nextMsg DoneGetSetupDirectory model.defaultSetupDirectory
            )

        DoneGetSetupDirectory setupDirectory ->
            ( { model | setupDirectory = setupDirectory }, nextMsg StartReadExportedSetupFiles () )

        StartReadExportedSetupFiles () ->
            ( { model | statusText = "loading exported setup files...", pidReadExportedSetupFiles = Nothing, numSetups = 0, numIgnored = 0, numErrors = 0, setups = Dict.empty }, readExportedSetupFiles model.setupDirectory )

        StartedReadExportedSetupFiles pid ->
            ( { model | pidReadExportedSetupFiles = Just pid }, Cmd.none )

        PartialResultReadExportedSetupFiles ( pid, json ) ->
            if model.pidReadExportedSetupFiles == Just pid then
                ( SetupParser.parseAppendSetupFiles model json, Cmd.none )

            else
                ( model, Cmd.none )

        DoneReadExportedSetupFiles pid ->
            if model.pidReadExportedSetupFiles == Just pid then
                let
                    numFiles =
                        model.numSetups + model.numIgnored + model.numErrors

                    statusText =
                        String.fromInt numFiles ++ " files (" ++ String.fromInt model.numSetups ++ " setups, " ++ String.fromInt model.numIgnored ++ " ignored, " ++ String.fromInt model.numErrors ++ " errors)"
                in
                ( { model | pidReadExportedSetupFiles = Nothing, statusText = statusText }, nextMsg CleanUpSelection () )

            else
                ( model, Cmd.none )

        CancelReadExportedSetupFiles ->
            case model.pidReadExportedSetupFiles of
                Nothing ->
                    ( model, Cmd.none )

                Just pid ->
                    ( { model | statusText = "cancelling..." }, cancelReadExportedSetupFiles pid )

        DoneCancelReadExportedSetupFiles pid ->
            case model.pidReadExportedSetupFiles of
                Nothing ->
                    ( model, Cmd.none )

                Just pid_ ->
                    if pid_ == pid then
                        ( { model | statusText = "canceled", pidReadExportedSetupFiles = Nothing }, Cmd.none )

                    else
                        ( model, Cmd.none )

        CleanUpSelection () ->
            let
                cleaned =
                    Setup.getMany model.selectedSetupIds model.setups |> List.map .id
            in
            ( { model | selectedSetupIds = cleaned }, Cmd.none )

        HideInstructionsDialog ->
            ( { model | showInstructionsDialog = False }, Cmd.none )

        ShowInstructionsDialog ->
            ( { model | showInstructionsDialog = True }, Cmd.none )

        CloseInstructionsDialogThenReload ->
            ( { model | showInstructionsDialog = False }, nextMsg Reload () )

        CloseInstructionsDialogThenOpenSetupDirectryChooser ->
            ( { model | showInstructionsDialog = False }, nextMsg OpenSetupDirectryChooser () )

        ToggleShowMessages ->
            ( { model | showMessages = not model.showMessages }, Cmd.none )

        CarDropdownMsg subMsg ->
            let
                ( state, cmd ) =
                    Dropdown.update carDropdownConfig subMsg model model.carDropdownState
            in
            ( { model | carDropdownState = state }, cmd )

        CarChanged maybeNewIdString ->
            let
                maybeCar =
                    case maybeNewIdString of
                        Nothing ->
                            Nothing

                        Just newIdString ->
                            Car.get (Car.IdString newIdString) Master.cars
            in
            ( { model | maybeCar = maybeCar }, Cmd.none )

        TrackDropdownMsg subMsg ->
            let
                ( state, cmd ) =
                    Dropdown.update trackDropdownConfig subMsg model model.trackDropdownState
            in
            ( { model | trackDropdownState = state }, cmd )

        TrackChanged maybeNewIdString ->
            let
                maybeTrack =
                    case maybeNewIdString of
                        Nothing ->
                            Nothing

                        Just newIdString ->
                            Track.get (Track.IdString newIdString) Master.tracks
            in
            ( { model | maybeTrack = maybeTrack }, Cmd.none )

        NameFilterTextChanged newNameFilterText ->
            ( { model | nameFilterText = newNameFilterText }, Cmd.none )

        ToggleSetup setupId ->
            ( toggleSetup setupId model, Cmd.none )

        AddRemoveSetup setupId flag ->
            if flag then
                ( addSetup setupId model, Cmd.none )

            else
                ( removeSetup setupId model, Cmd.none )

        AddSetup setupId ->
            ( addSetup setupId model, Cmd.none )

        RemoveSetup setupId ->
            ( removeSetup setupId model, Cmd.none )

        MoveStarted draggedItemId ->
            ( { model | dragDropState = DragDrop.startDragging model.dragDropState draggedItemId }, Cmd.none )

        MoveTargetChanged dropTargetId ->
            ( { model | dragDropState = DragDrop.updateDropTarget model.dragDropState dropTargetId }, Cmd.none )

        MoveCanceled ->
            ( { model | dragDropState = DragDrop.stopDragging model.dragDropState }, Cmd.none )

        MoveCompleted draggedItemId dropTarget ->
            let
                listWithoutDraggedItem : List Setup.Id
                listWithoutDraggedItem =
                    model.selectedSetupIds
                        |> List.Extra.remove draggedItemId

                ( beforeDroppedElement, afterDroppedElement ) =
                    let
                        indexToSplitAt : Setup.Id -> Int
                        indexToSplitAt id =
                            List.Extra.elemIndex id model.selectedSetupIds
                                |> Maybe.withDefault 100

                        -- add one so that the element we just dragged and dropped comes first
                    in
                    case dropTarget of
                        OntoElement dropTargetId ->
                            listWithoutDraggedItem
                                |> List.Extra.splitAt (indexToSplitAt dropTargetId)

                        EndOfList ->
                            ( listWithoutDraggedItem, [] )
            in
            ( { model | selectedSetupIds = beforeDroppedElement ++ [ draggedItemId ] ++ afterDroppedElement, dragDropState = DragDrop.initialState }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ progress Progress
        , reload Reload
        , showInstructionsDialog (\() -> ShowInstructionsDialog)
        , doneGetDefaultSetupDirectory DoneGetDefaultSetupDirectory
        , doneGetDefaultSetupDirectoryError DoneGetDefaultSetupDirectoryError
        , doneSetStoredSetupDirectory DoneSetStoredSetupDirectory
        , doneGetStoredSetupDirectory DoneGetStoredSetupDirectory
        , doneGetStoredSetupDirectoryError DoneGetStoredSetupDirectoryError
        , doneGetSetupDirectory DoneGetSetupDirectory
        , startedReadExportedSetupFiles StartedReadExportedSetupFiles
        , partialResultReadExportedSetupFiles PartialResultReadExportedSetupFiles
        , doneReadExportedSetupFiles DoneReadExportedSetupFiles
        , doneCancelReadExportedSetupFiles DoneCancelReadExportedSetupFiles
        ]



-- VIEW


rawHtml : String -> List (Html.Html msg)
rawHtml str =
    case Html.Parser.run str of
        Ok nodes ->
            Html.Parser.Util.toVirtualDom nodes

        Err _ ->
            []


rawHtmlElement : String -> List (Element msg)
rawHtmlElement str =
    rawHtml str |> List.map html


dropdownLabel : Bool -> String -> Element Msg
dropdownLabel expanded labelString =
    let
        arrow =
            if expanded then
                "&#x25BC; "

            else
                "&#x25BA; "
    in
    row [] (rawHtmlElement arrow ++ [ text labelString ])


reloadOrCancelButton : Maybe Int -> Element Msg
reloadOrCancelButton pidReadExportedSetupFiles =
    case pidReadExportedSetupFiles of
        Nothing ->
            Input.button [ alignRight ] { onPress = Just (Reload ()), label = text "Reload" }

        Just _ ->
            Input.button [ alignRight ] { onPress = Just CancelReadExportedSetupFiles, label = text "Cancel" }


view : Model -> Html.Html Msg
view model =
    Element.layout
        [ Font.size 13
        , Background.color (rgb255 0 0 0)
        , Font.color <| rgb255 255 255 255
        , inFront (instructionsDialog model)
        ]
    <|
        column
            [ height fill
            , width fill
            , Background.color (rgb255 0 0 0)
            , Font.color <| rgb255 255 255 255
            , Font.size 13
            , padding 8
            ]
            [ html (Html.node "style" [] [ Html.text """
div[role='button'] { font-size: 12px; background: #dddddd; color: #000; border: solid 1px #a9a9a9; padding: 2px; }
    """ ])
            , column [ spacing 24 ]
                (row [ width fill ]
                    [ row [ alignLeft, spacing 12 ]
                        [ Input.button [ Font.underline, Background.color (rgb255 0 0 0), Font.color <| rgb255 255 255 255 ] { onPress = Just ToggleShowMessages, label = dropdownLabel model.showMessages model.statusText }
                        , Element.Lazy.lazy reloadOrCancelButton model.pidReadExportedSetupFiles
                        ]
                    , row [ alignRight, spacing 12 ]
                        [ text ("Setup Directory: '" ++ model.setupDirectory ++ "'")
                        , Input.button [] { onPress = Just (OpenSetupDirectryChooser ()), label = text "Change" }
                        ]
                    ]
                    :: (if model.showMessages then
                            [ text model.messages ]

                        else
                            []
                       )
                    ++ [ row
                            [ spacing 24 ]
                            [ viewCarForm model
                            , viewTrackForm model
                            , viewNameFilterForm model
                            ]
                       , viewAvailableSetups model
                       , column [ spacing 4 ]
                            [ text "Selected Setups"
                            , case model.selectedSetupIds of
                                [] ->
                                    text "(none selected)"

                                _ ->
                                    viewSelectedSetups model
                            ]
                       ]
                )
            ]


carDropdownConfig =
    let
        itemToText item =
            case Car.get (Car.IdString item) Master.cars of
                Nothing ->
                    "all cars"

                Just car ->
                    car.longName

        itemToTextWithCount item =
            itemToText item

        -- NOTE:  we want to add number of setups matched with this item, but it needs to access model, and model is not available here.
        itemToPrompt item =
            text (itemToTextWithCount item)

        itemToElement selected highlighted i =
            let
                attrs =
                    if highlighted then
                        [ Background.color <| rgb255 0 0 128 ]

                    else if selected then
                        [ Background.color <| rgb255 100 100 100 ]

                    else
                        [ Background.color <| rgb255 0 0 0 ]
            in
            el (attrs ++ [ width fill ]) (text <| itemToTextWithCount i)

        options model =
            (Nothing :: (Master.cars |> Dict.values |> List.sortBy .longName |> List.map Just)) |> List.map Car.stringifiedId
    in
    Dropdown.filterable
        { itemsFromModel = options
        , selectionFromModel = \model -> Just (Car.stringifiedId model.maybeCar)
        , dropdownMsg = CarDropdownMsg
        , onSelectMsg = CarChanged
        , itemToPrompt = itemToPrompt
        , itemToElement = itemToElement
        , itemToText = itemToText
        }
        |> Dropdown.withContainerAttributes [ width (px 300) ]
        |> Dropdown.withPromptElement (el [] (text "Select option"))
        |> Dropdown.withFilterPlaceholder "Type for option"
        |> Dropdown.withSelectAttributes [ Border.width 1, Border.rounded 2, paddingXY 16 8, spacing 10, width fill ]
        |> Dropdown.withListAttributes
            [ Border.width 1
            , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 2, bottomRight = 2 }
            , width fill
            , spacing 0
            ]
        |> Dropdown.withSearchAttributes [ Border.width 0, padding 0 ]


viewCarForm model =
    Dropdown.view carDropdownConfig model model.carDropdownState


trackDropdownConfig =
    let
        itemToText item =
            case Track.get (Track.IdString item) Master.tracks of
                Nothing ->
                    "all tracks"

                Just track ->
                    track.longName

        itemToTextWithCount item =
            itemToText item

        -- NOTE:  we want to add number of setups matched with this item, but it needs to access model, and model is not available here.
        itemToPrompt item =
            text (itemToTextWithCount item)

        itemToElement selected highlighted i =
            let
                attrs =
                    if highlighted then
                        [ Background.color <| rgb255 0 0 128 ]

                    else if selected then
                        [ Background.color <| rgb255 100 100 100 ]

                    else
                        [ Background.color <| rgb255 0 0 0 ]
            in
            el (attrs ++ [ width fill ]) (text <| itemToTextWithCount i)

        options model =
            (Nothing :: (Master.tracks |> Dict.values |> List.sortBy .longName |> List.map Just)) |> List.map Track.stringifiedId
    in
    Dropdown.filterable
        { itemsFromModel = options
        , selectionFromModel = \model -> Just (Track.stringifiedId model.maybeTrack)
        , dropdownMsg = TrackDropdownMsg
        , onSelectMsg = TrackChanged
        , itemToPrompt = itemToPrompt
        , itemToElement = itemToElement
        , itemToText = itemToText
        }
        |> Dropdown.withContainerAttributes [ width (px 300) ]
        |> Dropdown.withPromptElement (el [] (text "Select option"))
        |> Dropdown.withFilterPlaceholder "Type for option"
        |> Dropdown.withSelectAttributes [ Border.width 1, Border.rounded 2, paddingXY 16 8, spacing 10, width fill ]
        |> Dropdown.withListAttributes
            [ Border.width 1
            , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 2, bottomRight = 2 }
            , width fill
            , spacing 0
            ]
        |> Dropdown.withSearchAttributes [ Border.width 0, padding 0 ]


viewTrackForm model =
    Dropdown.view trackDropdownConfig model model.trackDropdownState


viewNameFilterForm model =
    column [ spacing 4 ]
        [ Input.text
            [ width (fill |> minimum 300 |> maximum 400)
            , Background.color (rgb255 0 0 0)
            , Font.color <| rgb255 255 255 255
            ]
            { onChange = NameFilterTextChanged
            , text = model.nameFilterText
            , placeholder = Just <| Input.placeholder [] <| text "filter by text"
            , label = Input.labelHidden "filter by text"
            }
        ]


viewAvailableSetups : Model -> Element Msg
viewAvailableSetups model =
    if model.setups == Dict.empty then
        viewInstructions

    else
        viewAvailableSetups_ model


viewInstructions : Element Msg
viewInstructions =
    column [ spacing 4, width fill ]
        [ el [ width fill, spacing 10, paddingXY 160 10, Font.size 16, Border.color <| rgb255 127 127 127, Border.width 1, Border.solid ]
            (Element.textColumn []
                [ el
                    [ padding 4
                    , centerX
                    , Font.center
                    , width fill
                    , Font.size 24
                    , Background.color (rgb255 64 0 0)
                    , Font.color <| rgb255 255 255 127
                    ]
                    (text "No Setup Files Loaded")
                , paragraph []
                    [ text "This program can read \"exported setup files\" only.  You need to export your setups manually in the garage screen in iRacing sim.  "
                    , link [ Element.Events.onClick ShowInstructionsDialog, Font.underline ] { url = "#", label = text "more info" }
                    ]
                ]
            )
        ]


dontPropagateClick_ : Html.Attribute Msg
dontPropagateClick_ =
    let
        msg =
            NoMessage
    in
    Html.Events.stopPropagationOn "click" (Json.Decode.map (\_ -> ( msg, True )) (Json.Decode.succeed msg))


dontPropagateClick : Attribute Msg
dontPropagateClick =
    htmlAttribute dontPropagateClick_


instructionsDialog : Model -> Element Msg
instructionsDialog model =
    if not model.showInstructionsDialog then
        column [] []

    else
        column [ spacing 4, width fill, height fill, Background.color (rgba255 48 48 48 0.9), Element.Events.onClick HideInstructionsDialog ]
            [ el
                [ width (fill |> minimum 600 |> maximum 600)
                , centerX
                , centerY
                , Font.size 16
                , Border.color <| rgb255 127 127 127
                , Border.width 1
                , Border.solid
                , dontPropagateClick
                ]
                (Element.textColumn [ padding 14, spacing 16 ]
                    [ paragraph [] [ text "This program can read \"exported setup files\" only.  You need to export your setups manually in the garage screen in iRacing sim:" ]
                    , Element.textColumn [ padding 14, spacing 16 ]
                        [ paragraph [] [ text "1. Launch the iRacing sim with correct car and track." ]
                        , paragraph [] [ text "2. Load a setup you want to export." ]
                        , paragraph []
                            [ text "3. Export it.  You can export it in the same directory (recommended), or in separate directory (not recommended, as you need to specify the directory everytime on export)."
                            , column [ width (px (600 - 56)) ]
                                [ el [ width fill, behindContent (image [ width fill, alpha 0.6 ] { src = "ss-garage.png", description = "" }) ] <|
                                    el []
                                        (html <|
                                            Svg.svg
                                                [ Svg.Attributes.viewBox "0 0 1022 841"
                                                ]
                                                [ Svg.rect
                                                    [ Svg.Attributes.x "780"
                                                    , Svg.Attributes.y "420"
                                                    , Svg.Attributes.width "250"
                                                    , Svg.Attributes.height "100"
                                                    , Svg.Attributes.stroke "cyan"
                                                    , Svg.Attributes.strokeWidth "12"
                                                    , Svg.Attributes.fillOpacity "0"
                                                    ]
                                                    []
                                                ]
                                        )
                                ]
                            ]
                        , paragraph [] [ text "4. Repeat 1, 2 and 3 for all setups you want to compare." ]
                        , paragraph []
                            [ text "5. "
                            , Input.button [] { onPress = Just CloseInstructionsDialogThenReload, label = text "Rescan setup directory" }
                            , text " (if you exported the files in default iRacing setup directory), or "
                            , Input.button [] { onPress = Just CloseInstructionsDialogThenOpenSetupDirectryChooser, label = text "Change setup directory" }
                            , text " (if you exported the files in other location)."
                            ]
                        ]
                    ]
                )
            ]


viewAvailableSetups_ : Model -> Element Msg
viewAvailableSetups_ model =
    row [ scrollbars, width fill, height (px 200) ]
        [ column [ spacing 4 ]
            (let
                entry setup =
                    let
                        carName =
                            Car.get (Car.Id setup.carId) Master.cars |> Maybe.map .longName |> Maybe.withDefault "???"

                        maybeSetupIndex =
                            List.Extra.elemIndex setup.id model.selectedSetupIds

                        indexLabelString =
                            case maybeSetupIndex of
                                Nothing ->
                                    ""

                                Just i ->
                                    String.fromInt i
                    in
                    row [ spacing 8 ]
                        [ el [ width (fill |> minimum 20) ] (el [ alignRight ] (text indexLabelString))
                        , Input.checkbox []
                            { onChange = AddRemoveSetup setup.id
                            , icon = Input.defaultCheckbox
                            , checked = maybeSetupIndex /= Nothing
                            , label = Input.labelRight [] (text (carName ++ " / " ++ setup.name))
                            }
                        ]
             in
             Setup.filterByCarTrack model.maybeCar model.maybeTrack model.nameFilterText model.setups
                |> List.map entry
            )
        ]


viewSelectedSetups : Model -> Element Msg
viewSelectedSetups model =
    let
        selectedSetups : List Setup.Setup
        selectedSetups =
            Setup.getMany model.selectedSetupIds model.setups
    in
    SetupView.viewSetupComparisonTable model.dragDropState selectedSetups
