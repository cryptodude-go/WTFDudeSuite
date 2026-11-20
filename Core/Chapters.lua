local _,HP=...
HP.chapterList={{id="chapter_01",minLevel=1,maxLevel=12,areaID=14,name="Durotar",number=1},{id="chapter_02",minLevel=1,maxLevel=12,areaID=215,name="Mulgore",number=2},{id="chapter_03",minLevel=1,maxLevel=12,areaID=85,name="Tirisfal Glades",number=3},{id="chapter_04",minLevel=12,maxLevel=15,areaID=17,name="Barrens",number=4},{id="chapter_05",minLevel=15,maxLevel=16,areaID=406,name="Stonetalon Mountains",number=5},{id="chapter_06",minLevel=16,maxLevel=20,areaID=17,name="Barrens",number=6},{id="chapter_07",minLevel=20,maxLevel=21,areaID=406,name="Stonetalon Mountains",number=7},{id="chapter_08",minLevel=22,maxLevel=23,areaID=17,name="Southern Barrens",number=8},{id="chapter_09",minLevel=23,maxLevel=25,areaID=406,name="Stonetalon Mountains",number=9},{id="chapter_10",minLevel=25,maxLevel=25,areaID=17,name="Southern Barrens",number=10},{id="chapter_11",minLevel=25,maxLevel=26,areaID=400,name="Thousand Needles",number=11},{id="chapter_12",minLevel=26,maxLevel=27,areaID=331,name="Ashenvale",number=12},{id="chapter_13",minLevel=27,maxLevel=28,areaID=406,name="Stonetalon Mountains",number=13},{id="chapter_14",minLevel=28,maxLevel=29,areaID=400,name="Thousand Needles",number=14},{id="chapter_15",minLevel=29,maxLevel=30,areaID=267,name="Hillsbrad Foothills",number=15},{id="chapter_16",minLevel=30,maxLevel=30,areaID=45,name="Arathi Highlands",number=16},{id="chapter_17",minLevel=30,maxLevel=31,areaID=33,name="Stranglethorn Vale",number=17},{id="chapter_18",minLevel=31,maxLevel=32,areaID=400,name="Shimmering Flats",number=18},{id="chapter_19",minLevel=32,maxLevel=34,areaID=405,name="Desolace",number=19},{id="chapter_20",minLevel=34,maxLevel=36,areaID=33,name="Stranglethorn Vale",number=20},{id="chapter_21",minLevel=36,maxLevel=37,areaID=45,name="Arathi Highlands",number=21},{id="chapter_22",minLevel=37,maxLevel=37,areaID=36,name="Alterac Mountains",number=22},{id="chapter_23",minLevel=37,maxLevel=38,areaID=400,name="Thousand Needles",number=23},{id="chapter_24",minLevel=38,maxLevel=38,areaID=15,name="Dustwallow Marsh",number=24},{id="chapter_25",minLevel=38,maxLevel=40,areaID=33,name="Stranglethorn Vale",number=25},{id="chapter_26",minLevel=40,maxLevel=41,areaID=3,name="Badlands",number=26},{id="chapter_27",minLevel=41,maxLevel=42,areaID=8,name="Swamp of Sorrows",number=27},{id="chapter_28",minLevel=42,maxLevel=43,areaID=33,name="Stranglethorn Vale",number=28},{id="chapter_29",minLevel=43,maxLevel=44,areaID=15,name="Dustwallow Marsh",number=29},{id="chapter_30",minLevel=44,maxLevel=44,areaID=405,name="Desolace",number=30},{id="chapter_31",minLevel=44,maxLevel=45,areaID=440,name="Tanaris",number=31},{id="chapter_32",minLevel=45,maxLevel=46,areaID=357,name="Feralas",number=32},{id="chapter_33",minLevel=47,maxLevel=47,areaID=47,name="Hinterlands",number=33},{id="chapter_34",minLevel=47,maxLevel=47,areaID=33,name="Stranglethorn Vale",number=34},{id="chapter_35",minLevel=47,maxLevel=48,areaID=51,name="Searing Gorge",number=35},{id="chapter_36",minLevel=48,maxLevel=49,areaID=8,name="Swamp of Sorrows",number=36},{id="chapter_37",minLevel=49,maxLevel=49,areaID=15,name="Dustwallow Marsh",number=37},{id="chapter_38",minLevel=49,maxLevel=50,areaID=440,name="Tanaris",number=38},{id="chapter_39",minLevel=50,maxLevel=50,areaID=16,name="Azshara",number=39},{id="chapter_40",minLevel=50,maxLevel=51,areaID=47,name="Hinterlands",number=40},{id="chapter_41",minLevel=51,maxLevel=51,areaID=4,name="Blasted Lands",number=41},{id="chapter_42",minLevel=51,maxLevel=53,areaID=490,name="Un'Goro Crater",number=42},{id="chapter_43",minLevel=53,maxLevel=53,areaID=46,name="Burning Steppes",number=43},{id="chapter_44",minLevel=53,maxLevel=54,areaID=16,name="Azshara",number=44},{id="chapter_45",minLevel=54,maxLevel=54,areaID=361,name="Felwood",number=45},{id="chapter_46",minLevel=54,maxLevel=55,areaID=618,name="Winterspring",number=46},{id="chapter_47",minLevel=55,maxLevel=56,areaID=361,name="Felwood",number=47},{id="chapter_48",minLevel=56,maxLevel=56,areaID=28,name="Western Plaguelands",number=48},{id="chapter_49",minLevel=56,maxLevel=57,areaID=139,name="Eastern Plaguelands",number=49},{id="chapter_50",minLevel=57,maxLevel=58,areaID=28,name="Western Plaguelands",number=50},{id="chapter_51",minLevel=58,maxLevel=59,areaID=1377,name="Silithus",number=51},{id="chapter_52",minLevel=59,maxLevel=60,areaID=618,name="Winterspring",number=52}}

for _,chapter in ipairs(HP.chapterList) do
    local source=HP.routes['zone_'..chapter.areaID]
    if source then
        local route={id=chapter.id,title=chapter.minLevel..'-'..chapter.maxLevel..' '..chapter.name,zone=chapter.name,minLevel=chapter.minLevel,maxLevel=chapter.maxLevel,mapID=source.mapID,catalog=true,chapter=true,chapterNumber=chapter.number,revision=2,steps={},description='Level-bracket chapter using our original quest planner. The supplied zone order is a reference; exact speedrun steps and subzone paths are not verified.',source=source.source}
        for _,step in ipairs(source.steps) do
            local q=HP.questData[step.questID];local level=q and (q.level or q.minLevel or 1) or 1
            if level>=chapter.minLevel-2 and level<=chapter.maxLevel+3 then route.steps[#route.steps+1]=step end
        end
        HP.routes[chapter.id]=route
    end
end
function HP.ReputationValue(id)
    local data=HP.Call(C_Reputation and C_Reputation.GetFactionDataByID,id)
    if type(data)=='table' and HP.Public(data.currentStanding) and type(data.currentStanding)=='number' then return data.currentStanding end
    if GetFactionInfoByID then
        local ok,a,b,c,d,e,f=pcall(GetFactionInfoByID,id)
        if ok and HP.Public(f) and type(f)=='number' then return f end
    end
end
local score=HP.CandidateScore
function HP.CandidateScore(step)
    local q=HP.questData[step.questID]
    if q and not HP.Active(step.questID) then
        for _,rule in ipairs({{q.requiredMinRep,true},{q.requiredMaxRep,false}}) do
            local gate=rule[1]
            if gate and #gate>=2 then local value=HP.ReputationValue(gate[1]);if not value or (rule[2] and value<gate[2]) or (not rule[2] and value>=gate[2]) then return end end
        end
    end
    return score(step)
end
local location=HP.StepLocation
function HP.StepLocation(step)
    local fallback=location(step)
    if step.action~='quest' then return fallback end
    local phase=HP.QuestStepPhase(step);local q=HP.questData[step.questID]
    if not q then return fallback end
    local points={}
    local function add(entity) for _,p in ipairs(entity and entity.spawns or {}) do points[#points+1]=p end end
    if phase.action=='accept' then add(HP.npcData[q.start]);add(HP.objectData[q.startObject])
    elseif phase.action=='turnin' then add(HP.npcData[q.finish]);add(HP.objectData[q.finishObject])
    else
        local objectives=HP.Objectives(step.questID)
        for i,goal in ipairs(q.goals or {}) do
            local o=objectives[i]
            if not o or not o.finished then
                if goal.kind=='item' then local item=HP.itemData[goal.id];for _,id in ipairs(item and item.objects or {}) do add(HP.objectData[id]) end;for _,id in ipairs(item and item.mobs or {}) do add(HP.npcData[id]) end
                else add(HP.Entity(goal.kind,goal.id)) end
                break
            end
        end
    end
    local best,distance=fallback,math.huge
    for _,p in ipairs(points) do local x,y=HP.NavigationVector(p);if x then local d=x*x+y*y;if d<distance then best,distance=p,d end end end
    return best
end
