module Global exposing (DropTargetIdType(..), Model, Msg(..))

import Car
import Dict exposing (Dict)
import Dom.DragDrop as DragDrop
import Setup
import Track


type DropTargetIdType
    = OntoElement Setup.Id
    | EndOfList


type alias Model =
    { maybeCar : Maybe Car.Car
    , maybeTrack : Maybe Track.Track
    , selectedSetupIds : List Setup.Id
    , dragDropState : DragDrop.State Setup.Id DropTargetIdType
    , setups : Dict Setup.Id Setup.Setup
    }


type Msg
    = CarChanged String
    | TrackChanged String
    | ToggleSetup Setup.Id
    | AddRemoveSetup Setup.Id Bool
    | AddSetup Setup.Id
    | RemoveSetup Setup.Id
    | MoveStarted Setup.Id
    | MoveTargetChanged DropTargetIdType
    | MoveCanceled
    | MoveCompleted Setup.Id DropTargetIdType
