
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end

local P_Save={
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
    return WoWToolsSave['Plus_StableFrame']
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PET_STABLE_SHOW')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_StableFrame']= WoWToolsSave['Plus_StableFrame'] or P_Save()

            WoWTools_HunterMixin.addName= '|A:groupfinder-icon-class-hunter:0:0|a'..(WoWTools_Mixin.onlyChinese and '猎人兽栏' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UnitClass('player'), STABLE_STABLED_PET_LIST_LABEL))

            --添加控制面板
                WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_HunterMixin.addName,
                tooltip= nil,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_HunterMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_Mixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
                WoWTools_MoveMixin:Setup(StableFrame)
                self:UnregisterAllEvents()
            else
                self:UnregisterEvent(event)
            end
        end

    elseif event=='PET_STABLE_SHOW' then
        WoWTools_HunterMixin:Init_StableFrame_Plus()
        WoWTools_HunterMixin:Init_Menu()
        WoWTools_HunterMixin:Set_StableFrame_List()
        WoWTools_HunterMixin:Init_UI()
        self:UnregisterEvent(event)
    end
end)