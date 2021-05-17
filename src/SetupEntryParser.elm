module SetupEntryParser exposing (parseSetupEntries)

import Dict exposing (Dict)
import Html.Parser
import Result exposing (andThen)
import Setup


trimColon : String -> String
trimColon str =
    if String.endsWith ":" str then
        String.dropRight 1 str

    else
        str


splitToSections_ rowHtml ctx =
    case rowHtml of
        Html.Parser.Element "h2" [] [ Html.Parser.Element "u" [] [ Html.Parser.Text sectionName_ ] ] ->
            -- new section found
            let
                sectionName =
                    String.trim sectionName_ |> trimColon

                sectionIndex =
                    ctx.currentSectionIndex + 1

                sectionKey =
                    ( sectionIndex, sectionName )
            in
            { ctx | currentSectionIndex = sectionIndex, currentSectionKey = sectionKey, currentSectionName = sectionName }

        el ->
            let
                sectionKey =
                    ctx.currentSectionKey

                oldEntryElements =
                    Dict.get sectionKey ctx.result |> Maybe.withDefault []

                newEntryElements =
                    oldEntryElements ++ [ el ]
            in
            { ctx | result = Dict.insert sectionKey newEntryElements ctx.result }


splitToSections : List Html.Parser.Node -> Dict ( number, String ) (List Html.Parser.Node)
splitToSections entriesHtml =
    let
        v =
            List.foldl splitToSections_ { result = Dict.empty, currentSectionIndex = -1, currentSectionKey = ( -1, "" ), currentSectionName = "" } entriesHtml
    in
    v.result


parseSection sectionKey elements =
    case elements of
        (Html.Parser.Text entryName_) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue0_ ]) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue1_ ]) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue2_ ]) :: (Html.Parser.Element "br" [] []) :: restElements ->
            let
                entryName =
                    String.trim entryName_ |> trimColon

                entryValue0 =
                    String.trim entryValue0_

                entryValue1 =
                    String.trim entryValue1_

                entryValue2 =
                    String.trim entryValue2_
            in
            { name = entryName, value = entryValue0 ++ " " ++ entryValue1 ++ " " ++ entryValue2 } :: parseSection sectionKey restElements

        (Html.Parser.Text entryName_) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue0_ ]) :: (Html.Parser.Element "br" [] []) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue1_ ]) :: (Html.Parser.Element "br" [] []) :: restElements ->
            let
                entryName =
                    String.trim entryName_ |> trimColon

                entryValue0 =
                    String.trim entryValue0_

                entryValue1 =
                    String.trim entryValue1_
            in
            { name = entryName, value = entryValue0 ++ " " ++ entryValue1 } :: parseSection sectionKey restElements

        (Html.Parser.Text entryName_) :: (Html.Parser.Element "u" [] [ Html.Parser.Text entryValue0_ ]) :: (Html.Parser.Element "br" [] []) :: restElements ->
            let
                entryName =
                    String.trim entryName_ |> trimColon

                entryValue0 =
                    String.trim entryValue0_
            in
            { name = entryName, value = entryValue0 } :: parseSection sectionKey restElements

        (Html.Parser.Text entryValue0_) :: [] ->
            let
                entryName =
                    "Notes"

                entryValue0 =
                    String.trim entryValue0_
            in
            [ { name = entryName, value = entryValue0 } ]

        _ ->
            []


type alias SectionKey =
    ( Float, String )


type alias Sections =
    Dict SectionKey (List { name : String, value : String })


preprocess : List Html.Parser.Node -> Result String Sections
preprocess entriesHtml =
    let
        v0 =
            splitToSections entriesHtml

        v1 =
            Dict.map parseSection v0
    in
    Ok v1


toString : SectionKey -> String
toString sectionKey =
    let
        ( n0_, n1 ) =
            sectionKey

        n0 =
            String.fromFloat n0_
    in
    "(" ++ n0 ++ ", " ++ n1 ++ ")"


renameSection : SectionKey -> SectionKey -> Sections -> Result String Sections
renameSection sectionKey0 sectionKey1 a =
    case Dict.get sectionKey0 a of
        Nothing ->
            Err ("failed to parse exported setup: " ++ toString sectionKey0 ++ ": section order or name mismatch.")

        Just sectionContent ->
            Ok (a |> Dict.remove sectionKey0 |> Dict.insert sectionKey1 sectionContent)


removeEntry : SectionKey -> String -> Sections -> Result String Sections
removeEntry sectionKey entryName a =
    case Dict.get sectionKey a of
        Nothing ->
            Ok a

        Just sectionContent ->
            let
                newSectionContent =
                    List.filter (\entry -> entry.name /= entryName) sectionContent
            in
            Ok (Dict.insert sectionKey newSectionContent a)


markComputed : String -> List Setup.SetupEntry -> Result String (List Setup.SetupEntry)
markComputed entryName entries =
    let
        result =
            List.map
                (\entry ->
                    if entry.name /= entryName then
                        entry

                    else
                        { entry | isComputed = True }
                )
                entries
    in
    Ok result


createSection sectionName a =
    Ok a


moveEntry sectionName0 sectionName1 entryName a =
    Ok a


flatten : Sections -> Result String (List Setup.SetupEntry)
flatten a =
    let
        renameEntry sectionKey entry =
            let
                ( _, sectionName ) =
                    sectionKey

                newName =
                    sectionName ++ " / " ++ entry.name
            in
            { name = newName, value = entry.value, isComputed = False }

        -- isComputed will be reset in parseSetupEntries_.
        processSection b sectionKey =
            Dict.get sectionKey b |> Maybe.withDefault [] |> List.map (renameEntry sectionKey)
    in
    Ok (Dict.keys a |> List.sort |> List.concatMap (processSection a))


parseSetupEntries_ : List Html.Parser.Node -> Result String (List Setup.SetupEntry)
parseSetupEntries_ entriesHtml =
    preprocess entriesHtml
        |> andThen (renameSection ( 0, "LEFT FRONT" ) ( 0, "TIRES / LEFT FRONT" ))
        |> andThen (renameSection ( 1, "LEFT REAR" ) ( 2, "TIRES / LEFT REAR" ))
        |> andThen (renameSection ( 2, "RIGHT FRONT" ) ( 1, "TIRES / RIGHT FRONT" ))
        |> andThen (renameSection ( 3, "RIGHT REAR" ) ( 3, "TIRES / RIGHT REAR" ))
        |> andThen (renameSection ( 4, "FRONT" ) ( 4, "CHASSIS / FRONT" ))
        |> andThen (renameSection ( 5, "LEFT FRONT" ) ( 5, "CHASSIS / LEFT FRONT" ))
        |> andThen (renameSection ( 6, "LEFT REAR" ) ( 7, "CHASSIS / LEFT REAR" ))
        |> andThen (renameSection ( 7, "RIGHT FRONT" ) ( 6, "CHASSIS / RIGHT FRONT" ))
        |> andThen (renameSection ( 8, "RIGHT REAR" ) ( 8, "CHASSIS / RIGHT REAR" ))
        |> andThen (renameSection ( 9, "REAR" ) ( 9, "REAR" ))
        |> andThen (removeEntry ( 0, "TIRES / LEFT FRONT" ) "Last hot pressure")
        |> andThen (removeEntry ( 0, "TIRES / LEFT FRONT" ) "Last temps O M I")
        |> andThen (removeEntry ( 0, "TIRES / LEFT FRONT" ) "Tread remaining")
        |> andThen (removeEntry ( 1, "TIRES / RIGHT FRONT" ) "Last hot pressure")
        |> andThen (removeEntry ( 1, "TIRES / RIGHT FRONT" ) "Last temps I M O")
        |> andThen (removeEntry ( 1, "TIRES / RIGHT FRONT" ) "Tread remaining")
        |> andThen (removeEntry ( 2, "TIRES / LEFT REAR" ) "Last hot pressure")
        |> andThen (removeEntry ( 2, "TIRES / LEFT REAR" ) "Last temps O M I")
        |> andThen (removeEntry ( 2, "TIRES / LEFT REAR" ) "Tread remaining")
        |> andThen (removeEntry ( 3, "TIRES / RIGHT REAR" ) "Last hot pressure")
        |> andThen (removeEntry ( 3, "TIRES / RIGHT REAR" ) "Last temps I M O")
        |> andThen (removeEntry ( 3, "TIRES / RIGHT REAR" ) "Tread remaining")
        -- |> andThen (removeEntry (4, "CHASSIS / FRONT") "Nose weight")
        -- |> andThen (removeEntry (4, "CHASSIS / FRONT") "Cross weight")
        -- |> andThen (removeEntry (4, "CHASSIS / FRONT") "Left side weight")
        -- |> andThen (removeEntry (5, "CHASSIS / LEFT FRONT") "Corner weight")
        -- |> andThen (removeEntry (5, "CHASSIS / LEFT FRONT") "Tube height")
        -- |> andThen (removeEntry (6, "CHASSIS / RIGHT FRONT") "Corner weight")
        -- |> andThen (removeEntry (6, "CHASSIS / RIGHT FRONT") "Tube height")
        -- |> andThen (removeEntry (7, "CHASSIS / LEFT REAR") "Corner weight")
        -- |> andThen (removeEntry (7, "CHASSIS / LEFT REAR") "Tube height")
        -- |> andThen (removeEntry (8, "CHASSIS / RIGHT REAR") "Corner weight")
        -- |> andThen (removeEntry (8, "CHASSIS / RIGHT REAR") "Tube height")
        |> andThen (createSection ( 1.5, "TIRES / FRONT" ))
        |> andThen (createSection ( 3.5, "TIRES / REAR" ))
        |> andThen (moveEntry ( 1, "TIRES / RIGHT FRONT" ) ( 1.5, "TIRES / FRONT" ) "Stagger")
        |> andThen (moveEntry ( 3, "TIRES / RIGHT REAR" ) ( 3.5, "TIRES / REAR" ) "Stagger")
        |> andThen flatten
        |> andThen (markComputed "CHASSIS / FRONT / Nose weight")
        |> andThen (markComputed "CHASSIS / FRONT / Cross weight")
        |> andThen (markComputed "CHASSIS / FRONT / Left side weight")
        |> andThen (markComputed "CHASSIS / LEFT FRONT / Corner weight")
        |> andThen (markComputed "CHASSIS / LEFT FRONT / Tube height")
        |> andThen (markComputed "CHASSIS / RIGHT FRONT / Corner weight")
        |> andThen (markComputed "CHASSIS / RIGHT FRONT / Tube height")
        |> andThen (markComputed "CHASSIS / LEFT REAR / Corner weight")
        |> andThen (markComputed "CHASSIS / LEFT REAR / Tube height")
        |> andThen (markComputed "CHASSIS / RIGHT REAR / Corner weight")
        |> andThen (markComputed "CHASSIS / RIGHT REAR / Tube height")


parseSetupEntries : List Html.Parser.Node -> Result String (List Setup.SetupEntry)
parseSetupEntries bodyChildren =
    case bodyChildren of
        _ :: (Html.Parser.Element "h2" _ _) :: (Html.Parser.Element "br" _ _) :: (Html.Parser.Text _) :: (Html.Parser.Element "br" _ _) :: (Html.Parser.Text _) :: (Html.Parser.Element "br" _ _) :: (Html.Parser.Text _) :: entriesHtml ->
            parseSetupEntries_ entriesHtml

        _ ->
            Err "failed to find setup entries at expected location"
