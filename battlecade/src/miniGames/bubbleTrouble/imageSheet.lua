--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ee3787fd43f6777447ca0184f95bd7f2:b4de400c92e6b35e9ab553e108e01c89:51eadd9eb612090d216e3ba3d4272adf$
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
            -- bubble_popped
            x=0,
            y=0,
            width=120,
            height=128,

        },
        {
            -- bubble_unpopped
            x=120,
            y=0,
            width=120,
            height=128,

        },
    },
    
    sheetContentWidth = 240,
    sheetContentHeight = 128
}

SheetInfo.frameIndex =
{

    ["bubble_popped"] = 1,
    ["bubble_unpopped"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
