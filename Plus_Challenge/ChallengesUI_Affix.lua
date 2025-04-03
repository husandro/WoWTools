

--[[(资料来自)：
https://www.wowhead.com/guide/mythic-plus-dungeons/dragonflight-season-4/overview#mythic-affixes
AngryKeystones Schedule



148/萨拉塔斯的交易：扬升
159/萨拉塔斯的交易：湮灭
158/萨拉塔斯的交易：虚缚
160/萨拉塔斯的交易：吞噬

https://www.wowhead.com/cn/affix=9/残暴
https://www.wowhead.com/cn/affix=152/挑战者的危境
https://www.wowhead.com/cn/affix=10/强韧
https://www.wowhead.com/cn/affix=147/萨拉塔斯的狡诈

local affixSchedule = {--C_MythicPlus.GetCurrentSeason() C_MythicPlus.GetCurrentUIDisplaySeason()
    --season=12,--当前赛季
    --[1]={[1]=9, [2]=124, [3]=6},	--Tyrannical Storming Raging
    [2]={[1]=10, [2]=134, [3]=7},	--Fortified Entangling Bolstering
    [3]={[1]=9, [2]=136, [3]=123},	--Tyrannical Incorporeal Spiteful
    [4]={[1]=10, [2]=135, [3]=6},	--Fortified 	Afflicted	Raging
    [5]={[1]=9, [2]=3, [3]=8},	--Tyrannical Volcanic 	Sanguine
    [6]={[1]=10, [2]=124, [3]=11},	--Fortified 	Storming Bursting
    [7]={[1]=9, [2]=135, [3]=7},	--Tyrannical Afflicted 	Bolstering
    [8]={[1]=10, [2]=136, [3]=8},	--Fortified 	Incorporeal Sanguine
    [9]={[1]=9, [2]=134, [3]=11},	--Tyrannical Entangling Bursting
    [10]={[1]=10, [2]=3, [3]=123},	--Fortified 	Volcanic 	Spiteful
    -- TWW Season 2 (Sort:[1](Level 4+);[2](Level 7+);[3](Level 10+);[4](Level 12+))
	-- Information from(资料来自)：https://www.wowhead.com/guide/mythic-plus-dungeons/the-war-within-season-2/overview
	{ [1]=148, [2] =9 , [3]=10, [4]=147, }, -- (1) Xal’atath’s Bargain: Ascendant | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=162, [2] =10, [3]=9 , [4]=147, }, -- (2) Xal’atath’s Bargain: Pulsar    | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=158, [2] =9 , [3]=10, [4]=147, }, -- (3) Xal’atath’s Bargain: Voidbound | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=160, [2] =10, [3]=9 , [4]=147, }, -- (4) Xal’atath’s Bargain: Devour    | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=162, [2] =9 , [3]=10, [4]=147, }, -- (5) Xal’atath’s Bargain: Pulsar    | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=148, [2] =10, [3]=9 , [4]=147, }, -- (6) Xal’atath’s Bargain: Ascendant | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=160, [2] =9 , [3]=10, [4]=147, }, -- (7) Xal’atath’s Bargain: Devour    | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=158, [2] =10, [3]=9 , [4]=147, }, -- (8) Xal’atath’s Bargain: Voidbound | Fortified  | Tyrannical | Xal’atath’s Guile
}

]]



--##################
--史诗钥石地下城, 界面
--[[词缀日程表AngryKeystones Schedule.lua
local function Init_Affix()
    if C_AddOns.IsAddOnLoaded("AngryKeystones")
        or not affixSchedule
        or Frame.affixesButton
        --or C_MythicPlus.GetCurrentSeason()~= affixSchedule.season
    then
        affixSchedule=nil
        return
    end
    local currentWeek
    local max= 0
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
        for index, affixes in ipairs(affixSchedule) do
            if not currentWeek then
                local matches = 0
                for _, affix in ipairs(currentAffixes) do
                    if affix.id == affixes[1] or affix.id == affixes[2] or affix.id == affixes[3] then
                        matches = matches + 1
                    end
                end
                if matches >= 3 then
                    currentWeek = index
                end
            end
            max=max+1
        end
    end

    if not currentWeek then
        affixSchedule=nil
        return
    end

    local one= currentWeek+1
    one= one>max and 1 or one

    for i=1, 3 do
        local btn= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, isType2=true})--建立 Affix 按钮
        local affixID= affixSchedule[one][i]
        btn.affixInfo= affixID
        btn:SetSize(24, 24)
        btn.Border= btn:CreateTexture(nil, "BORDER")
        btn.Border:SetAllPoints()
        btn.Border:SetAtlas("ChallengeMode-AffixRing-Sm")
        btn.Portrait = btn:CreateTexture(nil, "BACKGROUND")
        btn.Portrait:SetAllPoints(btn.Border)
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
        SetPortraitToTexture(btn.Portrait, filedataid)--btn.SetUp = ScenarioChallengeModeAffixMixin.SetUp
        btn:SetScript("OnEnter", ChallengesKeystoneFrameAffixMixin.OnEnter)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        btn.affixID = affixID
        btn:SetPoint('TOP', ChallengesFrame.WeeklyInfo.Child.AffixesContainer, 'BOTTOM', ((i-1)*24)-24, -3)---((index-1)*24))

        if i==1 then
            local label= WoWTools_LabelMixin:Create(btn)
            label:SetPoint('RIGHT', btn, 'LEFT')
            label:SetText(one)
            --if index==1 then
            --label:SetTextColor(0,1,0)
            label:EnableMouse(true)
            label.affixSchedule= affixSchedule
            label.currentWeek= currentWeek
            label.max= max
            label:SetScript('OnLeave', function(self) self:SetAlpha(1) end)
            label:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(WoWTools_ChallengeMixin.addName)
                GameTooltip:AddLine(' ')
                for idx=1, self.max do
                    local tab= self.affixSchedule[idx]
                    local text=''
                    for i2=1, 3 do
                        local affixID= tab[i2]
                        local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
                        text= text..'|T'..filedataid..':0|t'..WoWTools_TextMixin:CN(name)..'  '
                    end
                    local col= idx==self.currentWeek and '|cnGREEN_FONT_COLOR:' or (select(2, math.modf(idx/2))==0 and '|cffff8200') or '|cffffffff'
                    GameTooltip:AddLine(col..(idx<10 and '  ' or '')..idx..') '..text)
                end
                GameTooltip:Show()
                self:SetAlpha(0.3)
            end)
            --end
        end
    end
    --end
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', 0, -12)
end

]]