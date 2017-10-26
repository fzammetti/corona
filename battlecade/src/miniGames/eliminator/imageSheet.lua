--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:140be28482936b102c3012519695b146:3283deaa3727841ddb9b8e6e54fa782c:51eadd9eb612090d216e3ba3d4272adf$
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
            -- blank
            x=0,
            y=0,
            width=108,
            height=108,

        },
        {
            -- down
            x=108,
            y=0,
            width=108,
            height=108,

        },
        {
            -- empty
            x=216,
            y=0,
            width=108,
            height=108,

        },
        {
            -- up
            x=324,
            y=0,
            width=108,
            height=108,

        },
    },
    
    sheetContentWidth = 432,
    sheetContentHeight = 108
}

SheetInfo.frameIndex =
{

    ["blank"] = 1,
    ["down"] = 2,
    ["empty"] = 3,
    ["up"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
