module Pages.Top exposing (Model, Msg, page)

import Car
import Dict
import Dom.DragDrop as DragDrop
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes
import Html.Events
import List.Extra
import Master
import Setup
import SetupView
import TopTypes exposing (..)
import Track


type alias Model =
    { maybeCar : Maybe Car.Car
    , maybeTrack : Maybe Track.Track
    , selectedSetupIds : List Setup.Id
    , dragDropState : DragDrop.State Setup.Id TopTypes.DropTargetIdType
    }


type alias Msg =
    TopTypes.Msg


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "iRacing Notes"
        , init = always init
        , update = always update
        , view = always view
        }



-- INIT


init : Params.Top -> Model
init _ =
    Model Nothing Nothing [] DragDrop.initialState



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


update : Msg -> Model -> Model
update msg model =
    case msg of
        CarChanged newIdString ->
            { model | maybeCar = Car.get (Car.IdString newIdString) Master.cars }

        TrackChanged newIdString ->
            { model | maybeTrack = Track.get (Track.IdString newIdString) Master.tracks }

        ToggleSetup setupId ->
            toggleSetup setupId model

        AddRemoveSetup setupId flag ->
            if flag then
                addSetup setupId model

            else
                removeSetup setupId model

        AddSetup setupId ->
            addSetup setupId model

        RemoveSetup setupId ->
            removeSetup setupId model

        MoveStarted draggedItemId ->
            { model | dragDropState = DragDrop.startDragging model.dragDropState draggedItemId }

        MoveTargetChanged dropTargetId ->
            { model | dragDropState = DragDrop.updateDropTarget model.dragDropState dropTargetId }

        MoveCanceled ->
            { model | dragDropState = DragDrop.stopDragging model.dragDropState }

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
            { model | selectedSetupIds = beforeDroppedElement ++ [ draggedItemId ] ++ afterDroppedElement, dragDropState = DragDrop.initialState }



-- VIEW


view : Model -> Element Msg
view model =
    column [ spacing 24 ]
        [ row
            [ padding 10
            , spacing 24
            ]
            [ column [] [ viewCarForm model ]
            , column [] [ viewTrackForm model ]
            ]
        , column []
            [ row [] [ text "Setups" ]
            , column [ spacing 4 ]
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
                 Setup.filterByCarTrack model.maybeCar model.maybeTrack Master.setups
                    |> List.map entry
                )
            ]
        , column []
            [ row [] [ text "Selected Setups" ]
            , case model.selectedSetupIds of
                [] ->
                    text "(none selected)"

                _ ->
                    viewSelectedSetups model
            ]
        ]


viewCarForm model =
    column []
        [ text "Car"
        , let
            countMatches maybeCar =
                Master.setups |> Setup.filterByCarTrack maybeCar model.maybeTrack |> List.length |> String.fromInt

            entry car =
                Html.option
                    [ Html.Attributes.value (car.id |> String.fromInt)
                    , Html.Attributes.selected ((car.id |> String.fromInt) == Car.stringifiedId model.maybeCar)
                    ]
                    [ Html.text (car.longName ++ " (" ++ countMatches (Just car) ++ ")") ]

            nullOption =
                Html.option [ Html.Attributes.value "" ] [ Html.text ("all (" ++ countMatches Nothing ++ " setups)") ]

            options =
                Master.cars |> Dict.values |> List.map entry
          in
          html (Html.select [ Html.Events.onInput CarChanged ] (nullOption :: options))
        ]


viewTrackForm model =
    column []
        [ text "Track"
        , let
            countMatches maybeTrack =
                Master.setups |> Setup.filterByCarTrack model.maybeCar maybeTrack |> List.length |> String.fromInt

            entry track =
                Html.option
                    [ Html.Attributes.value (track.id |> String.fromInt)
                    , Html.Attributes.selected ((track.id |> String.fromInt) == Track.stringifiedId model.maybeTrack)
                    ]
                    [ Html.text (track.longName ++ " (" ++ countMatches (Just track) ++ ")") ]

            nullOption =
                Html.option [ Html.Attributes.value "" ] [ Html.text ("all (" ++ countMatches Nothing ++ " setups)") ]

            options =
                Master.tracks |> Dict.values |> List.map entry
          in
          html (Html.select [ Html.Events.onInput TrackChanged ] (nullOption :: options))
        ]


viewSelectedSetups model =
    SetupView.viewSetupComparisonTable model.dragDropState model.selectedSetupIds
