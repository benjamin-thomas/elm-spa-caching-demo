module Pages.List exposing (Model, Msg, page)

import Gen.Params.List exposing (Params)
import Gen.Route
import Html
import Html.Attributes
import Page
import Request
import Shared
import Task
import Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : ( Model, Cmd Msg )
init =
    ( Model Time.utc (Time.millisToPosix 0)
    , Cmd.batch
        [ Task.perform SetZone Time.here
        , Task.perform SetTime Time.now
        ]
    )



-- UPDATE


type Msg
    = SetZone Time.Zone
    | SetTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetZone zone ->
            ( { model | zone = zone }, Cmd.none )

        SetTime time ->
            ( { model | time = time }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    let
        format : (Time.Zone -> Time.Posix -> Int) -> String
        format fn =
            String.padLeft 2 '0' <| String.fromInt (fn model.zone model.time)

        hour =
            format Time.toHour

        minute =
            format Time.toMinute

        second =
            format Time.toSecond
    in
    { title = "A list"
    , body =
        [ Html.a [ Html.Attributes.href <| Gen.Route.toHref Gen.Route.Form ] [ Html.text "GO TO FORM" ]
        , Html.h1 [] [ Html.text ("Generated at: " ++ hour ++ ":" ++ minute ++ ":" ++ second) ]
        , Html.ul []
            [ Html.li [] [ Html.text "A" ]
            , Html.li [] [ Html.text "B" ]
            , Html.li [] [ Html.text "C" ]
            ]
        ]
    }
