
local e= select(2, ...)
local Save= function()
    return  WoWTools_MinimapMixin.Save
end
local Frame







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
    for i= LE_EXPANSION_DRAGONFLIGHT, e.ExpansionLevel, 1 do
        for _, factionID in pairs(C_MajorFactions.GetMajorFactionIDs(i) or {}) do--if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(i) then
            table.insert(tab, factionID)
        end
    end

    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do--MajorFactionsConstantsDocumentation.lu
        table.insert(tab, factionID)
    end

    table.sort(tab, function(a,b) return a>b end)

    return tab
end







local function Create_Button(frame)
    local btn= WoWTools_ButtonMixin:Cbtn(frame.frame, {size={235/2.5, 110/2.5}, icon='hide'})
    btn:SetPoint('TOPLEFT', frame.btn[n-1] or frame, 'BOTTOMLEFT')
    btn:SetHighlightAtlas('ChromieTime-Button-Highlight')
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', ReputationBarMixin.ShowMajorFactionRenownTooltip)
    btn:SetScript('OnClick', function(self)
        if
            not MajorFactionRenownFrame
            or not MajorFactionRenownFrame:IsVisible()
            or MajorFactionRenownFrame:GetCurrentFactionID()~=self.factionID
        then
            ToggleMajorFactionRenown(self.factionID)
        end
    end)
    btn.Text= WoWTools_LabelMixin:Create(btn)
    btn.Text:SetPoint('BOTTOMLEFT', btn, 'BOTTOM')
    return btn
end



--派系，列表 MajorFactionRenownFrame
local function Init_MajorFactionRenownFrame()
    Frame= WoWTools_ButtonMixin:Cbtn(MajorFactionRenownFrame, {size={22,22}, icon='hide'})

    function Frame:set_scale()
        self.frame:SetScale(Save().MajorFactionRenownFrame_Button_Scale or 1)
    end
    function Frame:set_texture()
        self:SetNormalAtlas(Save().hide_MajorFactionRenownFrame_Button and 'talents-button-reset' or e.Icon.icon)
    end

    function Frame:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MinimapMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hide_MajorFactionRenownFrame_Button), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().MajorFactionRenownFrame_Button_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end

    Frame:SetFrameStrata('HIGH')
    Frame:SetPoint('LEFT', MajorFactionRenownFrame.CloseButton, 'RIGHT', 4, 0)
    Frame:SetFrameStrata(MajorFactionRenownFrame.CloseButton:GetFrameStrata())
    Frame:SetScript('OnLeave', GameTooltip_Hide)
    Frame:SetScript('OnEnter', Frame.set_tooltips)
    Frame:SetScript('OnClick', function(self)
        Save().hide_MajorFactionRenownFrame_Button= not Save().hide_MajorFactionRenownFrame_Button and true or nil
        self:set_faction()
        self:set_texture()
        self:set_tooltips()
    end)

    Frame:SetScript('OnMouseWheel', function(self, d)
        local n= Save().MajorFactionRenownFrame_Button_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save().MajorFactionRenownFrame_Button_Scale=n
        self:set_scale()
        self:set_tooltips()
    end)


    Frame.frame=CreateFrame('Frame', nil, Frame)
    Frame.btn={}


    function Frame:set_faction()
        if Save().hide_MajorFactionRenownFrame_Button then
            self.frame:SetShown(false)
            return
        end
        self.frame:SetShown(true)

        --所有，派系声望
        local selectFactionID= MajorFactionRenownFrame:GetCurrentFactionID()
        local tab= Get_Major_Faction_List()--取得，所有，派系声望
        local n=1
        for _, factionID in pairs(tab) do
            local info=C_MajorFactions.GetMajorFactionData(factionID or 0)
            if info then
                local btn= self.btn[n] or Create_Button(self.frame)
                n= n+1
                btn.factionID= factionID
                btn:SetNormalAtlas('majorfaction-celebration-'..(info.textureKit or 'toastbg'))
                btn:SetPushedAtlas('MajorFactions_Icons_'..(info.textureKit or '')..'512')
                if selectFactionID==factionID then--选中
                    btn:LockHighlight()
                else
                    btn:UnlockHighlight()
                end
                btn.Text:SetText(Get_Major_Faction_Level(factionID, info.renownLevel))--等级
            end
        end
    end


    Frame:set_scale()
    Frame:set_texture()
    Frame.HeaderText= WoWTools_LabelMixin:Create(Frame.frame, {color={r=1, g=1, b=1}, copyFont=MajorFactionRenownFrame.HeaderFrame.Level, justifyH='LEFT', size=14})
    Frame.HeaderText:SetPoint('BOTTOMLEFT', MajorFactionRenownFrame.HeaderFrame.Level, 'BOTTOMRIGHT', 16, -4)

    function Frame.HeaderText:set_text()
        local text=''
        if not Save().hide_MajorFactionRenownFrame_Button then
            local factionID= MajorFactionRenownFrame:GetCurrentFactionID()
            local info=C_MajorFactions.GetMajorFactionData(factionID or 0)
            if info then
                text= Get_Major_Faction_Level(factionID, info.renownLevel)
            end
        end
        self:SetText(text)
    end

    hooksecurefunc(MajorFactionRenownFrame, 'Refresh', function(self)
        Frame:set_faction()
        Frame.HeaderText:set_text()
    end)
end























function WoWTools_ReputationMixin:Init_MajorFactionRenownFrame()
    self:Init_CovenantRenown(MajorFactionRenownFrame)--盟约 9.0
    Init_MajorFactionRenownFrame()
end



