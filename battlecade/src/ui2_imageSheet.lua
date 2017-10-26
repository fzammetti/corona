--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c653f6d18d996b3e77e5e8622065f2da:8578e9dacaca2e293205286e71fde711:fc736e23c17cbbb517598af24f66c48a$
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
            -- txtHeyThereHuman
            x=0,
            y=0,
            width=469,
            height=168,

        },
    },
    
    sheetContentWidth = 469,
    sheetContentHeight = 168
}

SheetInfo.frameIndex =
{

    ["txtHeyThereHuman"] = 1,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
