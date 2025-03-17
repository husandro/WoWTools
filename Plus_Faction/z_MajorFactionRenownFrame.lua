
local e= select(2, ...)
local Save= function()
    return  WoWTools_MinimapMixin.Save
end

local Button
local Buttons={}






--取得，等级，派系声望
local function Get_Major_Faction_Level(factionID, level)
    --WoWTools_FactionMixin:GetInfo(factionID, nil, nil)
    local text,hasRewardPending ='', false
    level= level or 0
    if C_MajorFactions.HasMaximumRenown(factionID) then
        if C_Reputation.IsFactionParagon(factionID) then--奖励
            local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and currentValue and threshold and threshold>0 then
                hasRewardPending= hasRewardPending2
                local completed= math.modf(currentValue/threshold)--完成次数
                currentValue= completed>0 and currentValue - threshold * completed or currentValue
                if hasRewardPending2 then
                    text= format('|cnGREEN_FONT_COLOR:%i%%|A:GarrMission-%sChest:0:0|a%s%d|r', currentValue/threshold*100, e.Player.faction, hasRewardPending and format('|A:%s:0:0|a', e.Icon.select) or '', completed)
                else
                    text= format('%i%%|A:Banker:0:0|a%s%d', currentValue/threshold*100, hasRewardPending and format('|A:%s:0:0|a', e.Icon.select) or '', completed)
                end
            end
        end
        text= text or format('|cnGREEN_FONT_COLOR:%d|r|A:common-icon-checkmark:0:0|a', level)
    else
        local levels = C_MajorFactions.GetRenownLevels(factionID)
        if levels then
            text= format('%d/%d', level, #levels)
        else
            text= format('%d', level)
        end
        local info = C_MajorFactions.GetMajorFactionData(factionID)
        if info then
            text= format('%s %i%%', text, info.renownReputationEarned/info.renownLevelThreshold*100)
        end
    end
    return text, hasRewardPending
end








--取得，所有，派系声望
local function Get_Major_Faction_List()
    local tab={}
    local find={}
    for i= LE_EXPANSION_DRAGONFLIGHT, e.ExpansionLevel, 1 do
        for _, factionID in pairs(C_MajorFactions.GetMajorFactionIDs(i) or {}) do--if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(i) then
            if not find[factionID] then
                table.insert(tab, factionID)
                find[factionID]=true
            end
        end
    end

    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do--MajorFactionsConstantsDocumentation.lu
        if not find[factionID] then
            table.insert(tab, factionID)
            find[factionID]=true
        end
    end

    table.sort(tab, function(a,b) return a>b end)
    find=nil
    return tab
end






local function Create_Button(index)
    local btn= WoWTools_ButtonMixin:Cbtn(Button.frame, {size={80, 32}})
    btn:SetPoint('TOPLEFT', Buttons[index-1] or Button.frame, 'BOTTOMLEFT')
    btn:SetHighlightAtlas('ChromieTime-Button-Highlight')
    btn:SetScript('OnLeave', function()
        Button:SetButtonState('NORMAL')
        WoWTools_SetTooltipMixin:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        Button:SetButtonState('PUSHED')
        WoWTools_SetTooltipMixin:Faction(self)
    end)
    btn:SetScript('OnClick', function(self)
        if
            not MajorFactionRenownFrame
            or not MajorFactionRenownFrame:IsVisible()
            or MajorFactionRenownFrame:GetCurrentFactionID()~=self.factionID
        then
            ToggleMajorFactionRenown(self.factionID)
        end
    end)

    btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
    btn.Text:SetPoint('BOTTOMLEFT', btn, 'BOTTOM')

    btn.SelectTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.SelectTexture:SetAllPoints()
    btn.SelectTexture:SetAtlas('auctionhouse-nav-button-select')

    btn.ANCHOR_RIGHT=true
    Buttons[index]= btn
    return btn
end











local function Settings()
    if Save().hide_MajorFactionRenownFrame_Button then
        Button.frame:SetShown(false)
        return
    end

    --所有，派系声望
    local selectFactionID= MajorFactionRenownFrame:GetCurrentFactionID()
    local tab= Get_Major_Faction_List()--取得，所有，派系声望

    local index=0
    for _, factionID in pairs(tab) do
        local info= C_MajorFactions.GetMajorFactionData(factionID or 0)
        if info then
            index= index+1
            local btn= Buttons[index] or Create_Button(index)

            btn.factionID= factionID
            btn:SetNormalAtlas('majorfaction-celebration-'..(info.textureKit or 'toastbg'))
            btn:SetPushedAtlas('MajorFactions_Icons_'..(info.textureKit or '')..'512')

            btn.SelectTexture:SetShown(selectFactionID==factionID)
            --[[if selectFactionID==factionID then--选中
                btn.Text:SetTextColor(0,1,0)
            else
                btn.Text:SetTextColor(1,1,1)
            end]]
            btn.Text:SetText(Get_Major_Faction_Level(factionID, info.renownLevel))--等级
        end
    end

    Button.frame:SetShown(true)
end
















local function Set_HeaderText()
    local text=''
    if not Save().hide_MajorFactionRenownFrame_Button then
        local factionID= MajorFactionRenownFrame:GetCurrentFactionID()
        local info=factionID and C_MajorFactions.GetMajorFactionData(factionID)
        if info then
            text= Get_Major_Faction_Level(factionID, info.renownLevel)
        end
    end
    Button.HeaderText:SetText(text)
end
















--派系，列表 MajorFactionRenownFrame
local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(MajorFactionRenownFrame.CloseButton, {size=22})

    function Button:set_scale()
        self.frame:SetScale(Save().MajorFactionRenownFrame_Button_Scale or 1)
    end
    function Button:set_texture()
        local hide= Save().hide_MajorFactionRenownFrame_Button
        if hide then
            self:SetNormalAtlas(e.Icon.icon)
            self:SetAlpha(0.3)
        else
            self:SetNormalTexture(0)
            self:SetAlpha(1)
        end
    end

    function Button:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MinimapMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.GetShowHide(not Save().hide_MajorFactionRenownFrame_Button), e.Icon.left)
        GameTooltip:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().MajorFactionRenownFrame_Button_Scale or 1), e.Icon.mid)
        GameTooltip:Show()
    end

    Button:SetPoint('LEFT', MajorFactionRenownFrame.CloseButton, 'RIGHT', 8, 0)
    Button:SetFrameStrata(MajorFactionRenownFrame.CloseButton:GetFrameStrata())

    Button:SetScript('OnLeave', GameTooltip_Hide)
    Button:SetScript('OnEnter', Button.set_tooltips)
    Button:SetScript('OnClick', function(self)
        Save().hide_MajorFactionRenownFrame_Button= not Save().hide_MajorFactionRenownFrame_Button and true or nil
        Settings()
        self:set_texture()
        self:set_tooltips()
    end)

    Button:SetScript('OnMouseWheel', function(self, d)
        local n= Save().MajorFactionRenownFrame_Button_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save().MajorFactionRenownFrame_Button_Scale=n
        self:set_scale()
        self:set_tooltips()
    end)


    Button.frame=CreateFrame('Frame', nil, Button)
    Button.frame:SetSize(1,1)
    Button.frame:SetAllPoints()

    Button.HeaderText= WoWTools_LabelMixin:Create(Button.frame, {color={r=1, g=1, b=1}, copyFont=MajorFactionRenownFrame.HeaderFrame.Level, justifyH='LEFT', size=14})
    Button.HeaderText:SetPoint('BOTTOMLEFT', MajorFactionRenownFrame.HeaderFrame.Level, 'BOTTOMRIGHT', 16, -4)

    hooksecurefunc(MajorFactionRenownFrame, 'Refresh', function()
        --C_Timer.After(0.5, Settings)
        Settings()
        Set_HeaderText()
    end)

    Button:set_scale()
    Button:set_texture()

end























function WoWTools_FactionMixin:Init_MajorFactionRenownFrame()
    self:Init_CovenantRenown(MajorFactionRenownFrame)--盟约 9.0
    Init()
end



