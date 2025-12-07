--########################
--打开周奖励时，提示拾取专精
--########################
local Frame






local function Init()
    if not C_WeeklyRewards.HasAvailableRewards() then
        Init=function()end
        return

    else
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and "返回宏伟宝库，获取你的奖励" or WEEKLY_REWARDS_RETURN_TO_CLAIM)
        )
    end

    Frame= CreateFrame('Frame')

    Frame.texture= Frame:CreateTexture(nil, 'BACKGROUND')
    Frame.texture:SetAllPoints()

    local border= Frame:CreateTexture(nil,'BORDER')
    border:SetSize(60,60)
    border:SetPoint('CENTER',3,-3)
    border:SetAtlas('UI-HUD-UnitFrame-TotemFrame-2x')

    Frame:SetSize(40,40)
    Frame:SetPoint("CENTER", -100, 60)
    Frame:SetShown(false)

    Frame:RegisterEvent('PLAYER_UPDATE_RESTING')
    Frame:RegisterEvent('PLAYER_ENTERING_WORLD')

    Frame:SetScript('OnEnter', function(frame)
        frame:set_Show(false)
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cffff00ff',
            WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION
        )
    end)

    Frame:SetScript('OnHide', function(self)
        if self.time then
            self.time:Cancel()
            self.time=nil
        end
        --WoWTools_CooldownMixin:Setup(self)
    end)


    function Frame:set_Event()
        if not C_WeeklyRewards.HasAvailableRewards() then
            self:UnregisterAllEvents()
            self:SetShown(false)
            return
        end
        if IsResting() then
            self:RegisterEvent('UNIT_SPELLCAST_SENT')
        else
            self:UnregisterEvent('UNIT_SPELLCAST_SENT')
        end
    end

    function Frame:set_Show(show)
        self:SetShown(show)
        WoWTools_CooldownMixin:Setup(self, nil, show and 4 or 0, nil, true, true, true)
    end

    function Frame:set_Texture()
        self:set_Show(true)

        self.time= C_Timer.NewTimer(4, function()
            self:SetShown(false)
        end)

        local loot = GetLootSpecialization()
        local texture
        if loot and loot>0 then
            texture= select(4, GetSpecializationInfoByID(loot))
        else
            texture= select(4, GetSpecializationInfo(GetSpecialization() or 0))
        end

        --SetPortraitToTexture(self.texture, texture or 0)
        self.texture:SetTexture(texture or 0)
    end

    Frame:SetScript('OnEvent', function(self, event, unit, target, _, spellID)
        if event=='PLAYER_UPDATE_RESTING' or event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()

        elseif (spellID==392391 or spellID==449976) and unit=='player' and target and target:find(RATED_PVP_WEEKLY_VAULT) then
            self:set_Texture()
            self:UnregisterAllEvents()
        end
    end)

    Frame:set_Event()

    Init=function()end
end



function WoWTools_ChallengeMixin:AvailableRewards()
    Init()
end