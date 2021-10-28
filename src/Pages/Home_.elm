module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Gen.Route
import Html
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ req =
    Page.element
        { init = init req
        , update = update req
        , view = view req
        , subscriptions = \_ -> Sub.none
        }



-- INIT


type alias Model =
    {}


init : Request -> ( Model, Cmd Msg )
init req =
    ( {}, Request.pushRoute Gen.Route.Form req )



-- UPDATE


type Msg
    = NoOp


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )


view : Request -> Model -> View Msg
view _ _ =
    { title = "Homepage"
    , body =
        [ Html.p [] [ Html.text "Redirecting..." ]
        ]
    }
