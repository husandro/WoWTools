--创建，空，按钮

local function Save()
    return WoWTools_MacroMixin.Save
end
--[[
local global, perChar = GetNumMacros()
local isGolbal= MacroFrame.macroBase==0
local isZero= (isGolbal and global==0) or (not isGolbal and perChar==0)
local isMax= (isGolbal and MacroFrame.macroMax==global) or (not isGolbal and MacroFrame.macroMax==perChar)
]]

local Button
--新建，宏，列表
--#############
local MacroButtonList={
    {macro='/reload', name='reload'},--134400
    {macro='/fstack', name='fstack'},
    {macro='/etrace', name='etrace'},
    {macro='#showtooltip\n/cast [mod:alt]\n/cast [mod:ctrl]\n/cast [mod:shift][noflyable]\n/cast [advflyable]\n/cast [swimming]\n/cast [flyable]', name='Mount'},
    {macro='/click ExtraActionButton1', name='Extra'},
    --{macro=, name=, icon=, },
}














--保存，宏
local function Save_Macro_Menu(frame, root)
--战斗中
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local selectIndex= frame.selectionIndex or MacroFrame:GetSelectedIndex()

    local index= selectIndex and MacroFrame:GetMacroDataIndex(selectIndex)

--保存
    local sub, sub2, sub3, name, icon, body, num, header, spellID, itemName, itemLink
    if index then
        name, icon, body = GetMacroInfo(index)
        itemName, itemLink= GetMacroItem(index)
        spellID= GetMacroSpell(index)
        local spellName= spellID and C_Spell.GetSpellName(spellID)

        WoWTools_Mixin:Load({id=itemLink, type='item'})
        WoWTools_Mixin:Load({id=spellID, type='spell'})

        header= '|T'..(icon or 134400)..':0|t'.. (name and name:gsub(' ', '') or '')..(spellName or spellID or '')..(itemName or itemLink or '')
        sub=root:CreateCheckbox(
            ((not body or body=='') and '|cff9e9e9e' or '')
            ..(WoWTools_Mixin.onlyChinese and '保存' or SAVE)
            ..' '..header,
        function(data)
            return data.header and Save().macro[data.header]
        end, function(data)
            if data.body and data.body~='' then
                Save().macro[data.header]=  not Save().macro[data.header] and {
                        name=data.name,
                        icon=data.icon,
                        body=data.body,
                    }
                    or nil
            end
        end, {name=name, icon=icon, body=body, header=header, itemLink=itemLink, spellID=spellID})

        WoWTools_MacroMixin:SetMenuTooltip(sub)--宏，提示
    else
        sub=root:CreateButton(WoWTools_Mixin.onlyChinese and '保存' or SAVE, function() return MenuResponse.Open end)
    end





--保存，列表
    num=0
    for head2, tab in pairs(Save().macro) do
--新建, 列表内容
        sub2=sub:CreateButton(
            head2,
        function(data)
            WoWTools_MacroMixin:CreateMacroNew(data.tab.name, data.tab.icon, data.tab.body)--新建，宏
            return MenuResponse.Open
        end, {saveName=head2, tab=tab})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.saveName)
            if description.data.tab.body then
                tooltip:AddLine(description.data.tab.body)
                tooltip:AddLine(' ')
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..'|A:communities-chat-icon-plus:0:0|a'..(WoWTools_Mixin.onlyChinese and '新建' or NEW)..WoWTools_DataMixin.Icon.left)
            else
                tooltip:AddLine((WoWTools_Mixin.onlyChinese '无' or NONE))
            end
        end)
--删除
        sub3=sub2:CreateCheckbox(
            '|A:XMarksTheSpot:0:0|a'
            ..(WoWTools_Mixin.onlyChinese and '删除' or DELETE),
        function(data)
            return Save().macro[data.head2]
        end, function(data)
            Save().macro[data.head2]= not Save().macro[data.head2] and {name=data.name, icon=data.icon, body=data.body} or nil

            if Save().macro[data.head2] then
                print(WoWTools_MacroMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '保存' or SAVE))
            else
                print(WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '删除' or DELETE))
                print(data.body)
            end
        end, {head2=head2, name=tab.name, icon=tab.icon, body=tab.body})
        WoWTools_MacroMixin:SetMenuTooltip(sub3)--宏，提示
        num=num+1
    end

    if num>1 then
--全部清除
        sub:CreateDivider()
        WoWTools_MenuMixin:ClearAll(sub, function() Save().macro={} end)
--SetGridMode
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end
end















local function Init_Menu(_, root)
--战斗中/已满
    local notMax= MacroNewButton:IsEnabled()
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub

--列表    
    for _, tab in pairs(MacroButtonList) do
        sub=root:CreateButton(
            '|T'..(tab.icon or 0)..':0|t'..tab.name,
        function(data)
--新建，宏
            WoWTools_MacroMixin:CreateMacroNew(data.name, data.icon, data.macro)
            return MenuResponse.Open
        end, {name=tab.name, icon=tab.icon, macro=tab.macro})
--提示
        sub:SetTooltip(function(tooltip, description)
            tooltip:AddLine(WoWTools_MacroMixin:GetName(description.data.name, description.data.icon))
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.macro, nil, nil, nil, true)
        end)
        sub:SetEnabled(notMax)
    end

--保存
    root:CreateDivider()
    Save_Macro_Menu(_, root)
end













--创建，空，按钮
--#############
local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(MacroFrame, {size=22, name='WoWTools_MacroNewEmptyButton'})
    WoWTools_MacroMixin.NewEmptyButton= Button
    Button.texture= Button:CreateTexture(nil, 'ARTWORK')
    Button.texture:SetAtlas('communities-chat-icon-plus')
    Button.texture:SetAllPoints()

    Button:SetPoint('BOTTOMLEFT', MacroFrameTab2, 'BOTTOMRIGHT',2 ,0)
    Button:SetScript('OnLeave', GameTooltip_Hide)
    function Button:set_Tooltips()
        local col= WoWTools_MacroMixin:IsCanCreateNewMacro() and '' or '|cff9e9e9e'
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(col..'|A:communities-chat-icon-plus:0:0|a'..(WoWTools_Mixin.onlyChinese and '新建' or NEW)..WoWTools_DataMixin.Icon.left, WoWTools_DataMixin.Icon.right..col..(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU))
        GameTooltip:Show()
    end

    Button:SetScript('OnEnter', Button.set_Tooltips)
    Button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            WoWTools_MacroMixin:CreateMacroNew()--新建，宏
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    Button:SetScript('OnMouseUp', Button.set_Tooltips)

    hooksecurefunc(MacroFrame, 'UpdateButtons', function()
        if WoWTools_MacroMixin:IsCanCreateNewMacro() then
            Button.texture:SetVertexColor(0,1,0)
        else
            Button.texture:SetVertexColor(1,1,1)
        end
    end)

    function Button:settings()
        self:SetShown(not Save().hideBottomList)
    end

    Button:settings()
end








function WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
    Init()
end


function WoWTools_MacroMixin:Save_Macro_Menu(frame, root)
    Save_Macro_Menu(frame, root)
end