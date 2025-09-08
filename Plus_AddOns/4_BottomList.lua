
local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end
local BottomFrame--已加载，插件列表
local Buttons={}
local Name= 'WoWToolsAddOnsBottomListButton'







local function Create_Button(index)
    if _G[Name..index] then
        return _G[Name..index]
    end

    local btn= WoWTools_ButtonMixin:Cbtn(BottomFrame, {
        name=Name..index
    })

    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetAllPoints(btn)
    btn.texture2= btn:CreateTexture(nil, 'OVERLAY')
    btn.texture2:SetPoint('TOPLEFT',-2,2)
    btn.texture2:SetPoint('BOTTOMRIGHT', 2, -2)
    btn.texture2:SetVertexColor(0,1,0)
    btn.texture2:SetAtlas('Forge-ColorSwatchSelection')
    
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
        AddonTooltip:SetOwner(_G[Name..'1'], "ANCHOR_RIGHT")
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
            format('%s%s', WoWTools_DataMixin.onlyChinese and '查询' or WHO, WoWTools_DataMixin.Icon.left)
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

     table.insert(Buttons, index)

    return btn
end


















--已加载，插件列表
local function Set_Load_Button()--LoadButtons
    local isShow= Save().load_list

    BottomFrame:SetShown(isShow)

    if not isShow then
        return
    end

    local size= Save().load_list_size or 23
    local toTop= Save().load_list_top

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
       local btn= Create_Button(i)

       btn:ClearAllPoints()
        if toTop then
            btn:SetPoint('BOTTOMRIGHT', _G[Name..(i-1)] or BottomFrame, 'BOTTOMLEFT')
        else
            btn:SetPoint('TOPRIGHT', _G[Name..(i-1)] or BottomFrame, 'TOPLEFT')
        end

        btn:SetSize(size, size)

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

    local num= math.modf((AddonList:GetWidth()+12)/size)
    num= num<4 and 4 or num

    for i=num+1, #Buttons, num do
        local btn= _G[Name..i]
        btn:ClearAllPoints()
        if toTop then
            btn:SetPoint('BOTTOMRIGHT', _G[Name..(i- num)], 'TOPRIGHT')
        else
            btn:SetPoint('TOPRIGHT', _G[Name..(i- num)], 'BOTTOMRIGHT')
        end
    end

    for i=#newTab +1,  #Buttons do
        local btn= _G[Name..i]
        btn:SetShown(false)
        btn.load= nil
        btn.disabled= nil
    end
end



















local function Init()
    if not Save().load_list then
        return
    end

    BottomFrame= CreateFrame('Frame', 'WoWToolsAddOnsBottomFrame', AddonListCloseButton)

    BottomFrame:SetSize(1,1)
    BottomFrame:Hide()

    function BottomFrame:set_point()
        BottomFrame:ClearAllPoints()
        if Save().load_list_top then
            BottomFrame:SetPoint('BOTTOMRIGHT', AddonList, 'TOPRIGHT', 1, 2)
        else
            BottomFrame:SetPoint('TOPRIGHT', AddonList, 'BOTTOMRIGHT', 1, -2)
        end
    end


    AddonList:HookScript('OnSizeChanged', function()
        if BottomFrame:IsShown() then
            Set_Load_Button()
        end
    end)

    BottomFrame:set_point()
    Set_Load_Button()

    Init=function()
        BottomFrame:set_point()
        Set_Load_Button()
        
    end
end











function WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    Init()
end
