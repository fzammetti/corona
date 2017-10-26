--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:9464bed47e7efc926ab7ce9e5795ef8f:8507e7d6554ab7c7b2e12cc55f655c7e:e6804a7d3ed54d5d1339fe522245bc02$
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
            width=202,
            height=324,

        },
        {
            -- bubbleTrouble
            x=202,
            y=0,
            width=202,
            height=324,

        },
        {
            -- cavernCrasher
            x=404,
            y=0,
            width=202,
            height=324,

        },
        {
            -- colorblinded
            x=606,
            y=0,
            width=202,
            height=324,

        },
        {
            -- copycat
            x=808,
            y=0,
            width=202,
            height=324,

        },
        {
            -- cosmicSquirrel
            x=1010,
            y=0,
            width=202,
            height=324,

        },
        {
            -- deathtrap
            x=1212,
            y=0,
            width=202,
            height=324,

        },
        {
            -- defender
            x=1414,
            y=0,
            width=202,
            height=324,

        },
        {
            -- eliminator
            x=1616,
            y=0,
            width=202,
            height=324,

        },
        {
            -- farOutFowl
            x=1818,
            y=0,
            width=202,
            height=324,

        },
        {
            -- glutton
            x=0,
            y=324,
            width=202,
            height=324,

        },
        {
            -- hustler
            x=202,
            y=324,
            width=202,
            height=324,

        },
        {
            -- inMemoria
            x=404,
            y=324,
            width=202,
            height=324,

        },
        {
            -- mathematica
            x=606,
            y=324,
            width=202,
            height=324,

        },
        {
            -- pokeher
            x=808,
            y=324,
            width=202,
            height=324,

        },
        {
            -- refluxive
            x=1010,
            y=324,
            width=202,
            height=324,

        },
        {
            -- theBogazDerby
            x=1212,
            y=324,
            width=202,
            height=324,

        },
        {
            -- theEscape
            x=1414,
            y=324,
            width=202,
            height=324,

        },
        {
            -- theRedeyeOrder
            x=1616,
            y=324,
            width=202,
            height=324,

        },
        {
            -- virus
            x=1818,
            y=324,
            width=202,
            height=324,

        },
    },
    
    sheetContentWidth = 2020,
    sheetContentHeight = 648
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
