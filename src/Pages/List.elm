module Pages.List exposing (page)

import Gen.Params.List exposing (Params)
import Gen.Route
import Html
import Html.Attributes
import Page exposing (Page)
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page
page _ _ =
    Page.static
        { view = view
        }


view : View msg
view =
    { title = "A list"
    , body =
        [ Html.a [ Html.Attributes.href <| Gen.Route.toHref Gen.Route.Form ] [ Html.text "GO TO FORM" ]
        , Html.ul []
            [ Html.li [] [ Html.text "A" ]
            , Html.li [] [ Html.text "B" ]
            , Html.li [] [ Html.text "C" ]
            ]
        ]
    }
