﻿local FakeIllusion = {}
FakeIllusion.optionEnable = Menu.AddOptionBool({ "Другое" ,"Контроль иллюзий"}, "Активация", false)
FakeIllusion.Key1= Menu.AddKeyOption({ "Другое" ,"Контроль иллюзий"}, "Дать иллюзиям разбежаться", Enum.ButtonCode.BUTTON_CODE_NONE)
FakeIllusion.Key2= Menu.AddKeyOption({ "Другое" ,"Контроль иллюзий"}, "Двигаться на базу", Enum.ButtonCode.BUTTON_CODE_NONE)

function FakeIllusion.OnUpdate()
	if not Menu.IsEnabled(FakeIllusion.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if not Menu.IsKeyDown(FakeIllusion.Key1) and not Menu.IsKeyDown(FakeIllusion.Key2) then return end
	local illustable = FakeIllusion.FindIllus()
	if #illustable == 0 then
		local naga = NPC.GetAbility(myHero, "naga_siren_mirror_image")
		if naga and Ability.IsReady(naga) then
			if triger <= GameRules.GetGameTime() then
				Ability.CastNoTarget(naga)
				triger = GameRules.GetGameTime() + 1
			end
		end
		local doppelwalk = NPC.GetAbility(myHero, "phantom_lancer_doppelwalk")
		if doppelwalk and Ability.IsReady(doppelwalk) then
			if triger <= GameRules.GetGameTime() then
				if Entity.GetAbsOrigin(myHero):Distance(Input.GetWorldCursorPos()):Length2D() < Ability.GetCastRange(doppelwalk) then
					Ability.CastPosition(doppelwalk,FakeIllusion.GetVec(Entity.GetAbsOrigin(myHero),Input.GetWorldCursorPos(),Entity.GetAbsOrigin(myHero):Distance(Input.GetWorldCursorPos()):Length2D()))
				else
					Ability.CastPosition(doppelwalk,FakeIllusion.GetVec(Entity.GetAbsOrigin(myHero),Input.GetWorldCursorPos(),Ability.GetCastRange(doppelwalk)))
				end
				triger = GameRules.GetGameTime() + 0.5
			end
		end
		local manta = NPC.GetItem(myHero, "item_manta")
		if manta and Ability.IsReady(manta) then
			if triger <= GameRules.GetGameTime() then
				Ability.CastNoTarget(manta)
				triger = GameRules.GetGameTime() + 0.2
			end
		end
		local bottle = NPC.GetItem(myHero, "item_bottle")
		if bottle and Bottle.GetRuneType(bottle) == Enum.RuneType.DOTA_RUNE_ILLUSION then
			if triger <= GameRules.GetGameTime() then
				Ability.CastNoTarget(bottle)
				triger = GameRules.GetGameTime() + 0.5
			end
		end
	end
	if Menu.IsKeyDown(FakeIllusion.Key1) then
		if movetriger <= GameRules.GetGameTime() then
			if #illustable > 0 then
				for _,illusion in pairs(illustable) do
					if illusion then
						local npc = nil
						while not npc do
							npc = Trees.Get(math.random(0,Trees.Count()))
						end	
						local vector = Entity.GetAbsOrigin(npc)
						NPC.MoveTo(illusion,vector)
					end
				end
				movetriger = GameRules.GetGameTime() + 1
			end
		end
	end
	if Menu.IsKeyDown(FakeIllusion.Key2) then
		if movetriger <= GameRules.GetGameTime() then
			if #illustable > 0 then
				NPC.MoveTo(illustable[1],FakeIllusion.FindBase())
				for i,illusion in pairs(illustable) do
					if illusion ~= illustable[1] then
						NPC.MoveTo(illusion,Input.GetWorldCursorPos())
					end
				end
				NPC.MoveTo(Heroes.GetLocal(),Input.GetWorldCursorPos())
				movetriger = GameRules.GetGameTime() + 0.2
			end
		end
	end
end

function FakeIllusion.GetVec(poss1,poss2,range)
	if poss1 and poss2 and range then
		local pos1 = poss1
		local pos2 = poss1
		local pos3 = poss2
		pos1:SetZ(0)
		pos3:SetZ(0)
		return pos2 + ((pos3 - pos1):Normalized()):Scaled(range)
	else
		return nil
	end
end

function FakeIllusion.FindBase()
	for _,NA_Unit in pairs(NPCs.GetAll()) do
		if NA_Unit then
			if NPC.GetUnitName(NA_Unit) == "dota_fountain" and Entity.IsSameTeam(NA_Unit,Heroes.GetLocal()) then
				return Entity.GetAbsOrigin(NA_Unit)
			end
		end
	end
	return nil
end

function FakeIllusion.FindIllus()
	myillus = {}
	for _,npc in pairs(NPCs.GetAll()) do
		if npc and Entity.IsAlive(npc) and NPC.IsIllusion(npc) and NPC.GetUnitName(npc) == NPC.GetUnitName(Heroes.GetLocal()) then
			table.insert(myillus,npc)
		end
	end
	return myillus
end

function FakeIllusion.init()
	triger = 0
	movetriger = 0 
end

function FakeIllusion.OnGameStart()
  FakeIllusion.init()
end

function FakeIllusion.OnGameEnd()
  FakeIllusion.init()
end
FakeIllusion.init()

return FakeIllusion