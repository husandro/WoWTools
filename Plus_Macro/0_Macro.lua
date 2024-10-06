local id, e= ...
WoWTools_MacroMixin={
Save={
    --disabled= not e.Player.husandro,
    toRightLeft=3, -- 1,2, 3 左边 右边 默认
    spellButton=e.Player.husandro,
    --mcaro={},-- {name=tab.name, icon=tab.icon, body=tab.body}
    macro={}
},
addName= nil,
}

local function Save()
    return WoWTools_MacroMixin.Save
end





function WoWTools_MacroMixin:GetSpaceName(name)
    if name then
        return
            name:gsub('  ', '')==' '
            and (e.onlyChinese and '(空格)' or ('('..KEY_SPACE..')'))
            or name
    end
end











--取得选定宏，index
--################
function WoWTools_MacroMixin:GetSelectIndex()
    local index= MacroFrame:GetSelectedIndex()
    if index then
        return MacroFrame:GetMacroDataIndex(index)
    else
        return MacroFrame.macroBase +1
    end
end




function WoWTools_MacroMixin:IsCanCreateNewMacro()
    return not UnitAffectingCombat('player') and MacroNewButton:IsEnabled()
end



--修改，当前图标
--Blizzard_MacroIconSelector.lua MacroPopupFrameMixin:OkayButton_OnClick()
function WoWTools_MacroMixin:SetMacroTexture(iconTexture)--修改，当前图标
    if UnitAffectingCombat('player') or not iconTexture or iconTexture==0 then
        return
    end
    local MacroFrame =MacroFrame
    local actualIndex = WoWTools_MacroMixin:GetSelectIndex()
    if actualIndex then
        local name= GetMacroInfo(actualIndex)
        local index = EditMacro(actualIndex, name, iconTexture) - (MacroFrame.macroBase or 0);--战斗中，出现错误
        --e.call(MacroFrame.SaveMacro, MacroFrame)
        MacroFrame:SelectMacro(index or 1);
        e.call(MacroFrame.Update, MacroFrame)
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
    index= index- MacroFrame.macroBase-1

    MacroFrame:SelectMacro(index)
    --MacroFrame.MacroSelector:ScrollToSelectedIndex()

    --e.call(MacroFrame.Update, MacroFrame, true)
    MacroFrame:Update(true)


    print(WoWTools_MacroMixin.addName,
        '|T'..(icon or 134400)..':0|t|cnGREEN_FONT_COLOR:'
        ..(WoWTools_MacroMixin:GetSpaceName(name) or (e.onlyChinese and '新建' or NEW))
    )
    if body and body~='' then
        print(body)
    end
end





--宏，提示
--#######
function WoWTools_MacroMixin:SetTooltips(frame, index)
    index= frame.selectionIndex or index
    if index then
        index= (frame.selectionIndex and frame.selectionIndex+ MacroFrame.macroBase) or index
        local name, icon, body = GetMacroInfo(index)
        if name and body then
            e.tips:SetOwner(frame, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine('|T'..(icon or 134400)..':0|t'..WoWTools_MacroMixin:GetSpaceName(name), (e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..index)
            e.tips:AddLine(body, nil,nil,nil, true)
            e.tips:AddLine(' ')
            if frame~=MacroFrameSelectedMacroButton then
                local col= UnitAffectingCombat('player') and '|cff9e9e9e' or '|cffffffff'
                e.tips:AddDoubleLine(
                    col..(e.onlyChinese and '删除' or DELETE),
                    col..'Alt+'..(e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left
                )
            end
            local spellID= GetMacroSpell(index)
            if spellID then
                e.LoadData({id=spellID, type='spell'})
                local spellName= C_Spell.GetSpellName(spellID)
                local spellIcon= C_Spell.GetSpellTexture(spellID)
                if spellName and spellIcon then
                    e.tips:AddDoubleLine('|T'..spellIcon..':0|t'..spellName, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '法术' or SPELLS, spellID))
                end
                --Set_Action_Focus(spellID)
            end

            e.tips:Show()

            return icon
        end
    end
end
















--初始
--####
local function Init()
   

    WoWTools_MacroMixin:Init_Set_UI()

    MacroFrame.Menu= CreateFrame("Frame", nil, MacroFrame, "UIDropDownMenuTemplate")


    WoWTools_MacroMixin:Init_Button()--宏列表，位置
    WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
    WoWTools_MacroMixin:Init_List_Button()--命令，按钮，列表
    WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
end




















local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[MACRO] then
                WoWTools_MacroMixin.Save= WoWToolsSave[MACRO]
                if WoWTools_MacroMixin.Save.toRightLeft==nil then
                    WoWTools_MacroMixin.Save=3
                end
                WoWToolsSave[MACRO]= nil
            else
                WoWTools_MacroMixin.Save= WoWToolsSave['Plus_Macro'] or Save()
            end

            WoWTools_MacroMixin.Save.macro= WoWTools_MacroMixin.Save.macro or {}
--旧版本

            if Save().mcaro then
                ----mcaro={},-- {name=tab.name, icon=tab.icon, body=tab.body}
                do for _, info in pairs(Save().mcaro) do
                    Save().macro['|T'..(info.icon or 134400)..':0|t'..info.name]= info
                end end
                Save().mcaro=nil
            end

            WoWTools_MacroMixin.addName= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(e.onlyChinese and '宏' or MACRO)
            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_MacroMixin.addName,
                tooltip= ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                    ..'|r|n'..(e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(e.addName, WoWTools_MacroMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled  then
                self:UnregisterEvent('ADDON_LOADED')

            else
                if C_AddOns.IsAddOnLoaded("MacroToolkit") then
                    print(e.addName, WoWTools_MacroMixin.addName,
                        e.GetEnabeleDisable(false), 'MacroToolkit',
                        e.onlyChinese and '插件' or ADDONS
                    )
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_MacroUI') then
                    Init()
                    self:UnregisterEvent('ADDON_LOADED')
                end
            end

        elseif arg1=='Blizzard_MacroUI' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Macro']= Save()
        end
    end
end)