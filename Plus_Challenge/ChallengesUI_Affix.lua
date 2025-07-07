local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local CurrentWeek
local Frame





local function Find_Cursor_Affix()
    if CurrentWeek then
        return
    end

    local currentAffixes=C_MythicPlus.GetCurrentAffixes()
    if not currentAffixes then
        return
    end
    for index, affixes in pairs(WoWTools_DataMixin.affixSchedule) do
        if affixes[1]== currentAffixes[1].id and affixes[2]==currentAffixes[2].id and affixes[3]==currentAffixes[3].id and affixes[4]==currentAffixes[4].id then
            CurrentWeek= index
            return
        end
    end
end
--[[
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
]]














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

    --btn.Text:SetText(isCurrent and '|A:common-icon-rotateright:0:0|a' or data.index)
    btn.Text:SetText(
        (isCurrent and '|cnGREEN_FONT_COLOR:' or '')
        .. data.index
    )

    --local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
end













local function Set_List()
    Find_Cursor_Affix()

    local data = CreateDataProvider()
    for index, info in pairs(WoWTools_DataMixin.affixSchedule) do
        data:Insert({
            index= index,
            data=info,
        })
    end
    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    Frame.ScrollBox:ScrollToElementDataIndex(CurrentWeek or 1)

    local season= C_MythicPlus.GetCurrentSeason()
    Frame.Text:SetText(
        (season==WoWTools_DataMixin.affixScheduleSeason and '' or '|cff828282')
        ..season
    )
end














local function Init()
    if Save().hideAffix then
        return
    end



    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:Hide()


    Frame.ScrollBox= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox:SetAllPoints()

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame, "TOPRIGHT", 6, -12)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar, true)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsAffixTemplate', function(...) Initializer(...) end)



    function Frame:Settings()
        self:SetSize(Save().affixW or 238, Save().affixH or 177)
        self:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMRIGHT', Save().affixX or -45, Save().affixY or 300)
        self:SetScale(Save().affixScale or 0.4)
        self:SetShown(not Save().hideAffix)
    end

    Frame:SetScript('OnShow', function(self)
        Set_List()
        self:RegisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
    end)

    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider())
        self:UnregisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
    end)


    Frame:SetScript('OnEvent', function()
        Set_List()
    end)



--第几赛季
    Frame.Text= WoWTools_LabelMixin:Create(Frame, {color=true, mouse=true, size=32})
    Frame.Text:SetPoint('BOTTOMRIGHT', Frame.ScrollBar, 'TOPRIGHT',9, 3)
    Frame.Text:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    Frame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local sea=  C_MythicPlus.GetCurrentSeason() or 0
        local isCurrentWeek= sea==WoWTools_DataMixin.affixScheduleSeason

        GameTooltip:AddLine(
            format(
                WoWTools_DataMixin.onlyChinese and '%s第%d赛季' or EXPANSION_SEASON_NAME,
                WoWTools_DataMixin.Icon.wow2,
                sea
            )
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.left
            ..(isCurrentWeek and '' or '|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '当前：' or ITEM_UPGRADE_CURRENT)
            ..(CurrentWeek or 1)
        )
        if not isCurrentWeek then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                '|cnRED_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '当前赛季数据不匹配' or 'Current season data mismatch')
            )
        end
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)
    Frame.Text:SetScript('OnMouseDown', function(self)
        self:GetParent().ScrollBox:ScrollToElementDataIndex(CurrentWeek or 1)
    end)








    if WoWTools_DataMixin.Player.husandro then
        local season= C_MythicPlus.GetCurrentSeason()
        if season and season>0 and season~=WoWTools_DataMixin.affixScheduleSeason then
            print('|cnRED_FONT_COLOR:需要更新赛季数据', '0_3_Data_NeedUpdate.lua' )
        end
    end





    WoWTools_TextureMixin:CreateBG(Frame,{point=function(texture)
        texture:SetPoint('TOPLEFT', -2, 6)
        texture:SetPoint('BOTTOMLEFT', -2, -2)
        texture:SetPoint('RIGHT', Frame.ScrollBar, 10, 0)
    end})








    C_Timer.After(1, function() Set_List() end)
    Frame:Settings()

    Init=function()
        Frame:Settings()
    end
end














function WoWTools_ChallengeMixin:ChallengesUI_Affix()
    Init()
end
