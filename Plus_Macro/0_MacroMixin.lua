WoWTools_MacroMixin={}

function WoWTools_MacroMixin:GetName(name, icon)
    if name then
        return
            '|T'..(icon or 134400)..':0|t'
            ..(name:gsub('  ', '')==' '
            and (WoWTools_DataMixin.onlyChinese and '(空格)' or ('('..KEY_SPACE..')'))
            or name)
    end
end

--取得选定宏，index
function WoWTools_MacroMixin:GetSelectIndex()
    if WoWTools_FrameMixin:IsLocked(MacroFrame) then
        return
    end
    local index= MacroFrame:GetSelectedIndex()
    if index then
        return MacroFrame:GetMacroDataIndex(index)
    end
end

function WoWTools_MacroMixin:IsCanCreateNewMacro()
    return MacroNewButton:IsEnabled() and not WoWTools_FrameMixin:IsLocked(MacroFrame)
end

--修改，当前图标 Blizzard_MacroIconSelector.lua MacroPopupFrameMixin:OkayButton_OnClick()
function WoWTools_MacroMixin:SetMacroTexture(iconTexture)--修改，当前图标
    if WoWTools_FrameMixin:IsLocked(MacroFrame) or not iconTexture or iconTexture==0 then
        return
    end
    local MacroFrame =MacroFrame
    local actualIndex = WoWTools_MacroMixin:GetSelectIndex()
    if actualIndex then
        local name= GetMacroInfo(actualIndex)
        local index = EditMacro(actualIndex, name, iconTexture) - (MacroFrame.macroBase or 0);--战斗中，出现错误
        MacroFrame:SelectMacro(index or 1);
        WoWTools_Mixin:Call(MacroFrame.Update, MacroFrame, true)
    end
end

--新建，宏
function WoWTools_MacroMixin:CreateMacroNew(name, icon, body)--新建，宏
    if not self:IsCanCreateNewMacro() or WoWTools_FrameMixin:IsLocked(MacroFrame) then
        return
    end
    if type(icon)=='string' then
        icon= GetFileIDFromPath(icon) or icon
    end
    local index = CreateMacro(name or ' ', icon or 134400, body or '', MacroFrame.macroBase>0)
    index= index- MacroFrame.macroBase

    MacroFrame:SelectMacro(index)

    WoWTools_Mixin:Call(MacroFrame.Update, MacroFrame, true)
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
            GameTooltip:AddDoubleLine(WoWTools_MacroMixin:GetName(name, icon), (WoWTools_DataMixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..index)
            GameTooltip:AddLine(body, nil,nil,nil, true)
            GameTooltip:AddLine(' ')
            if frame~=MacroFrameSelectedMacroButton then
                local col= WoWTools_FrameMixin:IsLocked(MacroFrame) and '|cff828282' or '|cffffffff'
                GameTooltip:AddDoubleLine(
                    col..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE),
                    col..'Alt+'..(WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left
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




