--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:63986b29cc984fe86e92a7a32ffdef65:1a74ed862c2650c15400f4e660013d87:51eadd9eb612090d216e3ba3d4272adf$
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
            -- symbol_1
            x=0,
            y=0,
            width=98,
            height=90,

        },
        {
            -- symbol_2
            x=98,
            y=0,
            width=98,
            height=90,

        },
        {
            -- symbol_3
            x=196,
            y=0,
            width=98,
            height=90,

        },
        {
            -- symbol_empty
            x=294,
            y=0,
            width=98,
            height=90,

        },
    },
    
    sheetContentWidth = 392,
    sheetContentHeight = 90
}

SheetInfo.frameIndex =
{

    ["symbol_1"] = 1,
    ["symbol_2"] = 2,
    ["symbol_3"] = 3,
    ["symbol_empty"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
