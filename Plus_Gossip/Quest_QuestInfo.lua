
--任务目标，类型提示
local function Set_QuestInfo_Display()
    if not WoWTools_GossipMixin.Save.quest then
        return
    end

    for index, label in pairs(QuestInfoObjectivesFrame.Objectives) do
        if label:IsShown() then
            local text, type, finished = GetQuestLogLeaderBoard(index)
            if not finished then
                label:SetTextColor(0.180, 0.121, 0.588)
            end

            local atlas, icon
            if not finished then
                if type=='monster' then
                    atlas='UpgradeItem-32x32'

                elseif type=='item' then
                    if text then
                        local itemName= text:match('%d+/%d+ (.-) |A') or text:match('%d+/%d+ (.+)')
                        if itemName then
                            icon = C_Item.GetItemIconByID(itemName)
                        end
                    end
                    icon= icon or 134400

                elseif type=='object' then
                    atlas= 'QuestObjective'

                elseif type=='spell' then
                    atlas= 'plunderstorm-icon-utility'
                elseif type=='log' then
                    atlas='QuestionMarkContinent-Icon'
                end
            end

            if (atlas or icon) and not label.typeIcon then
                label.typeIcon= QuestInfoObjectivesFrame:CreateTexture(nil, 'OVERLAY')
                label.typeIcon:SetPoint('TOPLEFT', label, 'TOPRIGHT', -6, 0)
                label.typeIcon:SetSize(16,16)
            end
            if label.typeIcon then
                if atlas then
                    label.typeIcon:SetAtlas(atlas)
                else
                    label.typeIcon:SetTexture(icon or 0)
                end
            end
        else
            if label.typeIcon then
                label.typeIcon:SetTexture(0)
            end
        end
    end
end








function WoWTools_GossipMixin:Init_QuestInfo_Display()
    hooksecurefunc('QuestInfo_Display', Set_QuestInfo_Display)
end