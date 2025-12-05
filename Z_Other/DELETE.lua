--[[
你确定要摧毁%s吗？|n|n此操作无法撤销。|n|n请输入“%s”进行确认。
您确定要摧毁全部%d件%s吗？|n|n此操作无法撤销。|n|n请输入“%s”进行确认。
    StaticPopupDialogs["CONFIRM_DESTROY_DECOR"].acceptDelay= 0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_DESTROY_DECOR"],"OnShow",function(frame, data)
        local edit= frame:GetEditBox()
        edit:SetText(data.confirmationString or HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)--摧毁
        edit:ClearFocus()
    end)

你确定要删除群组\"%s\"吗？此操作无法撤销。|n|n请在输入框中输入\"DELETE\"以确认。
    StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"].acceptDelay= 1
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
        local edit= self:GetEditBox()
        edit:SetText(COMMUNITIES_DELETE_CONFIRM_STRING)
        edit:ClearFocus()
    end)

    
--"你真的要摧毁%s吗？\n\n请在输入框中输入\"DELETE\"以确认。"
    StaticPopupDialogs["DELETE_GOOD_ITEM"].acceptDelay=0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
        if not Save().notDELETE then
            local edit= self:GetEditBox()
            edit:SetText(DELETE_ITEM_CONFIRM_STRING)
            edit:ClearFocus()
        end
    end)
--"确定要摧毁%s吗？\n|cffff2020摧毁该物品也将同时放弃相关任务。|r\n\n请在输入框中输入\"DELETE\"以确认。"
    StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"].acceptDelay=0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow", function(self)
        if not Save().notDELETE then
            local edit= self:GetEditBox()
            edit:SetText(DELETE_ITEM_CONFIRM_STRING)
            edit:ClearFocus()
        end
    end)

--自动输入，忘却，文字，专业
    StaticPopupDialogs["UNLEARN_SKILL"].acceptDelay= 1
    WoWTools_DataMixin:Hook(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow", function(self)
        if Save().wangquePrefessionText then
            local edit= self:GetEditBox()
            edit:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)

--命运, 字符
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"], "OnShow", function(s)
        if Save().gossip then
            local edit= s.editBox or s:GetEditBox()
           edit:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
        end
    end)


StringUtil.lua
]]
local function Init()

    StaticPopupDialogs["UNLEARN_SKILL"].acceptDelay= 1
    StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"].acceptDelay= 1

    StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"].acceptDelay=0.5
    StaticPopupDialogs["DELETE_GOOD_ITEM"].acceptDelay=0.5

    hooksecurefunc('ConfirmationEditBoxMatches', function(editBox, expectedText)
        if not ConfirmationStringMatches(editBox:GetText(), expectedText) then
            editBox:SetText(expectedText)
            editBox:ClearFocus()
        end
    end)

    Init=function()end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then
            WoWToolsSave['Other_DELETE']= WoWToolsSave['Other_DELETE'] or {}

            local addName= '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and 'DELETE' or DELETE_ITEM_CONFIRM_STRING)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                Value= not WoWToolsSave['Other_DELETE'].disabled,
                GetValue=function() return not WoWToolsSave['Other_DELETE'].disabled end,
                SetValue= function()
                    WoWToolsSave['Other_DELETE'].disabled= not WoWToolsSave['Other_DELETE'].disabled and true or nil
                    Init()
                    if WoWToolsSave['Other_DELETE'].disabled then
                        print(addName..WoWTools_DataMixin.Icon.icon2, WoWTools_TextMixin:GetEnabeleDisable(WoWToolsSave['Other_DELETE'].disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    end
                end,
                tooltip= (WoWTools_DataMixin.onlyChinese and 'DELETE' or DELETE_ITEM_CONFIRM_STRING)..', '
                    ..(WoWTools_DataMixin.onlyChinese and '忘却' or UNLEARN_SKILL_CONFIRMATION)..', '
                    ..(WoWTools_DataMixin.onlyChinese and '命运' or SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)..', '
                    ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)

                    ..'|n|n'..(WoWTools_DataMixin.onlyChinese and '你真的要摧毁%s吗？\n\n请在输入框中输入'..DELETE_ITEM_CONFIRM_STRING..'以确认。' or DELETE_GOOD_ITEM):gsub('\n\n', '\n'),
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if not WoWToolsSave['Other_DELETE'].disabled then
                Init()
            end

            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)