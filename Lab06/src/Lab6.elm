import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


main = 
 Browser.sandbox { init = init, update = update, view = view }

-- Model 
type alias Model =
    { prop0 : String
    , prop1 : String
    }
    
type Msg = Change0 String | Change1 String

init : Model
init = 
    { prop0 = ""
    , prop1 = ""
    }

    

-- Update
update : Msg -> Model -> Model
update msg model = 
    case msg of
        Change0 newProp0 -> 
            { model | prop0 = newProp0 }
        Change1 newProp1 -> 
            { model | prop1 = newProp1 }

-- View
view : Model -> Html Msg
view model = div [] 
            [ input [placeholder "String1", value model.prop0, onInput Change0 ] [], input [placeholder "String2", value model.prop1, onInput Change1 ] []
                   , div [] [ text ( model.prop0 ++ ":"), text (model.prop1) ] 
            ]
            
    
