port module Ports.UrlState exposing (..)


type alias Param =
    { key : String
    , val : String
    }


port queryParamChanged : Param -> Cmd msg
