module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Html exposing (text)
import Page.FileManager as FileManager
import Url
import Url.Parser as Parser exposing (Parser, map, oneOf, top)


main : Program () Model Msg
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
    = Loading
    | NotFound
    | FileManager FileManager.Model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        FileManager fileManager ->
            Sub.map FileManagerMsg (FileManager.subscriptions fileManager)

        _ ->
            Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Loading ->
            { title = "Loading", body = [ text "Loading" ] }

        NotFound ->
            { title = "Not Found", body = [ text "Not Found" ] }

        FileManager fileManager ->
            { title = "File Manager"
            , body =
                [ FileManager.view fileManager |> Html.map FileManagerMsg
                ]
            }



-- INIT


init : () -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    stepUrl url
        { key = key
        , page = Loading
        }


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                [ route Parser.top
                    (stepFileManager model (FileManager.init ()))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
    Parser.map handler parser



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FileManagerMsg FileManager.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
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

        UrlChanged _ ->
            ( model, Cmd.none )

        FileManagerMsg msg ->
            case model.page of
                FileManager fileManager ->
                    stepFileManager model (FileManager.update msg fileManager)

                _ ->
                    ( model, Cmd.none )


stepFileManager : Model -> ( FileManager.Model, Cmd FileManager.Msg ) -> ( Model, Cmd Msg )
stepFileManager model ( fileManager, cmds ) =
    ( { model | page = FileManager fileManager }
    , Cmd.map FileManagerMsg cmds
    )
