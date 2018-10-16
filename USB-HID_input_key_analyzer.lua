KEY_CODE = {}
KEY_CODE[0x04] = {"a", "A"}
KEY_CODE[0x05] = {"b", "B"}
KEY_CODE[0x06] = {"c", "C"}
KEY_CODE[0x07] = {"d", "D"}
KEY_CODE[0x08] = {"e", "E"}
KEY_CODE[0x09] = {"f", "F"}
KEY_CODE[0x0a] = {"g", "G"}
KEY_CODE[0x0b] = {"h", "H"}
KEY_CODE[0x0c] = {"i", "I"}
KEY_CODE[0x0d] = {"j", "J"}
KEY_CODE[0x0e] = {"k", "K"}
KEY_CODE[0x0f] = {"l", "L"}
KEY_CODE[0x10] = {"m", "M"}
KEY_CODE[0x11] = {"n", "N"}
KEY_CODE[0x12] = {"o", "O"}
KEY_CODE[0x13] = {"p", "P"}
KEY_CODE[0x14] = {"q", "Q"}
KEY_CODE[0x15] = {"r", "R"}
KEY_CODE[0x16] = {"s", "S"}
KEY_CODE[0x17] = {"t", "T"}
KEY_CODE[0x18] = {"u", "U"}
KEY_CODE[0x19] = {"v", "V"}
KEY_CODE[0x1a] = {"w", "W"}
KEY_CODE[0x1b] = {"x", "X"}
KEY_CODE[0x1c] = {"y", "Y"}
KEY_CODE[0x1d] = {"z", "Z"}
KEY_CODE[0x1e] = {"1", "!"}
KEY_CODE[0x1f] = {"2", "@"}
KEY_CODE[0x20] = {"3", "#"}
KEY_CODE[0x21] = {"4", "$"}
KEY_CODE[0x22] = {"5", "%"}
KEY_CODE[0x23] = {"6", "^"}
KEY_CODE[0x24] = {"7", "&"}
KEY_CODE[0x25] = {"8", "*"}
KEY_CODE[0x26] = {"9", "("}
KEY_CODE[0x27] = {"0", ")"}
KEY_CODE[0x28] = {"[Enter]", "[Enter]"}
KEY_CODE[0x29] = {"[Escape]", "[Escape]"}
KEY_CODE[0x2a] = {"[Back Space]", "[Back Space]"}
KEY_CODE[0x2b] = {"[Tab]", "[Tab]"}
KEY_CODE[0x2c] = {" ", " "}
KEY_CODE[0x2d] = {"-", "_"}
KEY_CODE[0x2e] = {"=", "+"}
KEY_CODE[0x2f] = {"[", "{"}
KEY_CODE[0x30] = {"]", "}"}
KEY_CODE[0x31] = {"\\", "|"}
KEY_CODE[0x33] = {";", ":"}
KEY_CODE[0x34] = {"'", "\""}
KEY_CODE[0x35] = {"`", "~"}
KEY_CODE[0x36] = {",", "<"}
KEY_CODE[0x37] = {".", ">"}
KEY_CODE[0x38] = {"/", "?"}
KEY_CODE[0x39] = {"[Caps Lock]", "[Caps Lock]"}
KEY_CODE[0x3a] = {"[F1]", "[F1]"}
KEY_CODE[0x3b] = {"[F2]", "[F2]"}
KEY_CODE[0x3c] = {"[F3]", "[F3]"}
KEY_CODE[0x3d] = {"[F4]", "[F4]"}
KEY_CODE[0x3e] = {"[F5]", "[F5]"}
KEY_CODE[0x3f] = {"[F6]", "[F6]"}
KEY_CODE[0x40] = {"[F7]", "[F7]"}
KEY_CODE[0x41] = {"[F8]", "[F8]"}
KEY_CODE[0x42] = {"[F9]", "[F9]"}
KEY_CODE[0x43] = {"[F10]", "[F10]"}
KEY_CODE[0x44] = {"[F11]", "[F11]"}
KEY_CODE[0x45] = {"[F12]", "[F12]"}
KEY_CODE[0x4f] = {"[→]", "[→]"}
KEY_CODE[0x50] = {"[←]", "[←]"}
KEY_CODE[0x51] = {"[↓]", "[↓]"}
KEY_CODE[0x52] = {"[↑]", "[↑]"}


function analysis()
    local win = TextWindow.new("Analysis result")
    local tap = Listener.new("usb", nil)
    local pressed_key = ""

    local function remove_tap()
        tap:remove()
    end

    win:set_atclose(remove_tap)

    local shift_flag = false
    function tap.packet(pinfo, tvb, tapinfo)
        if tvb:len() == 35 and tonumber("0x" .. tostring(tvb:bytes(22, 1))) == 0x01 and shift_flag == false then
            if KEY_CODE[tonumber("0x" .. tostring(tvb:bytes(29, 1)))] ~= nil then
                if tonumber("0x" .. tostring(tvb:bytes(27, 1))) == 0x00 then
                    pressed_key = pressed_key .. KEY_CODE[tonumber("0x" .. tostring(tvb:bytes(29, 1)))][1]
                end

                -- 0x02: Left-Shift
                -- 0x20: Right-Shift
                if tonumber("0x" .. tostring(tvb:bytes(27, 1))) == 0x02 or tonumber("0x" .. tostring(tvb:bytes(27, 1))) == 0x20 then
                    pressed_key = pressed_key .. KEY_CODE[tonumber("0x" .. tostring(tvb:bytes(29, 1)))][2]
                    shift_flag = true
                end
            end
        else
            shift_flag = false
        end
    end

    function tap.draw()
        win:clear()
        win:append(pressed_key)
    end

    function tap.reset()
        pressed_key = ""
    end

    retap_packets()
end


register_menu("Analysis of typed key", analysis, MENU_TOOLS_UNSORTED)
