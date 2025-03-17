local id, e= ...
WoWTools_MacroMixin={
Save={
    --disabled= not e.Player.husandro,
    toRightLeft=3, -- 1,2, 3 左边 右边 默认
    spellButton=e.Player.husandro,
    --旧版本 mcaro={},-- {name=tab.name, icon=tab.icon, body=tab.body}
    macro={},--{[|T..icon..:0|t..name..spllID..itemName]={name=tab.name, icon=tab.icon, body=tab.body}}

    --hideBottomList=true,隐藏底部，列表
    bottomListScale=1,
},
addName= nil,
BottomListFrame=nil,
NewEmptyButton=nil,
TargetButton=nil,
NoteEditBox=nil,
}

local function Save()
    return WoWTools_MacroMixin.Save
end


function WoWTools_MacroMixin:GetName(name, icon)
    if name then
        return
            '|T'..(icon or 134400)..':0|t'
            ..(name:gsub('  ', '')==' '
            and (e.onlyChinese and '(空格)' or ('('..KEY_SPACE..')'))
            or name)
    end
end

--取得选定宏，index
function WoWTools_MacroMixin:GetSelectIndex()
    local index= MacroFrame:GetSelectedIndex()
    if index then
        return MacroFrame:GetMacroDataIndex(index)
    end
end

function WoWTools_MacroMixin:IsCanCreateNewMacro()
    return not InCombatLockdown() and MacroNewButton:IsEnabled()
end

--修改，当前图标 Blizzard_MacroIconSelector.lua MacroPopupFrameMixin:OkayButton_OnClick()
function WoWTools_MacroMixin:SetMacroTexture(iconTexture)--修改，当前图标
    if InCombatLockdown() or not iconTexture or iconTexture==0 then
        return
    end
    local MacroFrame =MacroFrame
    local actualIndex = WoWTools_MacroMixin:GetSelectIndex()
    if actualIndex then
        local name= GetMacroInfo(actualIndex)
        local index = EditMacro(actualIndex, name, iconTexture) - (MacroFrame.macroBase or 0);--战斗中，出现错误
        MacroFrame:SelectMacro(index or 1);
        e.call(MacroFrame.Update, MacroFrame, true)
    end
end

--新建，宏
function WoWTools_MacroMixin:CreateMacroNew(name, icon, body)--新建，宏
    if not self:IsCanCreateNewMacro() then
        return
    end
    if type(icon)=='string' then
        icon= GetFileIDFromPath(icon) or icon
    end
    local index = CreateMacro(name or ' ', icon or 134400, body or '', MacroFrame.macroBase>0)
    index= index- MacroFrame.macroBase

    MacroFrame:SelectMacro(index)

    e.call(MacroFrame.Update, MacroFrame, true)
end

--宏，提示
function WoWTools_MacroMixin:SetTooltips(frame, index)
    index= index or (frame.selectionIndex and frame.selectionIndex+ MacroFrame.macroBase)

    if index then
        local name, icon, body = GetMacroInfo(index)
        if name and body then
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            local itemLink= select(2, GetMacroItem(index))
            local spellID= GetMacroSpell(index)

            GameTooltip:ClearLines()
            if itemLink then
                GameTooltip:AddLine(WoWTools_ItemMixin:GetName(nil, itemLink))--取得法术，名称
                GameTooltip:AddLine(' ')
            elseif spellID then
                GameTooltip:AddLine(WoWTools_SpellMixin:GetName(spellID))--取得法术，名称
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddDoubleLine(WoWTools_MacroMixin:GetName(name, icon), (e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..index)
            GameTooltip:AddLine(body, nil,nil,nil, true)
            GameTooltip:AddLine(' ')
            if frame~=MacroFrameSelectedMacroButton then
                local col= InCombatLockdown() and '|cff9e9e9e' or '|cffffffff'
                GameTooltip:AddDoubleLine(
                    col..(e.onlyChinese and '删除' or DELETE),
                    col..'Alt+'..(e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left
                )
            end

            GameTooltip:Show()

            return icon
        end
    end
end

--宏，提示
function WoWTools_MacroMixin:SetMenuTooltip(root)
    root:SetTooltip(function(tooltip, description)
        local name= description.data.name
        local icon= description.data.icon
        local body= description.data.body
        local spellID= description.data.spellID
        local itemLink= description.data.itemLink
        local index= description.data.index
        if index then
            spellID= GetMacroSpell(index)
            itemLink= select(2, GetMacroItem(index))
            name, icon, body= GetMacroInfo(index)
        end
        if itemLink then
            tooltip:AddLine(WoWTools_ItemMixin:GetName(nil, itemLink))--取得法术，名称
            tooltip:AddLine(' ')
        elseif spellID then
            tooltip:AddLine(WoWTools_SpellMixin:GetName(spellID))--取得法术，名称
            tooltip:AddLine(' ')
        end
        tooltip:AddLine(WoWTools_MacroMixin:GetName(name, icon))
        tooltip:AddLine(body, nil, nil, nil, true)
    end)
end









local function Init()
    WoWTools_MacroMixin:Init_Set_UI()
    WoWTools_MacroMixin:Init_Button()--宏列表，位置
    WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
    WoWTools_MacroMixin:Init_List_Button()--命令，按钮，列表
    WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
    WoWTools_MacroMixin:Init_ChangeTab()
    WoWTools_MacroMixin:Init_MacroButton_Plus()
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_MacroMixin.Save= WoWToolsSave['Plus_Macro2'] or Save()

            local addName= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(e.onlyChinese and '宏' or MACRO)
            WoWTools_MacroMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                tooltip= ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                    ..'|r|n'..(e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled  then
                self:UnregisterEvent(event)
            else
                if C_AddOns.IsAddOnLoaded("MacroToolkit") then
                    print(
                        WoWTools_Mixin.addName,
                        addName,
                        e.GetEnabeleDisable(false), 'MacroToolkit',
                        e.onlyChinese and '插件' or ADDONS
                    )
                end
            end

        elseif arg1=='Blizzard_MacroUI' then
            if InCombatLockdown() then
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            else
                Init()
            end
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if WoWTools_MacroMixin.NoteEditBox and WoWTools_MacroMixin.NoteEditBox:IsVisible() then
                WoWTools_MacroMixin.NoteEditBox:Hide()
            end
            WoWToolsSave['Plus_Macro2']= Save()
        end
    end
end)