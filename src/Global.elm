module Global exposing (DropTargetIdType(..), ExportedSetupOrInfo(..), Model, Msg(..), appendMessagesToModel, initialModel)

import Car
import Dict exposing (Dict)
import Dom.DragDrop as DragDrop
import Setup
import Track


type DropTargetIdType
    = OntoElement Setup.Id
    | EndOfList


type alias Model =
    { defaultSetupDirectory : String
    , storedSetupDirectory : Maybe String
    , setupDirectory : String
    , numSetups : Int
    , numIgnored : Int
    , numErrors : Int
    , setups : Dict Setup.Id Setup.Setup
    , showInstructionsDialog : Bool
    , showMessages : Bool
    , statusText : String
    , messages : String
    , messagesSize : Int
    , messagesTruncated : Bool
    , maybeCar : Maybe Car.Car
    , maybeTrack : Maybe Track.Track
    , nameFilterText : String
    , selectedSetupIds : List Setup.Id
    , dragDropState : DragDrop.State Setup.Id DropTargetIdType
    , pidReadExportedSetupFiles : Maybe Int
    }


initialModel =
    { defaultSetupDirectory = "/"
    , storedSetupDirectory = Nothing
    , setupDirectory = "/"
    , numSetups = 0
    , numIgnored = 0
    , numErrors = 0
    , setups = Dict.empty
    , showInstructionsDialog = False
    , showMessages = False
    , statusText = "initializing app..."
    , messages = ""
    , messagesSize = 0
    , messagesTruncated = False
    , maybeCar = Nothing
    , maybeTrack = Nothing
    , nameFilterText = ""
    , selectedSetupIds = []
    , dragDropState = DragDrop.initialState
    , pidReadExportedSetupFiles = Nothing
    }


type Msg
    = Reload ()
    | Progress Int
    | OpenSetupDirectryChooser ()
    | DoneGetDefaultSetupDirectory String
    | DoneGetDefaultSetupDirectoryError String
    | DoneSetStoredSetupDirectory String
    | DoneGetStoredSetupDirectory String
    | DoneGetStoredSetupDirectoryError String
    | DoneGetSetupDirectory String
    | StartReadExportedSetupFiles ()
    | StartedReadExportedSetupFiles Int
    | PartialResultReadExportedSetupFiles ( Int, String )
    | DoneReadExportedSetupFiles Int
    | CancelReadExportedSetupFiles
    | DoneCancelReadExportedSetupFiles Int
    | CleanUpSelection ()
    | ToggleShowMessages
    | ToggleShowInstructionsDialog
    | CloseInstructionsDialogThenReload
    | CloseInstructionsDialogThenOpenSetupDirectryChooser
    | CarChanged String
    | TrackChanged String
    | NameFilterTextChanged String
    | ToggleSetup Setup.Id
    | AddRemoveSetup Setup.Id Bool
    | AddSetup Setup.Id
    | RemoveSetup Setup.Id
    | MoveStarted Setup.Id
    | MoveTargetChanged DropTargetIdType
    | MoveCanceled
    | MoveCompleted Setup.Id DropTargetIdType


type
    ExportedSetupOrInfo
    -- used in ports
    = Ignored { what : String }
    | ExportedSetup { basename : String, filename : String }


messagesCapacity : Int
messagesCapacity =
    200


truncateMessagesIfNeeded : Model -> Model
truncateMessagesIfNeeded model =
    let
        hasRoomForMessage =
            model.messagesSize < messagesCapacity

        noNeedToTruncate =
            model.messagesTruncated || hasRoomForMessage
    in
    if noNeedToTruncate then
        model

    else
        { model | messagesTruncated = True, messages = model.messages ++ "(truncated)\n" }


appendMessagesToModel : List String -> Model -> Model
appendMessagesToModel messages model =
    if messages == [] || model.messagesTruncated then
        model

    else
        let
            model_ =
                truncateMessagesIfNeeded model
        in
        if model_.messagesTruncated then
            model_

        else
            { model_
                | messages = model_.messages ++ String.join "\n" messages ++ "\n"
                , messagesSize = model_.messagesSize + List.length messages
            }
