




--专业技能 ProfessionsRecipeTracker
local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(ProfessionsRecipeTracker, WoWTools_Mixin.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, function(self)
        local num= 0
        local function clear_Recipe(isRecrafting)
            for index, recipeID in pairs(C_TradeSkillUI.GetRecipesTracked(isRecrafting) or {}) do
                C_TradeSkillUI.SetRecipeTracked(recipeID, false, isRecrafting)
                local itemLink= C_TradeSkillUI.GetRecipeItemLink(recipeID)
                if itemLink then
                    print(index..')', itemLink, isRecrafting and (WoWTools_Mixin.onlyChinese and '再造' or PROFESSIONS_CRAFTING_FORM_OUTPUT_RECRAFT) or '')
                end
                num=num+1
            end
        end
        clear_Recipe(true)
        clear_Recipe(false)
        self:print_text(num)
    end)


    hooksecurefunc(ProfessionsRecipeTracker, 'AddRecipe', function(self, recipeID, isRecraft)
        local blockID = NegateIf(recipeID, isRecraft);
	    local block = WoWTools_ObjectiveMixin:Get_Block(self, blockID)

        if not block then
            return
        end

        local data=  C_TradeSkillUI.GetRecipeInfo(recipeID)
        if data then
            WoWTools_ObjectiveMixin:Set_Block_Icon(block, data.icon, 'isRecipe')
        end

        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
        if not recipeSchematic or not recipeSchematic.reagentSlotSchematics then
            return
        end

        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                local reagentSlotSchematic= recipeSchematic.reagentSlotSchematics[index]
                if reagentSlotSchematic then
                    local reagent = reagentSlotSchematic.reagents[1] or {}
                    if reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.itemID);
                        subIcon = item:GetItemIcon()
                    elseif reagent.currencyID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
                        if currencyInfo then
                            subIcon = currencyInfo.iconFileID;
                        end
                    end
                end
            end

            WoWTools_ObjectiveMixin:Set_Line_Icon(line, subIcon)
        end
    end)
end






function WoWTools_ObjectiveMixin:Init_Professions()
    Init()
end