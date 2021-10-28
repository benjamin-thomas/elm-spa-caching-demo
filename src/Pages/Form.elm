module Pages.Form exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Form exposing (Params)
import Gen.Route
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Loading exposing (defaultConfig)
import Page
import Request
import Shared
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
    { firstName : String, lastName : String }


displayMsg : Maybe String -> String
displayMsg maybeMsg =
    case maybeMsg of
        Just msg ->
            msg

        Nothing ->
            "Fetching..."


init : ( Model, Effect Msg )
init =
    ( { firstName = "", lastName = "" }, Effect.fromShared Shared.SendHttpRequestOnce )



-- UPDATE


type Msg
    = Submit
    | SetFirstName String
    | SetLastName String


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Submit ->
            ( model, Effect.none )

        SetFirstName val ->
            ( { model | firstName = val }, Effect.none )

        SetLastName val ->
            ( { model | lastName = val }, Effect.none )



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



--noinspection SpellCheckingInspection


spinnerColor =
    "#4B4BDEFF"


debugFields : Model -> { firstName : String, lastName : String }
debugFields model =
    { firstName = model.firstName, lastName = model.lastName }


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "A form"
    , body =
        [ Html.a [ Html.Attributes.href <| Gen.Route.toHref Gen.Route.List ] [ Html.text "GO TO LIST" ]
        , Html.h1 [] [ Html.text "My form!" ]
        , Html.h2 [ Html.Attributes.style "max-width" "600px" ]
            [ Loading.render Loading.Circle { defaultConfig | color = spinnerColor, size = 20 } shared.loadingState
            , Html.text ("Slow request: " ++ displayMsg shared.srvMsg)
            ]
        , Html.pre [] [ Html.text <| Debug.toString <| debugFields model ]
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
            ]
        ]
    }
