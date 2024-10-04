--套装，标签, 内容,提示
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end






local NameLabel, SetTexture, SpecTexture, NumLabel

local function Set_Tooltip(frame)
    frame:EnableMouse(true)
    frame:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    frame:SetScript('OnMouseDown', function()
        e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab3, 3)--PaperDollFrame.lua
    end)
    frame:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if self.setID then
            e.tips:SetEquipmentSet(self.setID)
            e.tips:AddLine(' ')
        end
        e.tips:AddDoubleLine(self.tooltip, self.tooltip2, 0,1,0,0,1,0)
        --e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
end




local function Init()
    local w, h
--套装，名称
    NameLabel=WoWTools_LabelMixin:Create(PaperDollSidebarTab3, {justifyH='CENTER'})
    NameLabel:SetPoint('BOTTOM', 2, 0)
    Set_Tooltip(NameLabel)
    NameLabel.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '名称' or NAME)..'|r'

--套装图标图标
    SetTexture=PaperDollSidebarTab3:CreateTexture(nil, 'OVERLAY')
    SetTexture:SetPoint('CENTER',1,-2)
    w, h= PaperDollSidebarTab3:GetSize()
    SetTexture:SetSize(w-4, h-4)

--天赋图标
    SpecTexture=PaperDollSidebarTab3:CreateTexture(nil, 'OVERLAY')
    SpecTexture:SetPoint('BOTTOMLEFT', PaperDollSidebarTab3, 'BOTTOMRIGHT')
    h, w= PaperDollSidebarTab3:GetSize()
    SpecTexture:SetSize(h/3+2, w/3+2)
    Set_Tooltip(SpecTexture)
    SpecTexture.tooltip= '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)..'|r'

--套装数量
    NumLabel=WoWTools_LabelMixin:Create(PaperDollSidebarTab3, {justifyH='RIGHT'})
    NumLabel:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT',0, 4)
    NumLabel.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '装备' or EQUIPSET_EQUIP)
    Set_Tooltip(NumLabel)
end




local function Get_SetInfo()
    local name, icon, specIcon, nu, specName, setID
    local setIDs=C_EquipmentSet.GetEquipmentSetIDs()
    for _, v in pairs(setIDs) do
        local name2, icon2, _, isEquipped, numItems= C_EquipmentSet.GetEquipmentSetInfo(v)
        if isEquipped then
            name=name2
            name=WoWTools_TextMixin:sub(name, 2, 5)
            if icon2 and icon2~=134400 then
                icon=icon2
            end
            local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(v)
            if specIndex then
                local _, specName2, _, icon3 = GetSpecializationInfo(specIndex)
                specName= specName2
                if icon3 then
                    specIcon=icon3
                end
            end
            nu=numItems
            setID= v
            break
        end
    end

    return name, icon, specIcon, nu, specName, setID
end






local function Settings()--标签, 内容,提示
    local name, icon, specIcon, nu, specName, setID

    if not Save().hide then
        name, icon, specIcon, nu, specName, setID= Get_SetInfo()
    end

--套装，名称
    NameLabel:SetText(name or '')
    NameLabel.tooltip2= name
    NameLabel.setID= setID

--套装图标图标
    SetTexture:SetTexture(icon or 0)
    SetTexture:SetShown(icon and true or false)

--天赋图标
    SpecTexture:SetTexture(specIcon or 0)
    SpecTexture:SetShown(specIcon and true or false)
    SpecTexture.tooltip2= specIcon and (specIcon and "|T"..specIcon..':0|t' or '')..specName or nil
    SpecTexture.setID= setID

--套装数量
    NumLabel:SetText(nu or '')
    NumLabel.tooltip2= nu and (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..nu or nil
    NumLabel.setID= setID
end








function WoWTools_PaperDollMixin:Init_Tab3()
    Init()
end


function WoWTools_PaperDollMixin:Settings_Tab3()
    Settings()
end