--装备管理，Plus
--[[PaperDollFrame.lua
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end]]



local function Init()
--套装已装备数量
    WoWTools_DataMixin:Hook('GearSetButton_UpdateSpecInfo', function(self)
        local setID=self.setID
        local nu
        if setID then
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
    end)


--新建 空装，按钮 .addSetButton GearSetButtonTemplate
    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_InitButton', function(btn)
        local isShow= not btn.setID and true or false


        if not btn.createButton and isShow then
            btn.createButton= WoWTools_ButtonMixin:Cbtn(btn, {
                size=30,
                atlas='groupfinder-eye-highlight'
            })
            btn.createButton.str= WoWTools_DataMixin.onlyChinese and '空' or EMPTY
            btn.createButton:SetPoint('RIGHT', 0,-4)
            btn.createButton:SetScript('OnLeave', GameTooltip_Hide)
            btn.createButton:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_PaperDollMixin.addName)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(self.str,
                    C_EquipmentSet.GetEquipmentSetID(self.str)
                    and ('|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)..'|r')
                    or ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)..'|r')
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
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)..'|r', self.str)
                else
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)..'|r', self.str)
                end
            end)
        end
        if btn.createButton then
            btn.createButton:SetShown(isShow)
        end

--Hook
        if not btn.useButton and btn.setID then
            btn.useButton= WoWTools_ButtonMixin:Cbtn(btn, {
                size= 22,
                atlas= 'mechagon-projects',
            })
            btn.useButton:SetPoint('RIGHT', -28, 0)
            btn.useButton:SetScript('OnClick', function(self)
                local setID = self:GetParent().setID
                if not setID or C_EquipmentSet.EquipmentSetContainsLockedItems(setID) then
                    return
                end
                --C_EquipmentSet.UseEquipmentSet(setID)
                EquipmentManager_EquipSet(setID)
            end)

            btn.useButton:SetScript('OnLeave', function()
                GameTooltip:Hide()
            end)
            btn.useButton:SetScript('OnEnter', function(self)
                local p= self:GetParent()
                local setID = p.setID
                if not setID then
                    return
                end
                GameTooltip:SetOwner(p, 'ANCHOR_RIGHT')
                GameTooltip:SetText(
                    WoWTools_DataMixin.Icon.icon2
                    ..(C_EquipmentSet.EquipmentSetContainsLockedItems(setID) and '|cff606060' or '')
                    ..(WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP)
                )
                GameTooltip:Show()
            end)
        end
        if btn.useButton then
             btn.useButton:SetShown(btn.setID and not btn.Check:IsShown())
        end

        btn.SpecRing:SetShown(false)
    end)



    Init=function()end
end










function WoWTools_PaperDollMixin:Init_EquipSetPlus()--装备管理，Plus
    Init()
end