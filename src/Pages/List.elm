module Pages.List exposing (Model, Msg, page)

import Common.ForShared as ListMsg exposing (ListMsg)
import Effect exposing (Effect)
import Gen.Params.List exposing (Params)
import Gen.Route
import Html
import Html.Attributes
import Html.Events
import Page
import Request
import Shared
import Task
import Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.advanced
        { init = init
        , update = update shared
        , view = view shared
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : ( Model, Effect Msg )
init =
    ( Model Time.utc (Time.millisToPosix 0)
    , Effect.batch
        [ Effect.fromCmd <| Task.perform ListMsg.SetZone Time.here
        , Effect.fromCmd <| Task.perform ListMsg.SetTime Time.now
        ]
    )



-- UPDATE


type alias Msg =
    ListMsg


update : Shared.Model -> ListMsg -> Model -> ( Model, Effect ListMsg )
update shared msg model =
    case msg of
        ListMsg.SetZone zone ->
            ( { model | zone = zone }, Effect.none )

        ListMsg.SetTime time ->
            ( { model | time = time }, Effect.none )

        ListMsg.RequestStoreView ->
            ( model, Effect.fromShared <| Shared.StoreListView <| view shared model )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    case shared.listView of
        Just lv ->
            lv

        Nothing ->
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
                , Html.button [ Html.Events.onClick ListMsg.RequestStoreView ] [ Html.text "store view" ]
                ]
            }
