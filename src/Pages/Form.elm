module Pages.Form exposing (Model, Msg, page)

import Common.ForShared exposing (FormModel)
import Dict
import Effect exposing (Effect)
import Gen.Params.Form exposing (Params)
import Gen.Route
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Loading exposing (defaultConfig)
import Page
import Ports.UrlState
import Request exposing (Request)
import Shared
import View exposing (View)



-- PAGE


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared req
        , update = update shared
        , view = view shared
        , subscriptions = subscriptions
        }



-- UTILS


keyFor : Model
keyFor =
    { firstName = "fn"
    , lastName = "ln"
    , restored = False
    }



-- INIT


type alias Model =
    FormModel


init : Shared.Model -> Request -> ( Model, Effect Msg )
init shared req =
    let
        fromQueryParamsWithDefault default key =
            Maybe.withDefault default <| Dict.get key req.query

        initFirstName =
            fromQueryParamsWithDefault
                shared.formModel.firstName
                keyFor.firstName

        initLastName =
            fromQueryParamsWithDefault
                shared.formModel.lastName
                keyFor.lastName

        isRestored =
            Common.ForShared.emptyFormModel /= FormModel initFirstName initLastName False
    in
    ( { firstName = initFirstName, lastName = initLastName, restored = isRestored }
    , Effect.batch
        [ Effect.fromShared Shared.SendHttpRequestOnce

        -- Restore query params on first page load or reentry
        , Effect.fromCmd <| updateQueryParams keyFor.firstName initFirstName
        , Effect.fromCmd <| updateQueryParams keyFor.lastName initLastName

        -- Empty previously cached form data
        , Tuple.second <| update shared SaveFormModel Common.ForShared.emptyFormModel
        ]
    )



-- UPDATE


type Msg
    = Submit
    | Reset
    | SaveFormModel
    | SetFirstName String
    | SetLastName String


updateQueryParams key val =
    Ports.UrlState.queryParamChanged { key = key, val = val }


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Submit ->
            ( model, Effect.none )

        Reset ->
            ( Common.ForShared.emptyFormModel
            , Effect.batch
                [ Effect.fromCmd <| updateQueryParams keyFor.firstName ""
                , Effect.fromCmd <| updateQueryParams keyFor.lastName ""
                ]
            )

        SetFirstName val ->
            ( { model | firstName = val }
            , Effect.fromCmd <| updateQueryParams keyFor.firstName val
            )

        SetLastName val ->
            ( { model | lastName = val }
            , Effect.fromCmd <| updateQueryParams keyFor.lastName val
            )

        SaveFormModel ->
            ( model, Effect.fromShared <| Shared.StoreFormModel model )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )


onSubmit : msg -> Html.Attribute msg
onSubmit msg =
    Html.Events.preventDefaultOn "submit" (Json.Decode.map alwaysPreventDefault (Json.Decode.succeed msg))


notifyIfRestored : Bool -> Html.Html msg
notifyIfRestored restored =
    if restored then
        Html.p
            [ Html.Attributes.style "color" "orange"
            ]
            [ Html.text "NOTE: the form values have been restored from cached data or nav state" ]

    else
        Html.span [] []


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "A form"
    , body =
        [ Html.a [ Html.Attributes.href <| Gen.Route.toHref Gen.Route.List ] [ Html.text "GO TO LIST" ]
        , Html.h1 [] [ Html.text "My form!" ]
        , Html.h2 [ Html.Attributes.style "max-width" "600px" ]
            [ Loading.render Loading.Circle { defaultConfig | color = "blue", size = 20 } shared.loadingState
            , Html.text ("Slow request: " ++ Maybe.withDefault "Fetching..." shared.srvMsg)
            ]
        , Html.div []
            [ notifyIfRestored model.restored
            , Html.label [] [ Html.text "Keep data" ]
            , Html.input
                [ Html.Attributes.type_ "checkbox"
                , Html.Events.onClick SaveFormModel
                ]
                []
            ]
        , Html.pre [] [ Html.text <| Debug.toString <| model ]
        , Html.form
            [ Html.Attributes.style "display" "flex"
            , onSubmit Submit
            , Html.Attributes.autocomplete False
            ]
            [ Html.div []
                [ Html.label [ Html.Attributes.style "display" "block" ] [ Html.text "First name" ]
                , Html.input
                    [ Html.Events.onInput SetFirstName
                    , Html.Attributes.value model.firstName
                    , Html.Attributes.autofocus True
                    ]
                    []
                ]
            , Html.div []
                [ Html.label [ Html.Attributes.style "display" "block" ] [ Html.text "Last name" ]
                , Html.input
                    [ Html.Events.onInput SetLastName
                    , Html.Attributes.value model.lastName
                    ]
                    []
                ]
            , Html.button [ Html.Attributes.hidden True ] [ Html.text "Submit" ]
            , Html.button
                [ Html.Attributes.type_ "button"
                , Html.Events.onClick Reset
                ]
                [ Html.text "Reset" ]
            ]
        ]
    }
