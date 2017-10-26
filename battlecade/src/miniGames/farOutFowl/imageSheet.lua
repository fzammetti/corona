--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:848b8903bba6f910bff57fa2d917b62e:406686fb391693590d7465c1089c3ca9:51eadd9eb612090d216e3ba3d4272adf$
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
            -- catcher
            x=0,
            y=270,
            width=215,
            height=89,

        },
        {
            -- chicken_00
            x=0,
            y=0,
            width=288,
            height=270,

        },
        {
            -- chicken_01
            x=288,
            y=0,
            width=288,
            height=270,

        },
        {
            -- egg
            x=215,
            y=270,
            width=42,
            height=60,

        },
        {
            -- splatteredEgg
            x=257,
            y=270,
            width=126,
            height=48,

        },
    },
    
    sheetContentWidth = 576,
    sheetContentHeight = 359
}

SheetInfo.frameIndex =
{

    ["catcher"] = 1,
    ["chicken_00"] = 2,
    ["chicken_01"] = 3,
    ["egg"] = 4,
    ["splatteredEgg"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
