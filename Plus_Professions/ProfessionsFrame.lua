if PlayerGetTimerunningSeasonID() then
    return
end

--Blizzard_TrainerUI
local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end












local function Init()
    --###
    --数量
    --Blizzard_Professions.lua  ProfessionsRecipeSchematicFormMixin:Init
    hooksecurefunc(Professions,'SetupOutputIconCommon', function(outputIcon, quantityMin, quantityMax, icon, itemIDOrLink, quality)
        local num
        if itemIDOrLink then
            num= C_Item.GetItemCount(itemIDOrLink, true, false, true)
            local itemID= C_Item.GetItemInfoInstant(itemIDOrLink)
            if itemID then
                local all= 0--帐号数据
                for guid, info in pairs(WoWTools_WoWDate or {}) do
                    if guid and info and guid~=WoWTools_DataMixin.Player.GUID then
                        local tab=info.Item[itemID]
                        if tab and tab.bag and tab.bank then
                           all= all+1
                        end
                    end
                end
                if all>0 then
                    num= num..' (+'..all..')'
                end
            end
        end
        if not outputIcon.countBag and num then
            outputIcon.countBag= WoWTools_LabelMixin:Create(outputIcon, {color={r=0,g=1,b=0}, justifyH='CENTER'})--nil, nil, nil, {0,1,0}, nil, 'CENTER')
            outputIcon.countBag:SetPoint('BOTTOM', outputIcon, 'TOP',0,5)
        end
        if outputIcon.countBag then
            outputIcon.countBag:SetText(num or '')
        end
    end)


    --##################
    --移过，列表，物品提示
    --Blizzard_ProfessionsRecipeList.lua
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'OnEnter', function(self)
        local elementData = self:GetElementData()
        local info= elementData and elementData.data and elementData.data.recipeInfo
        if not info or not info.recipeID then
            return
        end

        local tradeSkillID, _, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(info.recipeID)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT", -18, 0)
        GameTooltip:ClearLines()
        GameTooltip:SetRecipeResultItem(info.recipeID, {}, nil, info.unlockedRecipeLevel)
        GameTooltip:AddLine(' ')

        local text= WoWTools_TextMixin:CN(nil, {recipeID=info.recipeID}) or C_TradeSkillUI.GetRecipeSourceText(info.recipeID)
        if text then
            GameTooltip:AddLine(text, nil, nil, nil, true)
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddLine(info.categoryID and 'categoryID '..info.categoryID, tradeSkillID and 'tradeSkillID '..tradeSkillID or (info.sourceType and 'sourceType'..info.sourceType))
        GameTooltip:AddDoubleLine('recipeID '..info.recipeID, parentTradeSkillID and 'parentTradeSkillID '..parentTradeSkillID)
        if info.itemLevel or info.skillLineAbilityID then
            GameTooltip:AddDoubleLine(info.skillLineAbilityID and 'skillLineAbilityID '..info.skillLineAbilityID,  info.itemLevel and info.itemLevel>1 and format(WoWTools_Mixin.onlyChinese and '物品等级%d' or ITEM_LEVEL, info.itemLevel))
        end
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_ProfessionMixin.addName)
        GameTooltip:Show()
    end)


    --专业，列表，增加图标, 颜色
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self, node)
        local elementData = node:GetData();
        local recipeInfo = Professions.GetHighestLearnedRecipe(elementData.recipeInfo) or elementData.recipeInfo
        if not recipeInfo then
            return
        end
        if recipeInfo.icon and not self.texture then
            self.texture= self:CreateTexture(nil, 'OVERLAY')
            self.texture:SetPoint('RIGHT',2,0)
            self.texture:SetSize(22,22)
            self.Count:ClearAllPoints()
            self.Count:SetPoint('RIGHT', self.texture, 'LEFT')
        end
        if self.texture then
            self.texture:SetTexture(recipeInfo.icon and recipeInfo.icon>0 and recipeInfo.icon or 0)
        end

        local r,g,b--颜色        
        if recipeInfo.learned or recipeInfo.isRecraf then
            local link= recipeInfo.hyperlink
            local quality= link and C_Item.GetItemQualityByID(link)
            if quality then
                r,g,b=C_Item.GetItemQualityColor(quality)
            end
            self.Label:SetTextColor(r or 1, g or 0.82, b or 0)
        else
            self.Label:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        end
    end)


    --######
    --附魔纸
    --Blizzard_ProfessionsRecipeSchematicForm.lua
    hooksecurefunc(ProfessionsFrame.CraftingPage.SchematicForm, 'Init', function(self, recipeInfo)--, isRecraftOverride)
        local recipeID = recipeInfo and recipeInfo.recipeID
        local isEnchant = recipeID and (self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Enchant) and not C_TradeSkillUI.IsRuneforging()

        if not isEnchant
            or not self.enchantSlot
            or not self.enchantSlot:IsShown()
            --or Save().disabled--禁用，按钮
            or ItemUtil.GetCraftingReagentCount(38682)==0--没有， 附魔纸
        then
            if self.enchantSlot and self.enchantSlot.btn then
                self.enchantSlot.btn:SetShown(false)
            end
            return
        end

        local btn= self.enchantSlot.btn
        if not btn then
            btn= WoWTools_ButtonMixin:Cbtn(self.enchantSlot, {
                size=16,
                atlas= Save().disabledEnchant and 'talents-button-reset' or WoWTools_DataMixin.Icon.icon
            })
            btn:SetPoint('TOPLEFT', self.enchantSlot, 'BOTTOMLEFT')
            btn:SetAlpha(0.3)
            btn:SetScript('OnClick', function(self2)
                Save().disabledEnchant= not Save().disabledEnchant and true or nil
                self2:SetNormalAtlas(Save().disabledEnchant and 'talents-button-reset' or WoWTools_DataMixin.Icon.icon)
            end)
            btn:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(0.3) end)
            btn:SetScript('OnEnter', function(self2)
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetItemByID(38682)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '自动加入' or AUTO_JOIN, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledEnchant))
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
                GameTooltip:Show()
                self2:SetAlpha(1)
            end)
            self.enchantSlot.btn=btn
        end
        btn:SetShown(true)


        if Save().disabledEnchant then
            return
        end

        local candidateGUIDs = C_TradeSkillUI.GetEnchantItems(recipeID);
        for index, item in ipairs(ItemUtil.TransformItemGUIDsToItems(candidateGUIDs)) do
            if candidateGUIDs[index] and item and item:GetItemID()== 38682 then--附魔纸
                local itemLocal= Item:CreateFromItemGUID(candidateGUIDs[index])
                if itemLocal then
                    self.transaction:SetEnchantAllocation(itemLocal);
                    self.enchantSlot:SetItem(itemLocal);
                    self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
                    break
                end
            end
        end
    end)


    --Blizzard_ProfessionsSpecializations.lua
    --全加点，专精，
    hooksecurefunc(ProfessionsFrame.SpecPage, 'UpdateDetailedPanel', function(self, setLocked)
        local button=self.DetailedView.SpendAllPointsButton
        if not button then
            button= WoWTools_ButtonMixin:Cbtn(self.DetailedView.SpendPointsButton, {isUI=true, size={80, 22}})
            button:SetPoint('LEFT', self.DetailedView.SpendPointsButton, 'RIGHT',40,0)
            button:SetText(WoWTools_Mixin.onlyChinese and '全部' or ALL)
            button:SetScript('OnClick', function(self2)
                local parent= self2:GetParent()
                while parent:IsEnabled() do
                    local success= C_Traits.PurchaseRank(self2.configID, self2.nodeID)
                    if not success then
                        return
                    end
                end
            end)
            button:SetScript('OnEnter', function(self2)
                GameTooltip:SetOwner(self2, "ANCHOR_TOPLEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(not WoWTools_Mixin.onlyChinese and PROFESSIONS_SPECS_ADD_KNOWLEDGE or "运用知识", WoWTools_Mixin.onlyChinese and '全部' or ALL)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
                GameTooltip:Show()
            end)
            button:SetScript('OnLeave', GameTooltip_Hide)
            self.DetailedView.SpendAllPointsButton= button
        end
        button:SetShown(self.DetailedView.SpendPointsButton:IsShown())
        button:SetEnabled(self.DetailedView.SpendPointsButton:IsEnabled())
        button.nodeID= self:GetDetailedPanelNodeID();
        button.configID= self:GetConfigID()
    end)


    --可加点数， 提示
    hooksecurefunc(ProfessionsSpecPathMixin, 'UpdateProgressBar', function(self)
        if not self.ProgressBar:IsShown() then
            return
        end
        local currRank, maxRank = self:GetRanks()
        local text
        if currRank and maxRank then
            if currRank<maxRank then
                text= '+'..(maxRank-currRank)
            else
                text= '|A:auctionhouse-icon-favorite:0:0|a'
            end
        end
        if text and not self.SpendText2 then
            self.SpendText2= WoWTools_LabelMixin:Create(self, {color={r=1, g=0, b=1}})
            self.SpendText2:SetPoint('LEFT', self.SpendText, 'RIGHT')
        end
        if self.SpendText2 then
            self.SpendText2:SetText(text or '')
        end
    end)
end












function WoWTools_ProfessionMixin:Init_ProfessionsFrame()
    Init()
    self:Init_ProfessionsFrame_Button()
end