module Language exposing (LanguageGroup, LanguageSetup(..), Model, Msg, init, languageGenerator, update, viewSettings)

import GeneratorParser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Encode as Enc
import List
import List.Extra
import Loading
import Markov
import Parser exposing (Parser)
import ParserError
import Random
import Random.Extra



-- INTERFACE


languageGenerator : Model -> Random.Generator String
languageGenerator model =
    case model.activeLanguage.generator of
        StaticGenerator generator ->
            generator

        FromCustomExamples ->
            Markov.generatorFromExamples 1 <| String.words <| model.customExamples

        FromCustomParts ->
            List.take model.customPartCount model.customPartsBuffers
                |> List.map String.words
                |> componentwiseGenerator
                    (if model.separateCustomParts then
                        " "

                     else
                        ""
                    )


componentwiseGenerator : String -> List (List String) -> Random.Generator String
componentwiseGenerator separator partOptions =
    Random.Extra.traverse Random.Extra.sample partOptions
        |> Random.map (List.filterMap identity)
        |> Random.map (String.join separator)



-- MODEL


type alias Model =
    { languageGroups : List LanguageGroup
    , activeLanguageIndex : LanguageIndex
    , activeLanguage : Language
    , customExamples : String -- only visible when in user Markov mode
    , customPartsBuffers : List String -- only visible when in user parts mode
    , customPartCount : Int -- number of buffers visible at once
    , separateCustomParts : Bool -- whether to separate custom parts with spaces
    }


init : List LanguageGroup -> ( Model, Cmd Msg )
init languageGroups =
    let
        allLanguageGroups =
            languageGroups ++ [ configurableLanguageGroup ]

        defaultModel =
            { languageGroups = []
            , activeLanguageIndex = ( -1, -1 )
            , activeLanguage = emptyLanguage
            , customExamples = ""
            , customPartsBuffers = List.repeat maxCustomParts ""
            , customPartCount = 2
            , separateCustomParts = False
            }

        firstIndexAndLanguageSpec : Maybe ( ( Int, Int ), LanguageSpec )
        firstIndexAndLanguageSpec =
            List.indexedMap
                (\groupIndex languageGroup ->
                    Maybe.map
                        (Tuple.pair ( groupIndex, 0 ))
                        (List.head languageGroup.languages)
                )
                allLanguageGroups
                |> List.filterMap identity
                |> List.head
    in
    case firstIndexAndLanguageSpec of
        Just ( firstLanguageIndex, firstLanguageSpec ) ->
            let
                ( initialLanguage, loadCmd ) =
                    loadLanguage firstLanguageIndex firstLanguageSpec
            in
            ( { defaultModel
                | languageGroups = allLanguageGroups
                , activeLanguageIndex = firstLanguageIndex
                , activeLanguage = initialLanguage
              }
            , loadCmd
            )

        Nothing ->
            ( defaultModel
            , Cmd.none
            )


type alias LanguageMetadata =
    { name : String
    , description : String
    }


type alias Language =
    { metadata : LanguageMetadata
    , generator : LanguageGenerator
    }


type LanguageGenerator
    = StaticGenerator (Random.Generator String)
    | FromCustomExamples
    | FromCustomParts


emptyLanguage : Language
emptyLanguage =
    { metadata =
        { name = "Empty Language"
        , description = "An empty language"
        }
    , generator = StaticGenerator <| Random.constant ""
    }


loadingLanguage : Language
loadingLanguage =
    { metadata =
        { name = "Loading..."
        , description = "Loading..."
        }
    , generator = StaticGenerator <| Random.constant "Loading..."
    }


maxCustomParts =
    4



-- UPDATE


type Msg
    = SelectLanguage LanguageIndex LanguageSpec
    | LoadedLanguage LanguageIndex Language
    | SetExamples String -- Custom Markov only
    | SetPartsBuffer Int String -- Custom Parts only
    | SetPartCount Int -- Custom Parts only
    | SetSeparateParts Bool -- Custom Parts only


type alias LanguageIndex =
    ( Int, Int )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ customPartsBuffers } as model) =
    case msg of
        SelectLanguage index languageSpec ->
            let
                ( language, loadCmd ) =
                    loadLanguage index languageSpec
            in
            ( { model
                | activeLanguageIndex = index
                , activeLanguage = language
              }
            , loadCmd
            )

        LoadedLanguage index language ->
            ( { model
                | activeLanguageIndex = index
                , activeLanguage = language
              }
            , Cmd.none
            )

        SetExamples examples ->
            ( { model | customExamples = examples }
            , Cmd.none
            )

        SetPartsBuffer index bufferContent ->
            ( { model
                | customPartsBuffers =
                    List.Extra.setAt index bufferContent customPartsBuffers
              }
            , Cmd.none
            )

        SetPartCount numVisible ->
            ( { model | customPartCount = numVisible }
            , Cmd.none
            )

        SetSeparateParts separateParts ->
            ( { model | separateCustomParts = separateParts }
            , Cmd.none
            )



-- LANGUAGE MANIFEST


type alias LanguageGroup =
    { name : String
    , languages : List LanguageSpec
    }


type alias LanguageSpec =
    { metadata : LanguageMetadata
    , setupSpec : LanguageSetup
    }


type LanguageSetup
    = UrlLanguageSetup String
    | CustomMarkovLanguageSetup
    | CustomPartsLanguageSetup
    | DummyLanguageSetup


emptyLanguageSpec : LanguageSpec
emptyLanguageSpec =
    { metadata = emptyLanguage.metadata
    , setupSpec = DummyLanguageSetup
    }


configurableLanguageGroup : LanguageGroup
configurableLanguageGroup =
    { name = "Configurable"
    , languages =
        [ customMarkovLanguageSpec
        , customPartsLanguageSpec
        ]
    }


customMarkovLanguageSpec : LanguageSpec
customMarkovLanguageSpec =
    { metadata =
        { name = "Custom Markov Input"
        , description = "Customizable Markov name generator"
        }
    , setupSpec = CustomMarkovLanguageSetup
    }


customPartsLanguageSpec : LanguageSpec
customPartsLanguageSpec =
    { metadata =
        { name = "Custom Componentwise"
        , description = "Custom names built from parts"
        }
    , setupSpec = CustomPartsLanguageSetup
    }


loadLanguage : LanguageIndex -> LanguageSpec -> ( Language, Cmd Msg )
loadLanguage index { metadata, setupSpec } =
    case setupSpec of
        UrlLanguageSetup url ->
            ( loadingLanguage
            , loadGeneratorFromUrl url GeneratorParser.language
                |> Cmd.map
                    (\generator ->
                        LoadedLanguage index
                            { metadata = metadata
                            , generator = generator
                            }
                    )
            )

        CustomMarkovLanguageSetup ->
            ( { metadata = metadata
              , generator = FromCustomExamples
              }
            , Cmd.none
            )

        CustomPartsLanguageSetup ->
            ( { metadata = metadata
              , generator = FromCustomParts
              }
            , Cmd.none
            )

        DummyLanguageSetup ->
            ( { metadata = metadata
              , generator = emptyLanguage.generator
              }
            , Cmd.none
            )


loadGeneratorFromUrl : String -> Parser (Random.Generator String) -> Cmd LanguageGenerator
loadGeneratorFromUrl url parser =
    let
        handleResponse body =
            case Parser.run parser body of
                Ok generator ->
                    StaticGenerator generator

                Err deadEnds ->
                    (StaticGenerator << Random.constant) <|
                        String.concat
                            [ "Error parsing "
                            , url
                            , ": "
                            , ParserError.deadEndsToString deadEnds
                            ]
    in
    Loading.loadFromUrl
        url
        { handleResponse = handleResponse
        , handleErrorMessage = StaticGenerator << Random.constant
        }



-- VIEW


viewSettings : Model -> Html Msg
viewSettings { languageGroups, activeLanguageIndex, activeLanguage, customExamples, customPartsBuffers, customPartCount, separateCustomParts } =
    Html.div [ Attr.class "language-settings" ] <|
        case activeLanguage.generator of
            StaticGenerator _ ->
                [ languageSelector languageGroups activeLanguageIndex activeLanguage ]

            FromCustomExamples ->
                [ languageSelector languageGroups activeLanguageIndex activeLanguage
                , customExamplesArea customExamples
                ]

            FromCustomParts ->
                languageSelector languageGroups activeLanguageIndex activeLanguage
                    :: partCountSelector customPartCount
                    :: bufferSeparationSelector separateCustomParts
                    :: List.indexedMap
                        customPartBuffer
                        (List.take customPartCount customPartsBuffers)


customExamplesArea : String -> Html Msg
customExamplesArea customExamples =
    Html.textarea
        [ Attr.class "examples-area"
        , Attr.value customExamples
        , Events.onInput SetExamples
        ]
        []


customPartBuffer : Int -> String -> Html Msg
customPartBuffer bufferIndex bufferContent =
    Html.textarea
        [ Attr.class "examples-area"
        , Attr.value bufferContent
        , Events.onInput <| SetPartsBuffer bufferIndex
        ]
        []


partCountSelector : Int -> Html Msg
partCountSelector customPartCount =
    Html.select
        [ Attr.class "component-count-selector"
        , Events.onInput
            (\countString ->
                let
                    partCount =
                        Maybe.withDefault maxCustomParts <|
                            String.toInt countString
                in
                min maxCustomParts (max 1 partCount)
                    |> SetPartCount
            )
        ]
    <|
        List.Extra.initialize
            maxCustomParts
            (\index ->
                let
                    countString =
                        String.fromInt <| index + 1
                in
                Html.option
                    [ Attr.value countString
                    , Attr.selected <| customPartCount == index + 1
                    ]
                    [ Html.text <| countString ++ " components" ]
            )


bufferSeparationSelector : Bool -> Html Msg
bufferSeparationSelector separateCustomParts =
    Html.label
        [ Attr.class "component-separation-selector" ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked separateCustomParts
            , Events.onCheck SetSeparateParts
            ]
            []
        , Html.text "Space Separated"
        ]


encodeLanguageIndex : ( Int, Int ) -> String
encodeLanguageIndex ( groupIndex, itemIndex ) =
    String.fromInt groupIndex ++ " " ++ String.fromInt itemIndex


decodeLanguageIndex : String -> ( Int, Int )
decodeLanguageIndex indexString =
    case String.split " " indexString of
        groupIndexString :: itemIndexString :: [] ->
            ( Maybe.withDefault 0 <| String.toInt groupIndexString
            , Maybe.withDefault 0 <| String.toInt itemIndexString
            )

        _ ->
            ( 0, 0 )


languageSelector : List LanguageGroup -> LanguageIndex -> Language -> Html Msg
languageSelector languageGroups activeLanguageIndex activeLanguage =
    Html.select
        [ Events.onInput
            (\indexString ->
                let
                    ( groupIndex, itemIndex ) =
                        decodeLanguageIndex indexString
                in
                SelectLanguage ( groupIndex, itemIndex ) <|
                    case List.Extra.getAt groupIndex languageGroups of
                        Nothing ->
                            emptyLanguageSpec

                        Just group ->
                            case List.Extra.getAt itemIndex group.languages of
                                Nothing ->
                                    emptyLanguageSpec

                                Just spec ->
                                    spec
            )
        , Attr.class "language-selector"
        , Attr.title activeLanguage.metadata.description
        ]
    <|
        List.indexedMap
            (languageOptionGroup activeLanguageIndex)
            languageGroups


languageOptionGroup : LanguageIndex -> Int -> LanguageGroup -> Html Msg
languageOptionGroup activeLanguageIndex groupIndex languageGroup =
    Html.optgroup
        [ Attr.property "label" <| Enc.string languageGroup.name ]
    <|
        List.indexedMap
            (languageOption activeLanguageIndex groupIndex)
            languageGroup.languages


languageOption : LanguageIndex -> Int -> Int -> LanguageSpec -> Html Msg
languageOption activeLanguageIndex groupIndex itemIndex languageSpec =
    Html.option
        [ Attr.value <| encodeLanguageIndex ( groupIndex, itemIndex )
        , Attr.selected <| activeLanguageIndex == ( groupIndex, itemIndex )
        ]
        [ Html.text languageSpec.metadata.name ]
