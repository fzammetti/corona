--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:635fcf1986167747c813d130e81b6717:d0660c4fad45473559eba595501f71da:51eadd9eb612090d216e3ba3d4272adf$
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
            -- enemy1_1
            x=704,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy1_2
            x=704,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy2_1
            x=791,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy2_2
            x=791,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy3_1
            x=0,
            y=0,
            width=88,
            height=107,

        },
        {
            -- enemy3_2
            x=878,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy4_1
            x=0,
            y=107,
            width=88,
            height=107,

        },
        {
            -- enemy4_2
            x=878,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy5_1
            x=965,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy5_2
            x=965,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy6_1
            x=1052,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy6_2
            x=1052,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy7_1
            x=88,
            y=0,
            width=88,
            height=107,

        },
        {
            -- enemy7_2
            x=1139,
            y=0,
            width=87,
            height=107,

        },
        {
            -- enemy8_1
            x=1139,
            y=107,
            width=87,
            height=107,

        },
        {
            -- enemy8_2
            x=1226,
            y=0,
            width=87,
            height=107,

        },
        {
            -- goodguy1_1
            x=88,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy1_2
            x=176,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy2_1
            x=176,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy2_2
            x=264,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy3_1
            x=264,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy3_2
            x=352,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy4_1
            x=1226,
            y=107,
            width=87,
            height=107,

        },
        {
            -- goodguy4_2
            x=352,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy5_1
            x=1313,
            y=0,
            width=87,
            height=107,

        },
        {
            -- goodguy5_2
            x=440,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy6_1
            x=440,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy6_2
            x=528,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy7_1
            x=1313,
            y=107,
            width=87,
            height=107,

        },
        {
            -- goodguy7_2
            x=528,
            y=107,
            width=88,
            height=107,

        },
        {
            -- goodguy8_1
            x=616,
            y=0,
            width=88,
            height=107,

        },
        {
            -- goodguy8_2
            x=616,
            y=107,
            width=88,
            height=107,

        },
    },
    
    sheetContentWidth = 1400,
    sheetContentHeight = 214
}

SheetInfo.frameIndex =
{

    ["enemy1_1"] = 1,
    ["enemy1_2"] = 2,
    ["enemy2_1"] = 3,
    ["enemy2_2"] = 4,
    ["enemy3_1"] = 5,
    ["enemy3_2"] = 6,
    ["enemy4_1"] = 7,
    ["enemy4_2"] = 8,
    ["enemy5_1"] = 9,
    ["enemy5_2"] = 10,
    ["enemy6_1"] = 11,
    ["enemy6_2"] = 12,
    ["enemy7_1"] = 13,
    ["enemy7_2"] = 14,
    ["enemy8_1"] = 15,
    ["enemy8_2"] = 16,
    ["goodguy1_1"] = 17,
    ["goodguy1_2"] = 18,
    ["goodguy2_1"] = 19,
    ["goodguy2_2"] = 20,
    ["goodguy3_1"] = 21,
    ["goodguy3_2"] = 22,
    ["goodguy4_1"] = 23,
    ["goodguy4_2"] = 24,
    ["goodguy5_1"] = 25,
    ["goodguy5_2"] = 26,
    ["goodguy6_1"] = 27,
    ["goodguy6_2"] = 28,
    ["goodguy7_1"] = 29,
    ["goodguy7_2"] = 30,
    ["goodguy8_1"] = 31,
    ["goodguy8_2"] = 32,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
