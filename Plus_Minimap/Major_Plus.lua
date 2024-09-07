
local e= select(2, ...)
local addName

local Save= function()
    return  WoWTools_MinimapMixin.Save
end







--派系，列表 MajorFactionRenownFrame
local function Init_MajorFactionRenownFrame()
    MajorFactionRenownFrame.WoWToolsFaction= WoWTools_ButtonMixin:Cbtn(MajorFactionRenownFrame, {size={22,22}, icon='hide'})
    function MajorFactionRenownFrame.WoWToolsFaction:set_scale()
        self.frame:SetScale(Save().MajorFactionRenownFrame_Button_Scale or 1)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_texture()
        self:SetNormalAtlas(Save().hide_MajorFactionRenownFrame_Button and 'talents-button-reset' or e.Icon.icon)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hide_MajorFactionRenownFrame_Button), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().MajorFactionRenownFrame_Button_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end
    MajorFactionRenownFrame.WoWToolsFaction:SetFrameStrata('HIGH')
    MajorFactionRenownFrame.WoWToolsFaction:SetPoint('LEFT', MajorFactionRenownFrame.CloseButton, 'RIGHT', 4, 0)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnLeave', GameTooltip_Hide)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnEnter', MajorFactionRenownFrame.WoWToolsFaction.set_tooltips)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnClick', function(self)
        Save().hide_MajorFactionRenownFrame_Button= not Save().hide_MajorFactionRenownFrame_Button and true or nil
        self:set_faction()
        self:set_texture()
        self:set_tooltips()
    end)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnMouseWheel', function(self, d)
        local n= Save().MajorFactionRenownFrame_Button_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save().MajorFactionRenownFrame_Button_Scale=n
        self:set_scale()
        self:set_tooltips()
    end)


    MajorFactionRenownFrame.WoWToolsFaction.frame=CreateFrame('Frame', nil, MajorFactionRenownFrame.WoWToolsFaction)
    MajorFactionRenownFrame.WoWToolsFaction.btn={}
    function MajorFactionRenownFrame.WoWToolsFaction:set_faction()
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
                local btn= self.btn[n]
                if not btn then
                    btn= WoWTools_ButtonMixin:Cbtn(self.frame, {size={235/2.5, 110/2.5}, icon='hide'})
                    btn:SetPoint('TOPLEFT', self.btn[n-1] or self, 'BOTTOMLEFT')
                    btn:SetHighlightAtlas('ChromieTime-Button-Highlight')
                    btn:SetScript('OnLeave', GameTooltip_Hide)
                    btn:SetScript('OnEnter', ReputationBarMixin.ShowMajorFactionRenownTooltip)
                    btn:SetScript('OnClick', function(frame)
                        if MajorFactionRenownFrame:GetCurrentFactionID()~=frame.factionID then
                            ToggleMajorFactionRenown(frame.factionID)
                        end
                    end)
                    btn.Text= e.Cstr(btn)
                    btn.Text:SetPoint('BOTTOMLEFT', btn, 'BOTTOM')
                    self.btn[n]= btn
                end
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

        --盟约
        local activityID = C_Covenants.GetActiveCovenantID() or 0
        if activityID>0 then
            for i=1, 4 do
                Set_Covenant_Button(self, i, activityID)
            end
        end

    end


    MajorFactionRenownFrame.WoWToolsFaction:set_scale()
    MajorFactionRenownFrame.WoWToolsFaction:set_texture()
    MajorFactionRenownFrame.WoWToolsFaction.HeaderText= e.Cstr(MajorFactionRenownFrame.WoWToolsFaction.frame, {color={r=1, g=1, b=1}, copyFont=MajorFactionRenownFrame.HeaderFrame.Level, justifyH='LEFT', size=14})
    MajorFactionRenownFrame.WoWToolsFaction.HeaderText:SetPoint('BOTTOMLEFT', MajorFactionRenownFrame.HeaderFrame.Level, 'BOTTOMRIGHT', 16, -4)

    function MajorFactionRenownFrame.WoWToolsFaction.HeaderText:set_text()
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
        self.WoWToolsFaction:set_faction()
        self.WoWToolsFaction.HeaderText:set_text()
    end)
end





--盟约 9.0
function WoWTools_MinimapMixin:Init_CovenantRenown()
    CovenantRenownFrame:HookScript('OnShow', function(self)
        local activityID = C_Covenants.GetActiveCovenantID() or 0
        if activityID>0 then
            for i=1, 4 do
                if Save().hide_MajorFactionRenownFrame_Button then
                    local btn= self['covenant'..i]
                    if btn then
                        btn:SetShown(false)
                    end
                else
                    local btn=Set_Covenant_Button(CovenantRenownFrame, i, activityID)
                    btn:SetShown(true)
                end
            end
        end
    end)
end









function WoWTools_MinimapMixin:Init_MajorFactionRenownFrame()
    Init_MajorFactionRenownFrame()
end



