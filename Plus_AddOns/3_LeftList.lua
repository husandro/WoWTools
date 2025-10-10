
local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end
local Buttons={}--快捷键
local LeftFrame
local Name= 'WoWToolsAddOnsLeftListButton'









local function Create_Fast_Button(index)
    local btn= WoWTools_ButtonMixin:Cbtn(LeftFrame, {
        size=23,
        name=Name..index,
    })
    btn.Text= WoWTools_LabelMixin:Create(btn, {size=14})
    btn.Text:SetPoint('RIGHT', btn, 'LEFT')

    btn.checkTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.checkTexture:SetAtlas('GarrMission_EncounterBar-CheckMark')
    btn.checkTexture:SetPoint('BOTTOMRIGHT', 4, -2)
    btn.checkTexture:SetSize(16,16)

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
        WoWTools_AddOnsMixin:LevelButtonTip(self)
        GameTooltip_Hide()
        self.Text:SetAlpha(1)
    end)
    function btn:set_tooltips()
        AddonTooltip:SetOwner(self.Text, "ANCHOR_LEFT")
        AddonTooltip_Update(self)
        AddonTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.left
            ..WoWTools_TextMixin:GetEnabeleDisable(nil, true),

          (WoWTools_DataMixin.onlyChinese and '转向' or NPE_TURN)
            ..WoWTools_DataMixin.Icon.right
            ..self:GetID()
        )
        AddonTooltip:Show()
    end
    btn:SetScript('OnEnter', function(self)
        local i2= self:GetID()
        if i2 and C_AddOns.GetAddOnInfo(i2)==self.name then
            self:set_tooltips()
        else
           local findIndex
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.GetAddOnName(i)== self.name then
                    findIndex= i
                    Save().fast[self.name]= i
                    self:set_tooltips()
                    break
                end
            end
            if not findIndex then
                local name, atlas, texture= self:get_add_info()
                local icon= atlas and format('|A:%s:26:26|a', atlas) or (texture and format('|T%d:26|t', texture)) or ''
                GameTooltip:SetOwner(self.Text, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(icon..name)
                GameTooltip:Show()
                findIndex= 0
            else
                i2=findIndex
            end
            self:SetID(findIndex)
        end
        if i2 and i2>0 then
           WoWTools_AddOnsMixin:EnterButtonTip(self)
        end
        self.Text:SetAlpha(0.3)
    end)

--AddonList_Enable(index, enabled)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            if C_AddOns.GetAddOnEnableState(self.name)~=0 then
                C_AddOns.DisableAddOn(self.name)
            else
                C_AddOns.EnableAddOn(self.name)
            end
            WoWTools_DataMixin:Call(AddonList_Update)
            self:set_tooltips()
        else
           WoWTools_AddOnsMixin:FindAddon(self:GetID())
        end
    end)

    if index==1 then
        btn:SetPoint('TOPRIGHT', LeftFrame)
    else
        btn:SetPoint('TOPRIGHT', _G[Name..(index-1)], 'BOTTOMRIGHT')
    end

    table.insert(Buttons, index)

    return btn
end












local function Set_Left_Buttons()
    if not LeftFrame:IsShown() then
        return
    end

    local newTab={}
    local max= C_AddOns.GetNumAddOns()
    for name, index in pairs(Save().fast) do
        index= type(index)=='number' and index or 1
        if C_AddOns.DoesAddOnExist(name) then
            table.insert(newTab, {name=name, index=index})
        else
            Save().fast[name]= nil
        end
    end
    table.sort(newTab, function(a, b) return a.index< b.index end)

    local btn
    local w=0
    for i, info in pairs(newTab) do
        btn= _G[Name..i] or Create_Fast_Button(i)
        btn.name= info.name
        btn:SetID(math.min(i, max))
        btn:settings()
        btn:SetShown(true)
        w= math.max(w, btn.Text:GetStringWidth())
    end

    if btn then
        LeftFrame.Background:SetPoint('BOTTOMLEFT', btn, -2-w, -2)
    end
    LeftFrame.Background:SetShown(btn and true or false)

    for i= #newTab +1, #Buttons do
        btn= _G[Name..i]
        btn:SetShown(false)
        btn.name=nil
    end
end











--hooksecurefunc(AddonListEntryMixin, 'OnLoad', function()



local function Init()
    if Save().hideLeftList then
        return
    end

    LeftFrame= CreateFrame("Frame", 'WoWToolsAddOnsLeftFrame', AddonListCloseButton)
    LeftFrame:SetSize(1,1)
    LeftFrame:SetPoint('TOPRIGHT', AddonList, 'TOPLEFT', -2, -3)

    LeftFrame.Background= LeftFrame:CreateTexture(nil, 'BACKGROUND')
    LeftFrame.Background:SetPoint('TOPRIGHT', LeftFrame, 2, 0)
    LeftFrame.Background:SetColorTexture(0,0,0)

    function LeftFrame:settings()
        self:SetScale(Save().leftListScale or 1)
        self:SetShown(not Save().hideLeftList)
        self.Background:SetAlpha(Save().bgAlpha or 0.3)
    end

    LeftFrame:settings()
    Set_Left_Buttons()

    WoWTools_DataMixin:Hook('AddonList_Update', function()
        Set_Left_Buttons()
    end)


    --Menu.ModifyMenu("MENU_ADDON_LIST_ENTRY", function(self, root, desc, menu)


    Init= function()
        LeftFrame:settings()
        Set_Left_Buttons()
    end
end











function WoWTools_AddOnsMixin:Init_Left_Buttons()
    Init()
end
