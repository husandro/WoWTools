--装备管理，Plus
--PaperDollFrame.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end












local function Setttings(btn)
    if Save().hide then
        if btn.createButton then
            btn.createButton:SetShown(false)
        end
        return
    end

    
    if not btn.setID and not btn.createButton  then
        btn.createButton= WoWTools_ButtonMixin:Cbtn(btn, {size=30, atlas='groupfinder-eye-highlight'})
        btn.createButton.str= WoWTools_Mixin.onlyChinese and '空' or EMPTY
        btn.createButton:SetPoint('RIGHT', 0,-4)
        btn.createButton:SetScript('OnLeave', GameTooltip_Hide)
        btn.createButton:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(self.str,
                C_EquipmentSet.GetEquipmentSetID(self.str)
                and ('|cffff00ff'..(WoWTools_Mixin.onlyChinese and '修改' or EDIT)..'|r')
                or ('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '新建' or NEW)..'|r')
            )
            GameTooltip:Show()
        end)

        btn.createButton:SetScript('OnClick', function(self)
            local setID= C_EquipmentSet.GetEquipmentSetID(self.str)
            if setID then
                C_EquipmentSet.DeleteEquipmentSet(setID)
            end
            for i=1, 18 do
                C_EquipmentSet.IgnoreSlotForSave(i)
            end
            C_EquipmentSet.CreateEquipmentSet(self.str)
            if setID then
                print(e.Icon.icon2..WoWTools_PaperDollMixin.addName, '|cffff00ff'..(WoWTools_Mixin.onlyChinese and '修改' or EDIT)..'|r', self.str)
            else
                print(e.Icon.icon2..WoWTools_PaperDollMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '新建' or NEW)..'|r', self.str)
            end
        end)
    end
    if btn.createButton then
        btn.createButton:SetShown(not btn.setID and true or false)
    end

    if not btn.setScripOK then
        btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
        btn:HookScript('OnClick', function(self, d)
            if self.setID and not Save().hide and d=='RightButton' then
                local notCan= WoWTools_ItemMixin:IsCan_EquipmentSet(self.setID)
                if notCan then
                    print(e.Icon.icon2..WoWTools_PaperDollMixin.addName, notCan)
                else
                    C_EquipmentSet.UseEquipmentSet(self.setID)
                    local name, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                    print(e.Icon.icon2..WoWTools_PaperDollMixin.addName, iconFileID and '|T'..iconFileID..':0|t|cnGREEN_FONT_COLOR:' or '', name)
                end
            end
        end)

        btn:HookScript('OnEnter', function(self)
            if self.setID and not Save().hide then
                local notCan= WoWTools_ItemMixin:IsCan_EquipmentSet(self.setID)
                GameTooltip:AddDoubleLine(notCan or ' ', (notCan and '|cff9e9e9e' or '')..(WoWTools_Mixin.onlyChinese and '装备' or EQUIPSET_EQUIP)..e.Icon.right)
                GameTooltip:Show()
            end
        end)
        btn.setScripOK=true
    end
end








--套装已装备数量
local function UpdateSpecInfo(self)
    local setID=self.setID
    local nu
    if setID and not Save().hide then
        if not self.nu then
            self.nu=WoWTools_LabelMixin:Create(self)
            self.nu:SetJustifyH('RIGHT')
            self.nu:SetPoint('BOTTOMLEFT', self.text, 'BOTTOMLEFT')
        end
        local  numItems, numEquipped= select(5, C_EquipmentSet.GetEquipmentSetInfo(setID))
        if numItems and numEquipped then
            nu=numEquipped..'/'..numItems
        end
    end
    if self.nu then
        self.nu:SetText(nu or '')
    end
end










local function Init()
    hooksecurefunc('GearSetButton_UpdateSpecInfo', UpdateSpecInfo)--套装已装备数量
    hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', Setttings)
end










function WoWTools_PaperDollMixin:Init_Tab3_Set_Plus()
    Init()
end