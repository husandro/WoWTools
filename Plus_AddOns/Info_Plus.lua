local e= select(2, ...)
local function Save()
    return WoWTools_AddOnsMixin.Save
end














--依赖，移过，提示
local function Find_AddOn_Dependencies(find, check)--依赖，提示
    local addonIndex= check:GetID()
    local tab={}
    for _, depName in pairs({C_AddOns.GetAddOnDependencies(addonIndex)}) do
        tab[depName]=true
    end
    for _, frame in pairs(AddonList.ScrollBox:GetFrames() or {}) do
        if frame.check then
            local show=false
            if find then
                local index= frame:GetID()
                if index== addonIndex or tab[C_AddOns.GetAddOnInfo(index)] then
                    show=true
                end
            end
            frame.check.select:SetShown(show)
        end
    end
end













local function Create_Check(frame)
    if frame.check then
        return
    end
    frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")

    frame.check:SetSize(20,20)--Fast，选项

    frame.check:SetPoint('RIGHT', frame)
    frame.check:SetScript('OnClick', function(self)
        Save().fast[self.name]= not Save().fast[self.name] and self:GetID() or nil
        WoWTools_AddOnsMixin:Set_Left_Buttons()
    end)

    frame.check.dep= frame:CreateLine()--依赖，提示
    frame.check.dep:Hide()
    frame.check.dep:SetColorTexture(1, 0.82, 0)
    frame.check.dep:SetStartPoint('BOTTOMLEFT', 55,2)
    frame.check.dep:SetEndPoint('BOTTOMRIGHT', -20,2)
    frame.check.dep:SetThickness(0.5)
    frame.check.dep:SetAlpha(0.2)

    frame.check.select= frame:CreateTexture(nil, 'OVERLAY')--光标，移过提示
    frame.check.select:SetAtlas('CreditsScreen-Selected')
    frame.check.select:SetAllPoints(frame)
    frame.check.select:Hide()

    frame.check.Text:SetParent(frame)--索引
    frame.check.Text:ClearAllPoints()
    frame.check.Text:SetPoint('RIGHT', frame.check, 'LEFT')

    frame.check.memoFrame= CreateFrame("Frame", nil, frame.check)
    frame.check.memoFrame.Text= WoWTools_LabelMixin:CreateLabel(frame, {justifyH='RIGHT'})
    frame.check.memoFrame.Text:SetPoint('RIGHT', frame.Status, 'LEFT')
    frame.check.memoFrame.Text:SetAlpha(0.5)
    frame.check.memoFrame:Hide()
    frame.check.memoFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 3) + elapsed
        if self.elapsed > 3 then
            self.elapsed = 0
            self.Text:SetText(WoWTools_AddOnsMixin:Get_MenoryValue(self:GetID(), false) or '')
        end
    end)
    frame.check.memoFrame:SetScript('OnHide', function(self)
        self.Text:SetText('')
        self.elapsed=nil
    end)


    function frame.check:set_leave_alpha()
        local addonIndex= self:GetID()
        self:SetAlpha(Save().fast[self.name] and 1 or 0)
        self.Text:SetAlpha(C_AddOns.GetAddOnDependencies(addonIndex) and 0.3 or 1)
        local check= self:GetParent().Enabled
        check:SetAlpha(check:GetChecked() and 1 or 0)
        Find_AddOn_Dependencies(false, self)--依赖，移过，提示
    end
    function frame.check:set_enter_alpha()
        self:SetAlpha(1)
        self.Text:SetAlpha(1)
        self:GetParent().Enabled:SetAlpha(1)
        Find_AddOn_Dependencies(true, self)--依赖，移过，提示
    end


    frame.check:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:set_leave_alpha()
    end)
    frame.check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_AddOnsMixin.addName)
        local addonIndex= self:GetID()
        local icon= select(3, WoWTools_TextureMixin:IsAtlas( C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture") or C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas"))) or ''--Atlas or Texture
        e.tips:AddDoubleLine(
            format('%s%s |cnGREEN_FONT_COLOR:%d|r', icon, self.name or '', addonIndex),
            format('%s%s', e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, e.Icon.left)
        )
        e.tips:Show()
        self:set_enter_alpha()
    end)
    frame.Enabled:HookScript('OnLeave', function(self)
        self:GetParent().check:set_leave_alpha()
    end)
    frame.Enabled:HookScript('OnEnter', function(self)
        self:GetParent().check:set_enter_alpha()
    end)
    frame:HookScript('OnLeave', function(self)
        self.check:set_leave_alpha()
    end)
    frame:HookScript('OnEnter', function(self)
        self.check:set_enter_alpha()
    end)
end















   
--列表，内容
local function Init_Set_List(frame, addonIndex)
    Create_Check(frame)

    local name, title= C_AddOns.GetAddOnInfo(addonIndex)
    local isChecked= Save().fast[name] and true or false
    if isChecked then
        Save().fast[name]= addonIndex
    end

    local iconTexture = C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture")
    local iconAtlas = C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas")

    if not iconTexture and not iconAtlas then--去掉，没有图标，提示
       frame.Title:SetText('       '..(title or name))
    end

    frame.check:SetID(addonIndex)
    frame.check:SetCheckedTexture(iconTexture or e.Icon.icon)
    frame.check.name= name
    frame.check.isDependencies= C_AddOns.GetAddOnDependencies(addonIndex) and true or nil
    frame.check:SetChecked(isChecked)--fast
    frame.check:SetAlpha(isChecked and 1 or 0.1)

    frame.check.Text:SetText(addonIndex or '')--索引
    frame.check.memoFrame:SetID(addonIndex)
    frame.check.memoFrame:SetShown(C_AddOns.IsAddOnLoaded(addonIndex))


    if frame.check.isDependencies then--依赖
        frame.check.select:SetVertexColor(0,1,0)
        frame.check.Text:SetTextColor(0.5,0.5,0.5)
        frame.check.Text:SetAlpha(0.3)
        frame.check.dep:SetShown(false)
    else
        frame.check.select:SetVertexColor(1,1,1)
        frame.check.Text:SetTextColor(1, 0.82, 0)
        frame.check.Text:SetAlpha(1)
        frame.check.dep:SetShown(true)
    end
    frame.Status:SetAlpha(0.5)
    frame.Enabled:SetAlpha(frame.Enabled:GetChecked() and 1 or 0)
end


















local function Init()
    hooksecurefunc('AddonList_InitButton', function(frame, addonIndex)
        frame.Title:SetPoint('RIGHT', -220, 0 )
        Init_Set_List(frame, addonIndex)--列表，内容
    end)

    hooksecurefunc('AddonTooltip_Update', function(frame)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况

        local index= frame:GetID()
        local va= WoWTools_AddOnsMixin:Get_MenoryValue(index, true)
        if va then
            local iconTexture = C_AddOns.GetAddOnMetadata(index, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or ''
            AddonTooltip:AddLine(icon..va, 1,0.82,0)
            AddonTooltip:Show()
        end
    end)

    hooksecurefunc('AddonList_Update', function()
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
    end)
end










function WoWTools_AddOnsMixin:Init_Info_Plus()
    if not Save().disabledInfoPlus then
        Init()
    end
end