--[[
打开周奖励时，提示拾取专精
    [449976]=1,
    [392391]=1,
    [1271478]=1,--12.01
]]

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

    local frame= CreateFrame('Frame')

    frame.texture= frame:CreateTexture(nil, 'BACKGROUND')
    frame.texture:SetAllPoints()

    local border= frame:CreateTexture(nil,'BORDER')
    border:SetSize(60,60)
    border:SetPoint('CENTER',3,-3)
    border:SetAtlas('UI-HUD-Unitframe-Totemframe-2x')

    frame:SetSize(40,40)
    frame:SetPoint("CENTER", -100, 60)
    frame:SetShown(false)

    frame:RegisterEvent('PLAYER_UPDATE_RESTING')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')

    frame:SetScript('OnEnter', function(self)
        self:set_show(false)
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cffff00ff',
            WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION
        )
    end)

    frame:SetScript('OnHide', function(self)
        if self.time then
            self.time:Cancel()
            self.time=nil
        end
        --WoWTools_CooldownMixin:Setup(self)
    end)


    function frame:set_event()
        if not C_WeeklyRewards.HasAvailableRewards() then
            self:UnregisterAllEvents()
            self:SetShown(false)
            return
        end
        if IsResting() then
            self:RegisterUnitEvent('UNIT_SPELLCAST_SENT')
        else
            self:UnregisterEvent('UNIT_SPELLCAST_SENT')
        end
    end

    function frame:set_show(show)
        self:SetShown(show)
        WoWTools_CooldownMixin:Setup(self, nil, show and 4 or 0, nil, true, true, true)
    end

    function frame:set_Texture()
        self:set_show(true)

        self.time= C_Timer.NewTimer(4, function()
            self:SetShown(false)
        end)

        local loot = GetLootSpecialization()
        local texture
        if loot and loot>0 then
            texture= select(4, GetSpecializationInfoByID(loot))
        else
            texture= select(4, C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0))
        end

        --SetPortraitToTexture(self.texture, texture or 0)
        self.texture:SetTexture(texture or 0)
    end

    frame:SetScript('OnEvent', function(self, event, _, target)
        if event=='PLAYER_UPDATE_RESTING' or event=='PLAYER_ENTERING_WORLD' then
            self:set_event()

        elseif not canaccessvalue(target) then
            return

        elseif target==RATED_PVP_WEEKLY_VAULT then
            self:set_Texture()
            C_Timer.After(5, function()
                self:set_event()
            end)
        end
    end)

    frame:set_event()

    Init=function()end
end



function WoWTools_ChallengeMixin:AvailableRewards()
    Init()
end