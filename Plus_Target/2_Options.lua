local e= select(2, ...)
local Frame

local function Save()
    return WoWTools_TargetMixin.Save
end







  --添加控制面板
  local function Init_Options()
    Frame= CreateFrame('Frame', nil, SettingsPanel)

    e.AddPanel_Sub_Category({
        name= WoWTools_TargetMixin.addName,
        frame= Frame,
        disabled= Save().disabled
    })

    e.ReloadPanel({panel=Frame, addName= WoWTools_TargetMixin.addName, restTips=nil, checked=not Save.disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
        disabledfunc=function()
            Save.disabled= not Save.disabled and true or nil
            if not targetFrame and not Save.disabled  then
                set_Option()
                Init()
            end
            print(WoWTools_Mixin.addName, WoWTools_TargetMixin.addName, e.GetEnabeleDisable(not Save.disabled), Save.disabled and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
        end,
        clearfunc= function() Save=nil WoWTools_Mixin:Reload() end}
    )
end




function WoWTools_TargetMixin:Init_Options()
    Init_Options()
end

function WoWTools_TargetMixin:Blizzard_Settings()
    Init()
end