# Quest data audit · 1.5

Sources: user Questie-v12.9.0.zip and official QuestieDB 1.1.1 Forever (https://www.curseforge.com/wow/addons/questiedb/files/9602575), downloaded 15 November 2026. Questie 12.9.0 uses the separate database provider; its ZIP alone has no complete entity database.

Compared 5914 provider quest summaries with existing Suite facts. Missing 682: added 611 factual quest records; excluded 71 records for reasons listed in QUESTIE-MISSING-1.5.csv. Added supporting missing NPC/object/item facts: 77/121/26. Existing reviewed facts and authored route order remain unchanged.

Preserved class/race masks, prerequisite groups, alternative prerequisites, exclusivity, profession/reputation requirements and source items. Advanced conditions not implemented by the existing availability engine are retained and block automatic new-quest suggestions until the quest is in the live log. No arbitrary new walking routes are invented; database coverage is not a claim of authored guide coverage. Unmapped or unknown coordinates stay unavailable, with no fallback to fabricated positions. Data is factual; no quest narrative imported. Database source is GPL-3.0, attribution and upstream license retained in Licenses/.

Also restored six existing Suite quest records to the native database reader (78830, 79098, 79235, 79236, 79242, 93045), without replacing their reviewed Suite facts.
