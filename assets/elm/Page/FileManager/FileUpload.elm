module Page.FileManager.FileUpload exposing
    ( Msg
    , State(..)
    , continue
    , newFileRef
    , start
    , state
    , trackProgress
    )

import File exposing (File)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Page.FileManager.FileRef as FileRef exposing (FileRef)
import Url.Builder


type State
    = Pending
    | Uploading String Int
    | Success
    | Failure


state : Msg -> Maybe State
state msg =
    case msg of
        NoOp ->
            Nothing

        UrlReceived _ (Ok ( fileRef, _ )) ->
            Just <| Uploading fileRef.id 0

        UrlReceived _ (Err _) ->
            Just Failure

        Progress id bytes ->
            Just <| Uploading id bytes

        Uploaded _ (Ok ()) ->
            Nothing

        Uploaded _ (Err _) ->
            Just Failure

        Complete _ (Ok ()) ->
            Just Success

        Complete _ (Err _) ->
            Just Failure


type Msg
    = NoOp
    | UrlReceived File (Result Http.Error ( FileRef, String ))
    | Progress String Int
    | Uploaded FileRef (Result Http.Error ())
    | Complete FileRef (Result Http.Error ())


start : File -> Cmd Msg
start =
    getUrl


continue : Msg -> Cmd Msg
continue msg =
    case msg of
        NoOp ->
            Cmd.none

        UrlReceived file (Ok ( fileRef, url )) ->
            uploadFile fileRef url file

        UrlReceived _ (Err _) ->
            Cmd.none

        Progress _ _ ->
            Cmd.none

        Uploaded fileRef (Ok ()) ->
            completeUpload fileRef

        Uploaded _ (Err _) ->
            Cmd.none

        Complete _ (Ok ()) ->
            Cmd.none

        Complete _ (Err _) ->
            Cmd.none


newFileRef : Msg -> Maybe FileRef
newFileRef msg =
    case msg of
        Complete fileRef (Ok ()) ->
            Just fileRef

        _ ->
            Nothing


trackProgress : String -> Sub Msg
trackProgress id =
    Http.track id (progressMsg id)


progressMsg : String -> Http.Progress -> Msg
progressMsg id httpProgress =
    case httpProgress of
        Http.Sending { sent } ->
            Progress id sent

        Http.Receiving _ ->
            NoOp


getUrl : File -> Cmd Msg
getUrl file =
    Http.post
        { url = Url.Builder.absolute [ "api", "upload", "start" ] []
        , expect =
            Http.expectJson (UrlReceived file)
                (Decode.map2
                    Tuple.pair
                    (Decode.field "fileRef" FileRef.decoder)
                    (Decode.field "uploadUrl" Decode.string)
                )
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "filename", Encode.string <| File.name file )
                    , ( "mime_type", Encode.string <| File.mime file )
                    , ( "size", Encode.int <| File.size file )
                    , ( "file_metadata", Encode.object [] )
                    ]
        }


uploadFile : FileRef -> String -> File -> Cmd Msg
uploadFile fileRef url file =
    Http.request
        { method = "PUT"
        , headers = [ Http.header "Content-Type" <| File.mime file ]
        , url = url
        , body = Http.fileBody file
        , expect = Http.expectWhatever (Uploaded fileRef)
        , timeout = Nothing
        , tracker = Just fileRef.id
        }


completeUpload : FileRef -> Cmd Msg
completeUpload fileRef =
    Http.post
        { url = Url.Builder.absolute [ "api", "upload", "complete" ] []
        , expect = Http.expectWhatever (Complete fileRef)
        , body =
            Http.jsonBody <| Encode.object [ ( "id", Encode.string fileRef.id ) ]
        }
