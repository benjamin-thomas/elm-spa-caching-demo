{-
   Make sure that you expose Msg(..) as shown above (instead of just Msg).
   This allows SignIn and SignOut to be available to pages that send shared updates.
-}


module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , User
    , init
    , subscriptions
    , update
    )

import Common.ForShared exposing (FormModel)
import Json.Decode
import Loading
import Process
import Request exposing (Request)
import Task
import View exposing (View)


type alias Flags =
    Json.Decode.Value


type alias User =
    { name : String
    }


type alias Model =
    { srvMsg : Maybe String
    , loadingState : Loading.LoadingState
    , formModel : FormModel
    , listView : Maybe (View Common.ForShared.ListMsg)
    }


type Msg
    = SendHttpRequestOnce
    | FakeHttpDataReceived (Result Json.Decode.Error String)
    | StoreFormModel Common.ForShared.FormModel
    | StoreListView (View Common.ForShared.ListMsg)


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { srvMsg = Nothing
      , loadingState = Loading.On
      , formModel = Common.ForShared.emptyFormModel
      , listView = Nothing
      }
    , Cmd.none
    )


fakeHttpRequest : Cmd Msg
fakeHttpRequest =
    Process.sleep 2000
        |> Task.andThen (\_ -> Task.succeed "SERVER MESSAGE!!")
        |> Task.attempt FakeHttpDataReceived


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SendHttpRequestOnce ->
            let
                cmd =
                    case model.srvMsg of
                        Just _ ->
                            Cmd.none

                        Nothing ->
                            fakeHttpRequest
            in
            ( model, cmd )

        FakeHttpDataReceived result ->
            case result of
                Ok value ->
                    ( { model | srvMsg = Just value, loadingState = Loading.Off }, Cmd.none )

                Err _ ->
                    ( { model | srvMsg = Nothing }, Cmd.none )

        StoreFormModel fm ->
            ( { model | formModel = fm }, Cmd.none )

        StoreListView view ->
            ( { model | listView = Just view }, Cmd.none )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
