--冒险指南,右边,显示所数据
local e= select(2, ...)

local AllTipsFrame



local function Create_Frame()
    
end


local function Init()
    if not EncounterJournal or Save().hideEncounterJournal_All_Info_Text then
        if AllTipsFrame then
            AllTipsFrame:SetShown(false)
        end
        return
    end

    if not AllTipsFrame then
        AllTipsFrame=CreateFrame("Frame", nil, EncounterJournal)
        AllTipsFrame:SetPoint('TOPLEFT', EncounterJournal, 'TOPRIGHT',40,0)
        AllTipsFrame:SetSize(1,1)
        AllTipsFrame.label= WoWTools_LabelMixin:CreateLabel(AllTipsFrame)
        AllTipsFrame.label:SetPoint('TOPLEFT')
        AllTipsFrame.weekLable= WoWTools_LabelMixin:CreateLabel(AllTipsFrame, {mouse=true})
        AllTipsFrame.weekLable:SetPoint('TOPLEFT', AllTipsFrame.label, 'BOTTOMLEFT', 0, -12)
        AllTipsFrame.weekLable:SetScript('OnMouseDown', function(self)
            WeeklyRewards_LoadUI()
            --[[if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then
                C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
            end]]--周奖励面板
            WeeklyRewards_ShowUI()--WeeklyReward.lua
            self:SetAlpha(1)
        end)
        AllTipsFrame.weekLable:SetScript('OnLeave', function(self) self:SetAlpha(1) end)
        AllTipsFrame.weekLable:SetScript('OnEnter', function(self) self:SetAlpha(0.5) end)

    end
    local m, text, num


    for insName, info in pairs(e.WoWDate[e.Player.guid].Instance.ins or {}) do
        text= text and text..'|n' or ''
        text= text..'|T450908:0|t'..e.cn(insName)
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

    for bossName, worldBossID in pairs(e.WoWDate[e.Player.guid].Worldboss.boss or {}) do--世界BOSS
        num=num+1
        text= text and text..', ' or ''
        text= text..  WoWTools_EncounterMixin:GetBossNameSort(e.cn(bossName), worldBossID)
    end
    if text then
        m= m and m..'|n|n' or ''
        m= m..num..' |cnGREEN_FONT_COLOR:'..text..'|r'
    end


    text= nil
    num=0
    for name, _ in pairs(e.WoWDate[e.Player.guid].Rare.boss or {}) do--稀有怪
        text= text and text..', ' or ''
        text= text.. WoWTools_EncounterMixin:GetBossNameSort(e.cn(name))
        num=num+1
    end
    if text then
        m= m and m..'|n|n' or ''
        m= m..num..' '..'|cnGREEN_FONT_COLOR:'..text..'|r'
    end
    AllTipsFrame.label:SetText(m or '')


   --本周还可获取奖励
   if C_WeeklyRewards.HasAvailableRewards() then--C_WeeklyRewards.CanClaimRewards() then
        AllTipsFrame.weekLable:SetText('|A:oribos-weeklyrewards-orb-dialog:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '宏伟宝库里有奖励在等待着你。' or GREAT_VAULT_REWARDS_WAITING))
    else
        AllTipsFrame.weekLable:SetText('')
    end
    --周奖励，提示
    local last= WoWTools_WeekMixin:Activities({frame=AllTipsFrame, point={'TOPLEFT', AllTipsFrame.weekLable, 'BOTTOMLEFT', 0, -2}, anchor='ANCHOR_RIGHT'})




    --物品，货币提示
    WoWTools_LabelMixin:ItemCurrencyTips({frame=AllTipsFrame, point={'TOPLEFT', last or AllTipsFrame.label, 'BOTTOMLEFT', 0, -12}})--, showAll=true})
    AllTipsFrame:SetShown(true)
end










function WoWTools_EncounterMixin:Set_RightAllInfo()
    Init()
end