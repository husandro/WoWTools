local e= select(2, ...)
local addName
local GossipButton
local function Save()
    return WoWTools_GossipMixin.Save
end











--自定义，对话，文本，放在主菜单，前
local function Init()
    


    Gossip_Text_Icon_Frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame', UIParent)--, 'DialogBorderTemplate')--'ButtonFrameTemplate')
    Gossip_Text_Icon_Frame:SetSize(580, 370)
    Gossip_Text_Icon_Frame:SetFrameStrata('HIGH')
    Gossip_Text_Icon_Frame:SetPoint('CENTER')


    local border= CreateFrame('Frame', nil, Gossip_Text_Icon_Frame,'DialogBorderTemplate')
    local Header= CreateFrame('Frame', nil, Gossip_Text_Icon_Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Header:Setup('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE)))
    local CloseButton=CreateFrame('Button', nil, Gossip_Text_Icon_Frame, 'UIPanelCloseButton')
    CloseButton:SetPoint('TOPRIGHT')

    e.Set_Alpha_Frame_Texture(border, {alpha=0.5})
    e.Set_Alpha_Frame_Texture(Header, {alpha=0.7})
    e.Set_Move_Frame(Gossip_Text_Icon_Frame, {needMove=true, minW=370, minH=240, notFuori=true, setSize=true, sizeRestFunc=function(btn)
        btn.target:SetSize(580, 370)
    end})


    local menu = CreateFrame("Frame", nil, Gossip_Text_Icon_Frame, "WowScrollBoxList")
    menu:SetPoint("TOPLEFT", 12, -30)
    menu:SetPoint("BOTTOMRIGHT", -310,12)
    Gossip_Text_Icon_Frame.menu= menu


    menu.bg= menu:CreateTexture(nil, 'BACKGROUND')
    menu.bg:SetPoint('TOPLEFT', -35, 80)
    menu.bg:SetPoint('BOTTOMRIGHT',35, -72)
    menu.bg:SetAtlas('QuestBG-Trading-Post')

    menu.ScrollBar  = CreateFrame("EventFrame", nil, Gossip_Text_Icon_Frame, "MinimalScrollBar")
    menu.ScrollBar:SetPoint("TOPLEFT", menu, "TOPRIGHT", 8,0)
    menu.ScrollBar:SetPoint("BOTTOMLEFT", menu, "BOTTOMRIGHT",8,0)

    menu.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(menu, menu.ScrollBar, menu.view)

    menu.view:SetElementInitializer("GossipTitleButtonTemplate", function(btn, info)-- UIPanelButtonTemplate GossipTitleButtonTemplate
        btn.gossipID= info.gossipID
        btn.spellID= info.spellID
        if not btn.delete then
            btn:SetScript("OnClick", function(self)
                Gossip_Text_Icon_Frame.menu:set_date(self.gossipID)
            end)
            btn:SetScript('OnLeave', function(self) self.delete:SetAlpha(0) end)
            btn:SetScript('OnEnter', function(self) self.delete:SetAlpha(1) end)

            btn.delete= WoWTools_ButtonMixin:Cbtn(btn, {size={18,18}, atlas='common-icon-redx'})
            btn.delete:SetPoint('RIGHT')
            btn.delete:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
            btn.delete:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
            btn.delete:SetScript('OnClick', function(self)
                Gossip_Text_Icon_Frame.menu:delete_gossip(self:GetParent().gossipID)
            end)
            btn.delete:SetAlpha(0)
            btn:GetFontString():SetPoint('RIGHT')

        end

        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(info.icon)
        if isAtlas then
            btn.Icon:SetAtlas(texture)
        else
            btn.Icon:SetTexture(texture or 0)
        end
        if Save().Gossip_Text_Icon_cnFont then
            btn:GetFontString():SetFont('Fonts\\ARHei.ttf', 14)
        else
            btn:GetFontString():SetFontObject('QuestFontLeft')
        end
        btn:SetText((info.hex and '|c'..info.hex or '')..(info.name or ''))
        btn:Resize()
    end)

    function menu:SortOrder(leftInfo, rightInfo)
        if GossipFrame:IsShown() then
            return leftInfo.orderIndex < rightInfo.orderIndex;
        else
            return leftInfo.gossipID < rightInfo.gossipID;
        end
    end

    function menu:set_list()
        if self:IsShown() then
            local n=0
            local gossipNum=0--GossipFrame 有多少对话
            self.dataProvider = CreateDataProvider()
            if GossipFrame:IsShown() then
                local tabs={}
                for _, info in pairs(C_GossipInfo.GetOptions() or {}) do
                    local data= Save().Gossip_Text_Icon_Player[info.gossipOptionID]
                    if data then
                        data.gossipOptionID= info.gossipOptionID
                        data.orderIndex= info.orderIndex
                        data.name= data.name or info.name or info.gossipOptionID
                        table.insert(tabs, data)
                    else
                        gossipNum= gossipNum +1
                    end
                end
                table.sort(tabs, function(a, b) return a.orderIndex< b.orderIndex end)
                for _, data in pairs(tabs) do
                    self.dataProvider:Insert({gossipID=data.gossipOptionID, icon=data.icon, name=data.name, hex=data.hex, spellID=data.spellID})
                end
                self.chat.Text:SetFormattedText('%s%d', gossipNum>0 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e', gossipNum)--GossipFrame 有多少已设置
                for _ in pairs(Save().Gossip_Text_Icon_Player) do
                    n=n+1
                end
            else
                for gossipID, data in pairs(Save().Gossip_Text_Icon_Player) do
                    self.dataProvider:Insert({gossipID=gossipID, icon=data.icon, name=data.name or gossipID, hex=data.hex})
                    n=n+1
                end
                self.chat.Text:SetText('')
            end
            self.view:SetDataProvider(self.dataProvider,  ScrollBoxConstants.RetainScrollPosition)

            self:FullUpdate()--FullUpdateInternal() FullUpdate()
            self.NumLabel:SetText(n)
        else
            self.dataProvider= nil
        end
    end


    function menu:update_list()
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames() or {}) do
            if btn.gossipID==self.gossipID then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
        local tab={}
        for _, data in pairs(C_GossipInfo.GetOptions() or {}) do
            tab[data.orderIndex]= data.gossipOptionID
        end
        if not GossipFrame.GreetingPanel.ScrollBox:GetView() then
            return
        end
        for _, b in pairs(GossipFrame.GreetingPanel.ScrollBox:GetFrames() or {}) do
            if tab[b:GetID()]==self.gossipID then
                b:LockHighlight()
            else
                b:UnlockHighlight()
            end
        end
    end


    function menu:get_gossipID()--取得gossipID
        return self.ID:GetNumber() or 0
    end
    function menu:get_name()--取得，名称
        local name= self.Name:GetText()
        if name=='' then
            return
        else
            return name
        end
    end
    function menu:get_icon()--设置，图片
        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(self.Icon:GetText())
        return texture, isAtlas
    end
    function menu:set_texture_size()--图片，大小
        self.Texture:SetSize(Save().Gossip_Text_Icon_Size, Save().Gossip_Text_Icon_Size)
    end

    function menu:set_all()
        local num= self:get_gossipID()
        local name= self:get_name()
        local icon= self:get_icon()
        local info= Save().Gossip_Text_Icon_Player[num]
        if info then
            self.gossipID=num
        else
            self.gossipID=nil
        end

        --local gossipID= self.gossipID
        --[[local text=''
        local info= gossipID and Save().Gossip_Text_Icon_Player[gossipID]
        if info then
            local icon=''
            local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(info.icon)
            if texture then
                icon= isAtlas and ('|A:'..texture..':0:0|a') or ('|T'..texture..':0|t')
            end
            text= gossipID..' '..icon..'|c'..(info.hex or 'ffffffff')..(info.name or '')..'|r'
        end
        self:SetText(text)]]
        --e.LibDD:UIDropDownMenu_SetText(self, text)--设置，菜单，文本

        local hex = self.Color.hex or 'ff000000'
        if info then
            if info.icon==icon and info.name==name and (info.hex==hex or (not info.hex and hex=='ff000000')) then--一样，数据
                self.Add:SetNormalAtlas('VignetteEvent')
                self.Add.tooltip=e.onlyChinese and '已存在' or UPDATE
            else--需要，更新，数据
                self.Add:SetNormalAtlas(e.Icon.select)
                self.Add.tooltip=e.onlyChinese and '需要更新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, UPDATE)
            end
        else
            self.Add:SetNormalAtlas('bags-icon-addslots')
            self.Add.tooltip=e.onlyChinese and '添加' or ADD
        end
        self.Delete:SetShown(self.gossipID and true or false)--显示/隐藏，删除按钮
        self.Add:SetShown(num>0 and (name or icon or hex~='ff000000'))--显示/隐藏，添加按钮
    end

    function menu:set_color(r, g, b, hex)--设置，颜色，颜色按钮，
        if hex then
            r,g,b= WoWTools_ColorMixin:HEXtoRGB(hex)
        elseif r and g and b then
            hex= WoWTools_ColorMixin:RGBtoHEX(r,g,b)
        else
            r,g,b,hex= 0,0,0, 'ff000000'
        end
        self.Color.r, self.Color.g, self.Color.b, self.Color.hex= r, g, b, hex
        self.Color.Color:SetVertexColor(r,g,b,1)
        self.Name:SetTextColor(r,g,b)
        self:set_all()
    end

    function menu:get_saved_all_date(gossipID)
        return Save().Gossip_Text_Icon_Player[gossipID] or WoWTools_GossipMixin:Get_GossipData()[gossipID]
    end
    function menu:set_date(gossipID)--读取，已保存数据
        if not gossipID then
            return
        end
        local name,icon,hex, name2, info
        for _, info2 in pairs(C_GossipInfo.GetOptions() or {}) do
            if info2 and info2.gossipOptionID==gossipID then
                name2= info2.name
                break
            end
        end
        info= self:get_saved_all_date(gossipID)
        if info then
            name, icon, hex= info.name, info.icon, info.hex
        end
        name= name or name2 or Save().gossipOption[gossipID] or ''
        self.ID:SetNumber(gossipID)
        self.Name:SetText(name)
        self.Icon:SetText(icon or '')
        self:set_color(nil, nil, nil, hex)
        self.GossipText:SetText(name2 or name)
    end


    function menu:add_gossip()
        if not self.Add:IsShown() then
            return
        end
        local num= self:get_gossipID()
        local texture = self:get_icon()
        local name= self:get_name()

        local r= self.Color.r or 1
        local g= self.Color.g or 1
        local b= self.Color.b or 1
        local hex= self.Color.hex
        if not hex and r~=1 and g~=1 and r~=1 then
            hex= WoWTools_ColorMixin:RGBtoHEX(r, g, b, 1)
        end
        if hex=='ff000000' then
            hex=nil
        end
        if num and (name or texture or hex) then
            Save().Gossip_Text_Icon_Player[num]= {
                name= name,
                icon= texture,
                hex= hex,
            }
            self.gossipID= num
            GossipButton:update_gossip_frame()
            self:set_list()
        end

        self:set_all()
        local icon
        local isAtlas, texture2= WoWTools_TextureMixin:IsAtlas(texture)
        if texture2 then
            if isAtlas then
                icon= '|A:'..texture2..':0:0|a'
            else
                icon= '|T'..texture2..':0|t'
            end
        end
        print(e.addName, addName, '|cnGREEN_FONT_COLOR:'..num..'|r', icon or '', '|c'..(hex or 'ff000000'), name)
    end

    function menu:delete_gossip(gossipID)
        if gossipID and Save().Gossip_Text_Icon_Player[gossipID] then
            local info=Save().Gossip_Text_Icon_Player[gossipID]
            Save().Gossip_Text_Icon_Player[gossipID]=nil
            print(e.addName, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r|n', gossipID, info.icon, info.hex, info.name)
            self:set_list()
            GossipButton:update_gossip_frame()
        end
        self:set_all()
    end


    menu.ID= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.ID:SetSize(234, 22)
    menu.ID:SetNumeric(true)
    menu.ID:SetPoint('TOPLEFT', menu, 'TOPRIGHT', 25, -40)
    menu.ID:SetAutoFocus(false)
    menu.ID.Instructions:SetText('gossipOptionID '..(e.onlyChinese and '数字' or 'Numeri'))
    menu.ID.searchIcon:SetAtlas('auctionhouse-icon-favorite')
    menu.ID:HookScript("OnTextChanged", function(self)
        local f= self:GetParent().menu
        f:set_all()
        f:update_list()
    end)

    menu.Name= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.Name:SetPoint('TOPLEFT', menu.ID, 'BOTTOMLEFT')
    menu.Name:SetSize(250, 22)
    menu.Name:SetAutoFocus(false)
    menu.Name:ClearFocus()
    menu.Name.Instructions:SetText(e.onlyChinese and '替换文本', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REPLACE, LOCALE_TEXT_LABEL))
    menu.Name.searchIcon:SetAtlas('NPE_ArrowRight')
    menu.Name:HookScript("OnTextChanged", function(self) self:GetParent().menu:set_all() end)

    menu.Name:SetFontObject('QuestFontLeft')
    menu.Name.r, menu.Name.g, menu.Name.b= menu.Name:GetTextColor()
    menu.Name.texture=menu.Name:CreateTexture(nil, 'BORDER')
    menu.Name.texture:SetAtlas('QuestBG-Parchment')
    menu.Name.texture:SetPoint('TOPLEFT', 8,-4)
    menu.Name.texture:SetPoint('BOTTOMRIGHT', -18, 3)
    menu.Name.texture:SetTexCoord(0.23243, 0.24698, 0.13550, 0.12206)
    --menu.Name.Middle:SetAtlas('QuestBG-Parchment')

    menu.Icon= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.Icon:SetPoint('TOPLEFT', menu.Name, 'BOTTOMLEFT')
    menu.Icon:SetSize(250, 22)
    menu.Icon:SetAutoFocus(false)
    menu.Icon:ClearFocus()
    menu.Icon.Instructions:SetText((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..' Texture or Atlas')
    menu.Icon.searchIcon:SetAtlas('NPE_ArrowRight')
    menu.Icon:HookScript("OnTextChanged", function(self)
        local frame= self:GetParent().menu
        local texture, isAtlas = frame:get_icon()
        if isAtlas and texture then
            frame.Texture:SetAtlas(texture)
        else
            frame.Texture:SetTexture(texture or 0)
        end
        frame:set_all()
    end)

    --设置，TAB键
    menu.tabGroup= CreateTabGroup(menu.ID, menu.Name, menu.Icon)
    menu.ID:SetScript('OnTabPressed', function(self) self:GetParent().menu.tabGroup:OnTabPressed() end)
    menu.Icon:SetScript('OnTabPressed', function(self) self:GetParent().menu.tabGroup:OnTabPressed() end)
    menu.Name:SetScript('OnTabPressed', function(self) self:GetParent().menu.tabGroup:OnTabPressed() end)

    --设置，Enter键
    menu.ID:SetScript('OnEnterPressed', function(self)  self:GetParent().menu:add_gossip() end)
    menu.Icon:SetScript('OnEnterPressed', function(self) self:GetParent().menu:add_gossip() end)
    menu.Name:SetScript('OnEnterPressed', function(self) self:GetParent().menu:add_gossip() end)



    --图标
    menu.Texture= Gossip_Text_Icon_Frame:CreateTexture()
    menu.Texture:SetPoint('BOTTOM', menu.ID, 'TOP' , 0, 2)
    menu:set_texture_size()

    --对话，内容
    menu.GossipText= WoWTools_LabelMixin:CreateLabel(Gossip_Text_Icon_Frame)
    menu.GossipText:SetPoint('TOP', menu.Icon, 'BOTTOM', 0,-2)


    --查找，图标，按钮
    menu.FindIcon= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='mechagon-projects'})
    menu.FindIcon:SetPoint('LEFT', menu.Icon, 'RIGHT', 2,0)
    menu.FindIcon:SetScript('OnLeave', GameTooltip_Hide)
    menu.FindIcon:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(e.onlyChinese and '选择图标' or COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS)
        if not _G['TAV_CoreFrame'] then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('|cnRED_FONT_COLOR:Texture Atlas Viewer', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        end
        e.tips:Show()
    end)
    menu.FindIcon:SetScript('OnClick', function(f)
        local frame= f.frame
        if frame then
            frame:SetShown(not frame:IsShown())
            return
        end
        frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame_IconSelectorPopupFrame', Gossip_Text_Icon_Frame, 'IconSelectorPopupFrameTemplate')
        frame.IconSelector:SetPoint('BOTTOMRIGHT', -10, 36)
        e.Set_Move_Frame(frame, {notMove=true, setSize=true, minW=524, minH=276, maxW=524, sizeRestFunc=function(btn)
            btn.target:SetSize(524, 495)
        end})

        frame:Hide()
        frame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(e.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)
        frame.BorderBox.IconSelectorEditBox:SetAutoFocus(false)
        frame:SetScript('OnShow', function(self)
            IconSelectorPopupFrameTemplateMixin.OnShow(self);
            if self.iconDataProvider==nil then
                self.iconDataProvider= CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
            end
            self:SetIconFilter(self:GetIconFilter() or IconSelectorPopupFrameIconFilterTypes.All);
            --self.BorderBox.IconTypeDropDown:SetSelectedValue(self.BorderBox.IconTypeDropDown:GetSelectedValue() or IconSelectorPopupFrameIconFilterTypes.All);
            self:Update()
            self.BorderBox.IconSelectorEditBox:OnTextChanged()
            local function OnIconSelected(_, icon)
                self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);
                self.BorderBox.IconSelectorEditBox:SetText(icon)
            end
            self.IconSelector:SetSelectedCallback(OnIconSelected);
        end)

        frame:SetScript('OnHide', function(self)
            IconSelectorPopupFrameTemplateMixin.OnHide(self);
            self.iconDataProvider:Release();
            self.iconDataProvider = nil;
        end)
        function frame:Update()
            local texture
            texture= Gossip_Text_Icon_Frame.menu:get_icon()
            if texture then
                texture=tonumber(texture)
            end
            if not texture then
                self.origName = "";
                self.BorderBox.IconSelectorEditBox:SetText("");
                local initialIndex = 1;
                self.IconSelector:SetSelectedIndex(initialIndex);
                self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
            else
                self.BorderBox.IconSelectorEditBox:SetText(texture);
                self.BorderBox.IconSelectorEditBox:HighlightText();
                self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
                self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture);
            end
            local getSelection = GenerateClosure(self.GetIconByIndex, self);
            local getNumSelections = GenerateClosure(self.GetNumIcons, self);
            self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
            self.IconSelector:ScrollToSelectedIndex();
            self:SetSelectedIconText();
        end
        function frame:OkayButton_OnClick()
            IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
            local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
            local m= Gossip_Text_Icon_Frame.menu
            m.Icon:SetText(iconTexture or '')
            local gossip= m:get_gossipID()
            if gossip==0 then
                m.ID:SetFocus()
            else
                m.Name:SetFocus()
                Gossip_Text_Icon_Frame.menu:add_gossip()
            end
        end
        f.frame= frame
        frame:Show()
    end)
    if _G['TAV_CoreFrame'] then--查找，图标，按钮， Texture Atlas Viewer， 插件
        menu.tav= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='communities-icon-searchmagnifyingglass'})
        menu.tav:SetPoint('TOP', menu.FindIcon, 'BOTTOM', 0, -2)
        menu.tav:SetScript('OnClick', function() _G['TAV_CoreFrame']:SetShown(not _G['TAV_CoreFrame']:IsShown()) end)
        menu.tav:SetScript('OnLeave', GameTooltip_Hide)
        menu.tav:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:AddLine(' ')
            e.tips:AddLine('Texture Atlas Viewer')
            e.tips:Show()
        end)
    end

    --颜色
    menu.Color= CreateFrame('Button', nil, Gossip_Text_Icon_Frame, 'ColorSwatchTemplate')--ColorSwatchMixin
    menu.Color:SetPoint('LEFT', menu.ID, 'RIGHT', 2,0)
    menu.Color:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    menu.Color:SetScript('OnLeave', GameTooltip_Hide)
    function menu.Color:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((self.hex and format('|c%s|r', self.hex) or '')..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), e.Icon.left)
        local col= (not self.hex or self.hex=='ff000000') and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(format('%s%s', col, e.onlyChinese and '默认' or DEFAULT), e.Icon.right)
        e.tips:Show()
    end
    menu.Color:SetScript('OnEnter', menu.Color.set_tooltips)
    menu.Color:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            local R=self.r or 1
            local G=self.g or 1
            local B=self.b or 1
            WoWTools_ColorMixin:ShowColorFrame(R, G, B, nil, function()--swatchFunc
                local r,g,b = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                Gossip_Text_Icon_Frame.menu:set_color(r,g,b)
                Gossip_Text_Icon_Frame.menu:add_gossip()
            end, function()--cancelFunc
                Gossip_Text_Icon_Frame.menu:set_color(R,G,B)
                Gossip_Text_Icon_Frame.menu:add_gossip()
            end)
        else
            Gossip_Text_Icon_Frame.menu:set_color(0,0,0)
            Gossip_Text_Icon_Frame.menu:add_gossip()
        end
        self:set_tooltips()
    end)

    --添加
    menu.Add= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, icon='hide'})
    menu.Add:SetPoint('LEFT', menu.Color, 'RIGHT', 2, 0)
    menu.Add:SetScript('OnLeave', GameTooltip_Hide)
    menu.Add:SetScript('OnEnter', function(self)
        local frame=Gossip_Text_Icon_Frame.menu
        local num= frame:get_gossipID()
        local texture = frame:get_icon()
        local name= frame:get_name()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(self.tooltip)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('gossipOptionID', num)
        e.tips:AddDoubleLine('name', name)
        e.tips:AddDoubleLine('icon', texture)
        e.tips:AddDoubleLine('hex', frame.Color.hex)
        e.tips:Show()
    end)
    menu.Add:SetScript('OnClick', function(self)
        self:GetParent().menu:add_gossip()
    end)

    --删除，内容
    menu.Delete= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='common-icon-redx'})
    menu.Delete:SetPoint('BOTTOM', menu.Add, 'TOP', 0,2)
    menu.Delete:Hide()
    menu.Delete:SetScript('OnLeave', GameTooltip_Hide)
    menu.Delete:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '删除' or DELETE, Gossip_Text_Icon_Frame.menu.gossipID)
        e.tips:Show()
    end)
    menu.Delete:SetScript('OnClick', function()
        Gossip_Text_Icon_Frame.menu:delete_gossip(Gossip_Text_Icon_Frame.menu.gossipID)
    end)

    --删除，玩家数据
    menu.DeleteAllPlayerData=WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='bags-button-autosort-up'})
    menu.DeleteAllPlayerData:SetPoint('BOTTOMLEFT', menu, 'TOPLEFT', -3, 2)
    menu.DeleteAllPlayerData:SetScript('OnLeave', GameTooltip_Hide)
    menu.DeleteAllPlayerData:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '全部清除' or CLEAR_ALL)
        e.tips:Show()
    end)
    menu.DeleteAllPlayerData:SetScript('OnClick', function()
        if not StaticPopupDialogs['WoWTools_Gossip_Delete_All_Player_Data'] then
            StaticPopupDialogs['WoWTools_Gossip_Delete_All_Player_Data']={
                text=e.addName' '..addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
                whileDead=true, hideOnEscape=true, exclusive=true,
                button1= e.onlyChinese and '全部清除' or CLEAR_ALL,
                button2= e.onlyChinese and '取消' or CANCEL,
                OnAccept = function()
                    Save().Gossip_Text_Icon_Player={}
                    print(e.addName, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '完成' or DONE))
                    Gossip_Text_Icon_Frame.menu:set_list()
                end,
            }
        end
        StaticPopup_Show('WoWTools_Gossip_Delete_All_Player_Data')
    end)

    --自定义，对话，文本，数量
    menu.NumLabel= WoWTools_LabelMixin:CreateLabel(Gossip_Text_Icon_Frame)
    menu.NumLabel:SetPoint('LEFT', menu.DeleteAllPlayerData, 'RIGHT')




    --图标大小, 设置
    menu.Size= e.CSlider(Gossip_Text_Icon_Frame, {min=8, max=72, value=Save().Gossip_Text_Icon_Size, setp=1, color=false, w=255,
        text= e.onlyChinese and '图标大小' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        func=function(frame, value)
            value= math.modf(value)
            value= value==0 and 0 or value
            frame:SetValue(value)
            frame.Text:SetText(value)
            Save().Gossip_Text_Icon_Size= value
            local f= frame:GetParent().menu
            f:set_texture_size()
            local icon= f.Texture:GetTexture()--设置，图片，如果没有
            if not icon or icon==0 then
                f.Texture:SetTexture(3847780)
            end
            GossipButton:update_gossip_frame()
    end})
    menu.Size:SetPoint('TOP', menu.Icon, 'BOTTOM', 0, -36)



    --修改，为中文，字体
    if LOCALE_zhCN or LOCALE_zhTW then
        Save().Gossip_Text_Icon_cnFont=nil
    elseif e.onlyChinese then
        menu.font= CreateFrame("CheckButton", nil, Gossip_Text_Icon_Frame, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
        menu.font:SetPoint('TOPLEFT', menu.Size, 'BOTTOMLEFT', 0, -12)
        menu.font:SetChecked(Save().Gossip_Text_Icon_cnFont)
        menu.font.Text:SetText('修改字体')
        menu.font.Text:SetFont('Fonts\\ARHei.ttf', 12)
        menu.font:SetScript('OnLeave', GameTooltip_Hide)
        menu.font:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName , addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('ARHei.ttf', '黑体字')
            e.tips:Show()
        end)
        menu.font:SetScript('OnMouseDown', function()
            Save().Gossip_Text_Icon_cnFont= not Save().Gossip_Text_Icon_cnFont and true or nil
            GossipButton:update_gossip_frame()
            Gossip_Text_Icon_Frame.menu:set_list()
            if not Save().Gossip_Text_Icon_cnFont then
                print(e.addName, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '需要重新加载UI' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, RELOADUI))
            end
        end)
    end

    --已打开，对话，列表
    menu.chat= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22, 22}, atlas='transmog-icon-chat'})
    menu.chat:SetPoint('LEFT', menu.Name, 'RIGHT', 2, 0)
    menu.chat:SetScript('OnLeave', GameTooltip_Hide)
    menu.chat:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '当前对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, ENABLE_DIALOG), e.onlyChinese and '添加' or ADD)
        e.tips:Show()
    end)
    menu.chat:SetScript('OnClick', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, Gossip_Text_Icon_Frame.menu, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                local tab= C_GossipInfo.GetOptions() or {}
                table.sort(tab, function(a, b) return a.orderIndex< b.orderIndex end)
                local f= Gossip_Text_Icon_Frame.menu
                local find={}
                for _, info in pairs(tab) do
                    if info.gossipOptionID then
                        local set= Gossip_Text_Icon_Frame.menu:get_saved_all_date(info.gossipOptionID) or {}
                        local name= set.name or info.name or ''
                        local icon= set.icon or info.icon
                        local hex= set.hex
                        e.LibDD:UIDropDownMenu_AddButton({
                            text= name..info.gossipOptionID,
                            checked= info.gossipOptionID== Gossip_Text_Icon_Frame.menu:get_gossipID(),
                            colorCode= hex and '|c'..hex or (WoWTools_GossipMixin:Get_GossipData()[info.gossipOptionID] and '|cnGREEN_FONT_COLOR:') or (Save().Gossip_Text_Icon_Player[info.gossipOptionID] and '|cffff00ff') or nil,
                            icon= icon,

                            tooltipOnButton=true,
                            tooltipTitle=info.gossipOptionID,
                            tooltipText= e.onlyChinese and '选择' or LFG_LIST_SELECT,
                            arg1=info.gossipOptionID,
                            func= function(_, arg1)
                                f:set_date(arg1)
                            end
                        }, level)
                        if not Save().Gossip_Text_Icon_Player[info.gossipOptionID] then
                            table.insert(find, {gossipID=info.gossipOptionID, name=info.name})
                        end
                    end
                end
                local num=#find
                if num>0 then
                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=format('%s |cnGREEN_FONT_COLOR:#%d', e.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD), num),
                        notCheckable=true,
                        arg1=find,
                        func= function(_, arg1)
                            for _, info in pairs(arg1) do
                                if not Save().Gossip_Text_Icon_Player[info.gossipID] then
                                    Save().Gossip_Text_Icon_Player[info.gossipID]= {name=info.name}
                                end
                            end
                            Gossip_Text_Icon_Frame.menu:set_list()
                        end
                    }, level)
                elseif #tab==0 then
                    e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, isTitle=true, notCheckable=true}, level)
                end
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
    end)
    --GossipFrame 有多少对话
    menu.chat.Text= WoWTools_LabelMixin:CreateLabel(menu.chat, {justifyH='CENTER'})
    menu.chat.Text:SetPoint('CENTER', 1, 4.2)

    --默认，自定义，列表
    menu.System= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22, 22}, icon='hide'})
    menu.System:SetPoint('BOTTOMRIGHT', menu.ID, 'TOPRIGHT', 0, 2)
    menu.System.Text= WoWTools_LabelMixin:CreateLabel(menu.System)
    menu.System.Text:SetPoint('CENTER')
    function menu.System:set_num()--默认，自定义，列表        
        local n=0
        for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
            n= n+1
        end
        self:SetNormalTexture(0)
        self.Text:SetText(n)
        self.num=n
    end
    menu.System:set_num()
    menu.System:SetScript('OnShow', menu.System.set_num)
    menu.System:SetScript('OnLeave', GameTooltip_Hide)
    menu.System:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine( e.onlyChinese and '对话' or ENABLE_DIALOG, e.GetEnabeleDisable(Save().gossip))
        e.tips:AddDoubleLine(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), e.GetEnabeleDisable(not Save().not_Gossip_Text_Icon))
        e.tips:AddLine(' ')
        e.tips:AddLine(format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '默认' or DEFAULT, self.num or 0))
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
        self:set_num()
    end)
    menu.System:SetScript('OnClick', function(self)
        if not self.Menu then
            self.Menu = CreateFrame("FRAME", nil, self, "UIDropDownMenuTemplate")--下拉，菜单
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                local find, info
                local f= Gossip_Text_Icon_Frame.menu
                local num= f:get_gossipID()
                for gossipID, tab in pairs(WoWTools_GossipMixin:Get_GossipData()) do
                    info={
                        text=(Save().Gossip_Text_Icon_Player[gossipID] and '|cnGREEN_FONT_COLOR:' or '|cffffffff')..gossipID..'|r |c'..(tab.hex or 'ffffffff')..(tab.name or '')..'|r',
                        icon= tab.icon,
                        checked=num==gossipID,
                        arg1= gossipID,
                        func= function(_, arg1)
                            f:set_date(arg1)--读取，已保存数据
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
                if not find then
                    e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
                end
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)



    --导入数据
    menu.DataFrame=WoWTools_EditBoxMixn:CreateMultiLineFrame(Gossip_Text_Icon_Frame,{
        instructions= 'text'
    })
    menu.DataFrame:Hide()
    menu.DataFrame:SetPoint('TOPLEFT', Gossip_Text_Icon_Frame, 'TOPRIGHT', 0, -10)
    menu.DataFrame:SetPoint('BOTTOMRIGHT', 310, 8)

    menu.DataFrame.CloseButton=CreateFrame('Button', nil, menu.DataFrame, 'UIPanelCloseButton')
    menu.DataFrame.CloseButton:SetPoint('TOPRIGHT',0, 13)
    menu.DataFrame.CloseButton:SetScript('OnClick', function(self)
        local frame=self:GetParent()
        frame:Hide()
        frame:SetText("")
    end)

    menu.DataFrame.enter= WoWTools_ButtonMixin:Cbtn(menu.DataFrame, {size={100, 23}, type=false})
    menu.DataFrame.enter:SetPoint('BOTTOM', menu.DataFrame, 'TOP', 0, 5)
    menu.DataFrame.enter:SetFormattedText('|A:Professions_Specialization_arrowhead:0:0|a%s', e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
    menu.DataFrame.enter:Hide()
    function menu.DataFrame.enter:set_date(tooltips)--导入数据，和提示
        local frame= self:GetParent()
        if not frame then
            return
        end
        
        local add, del, exist= {}, 0, 0
        local text= string.gsub(frame:GetText() or '', '(%[%d+]={.-})', function(t)
            local num, icon, name, hex= t:match('(%d+).-icon=(.-), name=(.-), hex=(.-)}')
            local gossipID= num and tonumber(num)
            if gossipID then
                icon= icon and icon:gsub(' ', '') or nil
                if icon=='' then icon=nil end
                if name=='' then name=nil end
                hex= hex and hex:gsub(' ', '') or nil
                if hex=='' then hex=nil end
                if not Save().Gossip_Text_Icon_Player[gossipID] then
                    if icon or name or hex then
                        table.insert(add, {gossipID=gossipID, tab={icon=icon, name=name, hex=hex}})
                        return ''
                    else
                        del= del+1
                    end
                else
                    exist= exist+1
                end
            end
        end)

        local addText= format('|cnGREEN_FONT_COLOR:%s %d|r', e.onlyChinese and '添加' or ADD, #add)
        local delText= format('|cffffffff%s %d|r', e.onlyChinese and '无效的组合' or SPELL_FAILED_CUSTOM_ERROR_455, del)
        local existText= format('|cnRED_FONT_COLOR:%s %d|r', e.onlyChinese and '已存在' or format(ERR_ZONE_EXPLORED, PROFESSIONS_CURRENT_LISTINGS), exist)
        if not tooltips then
            for _, info in pairs(add) do
                Save().Gossip_Text_Icon_Player[info.gossipID]= info.tab
                local texture, icon= select(2, WoWTools_TextureMixin:IsAtlas(info.tab.icon))
                print(format('|cnGREEN_FONT_COLOR:%s|r|n', e.onlyChinese and '添加', ADD),
                    info.gossipID, texture and format('%s%s', icon, texture) or '',
                    info.tab.name,
                    info.tab.hex and format('|c%s%s', info.tab.hex, info.tab.hex) or '')
            end
            Gossip_Text_Icon_Frame.menu:set_list()
            print(e.addName, addName, '|n', format('%s|n%s|n%s', addText, delText, existText))
            frame:SetText(text)
            self:GetParent():SetInstructions(e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        else
            e.tips:AddLine(addText)
            e.tips:AddLine(delText)
            e.tips:AddLine(existText)
        end
    end
    menu.DataFrame.enter:SetScript('OnLeave', GameTooltip_Hide)
    menu.DataFrame.enter:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddDoubleLine(e.onlyChinese and '格式' or FORMATTING, '|cffff00ff[gossipOptionID]={icon=, name=, hex=}')
        e.tips:AddLine(' ')
        self:set_date(true)
        e.tips:Show()
    end)
    menu.DataFrame.enter:SetScript('OnClick', function(self)--导入
       self:set_date()

    end)

    menu.DataUscita= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22, 22}, atlas='bags-greenarrow'})
    menu.DataUscita:SetPoint('LEFT', menu.DeleteAllPlayerData, 'RIGHT', 22, 0)
    menu.DataUscita:SetScript('OnLeave', GameTooltip_Hide)
    menu.DataUscita:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
        e.tips:Show()
    end)
    menu.DataUscita:SetScript('OnClick', function(self)
        local frame= self:GetParent().menu.DataFrame
        frame:SetShown(true)
        frame.enter:SetShown(false)
        local text=''
        local tabs= {}
        local old= Save().Gossip_Text_Icon_Player
        for gossipID, info in pairs(old) do
            info.gossipID= gossipID
            table.insert(tabs, info)
        end
        table.sort(tabs, function(a, b) return a.gossipID<b.gossipID end)
        for _, info in pairs(tabs) do
            text=text..format('[%d]={icon=%s, name=%s, hex=%s}|n',
                            info.gossipID,
                            info.icon or '',
                            info.name or '',
                            info.hex or ''
                        )
        end
        frame:SetText(text)
        frame:SetInstructions(e.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
    end)

    menu.DataEnter= WoWTools_ButtonMixin:Cbtn(Gossip_Text_Icon_Frame, {size={22, 22}, atlas='Professions_Specialization_arrowhead'})
    menu.DataEnter:SetPoint('LEFT', menu.DataUscita, 'RIGHT')
    menu.DataEnter:SetScript('OnLeave', GameTooltip_Hide)
    menu.DataEnter:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        e.tips:Show()
    end)
    menu.DataEnter:SetScript('OnClick', function(self)
        local frame= self:GetParent().menu.DataFrame
        frame:SetShown(true)
        frame.enter:SetShown(true)
        frame:SetText('')
    end)




    menu.chat:SetShown(GossipFrame:IsShown())
    menu:set_list()
    menu:set_color()




    GossipFrame:HookScript('OnShow', function()--已打开，对话，列表
        local frame= Gossip_Text_Icon_Frame.menu
        frame.chat:SetShown(true)
        frame:set_list()
    end)
    GossipFrame:HookScript('OnHide', function()
        local frame= Gossip_Text_Icon_Frame.menu
        frame.chat:SetShown(false)
        frame:set_list()
    end)

    Gossip_Text_Icon_Frame:SetScript('OnHide', function(self)
        GossipButton:update_gossip_frame()
        self.menu:set_list()
        if not GossipFrame.GreetingPanel.ScrollBox:GetView() then
            return
        end
        for _, b in pairs(GossipFrame.GreetingPanel.ScrollBox:GetFrames() or {}) do
            b:UnlockHighlight()
        end
    end)
    Gossip_Text_Icon_Frame:SetScript('OnShow', function(self)
        GossipButton:update_gossip_frame()
        self.menu:set_list()
    end)
    GossipButton:update_gossip_frame()
end




function WoWTools_GossipMixin:Init_Options_Frame()
    if not self.GossipButton then
        return
    end

    if Gossip_Text_Icon_Frame then
        Gossip_Text_Icon_Frame:SetShown(not Gossip_Text_Icon_Frame:IsShown())
    else
        addName= self.addName
        GossipButton= self.GossipButton
        Init()
    end
end