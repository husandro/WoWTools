local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local Frame
























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















local function GetNum(mapID, all)--取得完成次数,如 1/10
    local nu, to=0,0
    local info
    if all then
        info=C_MythicPlus.GetRunHistory(true, true) or {}--全部
    else
        info=C_MythicPlus.GetRunHistory(false, true) or {}--本周
    end
    for _,v in pairs(info) do
        if v.mapChallengeModeID==mapID then
            if v.completed then
                nu=nu+1
            end
            to=to+1
        end
    end
    if to>0 then
        return '|cff00ff00'..nu..'|r/'..to, nu, to
    end
end


























































local function Set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end


    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        if frame and frame.mapID then
            local insTab=WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID] or {}
            frame.spellID= insTab.spell
            frame.journalInstanceID= insTab.ins

            --#####
            --传送门
            --#####
            if not Save().hidePort then
                if frame.spellID then
                    if not frame.spellPort then
                        local h=frame:GetWidth()/3 +8
                        local texture= C_Spell.GetSpellTexture(frame.spellID)
                        frame.spellPort= WoWTools_ButtonMixin:Cbtn(frame, {
                            isSecure=true,
                            size=h,
                            texture= texture,
                            atlas=not texture and 'WarlockPortal-Yellow-32x32',
                            --pushe=not texture
                        })
                        frame.spellPort:SetPoint('BOTTOMRIGHT', frame)--, 4,-4)
                        frame.spellPort:SetScript("OnEnter",function(self2)
                            local parent= self2:GetParent()
                            if parent.spellID then
                                GameTooltip:SetOwner(parent, "ANCHOR_RIGHT")
                                GameTooltip:ClearLines()
                                GameTooltip:SetSpellByID(parent.spellID)
                                if not IsSpellKnownOrOverridesKnown(parent.spellID) then--没学会
                                    GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '法术尚未学会' or SPELL_FAILED_NOT_KNOWN))
                                end
                                GameTooltip:Show()
                                self2:SetAlpha(1)
                            end
                        end)
                        frame.spellPort:SetScript("OnLeave",function(self2)
                            GameTooltip:Hide()
                            local spellID=self2:GetParent().spellID
                            self2:SetAlpha(spellID and IsSpellKnownOrOverridesKnown(spellID) and 1 or 0.3)
                        end)
                        frame.spellPort:SetScript('OnHide', function(self2)
                            self2:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                        end)
                        frame.spellPort:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                        frame.spellPort:SetScript('OnShow', function(self2)
                            self2:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                            WoWTools_CooldownMixin:SetFrame(self2, {spell=self2:GetParent().spellID})
                        end)
                        frame.spellPort:SetScript('OnEvent', function(self2)
                            WoWTools_CooldownMixin:SetFrame(self2, {spell=self2:GetParent().spellID})
                        end)
                    end
                end
            end
            if frame.spellPort and frame.spellPort:CanChangeAttribute() then
                if frame.spellID and IsSpellKnownOrOverridesKnown(frame.spellID) then
                    local name= C_Spell.GetSpellName(frame.spellID)
                    frame.spellPort:SetAttribute("type", "spell")
                    frame.spellPort:SetAttribute("spell", name or frame.spellID)
                    frame.spellPort:SetAlpha(1)
                else
                    frame.spellPort:SetAlpha(0.3)
                end
                frame.spellPort:SetShown(not Save().hidePort)
                frame.spellPort:SetScale(Save().portScale or 1)
            end
        end
    end

    --[[if ChallengesFrame.WeeklyInfo.Child.WeeklyChest and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:GetText()==MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetText('')--隐藏，完成史诗钥石地下城即可获得
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:Hide()
    end
    if ChallengesFrame and ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.Description then
        ChallengesFrame.WeeklyInfo.Child.Description:SetText('')
        ChallengesFrame.WeeklyInfo.Child.Description:Hide()
    end]]
end





































--####
--初始
--####
local function Init()
    Frame= CreateFrame("Frame", nil, ChallengesFrame)
    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetPoint('TOPLEFT')
    Frame:SetSize(1, 1)

    function Frame:Settings()
        self:SetShown(not Save().hideTips)
        self:SetScale(Save().tipsScale or 1)
    end


    hooksecurefunc(ChallengesFrame, 'Update', Set_Update)

    Init=function()
        Set_Update()
    end
end





function WoWTools_ChallengeMixin:ChallengesUI_Porta()
    Init()
end
