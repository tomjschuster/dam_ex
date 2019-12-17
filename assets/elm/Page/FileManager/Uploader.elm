module Page.FileManager.Uploader exposing
    ( Msg
    , Uploader
    , empty
    , newFileRef
    , toList
    , trackProgress
    , update
    , upload
    )

import File exposing (File)
import Page.FileManager.FileRef exposing (FileRef)
import Page.FileManager.FileUpload as FileUpload
import Page.FileManager.MimeType as MimeType
import Task exposing (Task)


type Uploader
    = Uploader (List ( File, Maybe String, FileUpload.State ))


empty : Uploader
empty =
    Uploader []


toList : Uploader -> List ( File, Maybe String, FileUpload.State )
toList (Uploader fileList) =
    fileList


addFiles : List ( File, Maybe String, FileUpload.State ) -> Uploader -> Uploader
addFiles addedFileList (Uploader fileList) =
    Uploader (fileList ++ addedFileList)


upload : List File -> Cmd Msg
upload =
    List.map (\file -> file |> maybeGetFileUrl |> Task.map (\maybeFileUrl -> ( file, maybeFileUrl )))
        >> Task.sequence
        >> Task.perform FileUrlsReceived


maybeGetFileUrl : File -> Task Never (Maybe String)
maybeGetFileUrl file =
    if file |> File.mime |> MimeType.fromString |> Maybe.map MimeType.isImage |> Maybe.withDefault False then
        file |> File.toUrl |> Task.map Just |> Task.onError (always <| Task.succeed Nothing)

    else
        Task.succeed Nothing


startUpload : Int -> File -> Cmd Msg
startUpload index file =
    FileUpload.start file |> Cmd.map (FileUploadMsg index)


setState : FileUpload.State -> Int -> Uploader -> Uploader
setState uploadState index =
    toList
        >> List.indexedMap
            (\currIndex ( file, maybeFileUrl, status ) ->
                if currIndex == index then
                    ( file, maybeFileUrl, uploadState )

                else
                    ( file, maybeFileUrl, status )
            )
        >> Uploader


type Msg
    = FileUrlsReceived (List ( File, Maybe String ))
    | FileUploadMsg Int FileUpload.Msg


trackProgress : Uploader -> Sub Msg
trackProgress (Uploader fileList) =
    fileList
        |> List.indexedMap
            (\index ( _, _, status ) ->
                case status of
                    FileUpload.Uploading id _ ->
                        FileUpload.trackProgress id
                            |> Sub.map (FileUploadMsg index)

                    _ ->
                        Sub.none
            )
        |> Sub.batch


update : Msg -> Uploader -> ( Uploader, Cmd Msg )
update msg uploader =
    case msg of
        FileUrlsReceived filesWithUrls ->
            let
                nextIndex =
                    uploader |> toList |> List.length

                addedFileList =
                    List.map (\( file, maybeFileUrl ) -> ( file, maybeFileUrl, FileUpload.Pending )) filesWithUrls
            in
            ( addFiles addedFileList uploader
            , addedFileList
                |> List.indexedMap (\index ( file, _, _ ) -> startUpload (index + nextIndex) file)
                |> Cmd.batch
            )

        FileUploadMsg index subMsg ->
            ( subMsg
                |> FileUpload.state
                |> Maybe.map (\status -> setState status index uploader)
                |> Maybe.withDefault uploader
            , subMsg
                |> FileUpload.continue
                |> Cmd.map (FileUploadMsg index)
            )


newFileRef : Msg -> Maybe FileRef
newFileRef msg =
    case msg of
        FileUploadMsg _ subMsg ->
            FileUpload.newFileRef subMsg

        _ ->
            Nothing
