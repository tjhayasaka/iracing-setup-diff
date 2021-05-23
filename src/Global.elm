module Global exposing (DropTargetIdType(..), ExportedSetupOrInfo(..), Model, Msg(..), initialModel)

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
    , showMessages : Bool
    , statusText : String
    , messages : String
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
    , setups = Dict.fromList []
    , showMessages = False
    , statusText = "initializing app..."
    , messages = ""
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
    | OpenSetupDirectryChooser
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
