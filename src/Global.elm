module Global exposing (DropTargetIdType(..), ExportedSetupOrInfo(..), Model, Msg(..))

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
    , setups : Dict Setup.Id Setup.Setup
    , showMessages : Bool
    , statusText : String
    , messages : String
    , maybeCar : Maybe Car.Car
    , maybeTrack : Maybe Track.Track
    , nameFilterText : String
    , selectedSetupIds : List Setup.Id
    , dragDropState : DragDrop.State Setup.Id DropTargetIdType
    }


type Msg
    = Reload ()
    | OpenSetupDirectryChooser
    | DoneGetDefaultSetupDirectory String
    | DoneGetDefaultSetupDirectoryError String
    | DoneGetStoredSetupDirectory String
    | DoneGetStoredSetupDirectoryError String
    | DoneGetSetupDirectory String
    | StartReadExportedSetupFiles ()
    | DoneReadExportedSetupFiles String
    | CleanUpSelection ()
    | ToggleShowMessages
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
