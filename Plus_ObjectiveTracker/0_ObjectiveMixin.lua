WoWTools_ObjectiveMixin={}


--清除，全部，按钮
function WoWTools_ObjectiveMixin:Add_ClearAll_Button(frame, tooltip, func)
    if WoWTools_FrameMixin:IsLocked(frame) then
        return
    end
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {size=22, atlas='bags-button-autosort-up', alpha=0.2})
    btn:SetPoint('RIGHT', frame.Header.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', function(f) f:SetAlpha(0.2) GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(f)
        GameTooltip:SetOwner(f:GetParent(), "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_ObjectiveMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ..'|A:bags-button-autosort-up:0:0|a|cffff00ff'..(f.tooltip or '')
            ..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:Show()
        f:SetAlpha(1)
    end)

    btn:SetScript('OnClick', func)
    --btn:SetScript('OnDoubleClick', function()
    btn.tooltip= tooltip
end





function WoWTools_ObjectiveMixin:Set_Block_Icon(block, icon, type)
    if WoWTools_FrameMixin:IsLocked(block) then
        return
    end
    if icon and not block.Icon2 then
        block.Icon2= block:CreateTexture(nil, 'OVERLAY')
        if block.poiButton then
            block.Icon2:SetPoint('RIGHT',block.poiButton.Display.Icon, 'LEFT', -2, 0)
        else
            block.Icon2:SetPoint('TOPRIGHT', block.HeaderText, 'TOPLEFT', -4,-1)
        end
        block.Icon2:SetSize(26,26)
        block.Icon2:EnableMouse()
        block.Icon2:SetScript('OnLeave', function(f) GameTooltip:Hide() f:GetParent():SetAlpha(1) end)
        block.Icon2:SetScript('OnEnter', function(f)
            local parent= f:GetParent()
            parent:SetAlpha(0.5)
            local typeID= parent.id
            if not typeID then
                return
            end
            GameTooltip:SetOwner(f, "ANCHOR_LEFT")
            if f.type=='isAchievement' then
                GameTooltip:SetAchievementByID(typeID)
            --elseif f.type=='isItem' then
                --GameTooltip:SetItemByID(typeID)
            elseif f.type=='isRecipe' then
                GameTooltip:SetRecipeResultItem(typeID)
            end
            GameTooltip:Show()
        end)
    end
    if block.Icon2 then
        block.Icon2.type= type
        block.Icon2:SetTexture(icon or 0)
    end
end


function WoWTools_ObjectiveMixin:Set_Line_Icon(line, icon)
    if icon and not line.Icon2 then
        line.Icon2= line:CreateTexture(nil, 'OVERLAY')
        line.Icon2:SetPoint('RIGHT', line.Text)
        line.Icon2:SetSize(16, 16)
        line.Icon2:EnableMouse()
        line.Icon2:SetScript('OnLeave', function(f) f:GetParent():SetAlpha(1) end)
        line.Icon2:SetScript('OnEnter', function(f)
            local parent= f:GetParent()
            parent:SetAlpha(0.5)
        end)
    end
    if line.Icon2 then
        line.Icon2:SetTexture(icon or 0)
    end
end


function WoWTools_ObjectiveMixin:Get_Block(f, index)
    if f.usedBlocks[f.blockTemplate] then
        return f.usedBlocks[f.blockTemplate][index]
    end
end

















--清除，成就
function WoWTools_ObjectiveMixin:Clear_Achievement(isPrint)
    local num=0
    for index, achievementID in pairs(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement) or {}) do
        C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID,  Enum.ContentTrackingStopType.Manual)
        num= index
        if isPrint then
            print(
                index..')',
                GetAchievementLink(achievementID)
                or ('|cffffff00|Hachievement:'..achievementID..':'..WoWTools_DataMixin.Player.GUID..':0:0:0:-1:0:0:0:0|h['..achievementID..']|h|r')
            )
        end
    end
    if num>0 and AchievementFrame and AchievementFrame:IsVisible() and AchievementFrameAchievements_ForceUpdate then
        WoWTools_DataMixin:Call(AchievementFrameAchievements_ForceUpdate)
    end
end











--清除，配方
local function clear_Recipe(isRecrafting)
    local num= 0
    for index, recipeID in pairs(C_TradeSkillUI.GetRecipesTracked(isRecrafting) or {}) do
        C_TradeSkillUI.SetRecipeTracked(recipeID, false, isRecrafting)
        local itemLink= C_TradeSkillUI.GetRecipeItemLink(recipeID)
        if itemLink then
            print(index..')', itemLink, isRecrafting and (WoWTools_DataMixin.onlyChinese and '再造' or PROFESSIONS_CRAFTING_FORM_OUTPUT_RECRAFT) or '')
        end
        num=num+1
    end
end
function WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe(isPrint, isRecrafting)
    if isRecrafting==nil then
        return clear_Recipe(isPrint, true) + clear_Recipe(isPrint, false)
    else
        return clear_Recipe(isPrint, isRecrafting)
    end
end









--清除，任务
function WoWTools_ObjectiveMixin:Clear_Quest(isPrint)
    local num = 0
    for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
        local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID and questID>0 and not C_CampaignInfo.IsCampaignQuest(questID) then
            local wasRemoved= C_QuestLog.RemoveQuestWatch(questID)
            if wasRemoved then
                num= num +1
                if isPrint then
                    print(num..')', GetQuestLink(questID) or questID)
                end
            end
        end
    end
end








--清除，世界任务
function WoWTools_ObjectiveMixin:Clear_WorldQuest(isPrint)
    local index=0
    for i= 1, C_QuestLog.GetNumWorldQuestWatches() or 0, 1 do
        local questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if questID and questID>0 and C_QuestLog.RemoveWorldQuestWatch(questID)then
            index= index+1
            if isPrint then
                print(index..')', GetQuestLink(questID) or questID)
            end
        end
    end
end




--清除，战役任务
function WoWTools_ObjectiveMixin:Clear_CampaignQuest(isPreint)
    local num= 0
    for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
        local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID
            and questID>0
            and C_CampaignInfo.IsCampaignQuest(questID)
            and C_QuestLog.RemoveQuestWatch(questID)--移除
        then
            num= num+1
            if isPreint then
                print(num..')', GetQuestLink(questID) or questID)
            end
        end
    end
end









--清除，旅行者日志 任务
function WoWTools_ObjectiveMixin:Clear_MonthlyActivities(isPring)
    local num= 0
    for _, perksActivityIDs in pairs(C_PerksActivities.GetTrackedPerksActivities() or {}) do
        for _, perksActivityID in pairs(perksActivityIDs) do
            C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
            num= num+1
            if isPring then
                  print(num..') ',
                    C_PerksActivities.GetPerksActivityChatLink(perksActivityID) or perksActivityID
                )
            end
        end
    end
end
