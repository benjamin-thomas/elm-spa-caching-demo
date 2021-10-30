module Common.ForShared exposing (FormModel, ListMsg(..), emptyFormModel)

import Time


type alias FormModel =
    { firstName : String, lastName : String, restored : Bool }


emptyFormModel : FormModel
emptyFormModel =
    FormModel "" "" False


type ListMsg
    = SetZone Time.Zone
    | SetTime Time.Posix
    | RequestStoreView
