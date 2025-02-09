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













local function Create_AbilityButton_Tips(btn)
    if btn.Settings then
        btn:Settings()
        return
    end

    btn.StrongTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.StrongTexture:SetPoint('TOPLEFT', btn, -4, 2)
    btn.StrongTexture:SetSize(15,15)


    btn.UpTexture=btn:CreateTexture(nil, 'OVERLAY')
    btn.UpTexture:SetPoint('TOP', btn.StrongTexture,'BOTTOM',0, 4)
    btn.UpTexture:SetSize(10,10)
    btn.UpTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')

    btn.TypeTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.TypeTexture:SetPoint('LEFT', btn, -4, 0)
    btn.TypeTexture:SetSize(15,15)

    btn.DownTexture=btn:CreateTexture(nil, 'OVERLAY')
    btn.DownTexture:SetPoint('TOP', btn.TypeTexture, 'BOTTOM', 0, 3)
    btn.DownTexture:SetSize(10,10)
    btn.DownTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')


    btn.WeakHintsTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.WeakHintsTexture:SetPoint('BOTTOMLEFT',-4,-2)
    btn.WeakHintsTexture:SetSize(15,15)

    btn.MaxCooldownText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=0,b=0}, justifyH='RIGHT'})--nil, nil, nil,{1,0,0}, 'OVERLAY', 'RIGHT')
    btn.MaxCooldownText:SetPoint('RIGHT',-6,-6)

    if btn.getPetIndex then
        btn.CooldownText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER', size=32})
        btn.CooldownText:SetPoint('CENTER')
    end

    function btn:Settings()
        if not self:IsVisible() then
            return
        end
        local typeTexture, strongTexture, weakHintsTexture, maxCooldown, petType, noStrongWeakHints, abilityID, texture, _
        local petIndex= self.getPetIndex and self:getPetIndex() or self.petIndex

        if petIndex then
            abilityID, _, texture, maxCooldown, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(self.petOwner, petIndex, self.abilityIndex)
        end
        self.abilityID= abilityID

        if petType then
            typeTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]
            if not noStrongWeakHints then
                strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱
            end
        end

        self.StrongTexture:SetTexture(strongTexture or 0)
        self.UpTexture:SetShown(strongTexture)
        self.TypeTexture:SetTexture(typeTexture or 0)
        self.WeakHintsTexture:SetTexture(weakHintsTexture or 0)
        self.DownTexture:SetShown(weakHintsTexture)

        self.MaxCooldownText:SetText(maxCooldown and maxCooldown>0 and maxCooldown or '')
        if self.getPetIndex then
            self:SetNormalTexture(texture or 0)
        end

        if self.set_other then
            self:set_other()
        end
    end
    btn:Settings()
end


function WoWTools_PetBattleMixin:Create_AbilityButton_Tips(btn)
    Create_AbilityButton_Tips(btn)
end

























local function Init()
    WoWTools_PetBattleMixin:Set_TypeButton()--宠物，类型

    WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
    --WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动

    WoWTools_PetBattleMixin:Set_Plus()--宠物对战 Plus
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
            WoWTools_PetBattleMixin.addName5= '|A:summon-random-pet-icon_32:0:0|a'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)..' Plus'
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