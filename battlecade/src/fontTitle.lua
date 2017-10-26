local Font = {}

Font.info = 
    {
    face              = "Skater Park",
    file              = "fontTitle.png",
    size              = 64,
    bold              = 1,
    italic            = 0,
    charset           = "",
    unicode           = 0,
    stretchH          = 100,
    smooth            = 1,
    aa                = 1,
    padding           = {0, 0, 0, 0},
    spacing           = 2,
    charsCount        = 95,
    kerningsCounts    = 389,
    }

Font.common =
    {
    lineHeight        = 94,
    base              = 74,
    scaleW            = 1024,
    scaleH            = 512,
    pages             = 1,
    packed            = 0,
    }

Font.chars =
    {
    {id=32,x=154,y=471,width=0,height=0,xoffset=0,yoffset=89,xadvance=30,page=0,chnl=0,letter="space"},
    {id=33,x=69,y=2,width=40,height=93,xoffset=0,yoffset=38,xadvance=38,page=0,chnl=0,letter="!"},
    {id=34,x=840,y=400,width=58,height=41,xoffset=-6,yoffset=39,xadvance=40,page=0,chnl=0,letter=string.char(34)},
    {id=35,x=154,y=400,width=71,height=66,xoffset=-8,yoffset=56,xadvance=51,page=0,chnl=0,letter="#"},
    {id=36,x=850,y=2,width=54,height=78,xoffset=-8,yoffset=54,xadvance=31,page=0,chnl=0,letter="$"},
    {id=37,x=265,y=327,width=81,height=70,xoffset=-6,yoffset=57,xadvance=61,page=0,chnl=0,letter="%"},
    {id=38,x=637,y=98,width=76,height=74,xoffset=-7,yoffset=53,xadvance=54,page=0,chnl=0,letter="&"},
    {id=39,x=900,y=400,width=37,height=41,xoffset=-5,yoffset=39,xadvance=19,page=0,chnl=0,letter="'"},
    {id=40,x=2,y=400,width=47,height=69,xoffset=-7,yoffset=52,xadvance=25,page=0,chnl=0,letter="("},
    {id=41,x=673,y=327,width=47,height=70,xoffset=-8,yoffset=55,xadvance=25,page=0,chnl=0,letter=")"},
    {id=42,x=452,y=400,width=58,height=52,xoffset=-8,yoffset=49,xadvance=37,page=0,chnl=0,letter="*"},
    {id=43,x=395,y=400,width=55,height=53,xoffset=-8,yoffset=55,xadvance=34,page=0,chnl=0,letter="+"},
    {id=44,x=735,y=400,width=41,height=46,xoffset=-7,yoffset=74,xadvance=21,page=0,chnl=0,letter=","},
    {id=45,x=2,y=471,width=50,height=36,xoffset=-8,yoffset=61,xadvance=30,page=0,chnl=0,letter="-"},
    {id=46,x=939,y=400,width=41,height=40,xoffset=-6,yoffset=71,xadvance=22,page=0,chnl=0,letter="."},
    {id=47,x=614,y=327,width=57,height=70,xoffset=-9,yoffset=57,xadvance=34,page=0,chnl=0,letter="/"},
    {id=48,x=848,y=177,width=72,height=72,xoffset=-7,yoffset=55,xadvance=50,page=0,chnl=0,letter="0"},
    {id=49,x=227,y=400,width=55,height=65,xoffset=-7,yoffset=59,xadvance=35,page=0,chnl=0,letter="1"},
    {id=50,x=545,y=177,width=59,height=73,xoffset=-6,yoffset=55,xadvance=39,page=0,chnl=0,letter="2"},
    {id=51,x=71,y=253,width=66,height=72,xoffset=-7,yoffset=57,xadvance=44,page=0,chnl=0,letter="3"},
    {id=52,x=477,y=177,width=66,height=73,xoffset=-7,yoffset=55,xadvance=45,page=0,chnl=0,letter="4"},
    {id=53,x=544,y=2,width=62,height=82,xoffset=-6,yoffset=50,xadvance=42,page=0,chnl=0,letter="5"},
    {id=54,x=2,y=2,width=65,height=94,xoffset=-6,yoffset=45,xadvance=44,page=0,chnl=0,letter="6"},
    {id=55,x=284,y=400,width=65,height=62,xoffset=-6,yoffset=57,xadvance=43,page=0,chnl=0,letter="7"},
    {id=56,x=791,y=98,width=68,height=74,xoffset=-5,yoffset=56,xadvance=49,page=0,chnl=0,letter="8"},
    {id=57,x=930,y=98,width=64,height=74,xoffset=-6,yoffset=57,xadvance=43,page=0,chnl=0,letter="9"},
    {id=58,x=351,y=400,width=42,height=61,xoffset=-6,yoffset=60,xadvance=22,page=0,chnl=0,letter=":"},
    {id=59,x=110,y=400,width=42,height=67,xoffset=-7,yoffset=63,xadvance=21,page=0,chnl=0,letter=";"},
    {id=60,x=625,y=400,width=53,height=46,xoffset=-5,yoffset=62,xadvance=34,page=0,chnl=0,letter="<"},
    {id=61,x=680,y=400,width=53,height=46,xoffset=-4,yoffset=62,xadvance=34,page=0,chnl=0,letter="="},
    {id=62,x=572,y=400,width=51,height=47,xoffset=-4,yoffset=61,xadvance=34,page=0,chnl=0,letter=">"},
    {id=63,x=652,y=2,width=54,height=80,xoffset=-5,yoffset=53,xadvance=35,page=0,chnl=0,letter="?"},
    {id=64,x=799,y=327,width=72,height=69,xoffset=-7,yoffset=54,xadvance=53,page=0,chnl=0,letter="@"},
    {id=65,x=482,y=98,width=71,height=75,xoffset=-8,yoffset=53,xadvance=48,page=0,chnl=0,letter="A"},
    {id=66,x=873,y=327,width=68,height=69,xoffset=-7,yoffset=55,xadvance=46,page=0,chnl=0,letter="B"},
    {id=67,x=489,y=327,width=61,height=70,xoffset=-8,yoffset=56,xadvance=38,page=0,chnl=0,letter="C"},
    {id=68,x=419,y=327,width=68,height=70,xoffset=-6,yoffset=56,xadvance=48,page=0,chnl=0,letter="D"},
    {id=69,x=522,y=253,width=57,height=72,xoffset=-7,yoffset=55,xadvance=35,page=0,chnl=0,letter="E"},
    {id=70,x=462,y=253,width=58,height=72,xoffset=-4,yoffset=56,xadvance=33,page=0,chnl=0,letter="F"},
    {id=71,x=722,y=327,width=75,height=69,xoffset=-7,yoffset=56,xadvance=54,page=0,chnl=0,letter="G"},
    {id=72,x=273,y=2,width=59,height=84,xoffset=-5,yoffset=48,xadvance=42,page=0,chnl=0,letter="H"},
    {id=73,x=202,y=2,width=69,height=86,xoffset=-6,yoffset=50,xadvance=49,page=0,chnl=0,letter="I"},
    {id=74,x=245,y=98,width=77,height=76,xoffset=-7,yoffset=53,xadvance=55,page=0,chnl=0,letter="J"},
    {id=75,x=408,y=98,width=72,height=75,xoffset=-5,yoffset=54,xadvance=53,page=0,chnl=0,letter="K"},
    {id=76,x=51,y=400,width=57,height=68,xoffset=-6,yoffset=57,xadvance=37,page=0,chnl=0,letter="L"},
    {id=77,x=166,y=327,width=97,height=70,xoffset=-7,yoffset=56,xadvance=77,page=0,chnl=0,letter="M"},
    {id=78,x=715,y=98,width=74,height=74,xoffset=-6,yoffset=57,xadvance=53,page=0,chnl=0,letter="N"},
    {id=79,x=706,y=253,width=76,height=71,xoffset=-7,yoffset=53,xadvance=55,page=0,chnl=0,letter="O"},
    {id=80,x=348,y=327,width=69,height=70,xoffset=-6,yoffset=57,xadvance=49,page=0,chnl=0,letter="P"},
    {id=81,x=906,y=2,width=84,height=77,xoffset=-5,yoffset=59,xadvance=55,page=0,chnl=0,letter="Q"},
    {id=82,x=162,y=177,width=85,height=73,xoffset=-7,yoffset=56,xadvance=50,page=0,chnl=0,letter="R"},
    {id=83,x=708,y=2,width=74,height=79,xoffset=-8,yoffset=52,xadvance=51,page=0,chnl=0,letter="S"},
    {id=84,x=784,y=2,width=64,height=78,xoffset=-6,yoffset=50,xadvance=43,page=0,chnl=0,letter="T"},
    {id=85,x=334,y=2,width=65,height=83,xoffset=-6,yoffset=51,xadvance=45,page=0,chnl=0,letter="U"},
    {id=86,x=401,y=2,width=63,height=83,xoffset=-5,yoffset=51,xadvance=40,page=0,chnl=0,letter="V"},
    {id=87,x=111,y=2,width=89,height=90,xoffset=-7,yoffset=49,xadvance=65,page=0,chnl=0,letter="W"},
    {id=88,x=624,y=253,width=80,height=71,xoffset=-8,yoffset=57,xadvance=57,page=0,chnl=0,letter="X"},
    {id=89,x=770,y=177,width=76,height=72,xoffset=-7,yoffset=56,xadvance=54,page=0,chnl=0,letter="Y"},
    {id=90,x=555,y=98,width=80,height=74,xoffset=-7,yoffset=56,xadvance=59,page=0,chnl=0,letter="Z"},
    {id=91,x=608,y=2,width=42,height=82,xoffset=-8,yoffset=58,xadvance=22,page=0,chnl=0,letter="["},
    {id=92,x=273,y=253,width=62,height=72,xoffset=-8,yoffset=58,xadvance=40,page=0,chnl=0,letter=string.char(92)},
    {id=93,x=466,y=2,width=44,height=83,xoffset=-8,yoffset=58,xadvance=24,page=0,chnl=0,letter="]"},
    {id=94,x=512,y=400,width=58,height=47,xoffset=-7,yoffset=51,xadvance=38,page=0,chnl=0,letter="^"},
    {id=95,x=99,y=471,width=53,height=29,xoffset=-9,yoffset=86,xadvance=28,page=0,chnl=0,letter="_"},
    {id=96,x=54,y=471,width=43,height=34,xoffset=-4,yoffset=33,xadvance=28,page=0,chnl=0,letter="`"},
    {id=97,x=2,y=98,width=74,height=77,xoffset=-9,yoffset=56,xadvance=48,page=0,chnl=0,letter="a"},
    {id=98,x=943,y=327,width=61,height=69,xoffset=-4,yoffset=56,xadvance=43,page=0,chnl=0,letter="b"},
    {id=99,x=400,y=253,width=60,height=72,xoffset=-7,yoffset=56,xadvance=39,page=0,chnl=0,letter="c"},
    {id=100,x=784,y=253,width=73,height=71,xoffset=-7,yoffset=54,xadvance=52,page=0,chnl=0,letter="d"},
    {id=101,x=59,y=327,width=53,height=71,xoffset=-5,yoffset=56,xadvance=35,page=0,chnl=0,letter="e"},
    {id=102,x=114,y=327,width=50,height=71,xoffset=-4,yoffset=56,xadvance=31,page=0,chnl=0,letter="f"},
    {id=103,x=207,y=253,width=64,height=72,xoffset=-7,yoffset=56,xadvance=42,page=0,chnl=0,letter="g"},
    {id=104,x=407,y=177,width=68,height=73,xoffset=-5,yoffset=55,xadvance=49,page=0,chnl=0,letter="h"},
    {id=105,x=581,y=253,width=41,height=72,xoffset=-5,yoffset=57,xadvance=24,page=0,chnl=0,letter="i"},
    {id=106,x=2,y=253,width=67,height=72,xoffset=-7,yoffset=55,xadvance=47,page=0,chnl=0,letter="j"},
    {id=107,x=78,y=98,width=71,height=77,xoffset=-4,yoffset=57,xadvance=52,page=0,chnl=0,letter="k"},
    {id=108,x=2,y=327,width=55,height=71,xoffset=-5,yoffset=55,xadvance=37,page=0,chnl=0,letter="l"},
    {id=109,x=68,y=177,width=92,height=73,xoffset=-7,yoffset=53,xadvance=68,page=0,chnl=0,letter="m"},
    {id=110,x=2,y=177,width=64,height=74,xoffset=-4,yoffset=56,xadvance=47,page=0,chnl=0,letter="n"},
    {id=111,x=929,y=253,width=65,height=71,xoffset=-6,yoffset=55,xadvance=44,page=0,chnl=0,letter="o"},
    {id=112,x=552,y=327,width=60,height=70,xoffset=-4,yoffset=56,xadvance=41,page=0,chnl=0,letter="p"},
    {id=113,x=689,y=177,width=79,height=72,xoffset=-6,yoffset=56,xadvance=58,page=0,chnl=0,letter="q"},
    {id=114,x=334,y=177,width=71,height=73,xoffset=-6,yoffset=55,xadvance=50,page=0,chnl=0,letter="r"},
    {id=115,x=861,y=98,width=67,height=74,xoffset=-6,yoffset=57,xadvance=46,page=0,chnl=0,letter="s"},
    {id=116,x=337,y=253,width=61,height=72,xoffset=-8,yoffset=56,xadvance=39,page=0,chnl=0,letter="t"},
    {id=117,x=139,y=253,width=66,height=72,xoffset=-6,yoffset=56,xadvance=47,page=0,chnl=0,letter="u"},
    {id=118,x=859,y=253,width=68,height=71,xoffset=-7,yoffset=56,xadvance=46,page=0,chnl=0,letter="v"},
    {id=119,x=249,y=177,width=83,height=73,xoffset=-7,yoffset=57,xadvance=60,page=0,chnl=0,letter="w"},
    {id=120,x=324,y=98,width=82,height=75,xoffset=-9,yoffset=55,xadvance=57,page=0,chnl=0,letter="x"},
    {id=121,x=606,y=177,width=81,height=72,xoffset=-8,yoffset=57,xadvance=57,page=0,chnl=0,letter="y"},
    {id=122,x=922,y=177,width=71,height=72,xoffset=-6,yoffset=56,xadvance=50,page=0,chnl=0,letter="z"},
    {id=123,x=151,y=98,width=46,height=77,xoffset=-8,yoffset=56,xadvance=25,page=0,chnl=0,letter="{"},
    {id=124,x=512,y=2,width=30,height=83,xoffset=-5,yoffset=60,xadvance=12,page=0,chnl=0,letter="|"},
    {id=125,x=199,y=98,width=44,height=77,xoffset=-7,yoffset=56,xadvance=25,page=0,chnl=0,letter="}"},
    {id=126,x=778,y=400,width=60,height=42,xoffset=-5,yoffset=52,xadvance=41,page=0,chnl=0,letter="~"},
    }

Font.kerning =
    {
    {first=34, second=106, amount=-7},
    {first=34, second=116, amount=2},
    {first=38, second=103, amount=2},
    {first=38, second=111, amount=2},
    {first=38, second=123, amount=2},
    {first=39, second=93, amount=6},
    {first=39, second=94, amount=-3},
    {first=39, second=101, amount=4},
    {first=39, second=103, amount=4},
    {first=39, second=111, amount=3},
    {first=39, second=116, amount=2},
    {first=40, second=43, amount=-1},
    {first=40, second=51, amount=2},
    {first=40, second=53, amount=1},
    {first=40, second=63, amount=-1},
    {first=40, second=74, amount=5},
    {first=40, second=79, amount=5},
    {first=40, second=104, amount=2},
    {first=40, second=109, amount=3},
    {first=40, second=121, amount=4},
    {first=40, second=124, amount=3},
    {first=44, second=105, amount=1},
    {first=46, second=105, amount=3},
    {first=47, second=49, amount=2},
    {first=47, second=53, amount=1},
    {first=47, second=56, amount=1},
    {first=47, second=98, amount=3},
    {first=47, second=100, amount=2},
    {first=47, second=101, amount=4},
    {first=47, second=102, amount=4},
    {first=47, second=116, amount=7},
    {first=47, second=118, amount=2},
    {first=47, second=119, amount=2},
    {first=47, second=120, amount=4},
    {first=47, second=121, amount=4},
    {first=48, second=55, amount=-2},
    {first=50, second=49, amount=2},
    {first=50, second=51, amount=1},
    {first=50, second=52, amount=-3},
    {first=51, second=49, amount=1},
    {first=51, second=55, amount=-1},
    {first=52, second=48, amount=2},
    {first=52, second=49, amount=2},
    {first=52, second=50, amount=-1},
    {first=52, second=52, amount=4},
    {first=52, second=53, amount=-3},
    {first=52, second=55, amount=-3},
    {first=52, second=56, amount=-3},
    {first=52, second=57, amount=-6},
    {first=53, second=50, amount=-3},
    {first=53, second=51, amount=-3},
    {first=53, second=55, amount=-4},
    {first=53, second=56, amount=-4},
    {first=53, second=57, amount=-5},
    {first=54, second=49, amount=1},
    {first=54, second=50, amount=-2},
    {first=54, second=51, amount=-2},
    {first=54, second=52, amount=1},
    {first=54, second=53, amount=-2},
    {first=54, second=55, amount=-4},
    {first=54, second=57, amount=-4},
    {first=55, second=47, amount=-6},
    {first=55, second=48, amount=-1},
    {first=55, second=50, amount=-2},
    {first=55, second=51, amount=-2},
    {first=55, second=52, amount=-2},
    {first=55, second=54, amount=-2},
    {first=55, second=57, amount=-2},
    {first=56, second=49, amount=2},
    {first=56, second=50, amount=-2},
    {first=56, second=53, amount=-1},
    {first=57, second=49, amount=3},
    {first=57, second=51, amount=-1},
    {first=57, second=52, amount=-3},
    {first=57, second=53, amount=-2},
    {first=58, second=105, amount=3},
    {first=59, second=36, amount=-7},
    {first=59, second=105, amount=3},
    {first=60, second=36, amount=2},
    {first=65, second=84, amount=-6},
    {first=65, second=86, amount=-5},
    {first=65, second=87, amount=-6},
    {first=65, second=89, amount=-9},
    {first=65, second=105, amount=-1},
    {first=65, second=118, amount=-10},
    {first=65, second=119, amount=-11},
    {first=65, second=121, amount=-8},
    {first=67, second=84, amount=-3},
    {first=67, second=105, amount=1},
    {first=69, second=84, amount=-4},
    {first=70, second=44, amount=-9},
    {first=70, second=46, amount=-9},
    {first=70, second=65, amount=-7},
    {first=70, second=74, amount=-5},
    {first=73, second=97, amount=-2},
    {first=73, second=105, amount=2},
    {first=74, second=79, amount=-3},
    {first=74, second=83, amount=-6},
    {first=75, second=79, amount=-7},
    {first=75, second=83, amount=-2},
    {first=76, second=79, amount=-2},
    {first=76, second=81, amount=-3},
    {first=76, second=84, amount=-7},
    {first=76, second=86, amount=-6},
    {first=76, second=87, amount=-6},
    {first=76, second=89, amount=-12},
    {first=76, second=121, amount=-10},
    {first=80, second=44, amount=-9},
    {first=80, second=46, amount=-9},
    {first=80, second=65, amount=-5},
    {first=80, second=97, amount=-6},
    {first=81, second=85, amount=-2},
    {first=81, second=89, amount=-8},
    {first=82, second=46, amount=-1},
    {first=82, second=79, amount=-1},
    {first=82, second=84, amount=-8},
    {first=82, second=89, amount=-10},
    {first=82, second=121, amount=-8},
    {first=84, second=44, amount=-7},
    {first=84, second=45, amount=-8},
    {first=84, second=46, amount=-7},
    {first=84, second=59, amount=-2},
    {first=84, second=65, amount=-6},
    {first=84, second=74, amount=-7},
    {first=84, second=81, amount=-4},
    {first=84, second=83, amount=-4},
    {first=84, second=97, amount=-6},
    {first=84, second=99, amount=-3},
    {first=84, second=101, amount=-1},
    {first=84, second=105, amount=-1},
    {first=84, second=111, amount=-4},
    {first=84, second=115, amount=-5},
    {first=84, second=119, amount=1},
    {first=84, second=121, amount=-1},
    {first=85, second=105, amount=-1},
    {first=86, second=44, amount=-11},
    {first=86, second=45, amount=-6},
    {first=86, second=46, amount=-11},
    {first=86, second=58, amount=-3},
    {first=86, second=59, amount=-2},
    {first=86, second=65, amount=-7},
    {first=86, second=69, amount=3},
    {first=86, second=74, amount=-6},
    {first=86, second=76, amount=1},
    {first=86, second=79, amount=-5},
    {first=86, second=82, amount=3},
    {first=86, second=84, amount=2},
    {first=86, second=85, amount=1},
    {first=86, second=87, amount=2},
    {first=86, second=89, amount=1},
    {first=86, second=97, amount=-9},
    {first=86, second=101, amount=-1},
    {first=86, second=111, amount=-5},
    {first=86, second=114, amount=1},
    {first=86, second=117, amount=1},
    {first=86, second=121, amount=-2},
    {first=87, second=44, amount=-7},
    {first=87, second=45, amount=-6},
    {first=87, second=46, amount=-10},
    {first=87, second=59, amount=1},
    {first=87, second=65, amount=-6},
    {first=87, second=74, amount=-6},
    {first=87, second=83, amount=-4},
    {first=87, second=97, amount=-9},
    {first=87, second=101, amount=1},
    {first=87, second=111, amount=-4},
    {first=87, second=114, amount=1},
    {first=87, second=117, amount=-1},
    {first=89, second=46, amount=-10},
    {first=89, second=58, amount=-3},
    {first=89, second=65, amount=-6},
    {first=89, second=69, amount=1},
    {first=89, second=73, amount=-2},
    {first=89, second=79, amount=-4},
    {first=89, second=80, amount=-2},
    {first=89, second=81, amount=-4},
    {first=89, second=85, amount=-1},
    {first=89, second=86, amount=-1},
    {first=89, second=97, amount=-9},
    {first=89, second=101, amount=-2},
    {first=89, second=105, amount=-2},
    {first=89, second=111, amount=-4},
    {first=89, second=112, amount=-2},
    {first=89, second=113, amount=-2},
    {first=89, second=117, amount=-2},
    {first=89, second=118, amount=-2},
    {first=97, second=105, amount=2},
    {first=97, second=116, amount=-6},
    {first=97, second=118, amount=-7},
    {first=97, second=119, amount=-8},
    {first=97, second=121, amount=-7},
    {first=97, second=122, amount=2},
    {first=98, second=44, amount=-2},
    {first=98, second=106, amount=-1},
    {first=98, second=117, amount=-2},
    {first=99, second=33, amount=2},
    {first=99, second=41, amount=2},
    {first=99, second=47, amount=3},
    {first=99, second=58, amount=2},
    {first=99, second=117, amount=-5},
    {first=99, second=118, amount=-6},
    {first=99, second=119, amount=-6},
    {first=99, second=121, amount=-7},
    {first=99, second=122, amount=-2},
    {first=100, second=44, amount=-5},
    {first=100, second=63, amount=-2},
    {first=101, second=33, amount=2},
    {first=101, second=47, amount=4},
    {first=101, second=63, amount=2},
    {first=101, second=120, amount=2},
    {first=101, second=122, amount=-1},
    {first=102, second=34, amount=2},
    {first=102, second=39, amount=2},
    {first=102, second=44, amount=-9},
    {first=102, second=46, amount=-9},
    {first=102, second=97, amount=-5},
    {first=102, second=105, amount=-1},
    {first=102, second=106, amount=-3},
    {first=102, second=109, amount=-4},
    {first=102, second=116, amount=2},
    {first=103, second=64, amount=2},
    {first=103, second=98, amount=-2},
    {first=103, second=100, amount=1},
    {first=103, second=113, amount=1},
    {first=103, second=116, amount=-3},
    {first=103, second=117, amount=-1},
    {first=105, second=116, amount=-2},
    {first=107, second=42, amount=-4},
    {first=107, second=45, amount=-5},
    {first=107, second=64, amount=-2},
    {first=107, second=99, amount=-5},
    {first=107, second=103, amount=-5},
    {first=107, second=105, amount=-2},
    {first=107, second=107, amount=-4},
    {first=107, second=108, amount=-2},
    {first=107, second=110, amount=-3},
    {first=107, second=111, amount=-5},
    {first=107, second=112, amount=-3},
    {first=107, second=113, amount=-5},
    {first=107, second=114, amount=-2},
    {first=107, second=115, amount=-2},
    {first=107, second=116, amount=-2},
    {first=107, second=117, amount=-2},
    {first=107, second=118, amount=-4},
    {first=107, second=122, amount=-3},
    {first=108, second=33, amount=6},
    {first=108, second=34, amount=-3},
    {first=108, second=41, amount=4},
    {first=108, second=44, amount=2},
    {first=108, second=46, amount=3},
    {first=108, second=47, amount=4},
    {first=108, second=58, amount=4},
    {first=108, second=97, amount=1},
    {first=108, second=98, amount=-1},
    {first=108, second=114, amount=-1},
    {first=108, second=116, amount=-6},
    {first=108, second=117, amount=-3},
    {first=108, second=118, amount=-6},
    {first=108, second=119, amount=-6},
    {first=108, second=120, amount=-1},
    {first=108, second=121, amount=-8},
    {first=108, second=122, amount=-1},
    {first=109, second=33, amount=4},
    {first=109, second=41, amount=3},
    {first=109, second=44, amount=2},
    {first=109, second=46, amount=4},
    {first=109, second=47, amount=5},
    {first=109, second=58, amount=3},
    {first=109, second=59, amount=2},
    {first=109, second=117, amount=-5},
    {first=109, second=122, amount=-1},
    {first=110, second=36, amount=2},
    {first=111, second=99, amount=1},
    {first=111, second=116, amount=-4},
    {first=112, second=34, amount=1},
    {first=112, second=39, amount=2},
    {first=112, second=44, amount=-9},
    {first=112, second=46, amount=-9},
    {first=112, second=63, amount=4},
    {first=112, second=97, amount=-8},
    {first=112, second=106, amount=-1},
    {first=112, second=111, amount=-1},
    {first=112, second=115, amount=-3},
    {first=112, second=119, amount=-1},
    {first=112, second=122, amount=-3},
    {first=113, second=33, amount=-1},
    {first=113, second=41, amount=2},
    {first=113, second=47, amount=1},
    {first=114, second=33, amount=1},
    {first=114, second=44, amount=-1},
    {first=114, second=46, amount=-1},
    {first=114, second=97, amount=-1},
    {first=114, second=121, amount=-7},
    {first=114, second=122, amount=-1},
    {first=115, second=33, amount=-1},
    {first=115, second=45, amount=2},
    {first=115, second=64, amount=3},
    {first=115, second=108, amount=-2},
    {first=115, second=119, amount=-3},
    {first=115, second=121, amount=-6},
    {first=116, second=34, amount=5},
    {first=116, second=39, amount=5},
    {first=116, second=44, amount=-3},
    {first=116, second=45, amount=-3},
    {first=116, second=46, amount=-4},
    {first=116, second=58, amount=-2},
    {first=116, second=59, amount=-1},
    {first=116, second=63, amount=1},
    {first=116, second=97, amount=-6},
    {first=116, second=98, amount=-1},
    {first=116, second=99, amount=-3},
    {first=116, second=100, amount=1},
    {first=116, second=101, amount=-1},
    {first=116, second=102, amount=-1},
    {first=116, second=105, amount=-1},
    {first=116, second=106, amount=-6},
    {first=116, second=111, amount=-3},
    {first=116, second=114, amount=1},
    {first=116, second=115, amount=-4},
    {first=116, second=116, amount=2},
    {first=116, second=119, amount=1},
    {first=116, second=121, amount=-1},
    {first=117, second=97, amount=-4},
    {first=117, second=105, amount=-2},
    {first=117, second=109, amount=-4},
    {first=118, second=44, amount=-10},
    {first=118, second=45, amount=-3},
    {first=118, second=46, amount=-9},
    {first=118, second=58, amount=-1},
    {first=118, second=59, amount=1},
    {first=118, second=97, amount=-9},
    {first=118, second=101, amount=-1},
    {first=118, second=111, amount=-2},
    {first=118, second=114, amount=1},
    {first=118, second=116, amount=2},
    {first=118, second=117, amount=1},
    {first=118, second=121, amount=1},
    {first=119, second=34, amount=2},
    {first=119, second=39, amount=3},
    {first=119, second=44, amount=-7},
    {first=119, second=45, amount=-3},
    {first=119, second=46, amount=-7},
    {first=119, second=59, amount=1},
    {first=119, second=63, amount=1},
    {first=119, second=97, amount=-7},
    {first=119, second=100, amount=2},
    {first=119, second=101, amount=1},
    {first=119, second=111, amount=-1},
    {first=119, second=114, amount=1},
    {first=119, second=116, amount=1},
    {first=119, second=117, amount=1},
    {first=119, second=119, amount=1},
    {first=119, second=120, amount=2},
    {first=119, second=121, amount=2},
    {first=120, second=41, amount=4},
    {first=120, second=46, amount=4},
    {first=120, second=58, amount=2},
    {first=120, second=59, amount=2},
    {first=120, second=97, amount=-1},
    {first=120, second=98, amount=-2},
    {first=120, second=109, amount=-1},
    {first=120, second=117, amount=1},
    {first=120, second=118, amount=-1},
    {first=120, second=120, amount=3},
    {first=121, second=34, amount=3},
    {first=121, second=39, amount=2},
    {first=121, second=44, amount=-5},
    {first=121, second=45, amount=-5},
    {first=121, second=46, amount=-4},
    {first=121, second=58, amount=3},
    {first=121, second=63, amount=-1},
    {first=121, second=97, amount=-9},
    {first=121, second=98, amount=-1},
    {first=121, second=100, amount=1},
    {first=121, second=101, amount=1},
    {first=121, second=103, amount=-3},
    {first=121, second=105, amount=1},
    {first=121, second=106, amount=-5},
    {first=121, second=113, amount=-1},
    {first=121, second=118, amount=-1},
    {first=121, second=120, amount=2},
    {first=121, second=121, amount=1},
    {first=122, second=34, amount=1},
    {first=122, second=39, amount=2},
    {first=122, second=100, amount=-1},
    {first=122, second=111, amount=-2},
    {first=122, second=116, amount=-2},
    {first=122, second=120, amount=1},
    {first=122, second=121, amount=-1},
    }

return Font