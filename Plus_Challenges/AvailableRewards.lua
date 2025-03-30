--########################
--打开周奖励时，提示拾取专精
--########################
local WeekRewardLookFrame






local function Init()
    local hasReward= C_WeeklyRewards.HasAvailableRewards()
    if hasReward==nil then
        Init=function()end
        return
    elseif hasReward==false then
        return true

    elseif hasReward then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName,
            '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and "返回宏伟宝库，获取你的奖励" or WEEKLY_REWARDS_RETURN_TO_CLAIM)
        )
    end

    WeekRewardLookFrame= CreateFrame('Frame')
    WeekRewardLookFrame:SetSize(40,40)
    WeekRewardLookFrame:SetPoint("CENTER", -100, 60)
    WeekRewardLookFrame:SetShown(false)

    WeekRewardLookFrame:RegisterEvent('PLAYER_UPDATE_RESTING')
    WeekRewardLookFrame:RegisterEvent('PLAYER_ENTERING_WORLD')


    function WeekRewardLookFrame:set_Event()
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

    function WeekRewardLookFrame:set_Show(show)
        if self.time and not self.time:IsCancelled() then
            self.time:Cancel()
        end
        self:SetShown(show)
        WoWTools_CooldownMixin:Setup(self, nil, show and 4 or 0, nil, true, true, true)
    end

    function WeekRewardLookFrame:set_Texture()
        if not self.texture then
            self.texture= self:CreateTexture(nil, 'BACKGROUND')
            self.texture:SetAllPoints(self)
            self:SetScript('OnEnter', function(frame)
                frame:set_Show(false)
                print(
                    WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName,
                    '|cffff00ff',
                    WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION
                )
            end)
            local texture= self:CreateTexture(nil,'BORDER')
            texture:SetSize(60,60)
            texture:SetPoint('CENTER',3,-3)
            texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame-2x')
        end
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

        SetPortraitToTexture(self.texture, texture or 0)
    end

    WeekRewardLookFrame:SetScript('OnEvent', function(self, event, unit, target, _, spellID)
        if event=='PLAYER_UPDATE_RESTING' or event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()

        elseif (spellID==392391 or spellID==449976) and unit=='player' and target and target:find(RATED_PVP_WEEKLY_VAULT) then
            self:set_Texture()
        end
    end)

    WeekRewardLookFrame:set_Event()

    Init=function()end
end



function WoWTools_ChallengeMixin:AvailableRewards()
    Init()
end