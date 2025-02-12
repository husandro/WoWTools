local id, e = ...

WoWTools_PetBattleMixin={

    Save={
        --clickToMove= e.Player.husandro,--禁用, 点击移动
        ClickMoveButton={
            --disabled= not e.Player.husandro,
            --Point,
            --Scale=1,
            --Strata='MEDIUM'
            PlayerFrame=true,
            lock_autoInteract=e.Player.husandro and '1' or nil,
            lock_cameraSmoothStyle= e.Player.husandro and '0' or nil,
            lock_cameraSmoothTrackingStyle= e.Player.husandro and '0' or nil,
        },
        TypeButton={
            --disabled=true,
            --point={},
            --hideFrame=true,
            --scale=1,
            --strata='MEDIUM',
            allShow=e.Player.husandro,
            showBackground=true,
        },
        Plus={
            --disabled=true,
        },
        AbilityButton={
            --disabled=true,
            --point..name={},
            --[[scaleEnemy2=0.85,
            scaleEnemy3=0.85,
            scaleAlly2=0.85,
            scaleAlly3=0.85,]]
            --sacle..name=1
            --strata..name='MEDIUM'
            --hide..name=true
            --hideBackground..name=true,
        }
    },
}






function WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱 SharedPetBattleTemplates.lua
    local strongTexture,weakHintsTexture, stringIndex, weakHintsIndex
    for i=1, C_PetJournal.GetNumPetTypes() do
        local modifier = C_PetBattles.GetAttackModifier(petType, i)
        if modifier then
            if ( modifier > 1 ) then
                strongTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                stringIndex=i
            elseif ( modifier < 1 ) then
                weakHintsTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                weakHintsIndex=i
            end
        end
        if strongTexture and weakHintsTexture then
            break
        end
    end
    return strongTexture, weakHintsTexture, stringIndex, weakHintsIndex
end







function WoWTools_PetBattleMixin:Collected(speciesID, itemID, onlyNum, petOwner, petIndex)--总收集数量， 25 25 25， 3/3
    if petOwner and petIndex then
        speciesID= C_PetBattles.GetPetSpeciesID(petOwner, petIndex)
    elseif (not speciesID or speciesID==0) and itemID then--宠物物品
        speciesID= select(13, C_PetJournal.GetPetInfoByItemID(itemID))
    end

    if not speciesID or speciesID==0 then
        return
    end

    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    if numCollected and limit then
        local AllCollected, CollectedNum, CollectedText
        if not onlyNum then--返回所有，数据
            local numPets, numOwned = C_PetJournal.GetNumPets()

            if numPets and numOwned and numPets>0 then
                if numPets<numOwned or numPets<3 then
                    AllCollected= WoWTools_Mixin:MK(numOwned, 3)
                else
                    AllCollected= WoWTools_Mixin:MK(numOwned,3)..'/'..WoWTools_Mixin:MK(numPets,3).. (' %i%%'):format(numOwned/numPets*100)
                end
            end
            if numCollected and numCollected>0 and limit and limit>0 then
                local text2
                for index= 1 ,numOwned do
                    local petID, speciesID2, _, _, level = C_PetJournal.GetPetInfoByIndex(index)
                    if speciesID2==speciesID and petID and level then
                        local rarity = select(5, C_PetJournal.GetPetStats(petID))
                        local col= rarity and select(4, C_Item.GetItemQualityColor(rarity-1))
                        if col then
                            text2= text2 and text2..' ' or ''
                            text2= text2..'|c'..col..level..'|r'
                        end
                    end
                end
                CollectedNum= text2
                
            end
        end
        local isCollectedAll--是否已全部收集
        if numCollected==0 then
            CollectedText='|cnRED_FONT_COLOR:'..numCollected..'|r/'..limit
        elseif limit and numCollected==limit and limit>0 then
            CollectedText= '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r'
            isCollectedAll= true
        else
            CollectedText= numCollected..'/'..limit
        end
        return AllCollected, CollectedNum, CollectedText, isCollectedAll
    end
end









local function Init()
    WoWTools_PetBattleMixin:Set_TypeButton()--宠物，类型

    WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
    --WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动

    --WoWTools_PetBattleMixin:Set_Plus()--宠物对战 Plus
    WoWTools_PetBattleMixin:Init_AbilityButton()--宠物对战，技能按钮
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWToolsSave[PET_BATTLE_COMBAT_LOG]=nil
            WoWToolsSave['Plus_PetBattles']= nil
            WoWToolsSave['Plus_PetBattle']=nil
            WoWTools_PetBattleMixin.Save= WoWToolsSave['Plus_PetBattle2'] or WoWTools_PetBattleMixin.Save

            WoWTools_PetBattleMixin.addName= '|A:WildBattlePetCapturable:0:0|a'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
            --WoWTools_PetBattleMixin.addName2= e.Icon.right..(e.onlyChinese and '点击移动' or CLICK_TO_MOVE)
            WoWTools_PetBattleMixin.addName3= '|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '点击移动按钮'or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLICK_TO_MOVE, 'Button'))
            WoWTools_PetBattleMixin.addName4= '|A:WildBattlePetCapturable:0:0|a'..(e.onlyChinese and '宠物类型' or PET_FAMILIES)
            --WoWTools_PetBattleMixin.addName5= '|A:summon-random-pet-icon_32:0:0|a'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)..' Plus'
            WoWTools_PetBattleMixin.addName6= '|A:plunderstorm-icon-offensive:0:0|a'..(e.onlyChinese and '技能按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PET_BATTLE_ABILITIES_LABEL, 'Button'))

            WoWTools_PetBattleMixin:Init_Options()

            if not WoWTools_PetBattleMixin.Save.disabled then
                Init()
            end

        elseif arg1=='Blizzard_Collections' then
            if not WoWTools_PetBattleMixin.Save.disabled then
                PetJournal:HookScript('OnShow', function()
                    WoWTools_PetBattleMixin:TypeButton_SetShown()
                end)
                PetJournal:HookScript('OnHide', function()
                    WoWTools_PetBattleMixin:TypeButton_SetShown()
                end)
            end
        elseif arg1=='Blizzard_Settings' then
            WoWTools_PetBattleMixin:Set_Options()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_PetBattle2']= WoWTools_PetBattleMixin.Save
        end
    end
end)