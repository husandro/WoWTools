
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    WoWTools_StableFrameMixin.Save={disabled=true}
    return
end

WoWTools_StableFrameMixin.Save={
    --hideIndex=true,--隐藏索引
    --hideTalent=true,--隐藏天赋
    -- modelScale=0.65,

    --line=15,

    --10.2.7
    --show_All_List=true,显示，所有宠物，图标列表
    --sortDown= true,--排序, 降序
    --all_List_Size==28--图标表表，图标大小
    --showTexture=true,--显示，材质
    sortType='specialization',
    all_List_Size=28
}

local function Save()
    return WoWTools_StableFrameMixin.Save
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_StableFrameMixin.Save= WoWToolsSave['Plus_StableFrame'] or Save()

            local addName= '|A:groupfinder-icon-class-hunter:0:0|a'..(WoWTools_Mixin.onlyChinese and '猎人兽栏' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UnitClass('player'), STABLE_STABLED_PET_LIST_LABEL))
            WoWTools_StableFrameMixin.addName= addName

            --添加控制面板
                WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                tooltip= nil,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_StableFrameMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save().disabled then
                self:RegisterEvent('PET_STABLE_SHOW')
            end

            self:UnregisterEvent(event)
        end

    elseif event=='PET_STABLE_SHOW' then
        WoWTools_StableFrameMixin:Init_StableFrame_Plus()
        WoWTools_StableFrameMixin:Init_Menu()
        WoWTools_StableFrameMixin:Set_StableFrame_List()
        WoWTools_StableFrameMixin:Init_UI()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Plus_StableFrame']= Save()
        end
    end
end)