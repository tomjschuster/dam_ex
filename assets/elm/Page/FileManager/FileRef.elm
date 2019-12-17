module Page.FileManager.FileRef exposing (FileRef, decoder)

import Json.Decode as Decode
import Page.FileManager.MimeType as MimeType exposing (MimeType)


type alias FileRef =
    { id : String
    , filename : String
    , mimeType : MimeType
    , size : Int
    }


decoder : Decode.Decoder FileRef
decoder =
    Decode.map4
        FileRef
        (Decode.field "id" Decode.string)
        (Decode.field "filename" Decode.string)
        (Decode.field "mimeType" MimeType.decoder)
        (Decode.field "fileSize" Decode.int)
