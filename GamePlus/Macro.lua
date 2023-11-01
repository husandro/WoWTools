local id, e= ...


local addName= MACRO--宏
local Save={
    --disabled= not e.Player.husandro,
    --toRightLeft= 1,2, nil --左边 右边 默认
    spellButton=e.Player.husandro,
}

--Blizzard_MacroUI.lua



local function Get_Spell_Macro(name, spellID)
    if spellID==6603 then--自动攻击
        return '/startattack'

    elseif spellID==5384 then--[假死]
        if IsSpellKnownOrOverridesKnown(209997) then
            local spellName= GetSpellInfo(209997)
            if spellName then
                return '/petfollow\n/cast '..spellName..'\n/cast '..name
            end
        end
        return '/petfollow\n/cast '..name

    elseif spellID==2643--[多重射击]
        or spellID==257620--[多重射击]
        or spellID==187708--[削凿]
    then
        local spellName= GetSpellInfo(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end

    elseif spellID==118--[变形术]
        or spellID==2139--[法术反制]

        or spellID==147362--[反制射击]
    then
        return '/stopcasting\n/cast [target=mouseover,harm,exists][target=focus,harm,exists]'
            ..name..';'..name
            ..'\n/focus [target=focus,noexists][target=focus,dead]target'
        
    elseif spellID==212653--[闪光术]
        or spellID==1953--[闪现术]
        or spellID==66--[隐形术]
        or spellID==110959--[强化隐形术]

        
    then
        local spellName= GetSpellInfo(45438)--[寒冰屏障]
        local text='/stopcasting\n/cast '..name
        if spellName then
            text= '/cancelaura '..spellName..'\n'..text
        end
        return text

    elseif  spellID==190336 then--[造餐术]
        local spellName= GetSpellInfo(190336)
        local itemName= C_Item.GetItemNameByID(113509)
        if spellName and itemName then
           return '/use [button:1]'..spellName..'\n/cast [button:2]'..itemName
        end

    elseif spellID==78675--[日光术]
        or spellID==33786--[旋风]
        or spellID==57994--[风剪]

        or spellID==45438--[寒冰屏障]
        
        
        

    then
        return '/stopcasting\n/cast '..name

    elseif spellID==145205--[百花齐放]
        or spellID==192058--[电能图腾]
        or spellID==51485--[陷地图腾]
        or spellID==73920--[治疗之雨]
        or spellID==61882--[地震术]
        or spellID==192222--[岩浆图腾]
        or spellID==198838--[大地之墙图腾]

        or spellID==358385--[山崩]
        or spellID==357210--[深呼吸]

        or spellID==113724--[冰霜之环]
        or spellID==2120--[烈焰风暴]
        or spellID==190356--[暴风雪]

        or spellID==187650--[冰冻陷阱]
        or spellID==187698--[焦油陷阱]
        or spellID==109248--[束缚射击]
        or spellID==162488--[精钢陷阱]
        or spellID==236776--[高爆陷阱]
        or spellID==1543--[照明弹]
        or spellID==6197--[鹰眼术]
        or spellID==260243--[乱射]
        or spellID==257284--[猎人印记]
        or spellID==190925--[鱼叉猛刺]
        
    then
        return '/cast [@cursor]'..name
    end
end














local function Create_Button(name)
    local btn= e.Cbtn(MacroEditButton, {size={60,22}, type=false})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(e.Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        local col= self:find_text() and '|cff606060' or ''
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col..self.text..(self.tip or ''), e.Icon.left)
        if self.text2 then
            e.tips:AddLine(' ')
            col= self:find_text(true) and '|cff606060' or ''
        end
        e.tips:AddDoubleLine(col..self.text2..(self.tip2 or ''), e.Icon.right)
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            if self.textCursor then
                MacroFrameText:SetCursorPosition(self.textCursor)
            end
            MacroFrameText:Insert(self.text)
            MacroFrameText:SetFocus()

        elseif d=='RightButton' and self.text2 then
            if self.text2Cursor then
                MacroFrameText:SetCursorPosition(self.text2Cursor)
            end
            MacroFrameText:Insert(self.text2)
            MacroFrameText:SetFocus()
        end
        self:set_tooltips()
    end)
    btn:SetText(name)
    btn:SetScript('OnLeave', function() e.tips:Hide() end)
    btn:SetScript("OnEnter", btn.set_tooltips)
    return btn
end

















local function Init()
    local w, h= 350, 600--672, 672
    MacroFrame:SetSize(w, h)--<Size x="338" y="424"/>
    MacroFrameScrollFrame:SetSize(w-43, h/2-45)
    MacroFrameText:SetSize(w-43, h/2-45)
    MacroFrameTextBackground:SetSize(w-30, h/2-30)
    MacroHorizontalBarLeft:SetWidth(w-85)

    MacroEditButton:SetSize(60,22)--170 22
    MacroEditButton:SetText(e.onlyChinese and '名称' or NAME)

    --设置，焦点
    MacroFrameTextBackground.NineSlice:SetScript('OnMouseDown', function(_, d)
        if d=='LeftButton' then
            MacroFrameText:SetFocus()
        end
    end)

    

    --设置，宏，图标，位置，长度
    hooksecurefunc(MacroFrame, 'ChangeTab', function(self, tabID)
        self.MacroSelector:ClearAllPoints()
        if tabID==1 then
            self.MacroSelector:SetHeight(590)--(319,588)
            if Save.toRightLeft==1 then--左边
                self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
            elseif Save.toRightLeft==2 then--右边
                self.MacroSelector:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,-12)
            else--默认
                self.MacroSelector:SetHeight(146)--,146)--<Size x="319" y="146"/>
                self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
            end
        else
            self.MacroSelector:SetHeight(146)--,146)--<Size x="319" y="146"/>
            self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
        end
    end)

    --设置按钮
    local toRightButton= e.Cbtn(MacroFrame.TitleContainer, {size={20,20}, icon='hide'})
    toRightButton:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerMacroFrame'] then
        toRightButton:SetPoint('RIGHT', _G['MoveZoomInButtonPerMacroFrame'], 'LEFT')
    else
        toRightButton:SetPoint('LEFT',0, -2)
    end
    function toRightButton:set_texture()
        if Save.toRightLeft==1 then--左边
            self:SetNormalAtlas(e.Icon.toLeft)
        elseif Save.toRightLeft==2 then--右边
            self:SetNormalAtlas(e.Icon.toRight)
        else--默认
            self:SetNormalAtlas(e.Icon.icon)
        end
    end
    function toRightButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..':')
        e.tips:AddDoubleLine(e.Icon.toLeft2..(e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT), Save.toRightLeft==1 and e.Icon.select2)
        e.tips:AddDoubleLine(e.Icon.toRight2..(e.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT), Save.toRightLeft==2 and e.Icon.select2)
        e.tips:AddDoubleLine('|A:'..e.Icon.icon..':0:0|a'..(e.onlyChinese and '默认' or DEFAULT), not Save.toRightLeft and e.Icon.select2)
        e.tips:Show()
        e.tips:SetAlpha(1)
    end
    toRightButton:SetScript('OnClick', function(self)
        if not Save.toRightLeft then
            Save.toRightLeft=1--左边
        elseif Save.toRightLeft==1 then
            Save.toRightLeft=2--右边
        elseif Save.toRightLeft==2 then
            Save.toRightLeft=nil--默认
        end
        Save.toRight= not Save.toRight and true or nil
        MacroFrame:ChangeTab(1)
        self:set_texture()
        self:set_tooltips()
    end)
    toRightButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    toRightButton:SetScript('OnEnter', toRightButton.set_tooltips)
    toRightButton:set_texture()


    --宏，提示
    local function set_btn_tooltips(self)
        if self.selectionIndex then
            local index= self.selectionIndex+ MacroFrame.macroBase
            local name, icon, body = GetMacroInfo(index)
            if name and icon and body then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|T'..icon..':0|t'..name, index)
                e.tips:AddLine(body)
                e.tips:Show()
            end
        end
    end
    hooksecurefunc(MacroButtonMixin, 'OnLoad', function(self)
        self:HookScript('OnEnter', set_btn_tooltips)
        self:HookScript('OnLeave', function() e.tips:Hide() end)
        local texture= self:GetRegions()
        texture:SetAlpha(0.3)
    end)
    MacroFrameSelectedMacroButton:HookScript('OnEnter', set_btn_tooltips)
    MacroFrameSelectedMacroButton:HookScript('OnLeave', function() e.tips:Hide() end)




    --选定宏，index提示
    MacroFrame.numSelectionLable= e.Cstr(MacroFrameSelectedMacroButton)
    MacroFrame.numSelectionLable:SetPoint('BOTTOM', MacroFrameSelectedMacroButton, 'TOP')
    MacroFrame.numSelectionLable:SetScript('OnLeave', function() e.tips:Hide() end)
    MacroFrame.numSelectionLable:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(self:GetText(), e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)
        e.tips:Show()
    end)
    hooksecurefunc(MacroFrame, 'SelectMacro', function(self, index)
        self.numSelectionLable:SetText(index and index+MacroFrame.macroBase or '')
        --index= index and index+MacroFrame.macroBase or nil
        MacroFrameSelectedMacroButton.selectionIndex= index
    end)
    --[[hooksecurefunc(SelectorButtonMixin, 'OnClick', function(self)
        local actualIndex = MacroFrame:GetMacroDataIndex(self:GetElementData())
        if actualIndex then
            actualIndex= actualIndex- MacroFrame.macroBase
        end
        MacroFrameSelectedMacroButton.numSelectionLable:SetText(actualIndex or '')
    end)]]


    --保存，提示
    MacroSaveButton.saveTip= MacroSaveButton:CreateTexture()
    MacroSaveButton.saveTip:SetPoint('RIGHT', MacroSaveButton, 'LEFT')
    MacroSaveButton.saveTip:SetSize(22,22)
    MacroSaveButton.saveTip:SetAtlas('common-icon-rotateright')
    MacroSaveButton.saveTip:Hide()
    local function set_saveTip()
        local show= false
        local index= MacroFrameSelectedMacroButton.selectionIndex
        if index then
            index= index + MacroFrame.macroBase
            local body = select(3, GetMacroInfo(index))
            show= body~= MacroFrameText:GetText()
        end
        MacroSaveButton.saveTip:SetShown(show)
    end
    MacroFrameText:HookScript('OnTextChanged', set_saveTip)
    MacroSaveButton:HookScript('OnClick', set_saveTip)


    --打开/关闭法术书
    MacroFrame.OpenSpellButton= e.Cbtn(MacroFrame, {size={32,32}, atlas='UI-HUD-MicroMenu-SpellbookAbilities-Up'})
    MacroFrame.OpenSpellButton:SetPoint('TOPRIGHT', -2, -28)
    MacroFrame.OpenSpellButton:SetScript('OnLeave', function() e.tips:Hide() end)
    MacroFrame.OpenSpellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', '|A:UI-HUD-MicroMenu-SpellbookAbilities-Up:22:22|a'..(e.onlyChinese and '打开/关闭法术书' or BINDING_NAME_TOGGLESPELLBOOK))
        e.tips:Show()
    end)
    MacroFrame.OpenSpellButton:SetScript("OnClick", function()
        ToggleSpellBook(BOOKTYPE_SPELL)
    end)

   


    --宏数量
    --Blizzard_MacroUI.lua
    MacroFrameTab1.label= e.Cstr(MacroFrameTab1)
    MacroFrameTab1.label:SetPoint('BOTTOM', MacroFrameTab1, 'TOP', 0, -8)
    MacroFrameTab2.label= e.Cstr(MacroFrameTab2)
    MacroFrameTab2.label:SetPoint('BOTTOM', MacroFrameTab2, 'TOP', 0, -8)
    hooksecurefunc(MacroFrame, 'Update', function()
    	local numAccountMacros, numCharacterMacros
        numAccountMacros, numCharacterMacros = GetNumMacros()
        numAccountMacros= numAccountMacros or 0
        numAccountMacros= numAccountMacros==MAX_ACCOUNT_MACROS and '|cnRED_FONT_COLOR:'..numAccountMacros or numAccountMacros

        numCharacterMacros= numCharacterMacros or 0
        numCharacterMacros= numCharacterMacros==MAX_CHARACTER_MACROS and '|cnRED_FONT_COLOR:'..numCharacterMacros or numCharacterMacros

        MacroFrameTab1.label:SetText(numAccountMacros..'/'..MAX_ACCOUNT_MACROS)
        MacroFrameTab2.label:SetText(numCharacterMacros..'/'..MAX_CHARACTER_MACROS)
    end)







    local attck= Create_Button(e.onlyChinese and '目标' or TARGET)
    attck:SetPoint('LEFT', MacroEditButton, 'RIGHT',5,15)
    attck.text=[[#showtooltip
/targetenemy [noharm][dead]
]]
    attck.text2=[[/cancelaura ]]
    attck.textCursor=0
    attck.text2Cursor=nil
    attck.tip=nil
    attck.tip2=e.onlyChinese and '光环名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AURAS, NAME)


    local cnacel= Create_Button(e.onlyChinese and '攻击' or ATTACK)
    cnacel:SetPoint('LEFT', attck, 'RIGHT')
    cnacel.text=[[/petattack
/startattack
]]
    cnacel.text2=[[/petfollow
/stopattack
/stopcasting
]]





    local function Spell_Menu(index)
        local _, _, offset, numSlots = GetSpellTabInfo(index)
        local num=0
        for i= offset+1, offset+ numSlots do
            local name, _, icon, _, _, _, spellID= GetSpellInfo(i, BOOKTYPE_SPELL)
            num= num +1
            if name and not IsPassiveSpell(i, BOOKTYPE_SPELL) and spellID then
                local col
                if not IsSpellKnownOrOverridesKnown(spellID) then
                    col='|cff606060'
                end
                icon= icon and '|T'..icon..':0|t' or ''
                
                e.LibDD:UIDropDownMenu_AddButton({
                    text=icon..name,
                    tooltipOnButton=true,
                    tooltipTitle= 'Alt '..icon..(e.onlyChinese and '查询' or WHO)..' '.. spellID,--'Alt /targetenemy|n'..(col or '')..
                    tooltipText= GetSpellDescription(spellID),
                    colorCode=col,
                    icon= 'services-number-'..math.ceil(num / SPELLS_PER_PAGE),
                    arg1= name,
                    arg2= spellID,
                    notCheckable=true,
                    func= function(_, arg1, arg2)
                        if IsShiftKeyDown() then
                            local link=GetSpellLink(arg2) or GetSpellInfo(arg2) or arg2
                            link= 'or spellID=='..arg2..'--'..link
                            if not ChatEdit_InsertLink(link) then
                                ChatFrame_OpenChat(link)
                            end
                        elseif IsAltKeyDown() then
                            e.call('SpellBookFrame_OpenToSpell', arg2)
                        else
                            local text=''
                            local macro= MacroFrameText:GetText() or ''
                            if macro=='' then
                                text= '#showtooltip '..name..'\n/targetenemy [noharm][dead]\n'
                            else
                                if not macro:find('#showtooltip') then
                                    text= '#showtooltip '..name..'\n'
                                end
                                if not macro:find('/targetenemy') then
                                    text= text..'/targetenemy [noharm][dead]\n'
                                end
                            end
                            text= text..(Get_Spell_Macro(arg1, arg2) or ('/cast '..arg1))
                            --MacroFrameText:SetCursorPosition(0)
                            MacroFrameText:Insert(text..'\n')
                            MacroFrameText:SetFocus()
                        end
                    end
                }, 1)
            end
        end
        if index==1 then
            e.LibDD:UIDropDownMenu_AddButton({
                text='ExtraActionButton1',
                tooltipOnButton=true,
                tooltipTitle='/click ExtraActionButton1',
                notCheckable=true,
                func= function()
                    MacroFrameText:Insert('/click ExtraActionButton1\n')
                    MacroFrameText:SetFocus()
                end
            }, 1)
            
        end
    end

    MacroFrame.Menu= CreateFrame("Frame", nil, MacroFrame, "UIDropDownMenuTemplate")

    local last
    for i=1, MAX_SKILLLINE_TABS do
        local name, icon, _, _, _, _, shouldHide, specID = GetSpellTabInfo(i)
        if (i==1 or i==2 or specID) and not shouldHide and name then
            local btn= e.Cbtn(MacroEditButton, {size={24,24}, texture=icon})
            btn.index= i
            if not last then
                btn:SetPoint('TOPLEFT', MacroEditButton, 'BOTTOMRIGHT',0,8)
            else
                btn:SetPoint('LEFT', last, 'RIGHT')
            end
           
            if i==3 then
                local texture= btn:CreateTexture(nil, 'OVERLAY')
                texture:SetAtlas('Forge-ColorSwatchSelection')
                texture:SetPoint('CENTER')
                texture:SetSize(28,28)
                texture:SetAlpha(0.7)
            end
            btn:SetScript('OnClick', function(self)
                e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function() Spell_Menu(self.index) end, 'MENU')
                e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
            end)
            btn:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
            btn:SetScript('OnEvent', function(self)
                self:SetNormalTexture( select(2, GetSpellTabInfo(self.index)) or 0)
            end)
            last= btn
        end
    end


end


















local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if PetStableFrame then
                Save= WoWToolsSave[addName] or Save

                --添加控制面板
                e.AddPanel_Check({
                    name= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(e.onlyChinese and '宏' or addName),
                    tooltip= ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                        ..'|r|n'..(e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                    value= not Save.disabled,
                    func= function()
                        Save.disabled = not Save.disabled and true or nil
                        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    end
                })

                if Save.disabled  then
                    self:UnregisterEvent('ADDON_LOADED')
                end
            end

        elseif arg1=='Blizzard_MacroUI' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PET_STABLE_SHOW' then
        Init()
        panel:UnregisterEvent('PET_STABLE_SHOW')
    end
end)