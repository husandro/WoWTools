local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end
local Category, Layout
    --添加控制面板



local function Init_Category()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_UnitMixin.addName,
        disabled=Save().disabled
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_UnitMixin.addName,
        GetValue= function() return not Save().disabled end,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
            if not Save().disabled then
                WoWTools_UnitMixin:Init_Options()
            end
        end,
        category= Category,
    })

    Init_Category= function()end
end
















local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') or Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(Layout, 'Plus')






--玩家框体
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '玩家框体' or HUD_EDIT_MODE_PLAYER_FRAME_LABEL,
        GetValue= function() return not Save().hidePlayerFrame end,
        func= function()
            Save().hidePlayerFrame= not Save().hidePlayerFrame and true or nil
            if Save().hidePlayerFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_PlayerFrame()--玩家
            end
        end,
        category= Category,
    })



--目标框体
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '目标框体' or HUD_EDIT_MODE_TARGET_FRAME_LABEL,
        GetValue= function() return not Save().hideTargetFrame end,
        func= function()
            Save().hideTargetFrame= not Save().hideTargetFrame and true or nil
            if Save().hideTargetFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_TargetFrame()--目标
            end
        end,
        category= Category,
    })





--小队框体
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '小队框体' or HUD_EDIT_MODE_PARTY_FRAMES_LABEL,
        GetValue= function() return not Save().hidePartyFrame end,
        func= function()
            Save().hidePartyFrame= not Save().hidePartyFrame and true or nil
            if Save().hidePartyFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_PartyFrame()--小队
                WoWTools_UnitMixin:Init_PartyFrame_Compact()--小队, 使用团框架
            end
        end,
        category= Category,
    })





--团队框体
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '团队框体' or HUD_EDIT_MODE_RAID_FRAMES_LABEL,
        GetValue= function() return not Save().hideRaidFrame end,
        func= function()
            Save().hideRaidFrame= not Save().hideRaidFrame and true or nil
            if Save().hideRaidFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_RaidFrame()--团队
            end
        end,
        category= Category,
    })





--首领框体
    WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_DataMixin.onlyChinese and '首领框体' or HUD_EDIT_MODE_BOSS_FRAMES_LABEL),
        GetValue= function() return not Save().hideBossFrame end,
        SetValue= function()
            Save().hideBossFrame= not Save().hideBossFrame and true or nil
            if Save().hideBossFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_BossFrame()
            end
        end,
        category= Category,
    })

--施法条
    WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_DataMixin.onlyChinese and '施法条' or HUD_EDIT_MODE_CAST_BAR_LABEL),
        GetValue= function() return not Save().hideCastingFrame end,
        SetValue= function()
            Save().hideCastingFrame= not Save().hideCastingFrame and true or nil
            if Save().hideCastingFrame then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_BossFrame()
            end
        end,
        category= Category,
    })



--职业图标
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '职业图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, EMBLEM_SYMBOL),
        tooltip=WoWTools_DataMixin.onlyChinese and '颜色, 图标' or (COLOR..', '..EMBLEM_SYMBOL) ,
        GetValue= function() return not Save().hideClassColor end,
        func= function()
            Save().hideClassColor= not Save().hideClassColor and true or nil
            if Save().hideClassColor then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_ClassTexture()
            end
        end,
        category= Category,
    })




   Init=function()end
end

function WoWTools_UnitMixin:Init_Options()
    Init_Category()
    Init()
end