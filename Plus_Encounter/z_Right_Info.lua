--冒险指南,右边,显示所数据


local function Get_Text()
    local m, text, num

    for insName, info in pairs(WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Instance.ins or {}) do
        text= text and text..'|n' or ''
        text= text..'|T450908:0|t'..WoWTools_TextMixin:CN(insName)
        for difficultyName, index in pairs(info) do
            text=text..'|n     '..index..' '.. difficultyName
        end
    end
    if text then
        m= m and m..'|n|n' or ''
        m= m..text
    end

    text=nil
    num=0

    for bossName in pairs(WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Worldboss.boss or {}) do--世界BOSS
        num=num+1
        text= text and text..', ' or ''
        text= text..  WoWTools_EncounterMixin:GetBossNameSort(WoWTools_TextMixin:CN(bossName))
    end
    if text then
        m= m and m..'|n|n' or ''
        m= m..num..' |cnGREEN_FONT_COLOR:'..text..'|r'
    end


    text= nil
    num=0
    for name, _ in pairs(WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss or {}) do--稀有怪
        text= text and text..', ' or ''
        text= text.. WoWTools_EncounterMixin:GetBossNameSort(WoWTools_TextMixin:CN(name))
        num=num+1
    end
    if text then
        m= m and m..'|n|n' or ''
        m= m..num..' '..'|cnGREEN_FONT_COLOR:'..text..'|r'
    end

    return m
end









local function Init()
    if WoWToolsSave['Adventure_Journal'].hideEncounterJournal_All_Info_Text then
        return
    end

    local frame=CreateFrame("Frame", 'WoWToolsEJRightFrame', EncounterJournal)
    frame:Hide()
    frame:SetPoint('TOPLEFT', EncounterJournal, 'TOPRIGHT',40,0)
    frame:SetSize(1,1)

    frame.label= WoWTools_LabelMixin:Create(frame)
    frame.label:SetPoint('TOPLEFT')

    frame.weekLable= WoWTools_LabelMixin:Create(frame, {mouse=true})
    frame.weekLable:SetPoint('TOPLEFT', frame.label, 'BOTTOMLEFT', 0, -12)

    frame.weekLable:SetScript('OnMouseDown', function(self)
        WeeklyRewards_LoadUI()
        WeeklyRewards_ShowUI()--WeeklyReward.lua
        self:SetAlpha(1)
    end)

    frame.weekLable:SetScript('OnLeave', function(self) self:SetAlpha(1) end)
    frame.weekLable:SetScript('OnEnter', function(self) self:SetAlpha(0.5) end)

    frame:SetScript('OnShow', function(self)
        self.label:SetText(Get_Text() or '')

   --本周还可获取奖励
    if C_WeeklyRewards.HasAvailableRewards() then--C_WeeklyRewards.CanClaimRewards() then
            self.weekLable:SetText('|A:oribos-weeklyrewards-orb-dialog:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '宏伟宝库里有奖励在等待着你。' or GREAT_VAULT_REWARDS_WAITING))
        else
            self.weekLable:SetText('')
        end

    --周奖励，提示
        local last= WoWTools_ChallengeMixin:ActivitiesFrame(self, {point={'TOPLEFT', self.weekLable, 'BOTTOMLEFT', 0, -2}, anchor='ANCHOR_RIGHT'})

    --物品，货币提示
        WoWTools_LabelMixin:ItemCurrencyTips({frame=self, point={'TOPLEFT', last or self.label, 'BOTTOMLEFT', 0, -12}})--, showAll=true})
    end)


    Init=function()
        _G['WoWToolsEJRightFrame']:SetShown(not WoWToolsSave['Adventure_Journal'].hideEncounterJournal_All_Info_Text)
    end
end



function WoWTools_EncounterMixin:Set_RightAllInfo()
    Init()
end