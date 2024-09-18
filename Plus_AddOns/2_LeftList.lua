local e= select(2, ...)
local function Save()
    return WoWTools_AddOnsMixin.Save
end
local FastButtons={}--快捷键
local LeftFrame










local function Create_Fast_Button(indexAdd)
    local btn= WoWTools_ButtonMixin:Cbtn(LeftFrame, {size=23})
    btn.Text= WoWTools_LabelMixin:CreateLabel(btn, {size=14})
    btn.Text:SetPoint('RIGHT', btn, 'LEFT')
    btn.checkTexture= btn:CreateTexture()
    btn.checkTexture:SetAtlas('AlliedRace-UnlockingFrame-Checkmark')
    btn.checkTexture:SetSize(16,16)
    btn.checkTexture:SetPoint('RIGHT', btn.Text, 'LEFT',0,-2)
    function btn:get_add_info()
        local atlas = C_AddOns.GetAddOnMetadata(self.name, "IconAtlas")
        local texture = C_AddOns.GetAddOnMetadata(self.name, "IconTexture")
        local name, title = C_AddOns.GetAddOnInfo(self.name)
        name= title or name or self.name or ''
        return name, atlas, texture
    end
    function btn:settings()
        local name, atlas, texture= self:get_add_info()
        if texture then
            self:SetNormalTexture(texture)
        elseif atlas then
            self:SetNormalAtlas(atlas)
        else
            self:SetNormalTexture(0)
        end
        self.Text:SetText(name or self.name)
        if C_AddOns.GetAddOnEnableState(self.name)~=0 then
            self.Text:SetTextColor(0,1,0)
            self.checkTexture:SetShown(true)
        else
            self.Text:SetTextColor(1, 0.82,0)
            self.checkTexture:SetShown(false)
        end
    end
    btn:SetScript('OnLeave', function(self)
        if self.findFrame then
            if self.findFrame.check then
                self.findFrame.check:set_leave_alpha()
            end
            self.findFrame=nil
        end
        GameTooltip_Hide()
        self.Text:SetAlpha(1)
    end)
    function btn:set_tooltips()
        AddonTooltip:SetOwner(self.checkTexture, "ANCHOR_LEFT")
        AddonTooltip_Update(self)
        AddonTooltip:AddLine(' ')
        AddonTooltip:AddDoubleLine(' ', e.GetEnabeleDisable(C_AddOns.GetAddOnEnableState(self:GetID())~=0)..e.Icon.left)
        AddonTooltip:Show()
    end
    btn:SetScript('OnEnter', function(self)
        local index= self:GetID()
        if C_AddOns.GetAddOnInfo(index)==self.name then
            self:set_tooltips()
        else
           local findIndex
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.GetAddOnInfo(i)== self.name then
                    findIndex= i
                    self:SetID(i)
                    Save().fast[self.name]= i
                    self:set_tooltips()
                    break
                end
            end
            if not findIndex then
                local name, atlas, texture= self:get_add_info()
                local icon= atlas and format('|A:%s:26:26|a', atlas) or (texture and format('|T%d:26|t', texture)) or ''
                e.tips:SetOwner(self.Text, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(icon..name)
                e.tips:Show()
            else
                index=findIndex
            end
        end
        if index then
            AddonList.ScrollBox:ScrollToElementDataIndex(index)
            for _, frame in pairs( AddonList.ScrollBox:GetFrames() or {}) do
                if frame:GetID()==index then
                    if frame.check then
                        frame.check:set_enter_alpha()
                        self.findFrame=frame
                    end
                    break
                end
            end
        end
        self.Text:SetAlpha(0.3)
    end)
    btn:SetScript('OnClick', function(self)
        if C_AddOns.GetAddOnEnableState(self.name)~=0 then
            C_AddOns.DisableAddOn(self.name)
        else
            C_AddOns.EnableAddOn(self.name)
        end
        e.call(AddonList_Update)
        self:set_tooltips()
    end)
    if indexAdd==1 then
        btn:SetPoint('TOPRIGHT', LeftFrame)
    else
        btn:SetPoint('TOPRIGHT', FastButtons[indexAdd-1], 'BOTTOMRIGHT')
    end
    FastButtons[indexAdd]= btn
    return btn
end














function WoWTools_AddOnsMixin:Init_Left_Buttons()
    LeftFrame= CreateFrame("Frame", nil, AddonList)
    LeftFrame:SetSize(1,1)
    LeftFrame:SetPoint('TOPRIGHT', AddonList, 'TOPLEFT')
    function LeftFrame:settings()
        self:SetScale(Save().leftListScale or 1)
        self:SetShown(not Save().hideLeftList)
    end
    LeftFrame:settings()

    WoWTools_AddOnsMixin.LeftFrame= LeftFrame
end












--插件，快捷，选中
function WoWTools_AddOnsMixin:Set_Left_Buttons()
    if not self.LeftFrame:IsShown() then
        return
    end

    local newTab={}
    for name, index in pairs(Save().fast) do
        if C_AddOns.DoesAddOnExist(name) then
            table.insert(newTab, {name=name, index=index or 0})
        else
            Save().fast[name]= nil
        end
    end
    table.sort(newTab, function(a, b) return a.index< b.index end)

    for i, info in pairs(newTab) do
        local btn= FastButtons[i] or Create_Fast_Button(i)
        btn.name= info.name
        btn:SetID(info.index)
        btn:settings()
        btn:SetShown(true)
    end
    for i= #newTab +1, #FastButtons do
        local btn= FastButtons[i]
        if btn then
            btn:SetShown(false)
            btn.name=nil
        end
    end
end