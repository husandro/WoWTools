
local e= select(2, ...)
local function Save()
    return WoWTools_AddOnsMixin.Save
end
local BottomFrame--已加载，插件列表






--已加载，插件列表
local function Set_Load_Button()--LoadButtons
    BottomFrame:SetShown(Save().load_list)
    if not Save().load_list then
        return
    end

    local newTab={}
    for i=1, C_AddOns.GetNumAddOns() do
        if not C_AddOns.GetAddOnDependencies(i) then
            local texture = C_AddOns.GetAddOnMetadata(i, "IconTexture")
            local atlas = C_AddOns.GetAddOnMetadata(i, "IconAtlas")
            if texture or atlas then
                if C_AddOns.IsAddOnLoaded(i) then
                    table.insert(newTab, 1, {index=i, load=true, atlas=atlas, texture=texture})
                elseif select(2, C_AddOns.IsAddOnLoadable(i))=='DEMAND_LOADED' then
                    table.insert(newTab, 1, {index=i, load=false, atlas=atlas, texture=texture})
                else
                    table.insert(newTab, {index=i, disabled=true, atlas=atlas, texture=texture})
                end
            end
        end
    end

    for i, info in pairs(newTab) do
       local btn= BottomFrame.buttons[i]
       if not btn then
            btn= WoWTools_ButtonMixin:Cbtn(BottomFrame)
            btn.texture= btn:CreateTexture(nil, 'BORDER')
            btn.texture:SetAllPoints(btn)
            btn.texture2= btn:CreateTexture(nil, 'OVERLAY')
            btn.texture2:SetAllPoints(btn)
            btn.texture2:SetAtlas('Forge-ColorSwatchSelection')
            --btn.Text= WoWTools_LabelMixin:Create(btn)
            --btn.Text:SetPoint('CENTER')
            btn:SetScript('OnLeave', function(self)
                if self.findFrame then
                    if self.findFrame.check then
                        self.findFrame.check:set_leave_alpha()
                    end
                    self.findFrame=nil
                end
                GameTooltip_Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                AddonTooltip:SetOwner(self:GetParent().buttons[1], "ANCHOR_RIGHT")
                AddonTooltip_Update(self)
                AddonTooltip:AddLine(' ')
                local addonIndex= self:GetID()
                local character = UIDropDownMenu_GetSelectedValue(AddonList.Dropdown);
                if ( character == true ) then
                    character = nil;
                end
                local loadable, reason = C_AddOns.IsAddOnLoadable(addonIndex, character)
                local checkboxState = C_AddOns.GetAddOnEnableState(addonIndex, character);
                if ( not InGlue() ) then
                    enabled = (C_AddOns.GetAddOnEnableState(addonIndex, UnitName("player")) > Enum.AddOnEnableState.None);
                else
                    enabled = (checkboxState > Enum.AddOnEnableState.None);
                end
                local col
                if ( loadable or ( enabled and (reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED") ) ) then
                    col='|cffffc600'
                elseif ( enabled and reason ~= "DEP_DISABLED" ) then
                    col='|cffff1919'
                else
                    col='|cff999999'
                end
                AddonTooltip:AddDoubleLine(
                    reason and col..(WoWTools_TextMixin:CN(_G["ADDON_"..reason]) or ' ') or ' ',
                    format('%s%s', WoWTools_Mixin.onlyChinese and '查询' or WHO, WoWTools_DataMixin.Icon.left)
                )

                AddonTooltip:Show()
                self:SetAlpha(1)
            end)
            btn:SetScript('OnClick', function(self)
                local findIndex= self:GetID()
                AddonList.ScrollBox:ScrollToElementDataIndex(findIndex)
                for _, frame in pairs(AddonList.ScrollBox:GetFrames() or {}) do
                    if frame:GetID()==findIndex then
                        if frame.check then
                            frame.check:set_enter_alpha()
                            self.findFrame=frame
                        end
                        break
                    end
                end
            end)
            BottomFrame.buttons[i]= btn
       end

       if info.texture then
            btn.texture:SetTexture(info.texture)
       elseif info.atlas then
            btn.texture:SetAtlas(info.atlas)
       end
       btn:SetID(info.index)
       btn.load= info.load
       btn.disabled= info.disabled
       btn.texture2:SetShown(not info.disabled)
       btn:SetShown(true)
    end
    for i=#newTab +1,  #BottomFrame.buttons do
        local btn= BottomFrame.buttons[i]
        if btn then
            btn:SetShown(false)
        end
    end
    BottomFrame:set_button_point()
end



















local function Init()
    BottomFrame= CreateFrame('Frame', 'WoWTools_AddOnsBottomFrame', WoWTools_AddOnsMixin.MenuButton)

    BottomFrame:SetSize(1,1)
    function BottomFrame:set_frame_point()
        BottomFrame:ClearAllPoints()
        if Save().load_list_top then
            BottomFrame:SetPoint('BOTTOMRIGHT', AddonList, 'TOPRIGHT', 1, 2)
        else
            BottomFrame:SetPoint('TOPRIGHT', AddonList, 'BOTTOMRIGHT', 1, -2)
        end
    end
    BottomFrame.buttons={}
    function BottomFrame:set_button_point()
        local last= self
        for _, btn in pairs(self.buttons) do
            btn:SetSize(Save().load_list_size, Save().load_list_size)
            btn:ClearAllPoints()
            if Save().load_list_top then
                btn:SetPoint('BOTTOMRIGHT', last, 'BOTTOMLEFT')
            else
                btn:SetPoint('TOPRIGHT', last, 'TOPLEFT')
            end
            last=btn
        end
        local num= math.modf((AddonList:GetWidth()+12)/Save().load_list_size)
        num= num<4 and 4 or num
        for i=num+1, #self.buttons, num do
            local btn= self.buttons[i]
            btn:ClearAllPoints()
            if Save().load_list_top then
                btn:SetPoint('BOTTOMRIGHT', self.buttons[i- num], 'TOPRIGHT')
            else
                btn:SetPoint('TOPRIGHT', self.buttons[i- num], 'BOTTOMRIGHT')
            end
        end
    end
    AddonList:HookScript('OnSizeChanged', function()
        BottomFrame:set_button_point()
    end)
    AddonList:HookScript('OnShow', function()
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        Set_Load_Button()
    end)
    BottomFrame:set_frame_point()



    function BottomFrame:Set_Load_Button()
        Set_Load_Button()
    end

    WoWTools_AddOnsMixin.BottomFrame= BottomFrame
end











function WoWTools_AddOnsMixin:Init_Load_Button()
    Init()
end