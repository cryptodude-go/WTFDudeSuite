local _,HP=...
-- Independently selected factual skill bands; live skill gains drive progress.
HP.professionBooks={}
local function book(name,id,spell,rows,gather)
 local b={name=name,skillID=id,spellID=spell,steps={},gather=gather};HP.professionBooks[name]=b
 for _,r in ipairs(rows) do b.steps[#b.steps+1]={from=r[1],to=r[2],recipe=r[3],zone=r[4],mapID=r[5],gather=gather} end
end
book('Alchemy',171,2259,{{1,60,'Minor Healing Potion'},{60,110,'Lesser Healing Potion'},{110,140,'Healing Potion'},{140,155,'Lesser Mana Potion'},{155,185,'Greater Healing Potion'},{185,210,'Elixir of Agility'},{210,215,'Elixir of Greater Defense'},{215,230,'Superior Healing Potion'},{230,265,'Elixir of Detect Undead'},{265,285,'Superior Mana Potion'},{285,300,'Major Healing Potion'}})
book('Blacksmithing',164,2018,{{1,30,'Rough Sharpening Stone'},{30,65,'Rough Grinding Stone'},{65,75,'Coarse Sharpening Stone'},{75,90,'Coarse Grinding Stone'},{90,100,'Runed Copper Belt'},{100,105,'Silver Rod'},{105,110,'Runed Copper Belt'},{110,125,'Rough Bronze Leggings'},{125,140,'Heavy Grinding Stone'},{140,150,'Patterned Bronze Bracers'},{150,155,'Golden Rod'},{155,165,'Green Iron Leggings'},{165,190,'Green Iron Bracers'},{190,200,'Golden Scale Bracers'},{200,210,'Solid Grinding Stone'},{210,225,'Heavy Mithril Gauntlet'},{225,235,'Steel Plate Helm'},{235,250,'Mithril Coif'},{250,260,'Dense Sharpening Stone'},{260,265,'Heavy Mithril Boots'},{265,270,'Imperial Plate Belt'},{270,295,'Imperial Plate Bracers'},{295,300,'Imperial Plate Boots'}})
book('Engineering',202,4036,{{1,30,'Rough Blasting Powder'},{30,50,'Handful of Copper Bolts'},{50,51,'Arclight Spanner'},{51,75,'Rough Copper Bomb'},{75,90,'Coarse Blasting Powder'},{90,100,'Coarse Dynamite'},{100,105,'Silver Contact'},{105,125,'Bronze Tube'},{125,135,'Standard Scope'},{135,150,'Whirring Bronze Gizmo'},{150,160,'Bronze Framework'},{160,175,'Explosive Sheep'},{175,194,'Solid Blasting Powder'},{194,195,'Gyromatic Micro-Adjustor'},{195,200,'Mithril Tube'},{200,215,'Unstable Trigger'},{215,238,'Mithril Casing'},{238,250,'Hi-Explosive Bomb'},{250,260,'Dense Blasting Powder'},{260,285,'Thorium Widget'},{285,300,'Thorium Tube'}})
book('Leatherworking',165,2108,{{1,45,'Light Armor Kit'},{45,55,'Handstitched Leather Cloak'},{55,100,'Embossed Leather Gloves'},{100,125,'Fine Leather Belt'},{125,137,'Dark Leather Boots'},{137,150,'Dark Leather Pants'},{150,155,'Heavy Leather'},{155,180,'Heavy Armor Kit'},{180,200,'Barbaric Leggings'},{200,205,'Thick Armor Kit'},{205,235,'Nightscape Headband'},{235,250,'Nightscape Pants'},{250,260,'Nightscape Boots'},{260,290,'Wicked Leather Gauntlets'},{290,300,'Runic Leather Headband'}})
book('Tailoring',197,3908,{{1,45,'Bolt of Linen Cloth'},{45,70,'Linen Belt'},{70,75,'Reinforced Linen Cape'},{75,100,'Bolt of Woolen Cloth'},{100,110,'Simple Kilt'},{110,125,'Double-stitched Woolen Shoulders'},{125,145,'Bolt of Silk Cloth'},{145,160,'Azure Silk Hood'},{160,170,'Silk Headband'},{170,175,'Formal White Shirt'},{175,185,'Bolt of Mageweave'},{185,205,'Crimson Silk Vest'},{205,215,'Crimson Silk Pantaloons'},{215,220,'Orange Mageweave Shirt'},{220,230,'Black Mageweave Gloves'},{230,250,'Black Mageweave Headband'},{250,260,'Bolt of Runecloth'},{260,280,'Runecloth Belt'},{280,290,'Runecloth Bag'},{290,300,'Runecloth Gloves'}})
book('Enchanting',333,7411,{{1,2,'Runed Copper Rod'},{2,90,'Enchant Bracer - Minor Health'},{90,100,'Enchant Bracer - Minor Stamina'},{100,101,'Runed Silver Rod'},{101,110,'Greater Magic Wand'},{110,135,'Enchant Cloak - Minor Agility'},{135,155,'Enchant Bracer - Lesser Stamina'},{155,156,'Runed Golden Rod'},{156,185,'Enchant Bracer - Lesser Strength'},{185,200,'Enchant Bracer - Strength'},{200,201,'Runed Truesilver Rod'},{201,220,'Enchant Bracer - Strength'},{220,225,'Enchant Cloak - Greater Defense'},{225,230,'Enchant Gloves - Agility'},{230,235,'Enchant Boots - Stamina'},{235,250,'Enchant Chest - Superior Health'},{250,265,'Lesser Mana Oil'},{265,294,'Enchant Shield - Greater Stamina'},{294,295,'Runed Arcanite Rod'},{295,300,'Enchant Cloak - Superior Defense'}})
book('Cooking',185,2550,{{1,50,'Charred Wolf Meat'},{50,100,'Longjaw Mud Snapper'},{100,130,'Bristle Whisker Catfish'},{130,175,'Curiously Tasty Omelet'},{175,225,'Roast Raptor'},{225,250,'Monster Omelet'},{250,275,'Poached Sunscale Salmon'},{275,300,'Lobster Stew'}})
book('First Aid',129,3273,{{1,40,'Linen Bandage'},{40,80,'Heavy Linen Bandage'},{80,115,'Wool Bandage'},{115,150,'Heavy Wool Bandage'},{150,180,'Silk Bandage'},{180,210,'Heavy Silk Bandage'},{210,240,'Mageweave Bandage'},{240,260,'Heavy Mageweave Bandage'},{260,290,'Runecloth Bandage'},{290,300,'Heavy Runecloth Bandage'}})
book('Herbalism',182,2366,{{1,70,'Peacebloom / Silverleaf','Mulgore',1412},{70,115,'Mageroyal / Briarthorn','The Barrens',1413},{115,170,'Bruiseweed / Kingsblood','Hillsbrad Foothills',1424},{170,205,'Fadeleaf / Goldthorn','Arathi Highlands',1417},{205,230,'Firebloom / Purple Lotus','Tanaris',1446},{230,270,'Sungrass / Golden Sansam','The Hinterlands',1425},{270,300,'Dreamfoil / Mountain Silversage','Winterspring',1452}},true)
book('Mining',186,2575,{{1,65,'Copper Vein','Durotar',1411},{65,125,'Tin / Silver Vein','The Barrens',1413},{125,175,'Iron / Gold Vein','Arathi Highlands',1417},{175,245,'Mithril / Truesilver Deposit','Tanaris',1446},{245,275,'Small Thorium Vein',"Un'Goro Crater",1449},{275,300,'Rich Thorium Vein','Winterspring',1452}},true)
book('Skinning',393,8613,{{1,75,'Skin beasts','Durotar',1411},{75,155,'Skin beasts','The Barrens',1413},{155,205,'Skin beasts','Thousand Needles',1441},{205,260,'Skin yetis / beasts','Feralas',1444},{260,300,'Skin beasts',"Un'Goro Crater",1449}},true)
book('Fishing',356,7620,{{1,75,'Fish in safe starting-zone water','Mulgore',1412},{75,150,'Fish in an oasis','The Barrens',1413},{150,225,'Fish along the coast','Desolace',1443},{225,300,'Fish along the coast','Feralas',1444}},true)
-- Original suggested surface corridors, not node spawns or obstacle-aware paths.
HP.gatherLoops={
 [1412]={{.45,.53},{.50,.38},{.59,.31},{.63,.49},{.56,.65},{.47,.72},{.38,.61},{.38,.48},{.45,.53}},
 [1411]={{.52,.43},{.56,.32},{.51,.20},{.43,.29},{.39,.48},{.45,.64},{.53,.72},{.56,.58},{.52,.43}},
 [1413]={{.51,.30},{.57,.40},{.57,.53},{.49,.63},{.45,.58},{.44,.45},{.49,.36},{.51,.30}},
 [1424]={{.57,.23},{.65,.32},{.70,.48},{.60,.61},{.47,.54},{.43,.36},{.57,.23}},
 [1417]={{.46,.46},{.59,.37},{.69,.48},{.68,.65},{.51,.73},{.37,.65},{.32,.45},{.46,.46}},
 [1446]={{.50,.29},{.62,.39},{.62,.58},{.51,.72},{.39,.63},{.36,.44},{.50,.29}},
 [1425]={{.45,.47},{.57,.45},{.68,.54},{.62,.68},{.48,.65},{.38,.55},{.45,.47}},
 [1452]={{.60,.37},{.65,.49},{.61,.62},{.51,.59},{.47,.45},{.53,.35},{.60,.37}},
 [1449]={{.52,.20},{.66,.27},{.73,.46},{.67,.65},{.51,.77},{.34,.66},{.28,.46},{.36,.29},{.52,.20}},
 [1441]={{.43,.31},{.51,.40},{.58,.53},{.66,.65},{.73,.77},{.65,.83},{.55,.69},{.46,.47},{.43,.31}},
 [1444]={{.74,.41},{.69,.49},{.58,.55},{.49,.49},{.48,.37},{.61,.34},{.74,.41}},
 [1443]={{.29,.52},{.31,.65},{.27,.77},{.24,.72},{.25,.59},{.29,.52}}}
HP.reputationBooks={
 [529]={name='Argent Dawn',bands={{7,'Run Scholomance / Stratholme. Equip the Argent Dawn Commission.','Western Plaguelands',1422,.83,.69},{8,'Turn in Scourgestones and finish Plaguelands quests. Kill dungeon bosses.','Western Plaguelands',1422,.83,.69}}},
 [576]={name='Timbermaw Hold',bands={{7,'Kill Deadwood in Felwood or Winterfall in Winterspring. Save feathers and beads.','Felwood',1448,.64,.09},{8,'Turn in Deadwood Headdress Feathers or Winterfall Spirit Beads.','Felwood',1448,.64,.09}}},
 [59]={name='Thorium Brotherhood',bands={{5,'Collect Incendosaur Scales and Heavy Leather, Iron Bars or Kingsblood for Burninate.','Searing Gorge',1427,.39,.28},{6,'Turn in Dark Iron Residue to Master Smith Burninate.','Searing Gorge',1427,.39,.28},{8,'Turn in Dark Iron Ore or Molten Core materials to Lokhtos in Blackrock Depths.','Blackrock Mountain',1427,.35,.85}}},
 [609]={name='Cenarion Circle',bands={{8,'Complete Silithus quests. Collect Encrypted Twilight Texts and complete field duties.','Silithus',1451,.52,.39}}},
 [749]={name='Hydraxian Waterlords',bands={{6,'Kill elementals and Molten Core enemies. Complete Duke Hydraxis quests.','Azshara',1447,.79,.74},{8,'Defeat Molten Core bosses.','Molten Core',1427,.35,.85}}},
 [270]={name='Zandalar Tribe',bands={{8,'Run Zul’Gurub. Turn in coins and bijous on Yojamba Isle.','Stranglethorn Vale',1434,.15,.16}}},
 [729]={name='Frostwolf Clan',bands={{8,'Play Alterac Valley. Capture objectives and complete Frostwolf turn-ins.','Alterac Valley',1459,.50,.50}}},
 [510]={name='The Defilers',bands={{8,'Play Arathi Basin. Hold bases and win matches.','Arathi Basin',1461,.50,.50}}},
 [889]={name='Warsong Outriders',bands={{8,'Play Warsong Gulch. Help your team capture flags.','Warsong Gulch',1460,.50,.50}}},
 [76]={name='Orgrimmar',bands={{8,'Complete Orgrimmar faction quests. Use cloth donations when available.','Orgrimmar',1454,.48,.76}}},
 [81]={name='Thunder Bluff',bands={{8,'Complete Thunder Bluff faction quests. Use cloth donations when available.','Thunder Bluff',1456,.45,.56}}},
 [68]={name='Undercity',bands={{8,'Complete Undercity faction quests. Use cloth donations when available.','Undercity',1458,.67,.38}}},
 [530]={name='Darkspear Trolls',bands={{8,'Complete Darkspear quests. Use cloth donations when available.','Durotar',1411,.56,.74}}},
 [21]={name='Booty Bay',bands={{8,'Complete Booty Bay quests. Fight Bloodsail pirates without attacking cartel members.','Stranglethorn Vale',1434,.27,.77}}}}

HP.professionTraining={
 ['First Aid']={[150]="Buy Expert First Aid — Under Wraps from Balai Lok’Wein in Brackenwall Village.",[225]='Complete Triage for Doctor Gregory Victor in Hammerfall.'},
 Cooking={[150]='Buy Expert Cookbook from Wulan in Shadowprey Village.',[225]='Complete Clamlette Surprise for Dirge Quikcleave in Gadgetzan.'},
 Fishing={[150]='Buy Expert Fishing — The Bass and You from Old Man Heming in Booty Bay.',[225]='Complete Nat Pagle, Angler Extreme in Dustwallow Marsh.'},
 Alchemy={[150]='Learn Expert Alchemy from Doctor Herbert Halsey in Undercity.',[225]='Learn Artisan Alchemy from Rogvar in Stonard.'},
 Blacksmithing={[150]='Learn Expert Blacksmithing from Saru Steelfury in Orgrimmar.',[225]='Learn Artisan Blacksmithing from Brikk Keencraft in Booty Bay.'},
 Enchanting={[150]='Learn Expert Enchanting from Hgarth in Sun Rock Retreat.',[225]='Find Annora in Uldaman to learn Artisan Enchanting. Bring a group.'},
 Engineering={[150]='Learn Expert Engineering from Roxxik in Orgrimmar.',[225]='Learn Artisan Engineering from Buzzek Bracketswing in Gadgetzan.'},
 Leatherworking={[150]='Learn Expert Leatherworking from Una in Thunder Bluff.',[225]='Learn Artisan Leatherworking from Hahrana Ironhide in Camp Mojache.'},
 Tailoring={[150]='Learn Expert Tailoring from Josef Gregorian in Undercity.',[225]='Learn Artisan Tailoring from Daryl Stack in Tarren Mill.'}}

HP.professionRecipeSources={
 ['Superior Mana Potion']='Algernon, Undercity — limited-stock recipe.',
 ['Major Healing Potion']='Evie Whirlbrew, Everlook — limited-stock recipe.',
 ['Imperial Plate Belt']='Derotain Mudsipper, Gadgetzan — recipe quest, level 50.',
 ['Imperial Plate Bracers']='Derotain Mudsipper, Gadgetzan — recipe quest, level 50.',
 ['Imperial Plate Boots']='Derotain Mudsipper, Gadgetzan — recipe quest, level 50.',
 ['Thorium Widget']='Sovik, Orgrimmar — buy the schematic.',
 ['Thorium Tube']='Xizzer Fizzbolt, Everlook — buy the schematic.',
 ['Enchant Cloak - Minor Agility']='Kulwia, Sun Rock Retreat — limited-stock formula.',
 ['Enchant Bracer - Lesser Strength']='Kulwia, Sun Rock Retreat — limited-stock formula.',
 ['Lesser Mana Oil']='Kania, Cenarion Hold — buy the formula.',
 ['Runecloth Bag']='Qia, Everlook — limited-stock pattern.',
 ['Runecloth Gloves']='Qia, Everlook — limited-stock pattern.',
 ['Longjaw Mud Snapper']='Naal Mistrunner, Thunder Bluff — buy the recipe.',
 ['Bristle Whisker Catfish']='Naal Mistrunner, Thunder Bluff — buy the recipe.',
 ['Curiously Tasty Omelet']='Keena, Hammerfall — buy the recipe.',
 ['Roast Raptor']='Keena, Hammerfall — buy the recipe.',
 ['Poached Sunscale Salmon']='Gikkix, Gadgetzan — buy the recipe.',
 ['Lobster Stew']='Sheendra Tallgrass, Camp Mojache in Feralas — buy the recipe.',
 ['Monster Omelet']='Bale, Felwood — buy the recipe.',
 ['Barbaric Leggings']='Jandia, Freewind Post or Keena, Hammerfall — limited-stock pattern.',
 ['Wicked Leather Gauntlets']='Werg Thickblade, Tirisfal Glades — limited-stock pattern.',
 ['Runic Leather Headband']='Jase Farlane, Eastern Plaguelands — limited-stock pattern.',
 ['Enchant Shield - Greater Stamina']='Daniel Bartlett, Undercity — limited-stock formula.',
 ['Enchant Cloak - Superior Defense']='Lorelae Wintersong, Moonglade — limited-stock formula.',
 ['Runed Arcanite Rod']='Lorelae Wintersong, Moonglade — limited-stock formula.',
 ['Heavy Silk Bandage']='Balai Lok’Wein, Brackenwall Village — buy the manual.',
 ['Mageweave Bandage']='Balai Lok’Wein, Brackenwall Village — buy the manual.',
 ['Heavy Mageweave Bandage']='Doctor Gregory Victor, Hammerfall — learn after Triage at skill 240.',
 ['Runecloth Bandage']='Doctor Gregory Victor, Hammerfall — learn after Triage at skill 260.',
 ['Heavy Runecloth Bandage']='Doctor Gregory Victor, Hammerfall — learn after Triage at skill 290.'}
