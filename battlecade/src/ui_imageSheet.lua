--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:7e48340e56f3166be8728301312604eb:dcf7111b5d5c68d74a40afab3cbea017:82471236ac072b2a4b221f4904720680$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bgSmall
            x=1000,
            y=0,
            width=1000,
            height=799,

        },
        {
            -- bgTall
            x=0,
            y=0,
            width=1000,
            height=1500,

        },
        {
            -- btnAllDone
            x=0,
            y=1679,
            width=550,
            height=139,

        },
        {
            -- btnBack
            x=0,
            y=1818,
            width=550,
            height=139,

        },
        {
            -- btnCancel
            x=1550,
            y=1377,
            width=379,
            height=139,

        },
        {
            -- btnChallenge
            x=0,
            y=1500,
            width=899,
            height=179,

        },
        {
            -- btnChallengeSomeone
            x=1000,
            y=1059,
            width=1000,
            height=139,

        },
        {
            -- btnContinue
            x=1000,
            y=1377,
            width=550,
            height=139,

        },
        {
            -- btnExit
            x=899,
            y=1516,
            width=550,
            height=139,

        },
        {
            -- btnGo
            x=899,
            y=1655,
            width=550,
            height=139,

        },
        {
            -- btnOk
            x=1650,
            y=1823,
            width=159,
            height=139,

        },
        {
            -- btnPractice
            x=1000,
            y=1198,
            width=899,
            height=179,

        },
        {
            -- btnRegister
            x=1449,
            y=1684,
            width=550,
            height=139,

        },
        {
            -- btnResume
            x=550,
            y=1794,
            width=550,
            height=139,

        },
        {
            -- btnStart
            x=1100,
            y=1823,
            width=550,
            height=139,

        },
        {
            -- matchRow
            x=1000,
            y=799,
            width=1000,
            height=260,

        },
        {
            -- pauseIcon
            x=1899,
            y=1198,
            width=80,
            height=79,

        },
        {
            -- txtChallengeSomeone
            x=1449,
            y=1516,
            width=464,
            height=168,

        },
        {
            -- txtGameOver
            x=550,
            y=1933,
            width=479,
            height=64,

        },
        {
            -- txtPaused
            x=550,
            y=1679,
            width=331,
            height=66,

        },
    },
    
    sheetContentWidth = 2000,
    sheetContentHeight = 1997
}

SheetInfo.frameIndex =
{

    ["bgSmall"] = 1,
    ["bgTall"] = 2,
    ["btnAllDone"] = 3,
    ["btnBack"] = 4,
    ["btnCancel"] = 5,
    ["btnChallenge"] = 6,
    ["btnChallengeSomeone"] = 7,
    ["btnContinue"] = 8,
    ["btnExit"] = 9,
    ["btnGo"] = 10,
    ["btnOk"] = 11,
    ["btnPractice"] = 12,
    ["btnRegister"] = 13,
    ["btnResume"] = 14,
    ["btnStart"] = 15,
    ["matchRow"] = 16,
    ["pauseIcon"] = 17,
    ["txtChallengeSomeone"] = 18,
    ["txtGameOver"] = 19,
    ["txtPaused"] = 20,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
