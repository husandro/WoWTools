local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local CurrentWeek




local function Find_Cursor_Affix()
    local currentAffixes={}
    for _, affix in pairs(C_MythicPlus.GetCurrentAffixes() or {}) do
        currentAffixes[affix.id]= true
    end

    local MaxAffix=  #WoWTools_DataMixin.affixSchedule[1]

    local matches

    for index, affixes in pairs(WoWTools_DataMixin.affixSchedule) do
        matches = 0
        for _, affix in pairs(affixes) do
            if currentAffixes[affix] then
                matches = matches + 1
            end
        end
        if matches >= MaxAffix then
            CurrentWeek= index
            return
        end
    end
end









local function Init_Affix()
    do
        Find_Cursor_Affix()
    end

    if not CurrentWeek then
        WoWTools_ChallengeMixin.notFindAffix= true
        MaxAffix= nil
        WoWTools_DataMixin.affixSchedule={}
        return
    end

    local nextAffix= CurrentWeek+1
    nextAffix= nextAffix>MaxAffix and 1 or nextAffix

    for i=1, MaxAffix do
        local btn= WoWTools_ButtonMixin:Cbtn(Frame, {--建立 Affix 按钮
            size=22,
            isType2=true
        })

        local affixID= WoWTools_DataMixin.affixSchedule[nextAffix][i]
        btn.affixInfo= affixID
        btn.border:SetAtlas('ChallengeMode-AffixRing-Sm')

        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
        SetPortraitToTexture(btn.texture, filedataid)

        btn:SetScript("OnEnter", ChallengesKeystoneFrameAffixMixin.OnEnter)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        btn.affixID = affixID
        btn:SetPoint('TOP', ChallengesFrame.WeeklyInfo.Child.AffixesContainer, 'BOTTOM', ((i-1)*24)-24, -3)

        if i==1 then
            local label= WoWTools_LabelMixin:Create(btn)
            label:SetPoint('RIGHT', btn, 'LEFT')
            label:SetText(nextAffix)
            --if index==1 then
            --label:SetTextColor(0,1,0)
            label:EnableMouse(true)
            --label.affixSchedule= WoWTools_DataMixin.affixSchedule
            --label.CurrentWeek= CurrentWeek
            label.max= max

            --end
        end
    end
    --end
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', 0, -12)
end




















local function Initializer(btn, data)
    local isCurrent= data.index==CurrentWeek
    for index, affixID in pairs(data.data) do
        local frame= btn['Affix'..index]
        if frame then
            frame:SetUp(affixID)
            if isCurrent then
                frame.Border:SetVertexColor(0, 1, 0)
            else
                frame.Border:SetVertexColor(1, 1, 1)
            end
        end
    end
    
    btn.Text:SetText(
        (isCurrent and '|cnGREEN_FONT_COLOR:' or '')
        ..data.index
    )
   
    --local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
end




local function Set_List()
    local data = CreateDataProvider()
    for index, info in pairs(WoWTools_DataMixin.affixSchedule) do
        data:Insert({
            index= index,
            data=info,
        })
    end
    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
end




local function Init()

    if Save().hideAffix then
        return
    end

    Find_Cursor_Affix()

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameLevel(ChallengesFrame.WeeklyInfo.Child.AffixesContainer:GetFrameLevel()+3)
    
    Frame:Hide()


    Frame.ScrollList= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollList:SetAllPoints()

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame, "TOPRIGHT", 6,-12)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT", 6,12)
    Frame.ScrollBar:SetHideIfUnscrollable(true)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollList, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsAffixTemplate', Initializer)






    function Frame:Settings()
        self:SetSize(Save().affixW or 240, Save().affixH or 179)
        Frame:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMRIGHT', Save().affixX or -45, Save().affixY or 250)
        self:SetScale(Save().affixScale or 0.4)
        self:SetShown(not Save().hideAffix)
    end

    Frame:SetScript('OnShow', function()
        Set_List()
    end)
    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider())
    end)

    Frame:Settings()

    


    Frame.ScrollBar:SetScrollPercentage(
        CurrentWeek/#WoWTools_DataMixin.affixSchedule*100
    )

    Init=function()
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Affix()
    Init()
end

--[[
label:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(WoWTools_ChallengeMixin.addName)
                GameTooltip:AddLine(' ')
                for idx=1, self.max do
                    local tab= self.WoWTools_DataMixin.affixSchedule[idx]
                    local text=''
                    for i2=1, MaxAffix do
                        local affixID= tab[i2]
                        local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
                        text= text..'|T'..filedataid..':0|t'..WoWTools_TextMixin:CN(name)..'  '
                    end
                    local col= idx==self.CurrentWeek and '|cnGREEN_FONT_COLOR:' or (select(2, math.modf(idx/2))==0 and '|cffff8200') or '|cffffffff'
                    GameTooltip:AddLine(col..(idx<10 and '  ' or '')..idx..') '..text)
                end
                GameTooltip:Show()
                self:SetAlpha(0.3)
            end)
]]