module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import File exposing (File)
import File.Select as Select
import Html exposing (div, input, text)
import Html.Attributes exposing (multiple, type_)
import Html.Events exposing (on)
import Http
import Json.Decode as Decode
import Url
import Url.Builder


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Navigation.Key
    , page : Page
    }


type Page
    = FileManager



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        FileManager ->
            { title = "File Manager"
            , body =
                [ div []
                    [ input
                        [ type_ "file"
                        , multiple True
                        , on "change" (Decode.map FilesSelected filesDecoder)
                        ]
                        []
                    , div [] [ text (Debug.toString model) ]
                    ]
                ]
            }


filesDecoder : Decode.Decoder (List File)
filesDecoder =
    Decode.at [ "target", "files" ] (Decode.list File.decoder)



-- INIT


init : () -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , page = FileManager
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FilesSelected (List File)
    | GotUrl (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Navigation.load href
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        FilesSelected files ->
            let
                _ =
                    Debug.log "a" files
            in
            ( model
            , Http.get
                { url = Url.Builder.absolute [ "api", "signed-upload-url" ] [ Url.Builder.string "path" "abc" ]
                , expect = Http.expectJson GotUrl (Decode.field "url" Decode.string)
                }
            )

        GotUrl url ->
            let
                _ =
                    Debug.log "url" url
            in
            ( model, Cmd.none )
