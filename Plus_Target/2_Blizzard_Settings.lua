
local Frame

local function Save()
    return WoWToolsSave['Plus_Target']
end

local function set_Target_Color(self, isInCombat)--设置，颜色
    if self then
        if isInCombat then
            self:SetVertexColor(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a)
        else
            self:SetVertexColor(Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a)
        end
    end
end

local TextureTab={
    ['auctionhouse-icon-favorite']='a',
    ['common-icon-rotateright']='a',
    ['Adventures-Target-Indicator']='a',
    ['Adventures-Target-Indicator-desat']='a',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Hunters_Mark.tga']='t',
    ['NPE_ArrowDown']='a',
    ['UI-HUD-MicroMenu-StreamDLYellow-Up']='a',
    ['Interface\\AddOns\\WeakAuras\\Media\\Textures\\targeting-mark.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Reticule.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\RedArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\NeonReticule.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\NeonRedArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\RedChevronArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\PaleRedChevronArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\arrow_tip_green.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\arrow_tip_red.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\skull.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\circles_target.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\red_star.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\greenarrowtarget.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\BlueArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\bluearrow1.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\gearsofwar.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\malthael.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\NewRedArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\NewSkull.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\PurpleArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Shield.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\NeonGreenArrow.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_FelFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_RedFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_ShadowFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_GreenGPS.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_RedGPS.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_WhiteGPS.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_GreenTarget.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_RedTarget.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Q_WhiteTarget.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_Towards.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_Away.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_SelfTowards.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_SelfAway.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_FriendTowards.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_FriendAway.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_FocusTowards.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\Arrows_FocusAway.tga']='t',
    ['Interface\\AddOns\\WoWTools\\Source\\Mouse\\green_arrow_down_11384.tga']='t',
}




local function get_texture_tab()
    for name, _ in pairs(WoWToolsPlayerDate['TargetTexture'] or {}) do
        if TextureTab[name] then
            WoWToolsPlayerDate['TargetTexture'][name]=nil
        else
            TextureTab[name]= 'use'
        end
    end
    return TextureTab
end





















local function Init_Options()
    if Save().disabled then
        return
    end

    local sel=CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    sel:SetPoint('TOPLEFT', 0, -40)
    sel:SetChecked(Save().target)
    sel:SetScript('OnClick', function()
        Save().target= not Save().target and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)
    sel.Text:SetText('1) |A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '目标' or TARGET))
    sel.Text:SetTextColor( Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a)
    sel.Text:EnableMouse(true)
    sel.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a
            local function func()
                Save().targetColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(Frame.tipTargetTexture, false)
                WoWTools_TargetMixin:Set_All_Init()
            end
            WoWTools_ColorMixin:ShowColorFrame(Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save().targetColor={r=1, g=1, b=1, a=1}
            self2:SetTextColor(1, 1, 1, 1)
            set_Target_Color(Frame.tipTargetTexture, false)
            WoWTools_TargetMixin:Set_All_Init()
        end
    end)
    sel.Text:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    sel.Text:SetScript('OnEnter', function(self2)
        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
        GameTooltip:AddLine(' ')
        local r,g,b,a= Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..WoWTools_DataMixin.Icon.right, r,g,b, 1,1,1)
        GameTooltip:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        GameTooltip:AddLine(' ')
        GameTooltip:Show()
        self2:SetAlpha(0.3)
    end)

    Frame.tipTargetTexture= Frame:CreateTexture()--目标，图片，提示
    Frame.tipTargetTexture:SetPoint("TOP")
    --set_Target_Texture(Frame.tipTargetTexture)--设置，图片
    Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
    set_Target_Color(Frame.tipTargetTexture, false)--设置，颜色

    local combatCheck=CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    combatCheck:SetPoint('LEFT', sel.Text, 'RIGHT', 15,0)
    combatCheck:SetChecked(Save().targetInCombat)
    combatCheck:SetScript('OnClick', function()
        Save().targetInCombat= not Save().targetInCombat and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)
    combatCheck.Text:EnableMouse(true)
    combatCheck.Text:SetText(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    combatCheck.Text:SetTextColor(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a)
    combatCheck.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a
            local function func()
                Save().targetInCombatColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(Frame.tipTargetTexture, true)
                WoWTools_TargetMixin:Set_All_Init()
            end
            WoWTools_ColorMixin:ShowColorFrame(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save().targetInCombatColor={r=1, g=0, b=0, a=1}
            self2:SetTextColor(1, 0, 0, 1)
            set_Target_Color(Frame.tipTargetTexture, false)
            WoWTools_TargetMixin:Set_All_Init()
        end
    end)
    combatCheck.Text:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    combatCheck.Text:SetScript('OnEnter', function(self2)
        local r,g,b,a= Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a
        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..WoWTools_DataMixin.Icon.right, r,g,b, 1,1,1)
        GameTooltip:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        GameTooltip:Show()
        self2:SetAlpha(0.3)
    end)


    local menuPoint= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menuPoint:SetPoint("LEFT", combatCheck.Text, 'RIGHT', 15, 0)
    menuPoint:SetWidth(195)
    menuPoint.Text:ClearAllPoints()
    menuPoint.Text:SetPoint('CENTER')
    menuPoint:SetDefaultText(Save().TargetFramePoint)
    menuPoint:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        for _, name in pairs({
            'TOP',
            'HEALTHBAR',
            'LEFT'
        }) do
            root:CreateCheckbox(
                name,
            function(data)
                return Save().TargetFramePoint==data.name
            end, function(data)
                Save().TargetFramePoint= data.name
                self:SetDefaultText(data.name)
                WoWTools_TargetMixin:Set_All_Init()
            end, {name=name})
        end
    end)


    local sliderX = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().x, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().x= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderX:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT',0, -12)
    local sliderY = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().y, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().y= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT',15,0)
    local sliderW = WoWTools_SliderMixin:CSlider(Frame, {min=10, max=100, value=Save().w, setp=1, w= 100,
    text= 'W',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().w= value
        Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderW:SetPoint("LEFT", sliderY, 'RIGHT',15,0)
    local sliderH = WoWTools_SliderMixin:CSlider(Frame, {min=10, max=100, value=Save().h, setp=1, w= 100, color=true,
    text= 'H',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().h= value
        Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderH:SetPoint("LEFT", sliderW, 'RIGHT',15,0)



    local sliderScale = WoWTools_SliderMixin:CSlider(Frame, {min=0.2, max=4, value=Save().scale or 1, setp=0.1, w= 100,
    text= WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().scale= value
        WoWTools_TargetMixin:Set_All_Init()
    end,
    --tooltip= '1 = '..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
    })
    sliderScale:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0,-16)

    local sliderElapsed = WoWTools_SliderMixin:CSlider(Frame, {min=0.3, max=1.5, value=Save().elapsed or 0.5, setp=0.1, w= 100, color=true,
    text= WoWTools_DataMixin.onlyChinese and '速度' or SPEED,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().elapsed= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderElapsed:SetPoint("LEFT", sliderScale, 'RIGHT',15, 0)


    local menu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menu:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT', -16,-82)
    menu:SetWidth(445)
    menu:SetDefaultText(Save().targetTextureName)
    menu.Text:ClearAllPoints()
    menu.Text:SetPoint('CENTER')
    menu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local num=0
        local sub
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, _, icon= WoWTools_TextureMixin:IsAtlas(name, 128)
            if icon then
                sub=root:CreateRadio(
                    (use=='use' and '|cnGREEN_FONT_COLOR:' or '')
                    ..(name:match('.+\\(.+)') or name):gsub('%..+', ''),
                function(data)
                    return Save().targetTextureName== data.name
                end, function(data)
                    Save().targetTextureName= data.name
                    self:SetDefaultText(data.icon)
                    self.edit:SetText(data.name)
                    WoWTools_TargetMixin:Set_All_Init()
                end, {name=name, icon=icon, isAtlas=isAtlas})

                sub:AddInitializer(function(btn, desc)
                    local t = btn:AttachTexture()
                    t:SetSize(32, 32)
                    t:SetPoint("RIGHT")
                    if desc.data.isAtlas then
                        t:SetAtlas(desc.data.name)
                    else
                        t:SetTexture(desc.data.name or 0)
                    end
                end)

                sub:SetTooltip(function(tooltip, desc)
                    tooltip:AddLine(desc.data.icon)
                    tooltip:AddLine(desc.data.name)
                end)
                num= num+1
            end
        end
--SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(root)
    end)

    menu.edit= CreateFrame("EditBox", nil, menu, 'InputBoxTemplate')--EditBox
    WoWTools_TextureMixin:SetEditBox(menu.edit)
    menu.edit:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT',22,-2)
	menu.edit:SetSize(420,22)
	menu.edit:SetAutoFocus(false)
    menu.edit:ClearFocus()
    menu.edit.Label= WoWTools_LabelMixin:Create(menu.edit)
    menu.edit.Label:SetPoint('RIGHT', menu.edit, 'LEFT', -4, 0)
    menu.edit:SetScript('OnShow', function(self)
        self:SetText(Save().targetTextureName)
    end)
    menu.edit:SetScript('OnTextChanged', function(self)
        local name, isAtlas
        name= self:GetText() or ''
        name= name:gsub(' ', '')
        name= name=='' and false or name
        if name then
            isAtlas, name= WoWTools_TextureMixin:IsAtlas(name)
            if name then
                if isAtlas then
                    Frame.tipTargetTexture:SetAtlas(name)
                else
                    Frame.tipTargetTexture:SetTexture(name)
                end
                self.Label:SetText(isAtlas and 'Atls' or 'Texture')
            else
                Frame.tipTargetTexture:SetTexture(0)
            end
        end
        self.del:SetShown(name and WoWToolsPlayerDate['TargetTexture'][name])
        self.add:SetShown(name and not WoWToolsPlayerDate['TargetTexture'][name])
    end)

    --删除，图片
    menu.edit.del= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas='xmarksthespot', size=23})
    menu.edit.del:SetPoint('LEFT', menu, 'RIGHT',2,0)
    menu.edit.del:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtals, name= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if name and WoWToolsPlayerDate['TargetTexture'][name] then
            WoWToolsPlayerDate['TargetTexture'][name]= nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)..'|r',
                (isAtals and '|A:'..name..':0:0|a' or ('|T'..name..':0|t'))..name
            )
            parent:SetText("")
            parent:SetText(name)
        end
    end)

    --添加按钮
    menu.edit.add= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas='common-icon-checkmark', size=23})--添加, 按钮
    menu.edit.add:SetPoint('LEFT', menu.edit, 'RIGHT', 5,0)
    menu.edit.add:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtlas, icon= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if icon and not WoWToolsPlayerDate['TargetTexture'][icon] then
            WoWToolsPlayerDate['TargetTexture'][icon]= isAtlas and 'a' or 't'
            parent:SetText('')
            print(WoWTools_DataMixin.addName,
                WoWTools_TargetMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..'|r',
                (isAtlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'))..icon
            )
        end
    end)
    menu.edit.add:SetScript('OnLeave', GameTooltip_Hide)
    menu.edit.add:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local atlas, icon= WoWTools_TextureMixin:IsAtlas(menu.edit:GetText())
        if icon then
            GameTooltip:AddDoubleLine(atlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'), WoWTools_DataMixin.onlyChinese and '添加' or ADD)
            GameTooltip:AddDoubleLine(atlas and 'Atlas' or 'Texture', icon)
        else
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '无' or NONE)
        end
        GameTooltip:Show()
    end)






















    local sel2= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    sel2.Text:SetText('2) '..(WoWTools_DataMixin.onlyChinese and '怪物数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)))
    sel2:SetPoint('TOPLEFT', menu.edit, 'BOTTOMLEFT', -32, -32)
    sel2:SetChecked(Save().creature)
    sel2:SetScript('OnLeave', GameTooltip_Hide)
    sel2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if WoWTools_DataMixin.onlyChinese then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r')
        else
            GameTooltip:AddLine(WoWTools_DataMixin.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
        end
        GameTooltip:Show()
    end)
    sel2:SetScript('OnClick', function()
        Save().creature= not Save().creature and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local numSize = WoWTools_SliderMixin:CSlider(Frame, {min=8, max=72, value=Save().creatureFontSize, setp=1, w=100, color=true,
    text= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
    func=function(self2, value)--字体大小
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().creatureFontSize= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    numSize:SetPoint("LEFT", sel2.Text, 'RIGHT',15,0)

    local numPostionCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    numPostionCheck.Text:SetText(WoWTools_DataMixin.onlyChinese and '自定义位置' or SPELL_TARGET_CENTER_LOC)
    numPostionCheck:SetPoint('LEFT', numSize, 'RIGHT', 10,0)
    numPostionCheck:SetChecked(Save().creatureUIParent)
    numPostionCheck:SetScript('OnClick', function()
        Save().creatureUIParent= not Save().creatureUIParent and true or nil
        WoWTools_TargetMixin:Set_All_Init()
        if not Save().creatureUIParent and not Save().target then
            print('|cnWARNING_FONT_COLOR:'..(
                WoWTools_DataMixin.onlyChinese
                    and '需要启用‘1) '..'|A:common-icon-rotateright:0:0|a'..'目标’'
                    or ('Need to enable the \"1) |Acommon-icon-rotateright:0:0|a'..WoWTools_TargetMixin.addName..'\"')
            ))
        end
    end)























    local unitIsMeCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    unitIsMeCheck.Text:SetText('3) '..(WoWTools_DataMixin.onlyChinese and '目标是'..WoWTools_DataMixin.Player.col..'你|r' or 'Target is '..WoWTools_DataMixin.Player.col..'You|r'))
    unitIsMeCheck:SetPoint('TOP', sel2, 'BOTTOM', 0, -24)
    unitIsMeCheck:SetChecked(Save().unitIsMe)
    unitIsMeCheck:SetScript('OnClick', function()
        Save().unitIsMe= not Save().unitIsMe and true or false
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(Save().unitIsMe), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        WoWTools_TargetMixin:Set_All_Init()
    end)

    --local menuUnitIsMePoint = CreateFrame("FRAME", nil, Frame, "UIDropDownMenuTemplate")--下拉，菜单
    local menuUnitIsMePoint= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menuUnitIsMePoint:SetPoint("LEFT", unitIsMeCheck.Text, 'RIGHT', 15, 0)
    menuUnitIsMePoint:SetWidth(230)
    menuUnitIsMePoint:SetDefaultText(Save().unitIsMePoint)
    menuUnitIsMePoint.Text:ClearAllPoints()
    menuUnitIsMePoint.Text:SetPoint('CENTER')
    menuUnitIsMePoint:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        for _, name in pairs({
            'TOPLEFT',
            'TOP',
            'TOPRIGHT',
            'LEFT',
            'RIGHT',
        }) do
            root:CreateRadio(
                name,
            function(data)
                return Save().unitIsMePoint==data.name
            end, function(data)
                Save().unitIsMePoint= data.name
                --self:SetDefaultText(data.name)
                WoWTools_TargetMixin:Set_All_Init()
            end, {name=name})
        end
        root:CreateDivider()
        for _, tab2 in pairs({
            {'healthBar', WoWTools_DataMixin.onlyChinese and '生命条' or 'HealthBar'},
            {'name', WoWTools_DataMixin.onlyChinese and '名称' or NAME},
        }) do
            root:CreateCheckbox(
                tab2[2],
            function(data)
                return  Save().unitIsMeParent== data.name
            end, function(data)
                Save().unitIsMeParent= data.name
                WoWTools_TargetMixin:Set_All_Init()
            end, {name= tab2[1]})
        end
    end)

    local menuUnitIsMe= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menuUnitIsMe:SetPoint("LEFT", menuUnitIsMePoint, 'RIGHT', 2,0)
    menuUnitIsMe:SetWidth(150)
    menuUnitIsMe.Text:ClearAllPoints()
    menuUnitIsMe.Text:SetPoint('CENTER')
    menuUnitIsMe:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local num=0
        local sub, isAtlas, _, icon
        for name in pairs(get_texture_tab()) do
            isAtlas, _, icon= WoWTools_TextureMixin:IsAtlas(name, 20)
            if icon then
                sub=root:CreateRadio(
                    '',--icon,
                function(data)
                    return Save().unitIsMeTextrue== data.name
                end, function(data)
                    Save().unitIsMeTextrue= data.name
                    self:set_icon()
                    WoWTools_TargetMixin:Set_All_Init()
                end, {name=name, icon=icon, isAtlas=isAtlas})


                sub:AddInitializer(function(btn, desc)
                    local t = btn:AttachTexture()
                    t:SetSize(32, 32)
                    t:SetPoint("CENTER")
                    if desc.data.isAtlas then
                        t:SetAtlas(desc.data.name)
                    else
                        t:SetTexture(desc.data.name or 0)
                    end
                end)

                sub:SetTooltip(function(tooltip, desc)
                    tooltip:AddLine(select(3, WoWTools_TextureMixin:IsAtlas(desc.data.name, 64)), nil)
                    tooltip:AddLine(desc.data.name)
                end)
                num= num+1
            end
        end

--SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(root)
    end)

    function menuUnitIsMe:set_icon()
        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save().unitIsMeTextrue)
        if isAtlas or not texture then
            self.Icon:SetAtlas(texture or 'auctionhouse-icon-favorite')
        else
            self.Icon:SetTexture(texture)
        end
        self.Icon:SetVertexColor(Save().unitIsMeColor.r or 1, Save().unitIsMeColor.g or 1, Save().unitIsMeColor.b or 1, Save().unitIsMeColor.a or 1)
    end

    menuUnitIsMe.Icon= menuUnitIsMe:CreateTexture()
    menuUnitIsMe.Icon:SetSize(32,32)
    menuUnitIsMe.Icon:SetPoint('LEFT', menuUnitIsMe, 'RIGHT', 2)
    menuUnitIsMe.Icon:Show()
    menuUnitIsMe.Icon:EnableMouse(true)
    menuUnitIsMe.Icon:SetScript("OnLeave", function(self) self:SetAlpha(1) GameTooltip:Hide() end)
    menuUnitIsMe.Icon:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_TargetMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS ,COLOR)),
                            'r'..Save().unitIsMeColor.r..' g'..Save().unitIsMeColor.g..' b'..Save().unitIsMeColor.b..' a'..Save().unitIsMeColor.a)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT), 'r1 g1 b1 a1' )
        GameTooltip:Show()
        self:SetAlpha(0.7)
    end)
    menuUnitIsMe.Icon:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            Save().unitIsMeColor.r, Save().unitIsMeColor.g, Save().unitIsMeColor.b, Save().unitIsMeColor.a= 1,1,1,1
            self:GetParent():set_icon()
            WoWTools_TargetMixin:Set_All_Init()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName, WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)
        else
            local r,g,b,a= Save().unitIsMeColor.r, Save().unitIsMeColor.g, Save().unitIsMeColor.b, Save().unitIsMeColor.a
            WoWTools_ColorMixin:ShowColorFrame(r,g,b,a,
                function()
                    Save().unitIsMeColor=  select(5, WoWTools_ColorMixin:Get_ColorFrameRGBA())--取得, ColorFrame, 颜色
                    self:GetParent():set_icon()
                    WoWTools_TargetMixin:Set_All_Init()
                end, function()
                    Save().unitIsMeColor.r, Save().unitIsMeColor.g, Save().unitIsMeColor.b, Save().unitIsMeColor.a= r, g, b, a
                    self:GetParent():set_icon()
                    WoWTools_TargetMixin:Set_All_Init()
                end
            )
            self:SetAlpha(1)
        end
    end)

    menuUnitIsMe:set_icon()

    local unitIsMeX = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().unitIsMeX, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().unitIsMeX= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    unitIsMeX:SetPoint("TOPLEFT", unitIsMeCheck, 'BOTTOMRIGHT',0, -12)
    local unitIsMeY = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().unitIsMeY, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().unitIsMeY= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    unitIsMeY:SetPoint("LEFT", unitIsMeX, 'RIGHT',15,0)

    local unitIsMeSize = WoWTools_SliderMixin:CSlider(Frame, {min=2, max=64, value=Save().unitIsMeSize, setp=1, w= 100, color=false,
    text= WoWTools_DataMixin.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE,
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().unitIsMeSize= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    unitIsMeSize:SetPoint("LEFT", unitIsMeY, 'RIGHT',15,0)




















    local questCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText('4) '..(WoWTools_DataMixin.onlyChinese and '任务进度' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, PVP_PROGRESS_REWARDS_HEADER))))
    questCheck:SetPoint('TOPLEFT', unitIsMeCheck, 'BOTTOMLEFT',0,-64)
    questCheck:SetChecked(Save().quest)
    questCheck:SetScript('OnClick', function()
        Save().quest= not Save().quest and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local questAllFactionCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetFormattedText(
        '%s|A:%s:0:0|a|A:%s:0:0|a',
        WoWTools_DataMixin.onlyChinese and '所有阵营' or TRANSMOG_SHOW_ALL_FACTIONS or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, FACTION),
        WoWTools_DataMixin.Icon.Horde, WoWTools_DataMixin.Icon.Alliance)

    questAllFactionCheck:SetPoint('LEFT', questCheck.Text, 'RIGHT',2,0)
    questAllFactionCheck:SetChecked(Save().questShowAllFaction)
    questAllFactionCheck:SetScript('OnClick', function()
        Save().questShowAllFaction= not Save().questShowAllFaction and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local classCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    classCheck.Text:SetText(WoWTools_DataMixin.onlyChinese and '职业' or CLASS)
    classCheck:SetPoint('LEFT', questAllFactionCheck.Text, 'RIGHT',2,0)
    classCheck:SetChecked(Save().questShowPlayerClass)
    classCheck:SetScript('OnClick', function()
        Save().questShowPlayerClass= not Save().questShowPlayerClass and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local instanceCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    instanceCheck.Text:SetText(WoWTools_DataMixin.onlyChinese and '在副本里显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INSTANCE))
    instanceCheck:SetPoint('TOPLEFT', questCheck, 'BOTTOMRIGHT')
    instanceCheck:SetChecked(Save().questShowInstance)
    instanceCheck:SetScript('OnClick', function()
        Save().questShowInstance= not Save().questShowInstance and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)






    Init_Options=function()end
end















--添加控制面板
local function Init()
    Frame= CreateFrame('Frame', nil, SettingsPanel)

    WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_TargetMixin.addName,
        frame= Frame,
        disabled= Save().disabled
    })

    WoWTools_ButtonMixin:ReloadButton({panel=Frame, addName= WoWTools_TargetMixin.addName, restTips=nil, checked=not Save().disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
        disabledfunc=function()
            Save().disabled= not Save().disabled and true or nil

            Init()
            WoWTools_TargetMixin:Set_All_Init()

            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), Save().disabled and (WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')

        end,
        clearfunc= function() WoWToolsSave['Plus_Target']=nil WoWTools_DataMixin:Reload() end}
    )

    Init_Options()

    Init=function()
        Init_Options()
    end
end













function WoWTools_TargetMixin:Blizzard_Settings()
    Init()
end