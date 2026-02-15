--装备管理，Plus
--PaperDollFrame.lua
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end



local function Refresh()
    local frame= PaperDollFrame and PaperDollFrame.EquipmentManagerPane
    if frame and frame:IsVisible() then
        WoWTools_DataMixin:Call('PaperDollEquipmentManagerPane_OnShow', frame)
    end
end










local function Create_Button(btn)
    btn.useButton= CreateFrame('Button', nil, btn.EditButton, 'WoWToolsButtonTemplate')
    btn.useButton:SetNormalAtlas('charactercreate-icon-customize-body-selected')
    btn.useButton:SetSize(16,16)

    btn.useButton:SetPoint('BOTTOMRIGHT', btn.EditButton, 'BOTTOMLEFT')
    btn.useButton:SetScript('OnClick', function(self)
        if not C_EquipmentSet.EquipmentSetContainsLockedItems(self.setID) and not InCombatLockdown() then
            EquipmentManager_EquipSet(self.setID)
        end
    end)

    btn.useButton:SetScript('OnLeave', GameTooltip_Hide)
    btn.useButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip_SetTitle(GameTooltip, 
            WoWTools_DataMixin.Icon.icon2
            ..(C_EquipmentSet.EquipmentSetContainsLockedItems(self.setID) and '|cff606060' or '')
            ..(WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP)
        )
        GameTooltip:Show()
    end)

--件数，提示
    btn.topRight= btn:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall2')
    btn.topRight:SetPoint('TOPRIGHT' ,-2, -2)
    btn.topRight:SetJustifyH('RIGHT')

    btn.count= btn:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall2')
    btn.count:SetPoint('BOTTOMLEFT', btn.text, 0,-2)
    btn.count:SetShadowOffset(1,-1)
    --btn.count:SetJustifyH('CENTER')


--新建，空
    btn.createButton= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
    btn.createButton:SetSize(30,30)
    btn.createButton.texture= btn.createButton:CreateTexture()
    btn.createButton.texture:SetSize(20,20)
    btn.createButton.texture:SetPoint('CENTER')
    btn.createButton.texture:SetAtlas('groupfinder-eye-highlight')

    btn.createButton.str= WoWTools_DataMixin.onlyChinese and '空' or EMPTY
    btn.createButton:SetPoint('RIGHT', 0,-4)
    btn.createButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetButtonState('NORMAL')
    end)
    btn.createButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip, WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2)
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
        GearManagerPopupFrame:Hide()
    end)

    btn.Check:SetAtlas('auctionhouse-icon-checkmark')
    WoWTools_ButtonMixin:AddMask(btn, false, btn.icon)
end











local function Init()
    if Save().notEquipSetPLus then
        return
    end


    WoWTools_DataMixin:Hook('GearSetButton_OnClick', function(self, button)
        if not self.setID
            or Save().notEquipSetPLus
            or not IsModifierKeyDown()
        then
            return
        end
        if IsShiftKeyDown() then
            C_EquipmentSet.DeleteEquipmentSet(self.setID)
            GearManagerPopupFrame:Hide()
        elseif IsAltKeyDown() then
            GearSetButton_OpenPopup(self)
        end
    end)

    WoWTools_DataMixin:Hook('GearSetButton_OnEnter', function(btn)
        local setID= btn.setID
        if not setID or Save().notEquipSetPLus then
            return
        end
        GameTooltip:SetOwner(btn:GetParent(), 'ANCHOR_RIGHT')
        --GameTooltip_SetDefaultAnchor(GameTooltip, btn)
        GameTooltip:SetEquipmentSet(setID)

        GameTooltip:AddLine(' ')
        GameTooltip_AddInstructionLine(GameTooltip,
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)
            ..WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP)
            ..'>'
        )
        GameTooltip_AddInstructionLine (GameTooltip,
            '<'
            ..'Alt+'
            ..WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '修改名称/图标' or EQUIPMENT_SET_EDIT)
            ..'>'
        )
        GameTooltip_AddInstructionLine (GameTooltip,
            '<'
            ..'Shif+'
            ..WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)
            ..'>'
        )
        GameTooltip:Show()
	end)


--新建 空装，按钮 .addSetButton GearSetButtonTemplate
    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_InitButton', function(btn, elementData)
        local count, topRight, isEquipped

        if not btn.createButton then
            Create_Button(btn)
        end

        local enabled= not Save().notEquipSetPLus
        local setID= enabled and btn.setID or nil

        if setID then
            local _, _, _, equipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(setID)
            isEquipped= equipped

            if numItems>0 then
                if numInInventory>0 then
                    topRight= numInInventory..'|A:bag-main:0:0|a'
                end
                if numLost> 0 then
                    topRight= (topRight and ' '..topRight or '')..numLost..'|A:XMarksTheSpot:0:0|a'
                end
                if numIgnored>0 then
                    topRight= (topRight and ' '..topRight or '')..numIgnored..'|A:transmog-icon-disabled-small:0:0|a'
                end

                count=numEquipped..'/'..numItems
            end
        end

        btn.useButton.setID= setID

        btn.createButton:SetShown(not setID and enabled)
        btn.useButton:SetShown(setID and not isEquipped)

        btn.count:SetText(count or '')
        btn.topRight:SetText(topRight or '')

        btn.SpecRing:SetAlpha(0)
    end)


    Refresh()

    Init= Refresh
end










function WoWTools_PaperDollMixin:Init_EquipSetPlus()--装备管理，Plus
    Init()
end