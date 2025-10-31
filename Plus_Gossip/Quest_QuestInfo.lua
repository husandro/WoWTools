
--任务目标，类型提示
local function Init()
WoWTools_DataMixin:Hook('QuestInfo_Display', function()
    if not WoWToolsSave['Plus_Gossip'].quest then
        return
    end
    local desc, obType, finished
    for index, label in pairs(QuestInfoObjectivesFrame.Objectives) do
        if label:IsShown() then
            desc, obType, finished = GetQuestLogLeaderBoard(index)
            if not finished then
                label:SetTextColor(0.180, 0.121, 0.588)
            end

            local atlas, icon
            if not finished then
                if obType=='monster' then
                    atlas='UpgradeItem-32x32'

                elseif obType=='item' then
                    if desc then
                        local itemName= desc:match('%d+/%d+ (.-) |A') or desc:match('%d+/%d+ (.+)')
                        if itemName then
                            icon = select(5, C_Item.GetItemInfoInstant(itemName))
                        end
                    end
                    icon= icon or 134400

                elseif obType=='object' then
                    atlas= 'QuestObjective'

                elseif obType=='spell' then
                    atlas= 'plunderstorm-icon-utility'
                elseif obType=='log' then
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
end)

Init=function()end
end








function WoWTools_GossipMixin:Init_QuestInfo_Display()
    Init()
end