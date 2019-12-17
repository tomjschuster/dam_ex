module Page.FileManager.Metadata exposing (Metadata, decoder)

import Json.Decode as Decode


type alias Metadata =
    { fileId : String
    , title : String
    }


decoder : Decode.Decoder Metadata
decoder =
    Decode.map2
        Metadata
        (Decode.field "fileRefId" Decode.string)
        (Decode.field "title" (Decode.string |> Decode.nullable |> Decode.map (Maybe.withDefault "")))
