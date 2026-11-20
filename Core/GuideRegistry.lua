local _,HP=...
HP.DingSource={}
HP.guideLibrary,HP.libraryOrder={},{}
HP.DingGuideAdapter={RegisterGuide=function(g)
 assert(type(g)=='table' and type(g.id)=='string' and type(g.steps)=='table','Invalid guide definition')
 assert(not HP.guideLibrary[g.id],'Duplicate guide id: '..g.id)
 g.category=({['ding-zones']='zones',['ding-class']='class',['ding-dungeons']='dungeon',['ding-items']='items'})[g.pack] or 'leveling'
 HP.guideLibrary[g.id]=g;HP.libraryOrder[#HP.libraryOrder+1]=g.id
end}
local function member(values,value)
 if not values then return true end
 if type(values)~='table' then values={values} end
 if value=='Undead' then value='Scourge' end
 for _,v in ipairs(values) do if v==value or v=='Undead' and value=='Scourge' then return true end end
 return false
end
function HP.LibraryMatches(def)
 local c=HP.character or HP.DetectCharacter()
 local side=HP.Call(UnitFactionGroup,'player')
 return (not def.faction or def.faction==side) and member(def.races,c.race) and member(def.classes,c.class)
end
function HP.LibraryIds(value) if type(value)=='table' then return value elseif type(value)=='number' then return {value} else return {} end end
function HP.LibraryItems(value)
 if type(value)=='number' then return {{value,1}} end
 if type(value)~='table' then return {} end
 if type(value[1])=='table' then return value end
 if #value==2 and type(value[2])=='number' and value[2]<1000 then return {value} end
 local out={};for _,id in ipairs(value) do out[#out+1]={id,1} end;return out
end
function HP.LibraryConditions(when)
 if type(when)~='table' then return true end
 for _,id in ipairs(HP.LibraryIds(when.done)) do if not HP.Completed(id) then return false end end
 for _,id in ipairs(HP.LibraryIds(when.notdone)) do if HP.Completed(id) then return false end end
 for _,id in ipairs(HP.LibraryIds(when.log)) do if not HP.Active(id) then return false end end
 for _,id in ipairs(HP.LibraryIds(when.notlog)) do if HP.Active(id) then return false end end
 for _,id in ipairs(HP.LibraryIds(when.ready)) do if not HP.Active(id) or not HP.Done({action='objective',questID=id}) then return false end end
 for _,item in ipairs(HP.LibraryItems(when.item)) do if HP.ItemCount(item[1])<(item[2] or 1) then return false end end
 for _,id in ipairs(HP.LibraryIds(when.noitem)) do if HP.ItemCount(id)>0 then return false end end
 local level=HP.character and HP.character.level or 1
 return (not when.minlevel or level>=when.minlevel) and (not when.maxlevel or level<=when.maxlevel)
end
