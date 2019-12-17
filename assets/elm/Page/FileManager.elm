module Page.FileManager exposing (Model, Msg, init, subscriptions, update, view)

import File exposing (File)
import File.Select as Select
import Html
    exposing
        ( Html
        , button
        , div
        , img
        , input
        , li
        , progress
        , text
        , ul
        )
import Html.Attributes as Attr
import Html.Events as Evt
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Page.FileManager.FileRef as FileRef exposing (FileRef)
import Page.FileManager.FileUpload as FileUpload
import Page.FileManager.Metadata as Metadata exposing (Metadata)
import Page.FileManager.MimeType as MimeType
import Page.FileManager.Uploader as Uploader exposing (Uploader)
import Url.Builder



-- INIT


init : () -> ( Model, Cmd Msg )
init () =
    ( { fileList = [], uploader = Uploader.empty }, getFiles )



-- MODEL


type alias Model =
    { fileList : List ( FileRef, Metadata )
    , uploader : Uploader
    }



-- UPDATE


type Msg
    = FileListLoaded (Result Http.Error (List ( FileRef, Metadata )))
    | SelectFilesClicked
    | FilesSelected File (List File)
    | InputTitle String String
    | UpdateMetadata String
    | FileUpdated (Result Http.Error Metadata)
    | DeleteFile String
    | FileDeleted String (Result Http.Error ())
    | UploaderMsg Uploader.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    model.uploader
        |> Uploader.trackProgress
        |> Sub.map UploaderMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileListLoaded (Ok fileList) ->
            ( { model | fileList = fileList }, Cmd.none )

        FileListLoaded (Err _) ->
            ( model, Cmd.none )

        SelectFilesClicked ->
            ( model, Select.files [] FilesSelected )

        FilesSelected head tail ->
            ( model, Uploader.upload (head :: tail) |> Cmd.map UploaderMsg )

        InputTitle id title ->
            ( { model
                | fileList =
                    List.map
                        (\( fileRef, metadata ) ->
                            if fileRef.id == id then
                                ( fileRef, { metadata | title = title } )

                            else
                                ( fileRef, metadata )
                        )
                        model.fileList
              }
            , Cmd.none
            )

        UpdateMetadata id ->
            model.fileList
                |> List.filter (Tuple.first >> .id >> (==) id)
                |> List.head
                |> Maybe.map
                    (\( _, metadata ) ->
                        ( model
                        , Http.request
                            { url = Url.Builder.absolute [ "api", "files", id, "metadata" ] []
                            , headers = []
                            , method = "PATCH"
                            , expect = Http.expectJson FileUpdated Metadata.decoder
                            , body =
                                Http.jsonBody <|
                                    Encode.object
                                        [ ( "metadata"
                                          , Encode.object [ ( "title", Encode.string metadata.title ) ]
                                          )
                                        ]
                            , timeout = Nothing
                            , tracker = Nothing
                            }
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        FileUpdated (Ok updatedMetadata) ->
            ( { model
                | fileList =
                    List.map
                        (\( fileRef, metadata ) ->
                            if fileRef.id == updatedMetadata.fileId then
                                ( fileRef, updatedMetadata )

                            else
                                ( fileRef, metadata )
                        )
                        model.fileList
              }
            , Cmd.none
            )

        FileUpdated (Err _) ->
            ( model, Cmd.none )

        DeleteFile id ->
            ( model
            , Http.request
                { url = Url.Builder.absolute [ "api", "files", id ] []
                , expect = Http.expectWhatever (FileDeleted id)
                , headers = []
                , body = Http.emptyBody
                , timeout = Nothing
                , tracker = Nothing
                , method = "delete"
                }
            )

        FileDeleted id (Ok ()) ->
            ( { model | fileList = List.filter (Tuple.first >> .id >> (==) id >> not) model.fileList }, Cmd.none )

        FileDeleted _ (Err _) ->
            ( model, Cmd.none )

        UploaderMsg uploaderMsg ->
            let
                ( uploader, uploaderCmd ) =
                    Uploader.update uploaderMsg model.uploader

                maybeNewFileRef =
                    Uploader.newFileRef uploaderMsg
            in
            ( maybeNewFileRef
                |> Maybe.map (\fileRef -> { model | fileList = ( fileRef, Metadata fileRef.id "" ) :: model.fileList, uploader = uploader })
                |> Maybe.withDefault { model | uploader = uploader }
            , Cmd.map UploaderMsg uploaderCmd
            )


getFiles : Cmd Msg
getFiles =
    Http.get
        { url = Url.Builder.absolute [ "api", "files" ] []
        , expect =
            Http.expectJson FileListLoaded
                (Decode.list (Decode.map2 Tuple.pair FileRef.decoder (Decode.field "metadata" Metadata.decoder)))
        }



-- VIEW


view : Model -> Html Msg
view { fileList, uploader } =
    div []
        [ ul [] (List.map viewFileRef fileList)
        , button [ Evt.onClick SelectFilesClicked ] [ text "Select Files" ]
        , viewUploader uploader
        ]


viewFileRef : ( FileRef, Metadata ) -> Html Msg
viewFileRef ( fileRef, metadata ) =
    li []
        [ input
            [ Evt.onInput (InputTitle metadata.fileId)
            , Attr.value metadata.title
            ]
            []
        , text <|
            "filename: "
                ++ fileRef.filename
                ++ " mime: "
                ++ MimeType.toRawValue fileRef.mimeType
                ++ " size: "
                ++ String.fromInt fileRef.size
        , button [ Evt.onClick (UpdateMetadata fileRef.id) ] [ text "Save" ]
        , button [ Evt.onClick (DeleteFile fileRef.id) ] [ text "X" ]
        ]


viewUploader : Uploader -> Html Msg
viewUploader uploader =
    ul [] (List.map (\( file, maybeFileUrl, state ) -> li [] <| viewUploadingFile file maybeFileUrl state) <| Uploader.toList uploader)


viewUploadingFile : File -> Maybe String -> FileUpload.State -> List (Html Msg)
viewUploadingFile file maybeFileUrl state =
    case state of
        FileUpload.Pending ->
            [ text <| "name: " ++ File.name file ++ " mime: " ++ File.mime file ++ " size: " ++ String.fromInt (File.size file)
            , case maybeFileUrl of
                Just url ->
                    img [ Attr.src url, Attr.width 100, Attr.height 100 ] []

                Nothing ->
                    text ""
            ]

        FileUpload.Uploading _ bytesUploaded ->
            [ text <| File.name file ++ ": " ++ String.fromInt bytesUploaded ++ "/" ++ String.fromInt (File.size file) ++ " bytes uploaded"
            , progress [ Attr.style "transition" "width 5s ease", Attr.max (String.fromInt (File.size file)), Attr.value (String.fromInt bytesUploaded) ] []
            , case maybeFileUrl of
                Just url ->
                    img [ Attr.src url, Attr.width 100, Attr.height 100 ] []

                Nothing ->
                    text ""
            ]

        FileUpload.Success ->
            [ text <| File.name file ++ ": Success"
            , case maybeFileUrl of
                Just url ->
                    img [ Attr.src url, Attr.width 100, Attr.height 100 ] []

                Nothing ->
                    text ""
            ]

        FileUpload.Failure ->
            [ text <| File.name file ++ ": Error"
            , case maybeFileUrl of
                Just url ->
                    img [ Attr.src url, Attr.width 100, Attr.height 100 ] []

                Nothing ->
                    text ""
            ]
