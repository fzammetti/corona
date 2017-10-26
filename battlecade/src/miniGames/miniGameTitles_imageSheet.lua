--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:6b1f0bbfd08f4bce2bc135d2ebedc32d:b38ff62bbf3526811a35d296fe8eb68d:d6f23220ef55193c8ea005de0882e423$
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
            -- antigravitator
            x=0,
            y=0,
            width=611,
            height=58,

        },
        {
            -- bubbleTrouble
            x=356,
            y=457,
            width=322,
            height=146,

        },
        {
            -- cavernCrasher
            x=0,
            y=562,
            width=342,
            height=145,

        },
        {
            -- colorblinded
            x=0,
            y=58,
            width=534,
            height=57,

        },
        {
            -- copycat
            x=406,
            y=400,
            width=333,
            height=57,

        },
        {
            -- cosmicSquirrel
            x=0,
            y=406,
            width=356,
            height=156,

        },
        {
            -- deathtrap
            x=406,
            y=284,
            width=422,
            height=58,

        },
        {
            -- defender
            x=611,
            y=56,
            width=359,
            height=56,

        },
        {
            -- eliminator
            x=406,
            y=342,
            width=419,
            height=58,

        },
        {
            -- farOutFowl
            x=678,
            y=457,
            width=303,
            height=143,

        },
        {
            -- glutton
            x=678,
            y=600,
            width=309,
            height=58,

        },
        {
            -- hustler
            x=672,
            y=658,
            width=312,
            height=58,

        },
        {
            -- inMemoria
            x=427,
            y=228,
            width=430,
            height=56,

        },
        {
            -- mathematica
            x=427,
            y=170,
            width=510,
            height=58,

        },
        {
            -- pokeher
            x=342,
            y=603,
            width=330,
            height=56,

        },
        {
            -- refluxive
            x=611,
            y=0,
            width=375,
            height=56,

        },
        {
            -- theBogazDerby
            x=0,
            y=260,
            width=406,
            height=146,

        },
        {
            -- theEscape
            x=534,
            y=112,
            width=442,
            height=58,

        },
        {
            -- theRedeyeOrder
            x=0,
            y=115,
            width=427,
            height=145,

        },
        {
            -- virus
            x=342,
            y=659,
            width=216,
            height=57,

        },
    },
    
    sheetContentWidth = 987,
    sheetContentHeight = 716
}

SheetInfo.frameIndex =
{

    ["antigravitator"] = 1,
    ["bubbleTrouble"] = 2,
    ["cavernCrasher"] = 3,
    ["colorblinded"] = 4,
    ["copycat"] = 5,
    ["cosmicSquirrel"] = 6,
    ["deathtrap"] = 7,
    ["defender"] = 8,
    ["eliminator"] = 9,
    ["farOutFowl"] = 10,
    ["glutton"] = 11,
    ["hustler"] = 12,
    ["inMemoria"] = 13,
    ["mathematica"] = 14,
    ["pokeher"] = 15,
    ["refluxive"] = 16,
    ["theBogazDerby"] = 17,
    ["theEscape"] = 18,
    ["theRedeyeOrder"] = 19,
    ["virus"] = 20,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
