local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end
local Frame










local function Init_Frame()
    Frame= CreateFrame('Frame', nil, ProfessionsFrame)
    Frame:SetPoint('BOTTOMLEFT', ProfessionsFrame, 'BOTTOMRIGHT',0, 35)
    Frame:SetSize(1,1)

    function Frame:set_event()
        self:UnregisterAllEvents()
        if ProfessionsFrame:IsVisible() then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        else
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
        end
    end
    Frame:SetScript('OnEvent', function()
        if ProfessionsFrame:IsVisible() then
            --GenerateClosure(ProfessionsFrame.CheckConfirmClose, ProfessionsFrame)
            HideUIPanel(ProfessionsFrame)
        end
    end)

    ProfessionsFrame:HookScript('OnShow', function()
        Frame:set_event()
    end)
    ProfessionsFrame:HookScript('OnHide', function()
        Frame:set_event()
    end)

    function Frame:set_scale()
        self:SetScale(Save().scaleButton or 1)
    end
    Frame:set_scale()
    Frame:set_event()
end














--专业界面, 按钮
local function Init_Buttons()
    local last
    local tab={GetProfessions()}--prof1, prof2, archaeology, fishing, cooking
    if tab[3]==10 and #tab>3 then
        local archaeology=tab[3]--10
        table.remove(tab, 3)
        table.insert(tab, archaeology)
    end

    for k , index in pairs(tab) do
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)
        if icon and skillLine then
            local button= WoWTools_ButtonMixin:Cbtn(Frame, {icon='hide',size={32, 32}})
            button:SetNormalTexture(icon)

            if not last then
                button:SetPoint('BOTTOMLEFT', Frame)
            elseif k==3 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 17)
            elseif skillLine==794 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 37)
            else
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0,2)
            end
            button:SetScript('OnMouseDown', function(self)
                C_TradeSkillUI.OpenTradeSkill(self.skillLine)
            end)
            button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self.name, 'skillLine '..self.skillLine)
                e.tips:AddDoubleLine(e.addName, WoWTools_ProfessionMixin.addName)
                e.tips:Show();
            end)
            button:SetScript('OnLeave',function(self)
                e.tips:Hide()
                self:SetButtonState('NORMAL')
            end)
            button.name= name
            button.skillLine= skillLine

            if skillLine==185 then--烹饪用火
                local name2= C_Spell.GetSpellName(818)
                if name2 then
                    local btn= WoWTools_ButtonMixin:Cbtn(button, {type= true, texture=135805 ,size={32, 32}})
                    btn:SetPoint('LEFT', button, 'RIGHT',2,0)

                    function btn:set_event()
                        e.SetItemSpellCool(self, {spell=818})
                    end
                    function btn:settings()
                        if self:IsVisible() then
                            self:set_event()
                            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                        else
                            e.SetItemSpellCool(self)
                            self:UnregisterAllEvents()
                        end
                    end
                    btn:SetScript('OnEvent', btn.set_event)
                    btn:SetScript('OnShow', btn.settings)
                    btn:SetScript('OnHide', btn.settings)
                    btn:settings()


                    btn:SetScript('OnLeave', GameTooltip_Hide)
                    btn:SetScript('OnEnter', function(self)
                        e.tips:SetOwner(self, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(818)

                        if self.toyName then
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine('|T236571:0|t|cnGREEN_FONT_COLOR:'..self.toyName, e.Icon.right)
                        end
                        e.tips:Show()
                    end)

                    btn:SetAttribute('type1', 'spell')
                    btn:SetAttribute('spell1', name2)
                    btn:SetAttribute('unit', 'player')

                    local toyName=C_Item.GetItemNameByID(134020)--玩具,大厨的帽子
                    btn:SetAttribute('type2', 'item')
                    btn:SetAttribute('item2', toyName)
                    btn.toyName= toyName
                end
            end
            last= button
        end
    end
end














local function Init()
    if Frame then
        Frame:SetShown(Save().setButton)
    else
        if Save().setButton then
            do
                Init_Frame()
            end
            Init_Buttons()
        end
    end
end
















local function Init_Menu(_, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end
    local sub

--启用
    sub=root:CreateCheckbox(
        e.onlyChinese and '显示快捷按钮' or SHOW_QUICK_BUTTON,
    function()
        return Save().setButton
    end, function()
        Save().setButton= not Save().setButton and true or nil
        if Frame then
            print(e.addName,  WoWTools_ProfessionMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
        Init()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT )..': '..e.GetShowHide(false))
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    --缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save().scaleButton or 1
    end, function(value)
        Save().scaleButton= value
        if Frame then
            Frame:set_scale()
        end
    end)

    root:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(root)
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ProfessionMixin.addName})
end










function WoWTools_ProfessionMixin:Init_ProfessionsFrame_Button()
    local btn=WoWTools_ButtonMixin:CreateMenu(ProfessionsFrame.CloseButton, {name='WoWToolsProfessionsEnableButton'})
    btn:SetPoint('RIGHT', ProfessionsFrame.MaximizeMinimize.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(f)
        e.tips:SetOwner(f, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.left)
        e.tips:Show()
    end)

    btn:SetupMenu(Init_Menu)
    Init()
end