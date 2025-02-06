local id, e = ...

WoWTools_PetBattleMixin={

    Save={
        --clickToMove= e.Player.husandro,--禁用, 点击移动
        MoveButton={
            disabled= not e.Player.husandro,
            --Point,
            PlayerFrame=true,
            --Scale=1,
            --Strata='MEDIUM'
        },
        TrackButton={
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
        EnemyButton={
            --point={},
        }
    },
}



--_G["BATTLE_PET_NAME_"..petType]
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














local function Init()
    WoWTools_PetBattleMixin:Set_TrackButton()
    WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
    WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动
    WoWTools_PetBattleMixin:Set_Plus()--宠物对战 Plus
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
            if WoWToolsSave[PET_BATTLE_COMBAT_LOG] then
                WoWToolsSave[PET_BATTLE_COMBAT_LOG]=nil
            end
            WoWTools_PetBattleMixin.Save= WoWToolsSave['Plus_PetBattle'] or WoWTools_PetBattleMixin.Save

            WoWTools_PetBattleMixin.addName= '|A:WildBattlePetCapturable:0:0|a'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
            WoWTools_PetBattleMixin.addName2= e.Icon.right..(e.onlyChinese and '点击移动' or CLICK_TO_MOVE)
            WoWTools_PetBattleMixin.addName3= '|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '点击移动按钮'or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLICK_TO_MOVE, 'Button'))
            WoWTools_PetBattleMixin.addName4= '|A:WildBattlePetCapturable:0:0|a'..(e.onlyChinese and '宠物类型' or PET_FAMILIES)
            WoWTools_PetBattleMixin.addName5= '|A:summon-random-pet-icon_32:0:0|a'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)..' Plus'
            
            WoWTools_PetBattleMixin:Init_Options()

            --[[添加控制面板
            local initializer2= e.AddPanel_Check_Button({
                checkName= '|A:WildBattlePetCapturable:0:0|a'..(e.onlyChinese and '宠物对战' or addName),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_PetBattleMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().point=nil
                    if TrackButton then
                        TrackButton:ClearAllPoints()
                        TrackButton:set_point()
                    end
                    Save().EnemyFramePoint=nil--对方, 技能提示， 框
                    if EnemyFrame then
                        EnemyFrame:set_point()
                    end
                    print(e.addName, WoWTools_PetBattleMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= WoWTools_PetBattleMixin.addName,
                layout= nil,
                category= nil,
            })

            local initializer= e.AddPanel_Check({
                name= e.Icon.right..(e.onlyChinese and '点击移动' or CLICK_TO_MOVE),
                tooltip= (not e.onlyChinese and CLICK_TO_MOVE..', '..REFORGE_CURRENT or '点击移动, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract"))
                    ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' < '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(false)
                    ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' = '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(true),
                GetValue= function() return Save().clickToMove end,
                SetValue= function()
                    Save().clickToMove = not Save().clickToMove and true or nil
                    WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动
                end
            })

            initializer:SetParentInitializer(initializer2, function() if not Save().disabled and TrackButton then return true else return false end end)

            initializer= e.AddPanel_Check({
                name= '|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button')),
                tooltip= e.onlyChinese and '位置：玩家框体' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHOOSE_LOCATION:gsub(CHOOSE, '')..': ', HUD_EDIT_MODE_PLAYER_FRAME_LABEL),
                GetValue= function() return Save().clickToMoveButton end,
                SetValue= function()
                    Save().clickToMoveButton = not Save().clickToMoveButton and true or nil
                    WoWTools_PetBattleMixin:ClickToMove_Button()
                end
            })
            initializer:SetParentInitializer(initializer2, function() if Save().disabled then return false else return true end end)
]]

            if not WoWTools_PetBattleMixin.Save.disabled then
                Init()
            end

        elseif arg1=='Blizzard_Collections' then
            if not WoWTools_PetBattleMixin.Save.disabled then
                PetJournal:HookScript('OnShow', function()
                    if WoWTools_PetBattleMixin.TrackButton then
                        WoWTools_PetBattleMixin.TrackButton:set_shown()
                    end
                end)
                PetJournal:HookScript('OnHide', function()
                    if WoWTools_PetBattleMixin.TrackButton then
                        WoWTools_PetBattleMixin.TrackButton:set_shown()
                    end
                end)
            end
        elseif arg1=='Blizzard_Settings' then
            WoWTools_PetBattleMixin:Set_Options()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_PetBattle']= WoWTools_PetBattleMixin.Save
        end
    end
end)