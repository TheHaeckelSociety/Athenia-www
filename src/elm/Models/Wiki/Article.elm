-- Module for the article model
module Models.Wiki.Article exposing(..)

import Models.Page as Page
import Models.User.User as User
import Models.Wiki.Iteration as Iteration
import Json.Decode as JsonDecode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Model =
    { id : Int
    , title : String
    , content : String
    , last_iteration_content : String
    , created_by : Maybe User.Model
    , iterations : List Iteration.Model
    }


type alias Page
    = Page.Model Model


-- Used for when creating a article
type alias CreateModel =
    { title : String
    , created_by : User.Model
    }


initCreateModel : User.Model -> CreateModel
initCreateModel user =
    { title = ""
    , created_by = user
    }


-- Converts a user model into a JSON string
toCreateJson : CreateModel -> Encode.Value
toCreateJson model =
    Encode.object
        <| List.concat
            <| [
                [ ("title", Encode.string model.title) ]
                , case model.created_by.id of
                    Just id ->
                        [ ("created_by_id", Encode.int id) ]
                    Nothing ->
                        []
            ]

-- Decodes a article model retrieved through the API
modelDecoder : Decoder Model
modelDecoder =
    JsonDecode.succeed Model
        |> required "id" int
        |> required "title" string
        |> optional "content" string ""
        |> optional "last_iteration_content" string ""
        |> optional "created_by" (maybe User.modelDecoder) Nothing
        |> optional "iterations" Iteration.listDecoder []


listDecoder : Decoder (List Model)
listDecoder =
    JsonDecode.list modelDecoder


pageDecoder : Decoder Page
pageDecoder =
    Page.modelDecoder listDecoder
