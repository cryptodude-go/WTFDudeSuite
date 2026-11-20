local _, HP = ...
HP.routes, HP.mobObjectives = {}, {}
HP.dataRevision = 2

-- Independently authored, geographically grouped chapters. Level brackets are
-- recommendations, not a promise that a fixed quest set yields exact XP.
local function newRoute(id,title,races,maxLevel)
    local r={id=id,title=title,races=races,minLevel=1,maxLevel=maxLevel,
        revision=HP.dataRevision,source="Classic coordinates; Forever quest listings checked",
        steps={},compatibleInterface=16001}
    HP.routes[id]=r
    return r
end
local function add(r,action,id,section,hint,options)
    local s={action=action,questID=id,section=section,hint=hint}
    for k,v in pairs(options or {}) do s[k]=v end
    r.steps[#r.steps+1]=s
end
local function classPair(r,id,race,class,section)
    local opt={races={race},classes={class}}
    add(r,"accept",id,section,"Pick up your class introduction.",opt)
    add(r,"turnin",id,section,"Speak to your class trainer; learn available skills.",opt)
end
local function level(r,target,section,text,map,x,y)
    add(r,"level",nil,section,text,{targetLevel=target,mapID=map,x=x/100,y=y/100})
end

local r=newRoute("durotar","Durotar (1-10)",{"Orc","Troll"},10)
local a="Valley of Trials · Levels 1-2"
add(r,"accept",4641,a,"Kaltunk is beside the starting path.")
add(r,"turnin",4641,a,"Go west into the Den to find Gornek.")
add(r,"accept",788,a,"Begin with the nearby boars.")
add(r,"objective",788,a,"Hunt Mottled Boars around the central valley.",{mapID=1411,x=.435,y=.655})
add(r,"accept",790,a,"Hana'zua is on the northwest side of the valley.")
add(r,"objective",790,a,"Sarkoth is on the southwest rise. Loot his claw.",{mapID=1411,x=.405,y=.6683})
add(r,"turnin",790,a,"Return to Hana'zua.")
add(r,"accept",804,a,"Take Hana'zua's message back to the Den.")
add(r,"turnin",788,a,"Return to Gornek inside the Den.")
add(r,"turnin",804,a,"Deliver Hana'zua's message to Gornek.")
local b="Valley of Trials · Levels 2-4"
for _,v in ipairs({
    {2383,"Orc","WARRIOR"},{3065,"Troll","WARRIOR"},
    {3087,"Orc","HUNTER"},{3082,"Troll","HUNTER"},
    {3088,"Orc","ROGUE"},{3083,"Troll","ROGUE"},
    {3089,"Orc","SHAMAN"},{3084,"Troll","SHAMAN"},
    {3090,"Orc","WARLOCK"},{3085,"Troll","PRIEST"},{3086,"Troll","MAGE"},
}) do classPair(r,v[1],v[2],v[3],b) end
add(r,"accept",789,b,"Pick up the scorpid-tail quest from Gornek.")
add(r,"accept",4402,b,"Galgar is just north of the Den.")
add(r,"accept",792,b,"Zureetha is outside the Den.",{excludedClasses={"WARLOCK"}})
level(r,3,b,"If needed, finish nearby boars and scorpids to reach level 3.",1411,43.5,64)
add(r,"accept",5441,b,"Foreman Thazz'ril stands east of the Den.")
add(r,"objective",789,b,"Loot Scorpid Workers northwest of the camp.",{mapID=1411,x=.407,y=.63})
add(r,"objective",4402,b,"Gather cactus apples around the valley while doing the other objectives.",{mapID=1411,x=.43,y=.63})
add(r,"objective",5441,b,"Find SLEEPING peons near the valley edges. Awake peons do not count.",{mapID=1411,x=.4565,y=.657,useItemID=16114})
add(r,"objective",792,b,"Clear Vile Familiars near the northern cave entrance.",{mapID=1411,x=.441,y=.559,excludedClasses={"WARLOCK"}})
add(r,"turnin",789,b,"Return to Gornek.")
add(r,"turnin",4402,b,"Return to Galgar.")
add(r,"turnin",5441,b,"Return to Foreman Thazz'ril.")
add(r,"turnin",792,b,"Return to Zureetha.",{excludedClasses={"WARLOCK"}})
local c="Valley of Trials · Levels 4-6"
add(r,"accept",6394,c,"Pick up the missing-pick quest.")
add(r,"accept",794,c,"Pick up the medallion quest.",{excludedClasses={"WARLOCK"}})
add(r,"objective",6394,c,"Find the pick inside Burning Blade Coven. Clear a path in and out.")
add(r,"objective",794,c,"Defeat Yarrog Baneshadow deeper in the cave and loot the medallion.",{excludedClasses={"WARLOCK"}})
add(r,"turnin",6394,c,"Return to Foreman Thazz'ril.")
add(r,"turnin",794,c,"Return to Zureetha.",{excludedClasses={"WARLOCK"}})
add(r,"accept",805,c,"Take the road toward Sen'jin Village.",{excludedClasses={"WARLOCK"}})
add(r,"turnin",805,c,"Master Gadrin is in Sen'jin Village.",{excludedClasses={"WARLOCK"}})
local d="Sen'jin Village · Levels 5-8"
level(r,5,d,"Finish remaining Valley objectives or nearby mobs before picking up these quests.",1411,45,64)
add(r,"accept",817,d,"Vel'rin Fang stands in Sen'jin Village.")
add(r,"accept",818,d,"Speak to Master Vornal in the village.")
add(r,"accept",808,d,"Speak to Master Gadrin.")
add(r,"accept",826,d,"Pick up the Echo Isles objectives.")
add(r,"accept",823,d,"Take the report north to Razor Hill.")
add(r,"accept",2161,d,"Ukor is beside the road north of Sen'jin.")
add(r,"turnin",2161,d,"Deliver the burden to Innkeeper Grosk in Razor Hill.")
add(r,"turnin",823,d,"Find Orgnil Soulscar in Razor Hill.")
add(r,"accept",784,d,"Speak to Gar'Thok.")
add(r,"accept",791,d,"Find Furl Scornbrow in the watchtower.")
add(r,"objective",784,d,"Fight the sailors and marines at Tiragarde Keep. Find Benedict upstairs.",{mapID=1411,x=.59,y=.585})
add(r,"objective",791,d,"Loot canvas scraps while clearing Tiragarde Keep.",{mapID=1411,x=.59,y=.585})
add(r,"turnin",784,d,"Return to Gar'Thok in Razor Hill.")
add(r,"turnin",791,d,"Return to Furl Scornbrow.")
add(r,"accept",825,d,"Pick up the wreckage quest.")
level(r,6,d,"Finish the Tiragarde objectives or nearby hunting before taking the egg quest.",1411,59,58)
add(r,"accept",815,d,"Speak to Cook Torka in Razor Hill.")
add(r,"objective",825,d,"Search the coastal wrecks east of Tiragarde Keep.",{mapID=1411,x=.623,y=.575})
add(r,"objective",818,d,"Loot makrura and crawlers on the southern coast.",{mapID=1411,x=.594,y=.747})
local e="Echo Isles · Levels 8-10"
level(r,8,e,"Complete coastal objectives or hunt safely near Tiragarde before tackling the Echo Isles.",1411,59,58)
add(r,"objective",817,e,"Loot tigers on the Echo Isles.",{mapID=1411,x=.647,y=.846})
add(r,"objective",815,e,"Gather eggs near the taillashers on the islands.")
add(r,"objective",808,e,"Retrieve Minshina's skull from the ritual circle.")
add(r,"objective",826,e,"Defeat the trolls and Zalazane. Pull carefully; group up if needed.",{mapID=1411,x=.674,y=.86})
add(r,"turnin",817,e,"Return to Vel'rin Fang in Sen'jin.")
add(r,"turnin",818,e,"Return to Master Vornal.")
add(r,"turnin",808,e,"Return to Master Gadrin.")
add(r,"turnin",826,e,"Return to Master Gadrin.")
add(r,"turnin",825,e,"Return north to Gar'Thok.")
add(r,"turnin",815,e,"Return to Cook Torka.")
level(r,10,e,"Finish local quests or hunt suitable mobs to reach level 10. The next chapter is not bundled yet.",1411,59,58)

r=newRoute("mulgore","Mulgore (1-6)",{"Tauren"},6)
a="Camp Narache · Levels 1-3"
add(r,"accept",747,a,"Speak to Grull Hawkwind in Camp Narache.")
add(r,"accept",752,a,"Speak to Chief Hawkwind.")
add(r,"objective",747,a,"Hunt and loot Plainstriders around Camp Narache.")
add(r,"turnin",752,a,"Find Greatmother Hawkwind at the southeast well.")
add(r,"accept",753,a,"Pick up her follow-up.")
add(r,"objective",753,a,"Collect a water pitcher beside the well.")
add(r,"turnin",753,a,"Return to Chief Hawkwind.")
add(r,"turnin",747,a,"Return to Grull Hawkwind.")
for _,v in ipairs({{3091,"WARRIOR"},{3092,"HUNTER"},{3093,"SHAMAN"},{3094,"DRUID"}}) do classPair(r,v[1],"Tauren",v[2],a) end
add(r,"accept",750,a,"Pick up the cougar-pelt quest.")
add(r,"accept",755,a,"Visit Seer Graytongue in the hills south of camp.")
add(r,"objective",750,a,"Hunt Mountain Cougars along southern Red Cloud Mesa.")
add(r,"turnin",755,a,"Speak with Seer Graytongue.")
add(r,"accept",757,a,"Pick up the Bristleback-belt quest.")
add(r,"turnin",750,a,"Return to Grull Hawkwind.")
b="Red Cloud Mesa · Levels 3-6"
level(r,3,b,"Finish the southern hunting objectives to reach level 3.",1412,46,85)
add(r,"accept",780,b,"Pick up the battleboar quest.")
add(r,"accept",3376,b,"Find Brave Windfeather in Camp Narache.")
add(r,"objective",780,b,"Loot Battleboars before entering Brambleblade Ravine.")
add(r,"objective",757,b,"Loot Bristlebacks in the ravine for belts.")
add(r,"objective",3376,b,"Find Chief Sharptusk in the ravine and loot his head.")
add(r,"turnin",780,b,"Return to Grull Hawkwind.")
add(r,"turnin",757,b,"Return to Chief Hawkwind.")
add(r,"turnin",3376,b,"Return to Brave Windfeather.")
add(r,"accept",763,b,"Take the road north toward Bloodhoof Village.")
add(r,"turnin",763,b,"Deliver the totem to Baine Bloodhoof.")
level(r,6,b,"Complete remaining Mesa quests or nearby hunting to reach level 6. The next chapter is not bundled yet.",1412,47.5,60.2)

r=newRoute("tirisfal","Tirisfal Glades (1-6)",{"Scourge"},6)
a="Deathknell · Levels 1-3"
add(r,"accept",363,a,"Speak to Undertaker Mordo in the crypt.")
add(r,"turnin",363,a,"Leave the crypt and find Shadow Priest Sarvis in the chapel.")
add(r,"accept",364,a,"Pick up the zombie objectives.")
add(r,"objective",364,a,"Clear the zombies around Deathknell.")
add(r,"turnin",364,a,"Return to Shadow Priest Sarvis.")
for _,v in ipairs({{3095,"WARRIOR"},{3096,"ROGUE"},{3097,"PRIEST"},{3098,"MAGE"},{3099,"WARLOCK"}}) do classPair(r,v[1],"Scourge",v[2],a) end
add(r,"accept",3901,a,"Pick up the skeleton quest.")
add(r,"accept",376,a,"Speak to Novice Elreth.")
add(r,"objective",376,a,"Loot wolves and bats outside Deathknell.")
add(r,"objective",3901,a,"Clear Rattlecage Skeletons around the village.")
add(r,"turnin",376,a,"Return to Novice Elreth.")
add(r,"turnin",3901,a,"Return to Shadow Priest Sarvis.")
b="Deathknell · Levels 3-6"
add(r,"accept",3902,b,"Speak to Deathguard Saltain.")
add(r,"accept",380,b,"Speak to Executor Arren.")
add(r,"objective",3902,b,"Gather the supply crates around Deathknell.")
add(r,"objective",380,b,"Clear the spiders at Night Web's Hollow northwest of the village.")
add(r,"turnin",3902,b,"Return to Deathguard Saltain.")
add(r,"turnin",380,b,"Return to Executor Arren.")
add(r,"accept",381,b,"Pick up the Scarlet armband quest.")
add(r,"objective",381,b,"Loot Scarlet Converts and Initiates east of Deathknell.")
add(r,"turnin",381,b,"Return to Executor Arren.")
add(r,"accept",382,b,"Pick up the messenger quest.")
add(r,"objective",382,b,"Defeat Meven Korgal at the Scarlet camp and loot the documents.")
add(r,"turnin",382,b,"Return to Executor Arren.")
add(r,"accept",383,b,"Take the road out toward Brill.")
add(r,"turnin",383,b,"Find Executor Zygand in Brill.")
level(r,6,b,"Complete remaining Deathknell quests or suitable hunting to reach level 6. The next chapter is not bundled yet.",1420,32,64)

-- Build the possible-loot/kill index only from the quests used by these routes.
local used={}
for _,route in pairs(HP.routes) do
    for _,step in ipairs(route.steps) do if step.questID then used[step.questID]=true end end
end
for questID in pairs(used) do
    local quest=HP.questData[questID]
    for index,goal in ipairs(quest.goals or {}) do
        local mobs=goal.kind=="kill" and {goal.id} or
            (goal.kind=="item" and HP.itemData[goal.id] and HP.itemData[goal.id].mobs or {})
        for _,mobID in ipairs(mobs) do
            HP.mobObjectives[mobID]=HP.mobObjectives[mobID] or {}
            HP.mobObjectives[mobID][#HP.mobObjectives[mobID]+1]={
                questID=questID,objectiveIndex=index,
                itemID=goal.kind=="item" and goal.id or nil,
                targetID=goal.id,kind=goal.kind,
            }
        end
    end
end

