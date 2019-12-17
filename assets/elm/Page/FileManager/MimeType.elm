module Page.FileManager.MimeType exposing
    ( ApplicationSubtype(..)
    , AudioSubtype(..)
    , ImageSubtype
    , MimeType
    , TextSubtype(..)
    , Type(..)
    , VideoSubtype(..)
    , decoder
    , encode
    , fromString
    , isImage
    , toRawValue
    , toType
    )

import Json.Decode as Decode
import Json.Encode as Encode


type MimeType
    = MimeType String Type


toType : MimeType -> Type
toType (MimeType _ type_) =
    type_


toRawValue : MimeType -> String
toRawValue (MimeType rawValue _) =
    rawValue


isImage : MimeType -> Bool
isImage mimeType =
    case toType mimeType of
        Image _ ->
            True

        _ ->
            False


type Type
    = Application ApplicationSubtype
    | Audio AudioSubtype
    | Font
    | Image ImageSubtype
    | Model
    | Text TextSubtype
    | Video VideoSubtype
    | Message
    | Multipart


type ApplicationSubtype
    = AbiWord
    | AppleInstaller
    | Archive
    | AmazonKindle
    | BZip
    | BZip2
    | Csh
    | EPub
    | GZip
    | JavaArchive
    | Json
    | JsonLd
    | MsExcel
    | MsExcelXml
    | MsPowerPoint
    | MsPowerPointXml
    | MsWord
    | MsWordXml
    | MsVisio
    | MsFont
    | OctetStream
    | OggApplication
    | OpenDocumentPresentation
    | OpenDocumentSpreadsheet
    | OpenDocumentText
    | Pdf
    | Php
    | Rar
    | Rtf
    | Sh
    | SmallWebFormat
    | Tar
    | XHtml
    | XmlApplication
    | Xul
    | Zip
    | SevenZip
    | OtherApplication


type AudioSubtype
    = Aac
    | WebMAudio
    | Midi
    | MpegAudio
    | OggAudio
    | Opus
    | ThreeGppAudio
    | ThreeGpp2Audio
    | Wave
    | OtherAudio


type ImageSubtype
    = APng
    | Bmp
    | Gif
    | Icon
    | Jpeg
    | Png
    | Svg
    | Tiff
    | WebP
    | OtherImage


type TextSubtype
    = Plain
    | Calendar
    | Css
    | Csv
    | Html
    | JavaScript
    | XmlText
    | OtherText


type VideoSubtype
    = Avi
    | MpegTransportStream
    | MpegVideo
    | OggVideo
    | ThreeGppVideo
    | ThreeGpp2Video
    | WebMVideo
    | OtherVideo


encode : MimeType -> Encode.Value
encode =
    toRawValue >> Encode.string


decoder : Decode.Decoder MimeType
decoder =
    Decode.string
        |> Decode.andThen
            (fromString
                >> Maybe.map Decode.succeed
                >> Maybe.withDefault (Decode.fail "invalid mime")
            )


fromString : String -> Maybe MimeType
fromString string =
    case string |> String.toLower |> String.split "/" of
        [ mimeType, mimeSubtypeAndMaybeParams ] ->
            case String.split ";" mimeSubtypeAndMaybeParams of
                mimeSubtype :: _ ->
                    mimeSubtype
                        |> typeFromString mimeType
                        |> Maybe.map (MimeType string)

                _ ->
                    Nothing

        _ ->
            Nothing


typeFromString : String -> String -> Maybe Type
typeFromString type_ mimeSubtype =
    case type_ of
        "application" ->
            Just <| Application <| applicationSubtypeFromString mimeSubtype

        "audio" ->
            Just <| Audio <| audioSubtypeFromString mimeSubtype

        "font" ->
            Just <| Font

        "image" ->
            Just <| Image <| imageSubtypeFromString mimeSubtype

        "message" ->
            Just <| Message

        "multipart" ->
            Just <| Multipart

        "model" ->
            Just <| Model

        "text" ->
            Just <| Text <| textSubtypeFromString mimeSubtype

        "video" ->
            Just <| Video <| videoSubtypeFromString mimeSubtype

        _ ->
            Nothing


applicationSubtypeFromString : String -> ApplicationSubtype
applicationSubtypeFromString subType =
    case subType of
        "x-abiword" ->
            AbiWord

        "vnd.amazon.ebook" ->
            AmazonKindle

        "octet-stream" ->
            OctetStream

        "x-bzip" ->
            BZip

        "x-bzip2" ->
            BZip2

        "x-csh" ->
            Csh

        "msword" ->
            MsWord

        "vnd.openxmlformats-officedocument.wordprocessingml.document" ->
            MsWordXml

        "vnd.ms-fontobject" ->
            MsFont

        "epub+zip" ->
            EPub

        "gzip" ->
            GZip

        "java-archive" ->
            JavaArchive

        "json" ->
            Json

        "ld+json" ->
            JsonLd

        "vnd.apple.installer+xml" ->
            AppleInstaller

        "vnd.oasis.opendocument.presentation" ->
            OpenDocumentPresentation

        "vnd.oasis.opendocument.spreadsheet" ->
            OpenDocumentSpreadsheet

        "vnd.oasis.opendocument.text" ->
            OpenDocumentText

        "ogg" ->
            OggApplication

        "pdf" ->
            Pdf

        "php" ->
            Php

        "vnd.ms-powerpoint" ->
            MsPowerPoint

        "vnd.openxmlformats-officedocument.presentationml.presentation" ->
            MsPowerPointXml

        "x-rar-compressed" ->
            Rar

        "rtf" ->
            Rtf

        "x-sh" ->
            Sh

        "x-shockwave-flash" ->
            SmallWebFormat

        "vnd.visio" ->
            MsVisio

        "xhtml+xml" ->
            XHtml

        "vnd.ms-excel" ->
            MsExcel

        "vnd.openxmlformats-officedocument.spreadsheetml.sheet" ->
            MsExcelXml

        "xml" ->
            XmlApplication

        "vdn.mozilla.xul+xml" ->
            Xul

        "zip" ->
            Zip

        "x-7z-compressed" ->
            SevenZip

        _ ->
            OtherApplication


audioSubtypeFromString : String -> AudioSubtype
audioSubtypeFromString subType =
    case subType of
        "aac" ->
            Aac

        "midi" ->
            Midi

        "x-midi" ->
            Midi

        "mpeg" ->
            MpegAudio

        "ogg" ->
            OggAudio

        "opus" ->
            Opus

        "wav" ->
            Wave

        "webm" ->
            WebMAudio

        "3gpp" ->
            ThreeGppAudio

        "3gpp2" ->
            ThreeGpp2Audio

        _ ->
            OtherAudio


imageSubtypeFromString : String -> ImageSubtype
imageSubtypeFromString subType =
    case subType of
        "vnd.mozilla.apng" ->
            APng

        "bmp" ->
            Bmp

        "gif" ->
            Gif

        "vdn.microsoft.icon" ->
            Icon

        "jpeg" ->
            Jpeg

        "png" ->
            Png

        "svg+xml" ->
            Svg

        "tiff" ->
            Tiff

        "webp" ->
            WebP

        _ ->
            OtherImage


textSubtypeFromString : String -> TextSubtype
textSubtypeFromString subType =
    case subType of
        "css" ->
            Css

        "csv" ->
            Csv

        "html" ->
            Html

        "calendar" ->
            Calendar

        "javascript" ->
            JavaScript

        "plain" ->
            Plain

        "xml" ->
            XmlText

        _ ->
            OtherText


videoSubtypeFromString : String -> VideoSubtype
videoSubtypeFromString subType =
    case subType of
        "x-msvideo" ->
            Avi

        "video" ->
            MpegVideo

        "ogg" ->
            OggVideo

        "mp2t" ->
            MpegTransportStream

        "webm" ->
            WebMVideo

        "3gpp" ->
            ThreeGppVideo

        "3gpp2" ->
            ThreeGpp2Video

        _ ->
            OtherVideo
