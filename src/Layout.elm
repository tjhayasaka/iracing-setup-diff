module Layout exposing (view)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Html exposing (node)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    column
        [ height fill
        , width fill
        , Background.color (rgb255 0 0 0)
        , Font.color <| rgb255 255 255 255
        , Font.size 14
        ]
        [ html (Html.node "style" [] [ Html.text """
div[role='button'] { font-size: 13px; background: #dddddd; color: #000; border: solid 1px #a9a9a9; padding: 2px; }
    """ ])
        , page
        ]
