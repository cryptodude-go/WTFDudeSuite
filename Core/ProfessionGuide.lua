local _,HP=...
local read=HP.ReadGuideAPI
local function number(value,fallback)
 return type(value)=='number' and value==value and value>=0 and value<10000000 and value or fallback
end
local function clean(value) return tostring(value or ''):lower():gsub('[%s%p]','') end
local function itemName(id)
 return read(C_Item and C_Item.GetItemNameByID,id) or read(GetItemInfo,id) or HP.professionItems[id] or ('Item '..tostring(id))
end
function HP.ProfessionSkills()
 local now=read(GetTime) or 0
 if HP.profSkillCache and now-HP.profSkillCache.at<2 then return HP.profSkillCache.data end
 local result={};local slots={read(GetProfessions)}
 -- GetProfessions may leave the primary slots nil while secondary skills exist.
 for i=1,6 do local index=slots[i];if index then
  local name,_,rank,maximum,_,_,skillID=read(GetProfessionInfo,index)
  if name and number(rank) then result[skillID or name]={name=name,rank=rank,maximum=number(maximum,300)} end
 end end
 for i=1,math.min(500,number(read(GetNumSkillLines),0)) do
  local name,header,_,rank,_,_,maximum=read(GetSkillLineInfo,i)
  if name and not header and number(rank) then for key,b in pairs(HP.professionBooks) do
   local localized=read(C_Spell and C_Spell.GetSpellName,b.spellID) or read(GetSpellInfo,b.spellID)
   if name==key or name==localized then result[b.skillID]={name=name,rank=rank,maximum=number(maximum,300)} end
  end end
 end
 HP.profSkillCache={at=now,data=result};return result
end
local function recipeMatch(name,id,link,fact)
 local linked=type(link)=='string' and tonumber(link:match('enchant:(%d+)') or link:match('spell:(%d+)'))
 local localized=read(C_Spell and C_Spell.GetSpellName,fact.id) or read(GetSpellInfo,fact.id)
 return id==fact.id or linked==fact.id or (type(name)=='string' and name~='' and (clean(name)==clean(fact.name) or (type(localized)=='string' and localized~='' and clean(name)==clean(localized))))
end
function HP.OpenRecipeData(recipe)
 local fact=HP.professionRecipes[recipe];if not fact then return end
 local now=read(GetTime) or 0
 if not HP.openRecipeCache or now-HP.openRecipeCache.at>1 then HP.openRecipeCache={at=now,items={}} end
 local cached=HP.openRecipeCache.items[fact.id];if cached~=nil then return cached or nil end
 local found;local ids=read(C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs)
 if type(ids)=='table' then for i,id in ipairs(ids) do if i>2000 then break end
  local info=read(C_TradeSkillUI.GetRecipeInfo,id)
  if info and recipeMatch(info.name,id,nil,fact) then
   found={name=info.name,recipeID=id,learned=info.learned,link=read(C_TradeSkillUI.GetRecipeLink,id),reagents={},kind=info.difficulty}
   local schematic=read(C_TradeSkillUI.GetRecipeSchematic,id,false)
   for _,slot in ipairs(schematic and schematic.reagentSlotSchematics or {}) do
    if slot.required~=false and number(slot.quantityRequired,0)>0 then
     local choices={};for _,v in ipairs(slot.reagents or {}) do if v.itemID then choices[#choices+1]=v.itemID end end
     if #choices>0 then local names={};for _,item in ipairs(choices) do names[#names+1]=itemName(item) end
      found.reagents[#found.reagents+1]={itemID=#choices==1 and choices[1] or nil,name=table.concat(names,' / '),count=slot.quantityRequired,alternatives=#choices>1}
     end
    end
   end
   break
  end
 end end
 -- An empty/filtered modern list must not suppress the legacy trade/craft APIs.
 if not found then for _,craft in ipairs({false,true}) do
  for i=1,math.min(2000,number(read(craft and GetNumCrafts or GetNumTradeSkills),0)) do
   local name,second,third=read(craft and GetCraftInfo or GetTradeSkillInfo,i);local kind=craft and third or second
   local link=kind~='header' and read(craft and GetCraftRecipeLink or GetTradeSkillRecipeLink,i)
   if kind~='header' and name and recipeMatch(name,nil,link,fact) then
    found={name=name,recipeID=fact.id,learned=true,link=link,reagents={},kind=kind}
    for j=1,math.min(20,number(read(craft and GetCraftNumReagents or GetTradeSkillNumReagents,i),0)) do
     local n,_,count=read(craft and GetCraftReagentInfo or GetTradeSkillReagentInfo,i,j)
     local reagentLink=read(craft and GetCraftReagentItemLink or GetTradeSkillReagentItemLink,i,j)
     local itemID=type(reagentLink)=='string' and tonumber(reagentLink:match('item:(%d+)')) or nil
     if not itemID then for _,r in ipairs(fact.reagents) do if clean(n)==clean(itemName(r[1])) or clean(n)==clean(HP.professionItems[r[1]]) then itemID=r[1];break end end end
     found.reagents[#found.reagents+1]={itemID=itemID,name=n or itemName(itemID),count=number(count,1)}
    end
    break
   end
  end
  if found then break end
 end end
 if found then local text={};for _,r in ipairs(found.reagents) do text[#text+1]=r.count..' '..r.name end;found.materials=table.concat(text,', ') end
 HP.knownProfessionRecipes=HP.knownProfessionRecipes or {}
 if found and found.learned then HP.knownProfessionRecipes[fact.id]=found end
 if not found then found=HP.knownProfessionRecipes[fact.id] end
 HP.openRecipeCache.items[fact.id]=found or false;return found
end
function HP.ProfessionEstimate(recipe,rank,target,maximum)
 local fact=HP.professionRecipes[recipe];if not fact then return end
 local live=HP.OpenRecipeData(recipe);local stop=math.min(target,maximum or 300,300)
 local result={fact=fact,live=live,rank=rank,target=stop,requested=target,minimum=math.max(0,stop-rank),source=HP.professionRecipeSources[recipe] or 'Learn this recipe from a profession trainer.'}
 -- Approximate skill-up curve. This is a shopping estimate, never an exact RNG promise.
 local expected=0
 if live and live.kind=='trivial' then result.blocked='This recipe is gray in your client; it cannot grant skill.'
 elseif stop>fact.gray then result.blocked='This reference recipe becomes gray before the target. Check the client recipe.'
 else
  for skill=rank,stop-1 do
   local chance=skill<fact.yellow and 1 or (fact.gray-skill)/math.max(1,fact.gray-fact.yellow)
   if chance<=0 then result.blocked='This recipe cannot grant the next skill point.';break end
   expected=expected+1/math.min(1,chance)
  end
 end
 if not result.blocked then
  result.crafts=math.ceil(expected);result.buffer=expected>result.minimum+.01 and math.max(result.crafts,math.ceil(expected*1.2)) or result.crafts
 end
 result.reagents={};local materials=live and live.reagents and #live.reagents>0 and live.reagents
 if not materials then materials={};for _,r in ipairs(fact.reagents) do materials[#materials+1]={itemID=r[1],name=itemName(r[1]),count=r[2]} end end
 for _,r in ipairs(materials) do
  local count=number(r.count,1);local owned=r.itemID and number(read(C_Item and C_Item.GetItemCount or GetItemCount,r.itemID,false,false)) or nil
  local total=result.crafts and result.crafts*count;local buffered=result.buffer and result.buffer*count
  result.reagents[#result.reagents+1]={itemID=r.itemID,name=r.name,count=count,owned=owned,total=total,buffered=buffered,missing=owned and total and math.max(0,total-owned),missingBuffered=owned and buffered and math.max(0,buffered-owned),alternatives=r.alternatives}
 end
 result.usesLiveMaterials=materials== (live and live.reagents)
 return result
end
function HP.ProfessionMaterialText(r)
 local total=r.total and (r.total==r.buffered and tostring(r.total) or (r.total..'–'..r.buffered)) or '?'
 local missing=r.missing and (r.missing==r.missingBuffered and tostring(r.missing) or (r.missing..'–'..r.missingBuffered)) or '?'
 local bags=r.owned and (' · bags '..r.owned..' · need ~'..missing) or (r.alternatives and ' · choose one reagent' or ' · bag count unavailable')
 return r.name..': ~'..total..bags
end
function HP.ShowProfessionRecipeTooltip(owner,estimate)
 if not GameTooltip or not estimate then return end
 local fact=estimate.fact;GameTooltip:SetOwner(owner,'ANCHOR_RIGHT')
 local link=estimate.live and estimate.live.link or (fact.patternID and 'item:'..fact.patternID) or 'spell:'..fact.id
 local ok=type(GameTooltip.SetHyperlink)=='function' and pcall(GameTooltip.SetHyperlink,GameTooltip,link)
 if not ok then GameTooltip:SetText(fact.name) end
 GameTooltip:AddLine('Recipe: '..fact.name,1,.82,.3,true)
 GameTooltip:AddLine(estimate.source,.85,.85,.8,true)
 if estimate.blocked then GameTooltip:AddLine(estimate.blocked,1,.25,.2,true)
 else
  local count=estimate.crafts==estimate.buffer and tostring(estimate.crafts) or (estimate.crafts..'–'..estimate.buffer)
  GameTooltip:AddLine('Skill '..estimate.rank..' → '..estimate.target..' · ~'..count..' crafts',.4,1,.55,true)
  if estimate.target<estimate.requested then GameTooltip:AddLine('Train past '..estimate.target..' before continuing to '..estimate.requested..'.',1,.8,.3,true) end
 end
 GameTooltip:AddLine('Materials per craft / approximate total',1,1,1,true)
 for _,r in ipairs(estimate.reagents) do
  GameTooltip:AddLine(HP.ProfessionMaterialText(r)..' · '..r.count..'/craft',.85,.9,1,true)
 end
 for _,id in ipairs(fact.tools or {}) do GameTooltip:AddLine('Tool: '..itemName(id)..' (not consumed)',.85,.85,.8,true) end
 GameTooltip:AddLine(estimate.usesLiveMaterials and 'Materials read from your profession window.' or 'Classic reference materials; open your profession to check Forever recipe changes.',.7,.7,.7,true)
 GameTooltip:AddLine('Upper estimate includes 20% spare for yellow/green skill-ups. Stop at the target. It can take more.',.7,.7,.7,true)
 GameTooltip:Show()
end
local gatherChoices={
 Herbalism={
  [115]={{115,'Wild Steelbloom'},{120,'Grave Moss'},{125,'Kingsblood'},{150,'Liferoot'}},
  [170]={{160,'Fadeleaf'},{170,'Goldthorn'},{185,"Khadgar’s Whisker"}},
  [205]={{205,'Firebloom'},{210,'Purple Lotus'}},
  [230]={{230,'Sungrass'},{210,'Purple Lotus'},{260,'Golden Sansam'}},
  [270]={{270,'Dreamfoil'},{280,'Mountain Silversage'},{290,'Icecap'}}},
 Mining={
  [65]={{65,'Tin Vein'},{75,'Silver Vein'}},
  [125]={{125,'Iron Deposit'},{155,'Gold Vein'}},
  [175]={{175,'Mithril Deposit'},{230,'Truesilver Deposit'}}}}
function HP.ProfessionTask(name)
 if HP.Suite and not HP.Suite:ProfessionAllowed(name) then return end
 if not HP.professionBooks[name] then name='Herbalism' end
 local b=HP.professionBooks[name];local skill=HP.ProfessionSkills()[b.skillID];local rank=skill and skill.rank or 0;local step,index
 for i,v in ipairs(b.steps) do if rank<v.to then step=v;index=i;break end end
 local task={book=b,rank=rank,maximum=skill and skill.maximum or 75,step=step,index=index or #b.steps,rows={},percent=math.min(1,math.max(0,rank/300))}
 if not skill then task.training=true;task.rows[1]={kind='info',text='Learn '..name..' from a trainer.',tooltipText='Ask a city guard for the profession trainer.'}
 elseif rank>=300 then task.complete=true;task.rows[1]={kind='info',text=name..' reached 300.'}
 elseif rank>=task.maximum then
  task.training=true;task.rows[1]={kind='info',text=HP.professionTraining[name] and HP.professionTraining[name][task.maximum] or ('Learn '..(task.maximum==75 and 'Journeyman ' or task.maximum==150 and 'Expert ' or 'Artisan ')..name..' from a trainer.'),tooltipText='Your live skill cap has been reached. Train the next rank before crafting further.'}
 elseif step and step.gather then
  task.rows={{kind='travel',text='Go to '..step.zone..'.',tooltipText='Suggested surface corridor. It does not locate live nodes or avoid obstacles.'},{kind='objective',text=step.recipe..' until skill '..step.to..'.',tooltipText='Gather nodes your live skill permits. Skill gains advance the guide.'}}
  local points=HP.gatherLoops[step.mapID];if points and points[1] then task.location={mapID=step.mapID,x=points[1][1],y=points[1][2]} end
 end
 if task.complete then task.percent=1 end
 if task.training or task.complete or not task.step then return task end
 local s=task.step
 if s.gather then
  local choices=gatherChoices[name] and gatherChoices[name][s.from]
  if choices then local available={};local all={}
   for _,v in ipairs(choices) do all[#all+1]=v[2]..' '..v[1];if task.rank>=v[1] then available[#available+1]=v[2] end end
   task.rows[2].text=table.concat(available,' / ')..' until skill '..s.to..'.';task.rows[2].tooltipText='Required skill: '..table.concat(all,', ')..'. Gather only nodes your live skill permits.'
  end
  if name=='Fishing' then
   local spots={[1412]={.47,.60},[1413]={.45,.22},[1443]={.25,.76},[1444]={.44,.42}};local p=spots[s.mapID]
   task.fishing=true;task.location=p and {mapID=s.mapID,x=p[1],y=p[2]} or nil
   task.rows[1].tooltipText='Fish at a suitable shoreline. This is a suggested fishing spot, not a land farming circuit.'
  end
  return task
 end
 local estimate=HP.ProfessionEstimate(s.recipe,task.rank,s.to,task.maximum);task.recipeGuide=estimate;task.rows={}
 if not estimate then task.rows[1]={kind='info',text='Open '..name..' to check the next recipe.'};return task end
 task.rows[1]={kind='objective',text=(name=='Enchanting' and s.recipe:find('^Enchant ') and 'Apply ' or 'Craft ')..s.recipe..' until '..estimate.target..'.',recipeGuide=estimate}
 if estimate.blocked then task.rows[2]={kind='info',text=estimate.blocked,recipeGuide=estimate}
 else
  local count=estimate.crafts==estimate.buffer and tostring(estimate.crafts) or (estimate.crafts..'–'..estimate.buffer)
  task.rows[2]={kind='info',text='~'..count..' crafts · hover for recipe & materials.',recipeGuide=estimate}
 end
 if estimate.live and estimate.live.learned==false then task.rows[#task.rows+1]={kind='info',text='Learn this recipe first.',recipeGuide=estimate} end
 return task
end
