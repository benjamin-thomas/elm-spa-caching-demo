module Common.ForShared exposing (FormModel, emptyFormModel)


type alias FormModel =
    { firstName : String, lastName : String, restored : Bool }


emptyFormModel : FormModel
emptyFormModel =
    FormModel "" "" False
