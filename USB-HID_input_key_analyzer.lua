KEY_CODE = {
    {"", ""},
    {"", ""},
    {"", ""},
    {"a", "A"},
    {"b", "B"},
    {"c", "C"},
    {"d", "D"},
    {"e", "E"},
    {"f", "F"},
    {"g", "G"},
    {"h", "h"},
    {"i", "I"},
    {"j", "J"},
    {"k", "K"},
    {"l", "L"},
    {"m", "M"},
    {"n", "N"},
    {"o", "O"},
    {"p", "P"},
    {"q", "Q"},
    {"r", "R"},
    {"s", "S"},
    {"t", "T"},
    {"u", "U"},
    {"v", "V"},
    {"w", "W"},
    {"x", "X"},
    {"y", "Y"},
    {"z", "Z"},
    {"1", "!"},
    {"2", "@"},
    {"3", "#"},
    {"4", "$"},
    {"5", "%"},
    {"6", "^"},
    {"7", "&"},
    {"8", "*"},
    {"9", "("},
    {"0", ")"},
    {"[Enter]", "[Enter]"},
    {"[Escape]", "[Escape]"},
    {"[Back Space]", "[Back Space]"},
    {"[Tab]", "[Tab]"},
    {" ", " "},
    {"-", "_"},
    {"=", "+"},
    {"[", "{"},
    {"]", "}"},
    {"\\", "|"},
    {"", ""},
    {";", ":"},
    {"'", "\""},
    {"`", "~"},
    {",", "<"},
    {".", ">"},
    {"/", "?"},
    {"[Caps Lock]", "[Caps Lock]"},
    {"[F1]", "[F1]"},
    {"[F2]", "[F2]"},
    {"[F3]", "[F3]"},
    {"[F4]", "[F4]"},
    {"[F5]", "[F5]"},
    {"[F6]", "[F6]"},
    {"[F7]", "[F7]"},
    {"[F8]", "[F8]"},
    {"[F9]", "[F9]"},
    {"[F10]", "[F10]"},
    {"[F11]", "[F11]"},
    {"[F12]", "[F12]"},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"", ""},
    {"[→]", "[→]"},
    {"[←]", "[←]"},
    {"[↓]", "[↓]"},
    {"[↑]", "[↑]"}
}

MODIFIER = {
    "Left-Ctrl",
    "Left-Shift",
    "Left-Alt",
    "Left-GUI",
    "Right-Ctrl",
    "Right-Shift",
    "Right-Alt",
    "Right-GUI"
}

function analysis()
    local win = TextWindow.new("Analysis of typed key")
    local tap = Listener.new("usb", nil)
    local pressed_key = ""

    local function remove_tap()
        tap:remove()
    end

    -- TextWindowを閉じるときtapを消す
    win:set_atclose(remove_tap)

    -- tapのフィルタに一致するたびに実行される
    function tap.packet(pinfo, tvb, tapinfo)
        -- URB transfer type: URB_INTERRUPT (0x01)
        if tvb:len() == 35 and tonumber("0x" .. tostring(tvb:bytes(22, 1))) == 0x01 then
            if 0x04 <= tonumber("0x" .. tostring(tvb:bytes(29, 1))) and tonumber("0x" .. tostring(tvb:bytes(29, 1))) <= 0x52 then
                if tonumber("0x" .. tostring(tvb:bytes(27, 1))) == 0x00 then
                    pressed_key = pressed_key .. KEY_CODE[tonumber("0x" .. tostring(tvb:bytes(29, 1)))][1]
                elseif tonumber("0x" .. tostring(tvb:bytes(27, 1))) == 0x02 then
                    pressed_key = pressed_key .. KEY_CODE[tonumber("0x" .. tostring(tvb:bytes(29, 1)))][2]
                else
                    pressed_key = pressed_key .. ""
                end
            end
        end
    end

    -- packet()ですべてのパケットを読み込み終わった後に実行される
    function tap.draw()
        win:clear()
        win:append(pressed_key)
    end

    -- draw()実行後に実行される
    function tap.reset()
        pressed_key = ""
    end

    -- すべてのパケットを再スキャンしてtapを実行
    retap_packets()
end

-- メニュー項目の[Tools]に[Analysis of typed key]を追加
register_menu("Analysis of typed key", analysis, MENU_TOOLS_UNSORTED)
