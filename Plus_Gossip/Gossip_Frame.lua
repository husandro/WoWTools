local e= select(2, ...)
local addName
local GossipButton, Frame, Menu


local function Save()
    return WoWTools_GossipMixin.Save
end








local function Chat_Menu(_, root)
    local tab= C_GossipInfo.GetOptions() or {}
    table.sort(tab, function(a, b) return a.orderIndex< b.orderIndex end)

    local find={}
    for _, info in pairs(tab) do
        if info.gossipOptionID then
            local set= Menu:get_saved_all_date(info.gossipOptionID) or {}
            local name= set.name or info.name or ''
            local icon= select(3, WoWTools_TextureMixin:IsAtlas(set.icon or info.icon)) or '     '
            local col= (set.hex and set.hex~='') and '|c'..set.hex
                or (WoWTools_GossipMixin:Get_GossipData()[info.gossipOptionID] and '|cnGREEN_FONT_COLOR:')
                or (Save().Gossip_Text_Icon_Player[info.gossipOptionID] and '|cffff00ff')
                or ''

            root:CreateCheckbox(
                icon..col..name..info.gossipOptionID,
            function(data)
                return data.gossipOptionID== Menu:get_gossipID()
            end, function(data)
                Menu:set_date(data.gossipOptionID)
            end, {gossipOptionID=info.gossipOptionID})

            if not Save().Gossip_Text_Icon_Player[info.gossipOptionID] then
                table.insert(find, {gossipID=info.gossipOptionID, name=info.name})
            end
        end
    end

    local num=#find
    if num>1 then
        WoWTools_MenuMixin:SetScrollMode(root)
        root:CreateDivider()
        root:CreateButton(
            (e.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD))..' '..num,
        function(data)
            for _, info in pairs(data.find) do
                if not Save().Gossip_Text_Icon_Player[info.gossipID] then
                    Save().Gossip_Text_Icon_Player[info.gossipID]= {name=info.name}
                end
            end
            Menu:set_list()
        end, {find=find})

    elseif #tab==0 then
        root:CreateTitle(e.onlyChinese and '无' or NONE)
    end
end














--自定义，对话，文本，放在主菜单，前


local function Init()
    Frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame', UIParent)--, 'DialogBorderTemplate')--'ButtonFrameTemplate')
    WoWTools_GossipMixin.Frame= Frame

    Menu = CreateFrame("Frame", nil, Frame, "WowScrollBoxList")
    Frame.Menu= Menu




    Frame:SetSize(580, 370)
    Frame:SetFrameStrata('HIGH')
    Frame:SetPoint('CENTER')

    local border= CreateFrame('Frame', nil, Frame,'DialogBorderTemplate')
    local Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Header:Setup('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE)))
    local CloseButton=CreateFrame('Button', nil, Frame, 'UIPanelCloseButton')
    CloseButton:SetPoint('TOPRIGHT')

    e.Set_Alpha_Frame_Texture(border, {alpha=0.5})
    e.Set_Alpha_Frame_Texture(Header, {alpha=0.7})
    e.Set_Move_Frame(Frame, {needMove=true, minW=370, minH=240, notFuori=true, setSize=true, sizeRestFunc=function(btn)
        btn.target:SetSize(580, 370)
    end})







    Menu:SetPoint("TOPLEFT", 12, -30)
    Menu:SetPoint("BOTTOMRIGHT", -310, 6)

    Menu.bg= Menu:CreateTexture(nil, 'BACKGROUND')
    Menu.bg:SetPoint('TOPLEFT', -35, 80)
    Menu.bg:SetPoint('BOTTOMRIGHT',35, -72)
    Menu.bg:SetAtlas('QuestBG-Trading-Post')

    Menu.ScrollBar  = CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Menu.ScrollBar:SetPoint("TOPLEFT", Menu, "TOPRIGHT", 8,0)
    Menu.ScrollBar:SetPoint("BOTTOMLEFT", Menu, "BOTTOMRIGHT",8,0)

    Menu.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Menu, Menu.ScrollBar, Menu.view)

    Menu.view:SetElementInitializer("GossipTitleButtonTemplate", function(btn, info)-- UIPanelButtonTemplate GossipTitleButtonTemplate
        btn.gossipID= info.gossipID
        btn.spellID= info.spellID
        if not btn.delete then
            btn:SetScript("OnClick", function(self)
                Frame.Menu:set_date(self.gossipID)
            end)
            btn:SetScript('OnLeave', function(self) self.delete:SetAlpha(0) end)
            btn:SetScript('OnEnter', function(self) self.delete:SetAlpha(1) end)

            btn.delete= WoWTools_ButtonMixin:Cbtn(btn, {size={18,18}, atlas='common-icon-redx'})
            btn.delete:SetPoint('RIGHT')
            btn.delete:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
            btn.delete:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
            btn.delete:SetScript('OnClick', function(self)
                Frame.Menu:delete_gossip(self:GetParent().gossipID)
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

    function Menu:SortOrder(leftInfo, rightInfo)
        if GossipFrame:IsShown() then
            return leftInfo.orderIndex < rightInfo.orderIndex;
        else
            return leftInfo.gossipID < rightInfo.gossipID;
        end
    end

    function Menu:set_list()
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


    function Menu:update_list()
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


    function Menu:get_gossipID()--取得gossipID
        return self.ID:GetNumber() or 0
    end
    function Menu:get_name()--取得，名称
        local name= self.Name:GetText()
        if name=='' then
            return
        else
            return name
        end
    end
    function Menu:get_icon()--设置，图片
        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(self.Icon:GetText())
        return texture, isAtlas
    end
    function Menu:set_texture_size()--图片，大小
        self.Texture:SetSize(Save().Gossip_Text_Icon_Size, Save().Gossip_Text_Icon_Size)
    end

    function Menu:set_all()
        local num= self:get_gossipID()
        local name= self:get_name()
        local icon= self:get_icon()
        local info= Save().Gossip_Text_Icon_Player[num]
        if info then
            self.gossipID=num
        else
            self.gossipID=nil
        end

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

    function Menu:set_color(r, g, b, hex)--设置，颜色，颜色按钮，
        if hex and hex~='' then
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

    function Menu:get_saved_all_date(gossipID)
        return Save().Gossip_Text_Icon_Player[gossipID] or WoWTools_GossipMixin:Get_GossipData()[gossipID]
    end
    function Menu:set_date(gossipID)--读取，已保存数据
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


    function Menu:add_gossip()
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
        --[[local icon
        local isAtlas, texture2= WoWTools_TextureMixin:IsAtlas(texture)
        if texture2 then
            if isAtlas then
                icon= '|A:'..texture2..':0:0|a'
            else
                icon= '|T'..texture2..':0|t'
            end
        end
        print(e.addName, addName, '|cnGREEN_FONT_COLOR:'..num..'|r', icon or '', '|c'..(hex or 'ff000000'), name)]]
    end

    function Menu:delete_gossip(gossipID)
        if gossipID and Save().Gossip_Text_Icon_Player[gossipID] then
            local info=Save().Gossip_Text_Icon_Player[gossipID]
            Save().Gossip_Text_Icon_Player[gossipID]=nil
            print(e.addName, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r|n', gossipID, info.icon, info.hex, info.name)
            self:set_list()
            GossipButton:update_gossip_frame()
        end
        self:set_all()
    end


    Menu.ID= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    Menu.ID:SetSize(234, 22)
    Menu.ID:SetNumeric(true)
    Menu.ID:SetPoint('TOPLEFT', Menu, 'TOPRIGHT', 25, -40)
    Menu.ID:SetAutoFocus(false)
    Menu.ID.Instructions:SetText('gossipOptionID '..(e.onlyChinese and '数字' or 'Numeri'))
    Menu.ID.searchIcon:SetAtlas('auctionhouse-icon-favorite')
    Menu.ID:HookScript("OnTextChanged", function(self)
        local f= self:GetParent().Menu
        f:set_all()
        f:update_list()
    end)

    Menu.Name= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    Menu.Name:SetPoint('TOPLEFT', Menu.ID, 'BOTTOMLEFT')
    Menu.Name:SetSize(250, 22)
    Menu.Name:SetAutoFocus(false)
    Menu.Name:ClearFocus()
    Menu.Name.Instructions:SetText(e.onlyChinese and '替换文本', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REPLACE, LOCALE_TEXT_LABEL))
    Menu.Name.searchIcon:SetAtlas('NPE_ArrowRight')
    Menu.Name:HookScript("OnTextChanged", function(self) self:GetParent().Menu:set_all() end)

    Menu.Name:SetFontObject('QuestFontLeft')
    Menu.Name.r, Menu.Name.g, Menu.Name.b= Menu.Name:GetTextColor()
    Menu.Name.texture=Menu.Name:CreateTexture(nil, 'BORDER')
    Menu.Name.texture:SetAtlas('QuestBG-Parchment')
    Menu.Name.texture:SetPoint('TOPLEFT', 8,-4)
    Menu.Name.texture:SetPoint('BOTTOMRIGHT', -18, 3)
    Menu.Name.texture:SetTexCoord(0.23243, 0.24698, 0.13550, 0.12206)
    --Menu.Name.Middle:SetAtlas('QuestBG-Parchment')

    Menu.Icon= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    Menu.Icon:SetPoint('TOPLEFT', Menu.Name, 'BOTTOMLEFT')
    Menu.Icon:SetSize(250, 22)
    Menu.Icon:SetAutoFocus(false)
    Menu.Icon:ClearFocus()
    Menu.Icon.Instructions:SetText((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..' Texture or Atlas')
    Menu.Icon.searchIcon:SetAtlas('NPE_ArrowRight')
    Menu.Icon:HookScript("OnTextChanged", function(self)
        local frame= self:GetParent().Menu
        local texture, isAtlas = frame:get_icon()
        if isAtlas and texture then
            frame.Texture:SetAtlas(texture)
        else
            frame.Texture:SetTexture(texture or 0)
        end
        frame:set_all()
    end)

    --设置，TAB键
    Menu.tabGroup= CreateTabGroup(Menu.ID, Menu.Name, Menu.Icon)
    Menu.ID:SetScript('OnTabPressed', function(self) self:GetParent().Menu.tabGroup:OnTabPressed() end)
    Menu.Icon:SetScript('OnTabPressed', function(self) self:GetParent().Menu.tabGroup:OnTabPressed() end)
    Menu.Name:SetScript('OnTabPressed', function(self) self:GetParent().Menu.tabGroup:OnTabPressed() end)

    --设置，Enter键
    Menu.ID:SetScript('OnEnterPressed', function(self)  self:GetParent().Menu:add_gossip() end)
    Menu.Icon:SetScript('OnEnterPressed', function(self) self:GetParent().Menu:add_gossip() end)
    Menu.Name:SetScript('OnEnterPressed', function(self) self:GetParent().Menu:add_gossip() end)



    --图标
    Menu.Texture= Frame:CreateTexture()
    Menu.Texture:SetPoint('BOTTOM', Menu.ID, 'TOP' , 0, 2)
    Menu:set_texture_size()

    --对话，内容
    Menu.GossipText= WoWTools_LabelMixin:CreateLabel(Frame)
    Menu.GossipText:SetPoint('TOP', Menu.Icon, 'BOTTOM', 0,-2)


    --查找，图标，按钮
    Menu.FindIcon= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, atlas='mechagon-projects'})
    Menu.FindIcon:SetPoint('LEFT', Menu.Icon, 'RIGHT', 2,0)
    Menu.FindIcon:SetScript('OnLeave', GameTooltip_Hide)
    Menu.FindIcon:SetScript('OnEnter', function(self)
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
    Menu.FindIcon:SetScript('OnClick', function(f)
        local frame= f.frame
        if frame then
            frame:SetShown(not frame:IsShown())
            return
        end
        frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame_IconSelectorPopupFrame', Frame, 'IconSelectorPopupFrameTemplate')
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
            texture= Frame.Menu:get_icon()
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
            local m= Frame.Menu
            m.Icon:SetText(iconTexture or '')
            local gossip= m:get_gossipID()
            if gossip==0 then
                m.ID:SetFocus()
            else
                m.Name:SetFocus()
                Frame.Menu:add_gossip()
            end
        end
        f.frame= frame
        frame:Show()
    end)
    if _G['TAV_CoreFrame'] then--查找，图标，按钮， Texture Atlas Viewer， 插件
        Menu.tav= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, atlas='communities-icon-searchmagnifyingglass'})
        Menu.tav:SetPoint('TOP', Menu.FindIcon, 'BOTTOM', 0, -2)
        Menu.tav:SetScript('OnClick', function() _G['TAV_CoreFrame']:SetShown(not _G['TAV_CoreFrame']:IsShown()) end)
        Menu.tav:SetScript('OnLeave', GameTooltip_Hide)
        Menu.tav:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:AddLine(' ')
            e.tips:AddLine('Texture Atlas Viewer')
            e.tips:Show()
        end)
    end

    --颜色
    Menu.Color= CreateFrame('Button', nil, Frame, 'ColorSwatchTemplate')--ColorSwatchMixin
    Menu.Color:SetPoint('LEFT', Menu.ID, 'RIGHT', 2,0)
    Menu.Color:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    Menu.Color:SetScript('OnLeave', GameTooltip_Hide)
    function Menu.Color:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((self.hex and format('|c%s|r', self.hex) or '')..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), e.Icon.left)
        local col= (not self.hex or self.hex=='ff000000') and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(format('%s%s', col, e.onlyChinese and '默认' or DEFAULT), e.Icon.right)
        e.tips:Show()
    end
    Menu.Color:SetScript('OnEnter', Menu.Color.set_tooltips)
    Menu.Color:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            local R=self.r or 1
            local G=self.g or 1
            local B=self.b or 1
            WoWTools_ColorMixin:ShowColorFrame(R, G, B, nil, function()--swatchFunc
                local r,g,b = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                Frame.Menu:set_color(r,g,b)
                Frame.Menu:add_gossip()
            end, function()--cancelFunc
                Frame.Menu:set_color(R,G,B)
                Frame.Menu:add_gossip()
            end)
        else
            Frame.Menu:set_color(0,0,0)
            Frame.Menu:add_gossip()
        end
        self:set_tooltips()
    end)

    --添加
    Menu.Add= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, icon='hide'})
    Menu.Add:SetPoint('LEFT', Menu.Color, 'RIGHT', 2, 0)
    Menu.Add:SetScript('OnLeave', GameTooltip_Hide)
    Menu.Add:SetScript('OnEnter', function(self)
        local frame=Frame.Menu
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
    Menu.Add:SetScript('OnClick', function(self)
        self:GetParent().Menu:add_gossip()
    end)

    --删除，内容
    Menu.Delete= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, atlas='common-icon-redx'})
    Menu.Delete:SetPoint('BOTTOM', Menu.Add, 'TOP', 0,2)
    Menu.Delete:Hide()
    Menu.Delete:SetScript('OnLeave', GameTooltip_Hide)
    Menu.Delete:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '删除' or DELETE, Frame.Menu.gossipID)
        e.tips:Show()
    end)
    Menu.Delete:SetScript('OnClick', function()
        Frame.Menu:delete_gossip(Frame.Menu.gossipID)
    end)

    --删除，玩家数据
    Menu.DeleteAllPlayerData=WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, atlas='bags-button-autosort-up'})
    Menu.DeleteAllPlayerData:SetPoint('BOTTOMLEFT', Menu, 'TOPLEFT', -3, 2)
    Menu.DeleteAllPlayerData:SetScript('OnLeave', GameTooltip_Hide)
    Menu.DeleteAllPlayerData:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '全部清除' or CLEAR_ALL)
        e.tips:Show()
    end)
    Menu.DeleteAllPlayerData:SetScript('OnClick', function()
        if not StaticPopupDialogs['WoWTools_Gossip_Delete_All_Player_Data'] then
            StaticPopupDialogs['WoWTools_Gossip_Delete_All_Player_Data']={
                text=e.addName..' '..addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
                whileDead=true, hideOnEscape=true, exclusive=true,
                button1= e.onlyChinese and '全部清除' or CLEAR_ALL,
                button2= e.onlyChinese and '取消' or CANCEL,
                OnAccept = function()
                    Save().Gossip_Text_Icon_Player={}
                    print(e.addName, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '完成' or DONE))
                    Frame.Menu:set_list()
                end,
            }
        end
        StaticPopup_Show('WoWTools_Gossip_Delete_All_Player_Data')
    end)

    --自定义，对话，文本，数量
    Menu.NumLabel= WoWTools_LabelMixin:CreateLabel(Frame)
    Menu.NumLabel:SetPoint('LEFT', Menu.DeleteAllPlayerData, 'RIGHT')




    --图标大小, 设置
    Menu.Size= e.CSlider(Frame, {min=8, max=72, value=Save().Gossip_Text_Icon_Size, setp=1, color=false, w=255,
        text= e.onlyChinese and '图标大小' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        func=function(frame, value)
            value= math.modf(value)
            value= value==0 and 0 or value
            frame:SetValue(value)
            frame.Text:SetText(value)
            Save().Gossip_Text_Icon_Size= value
            local f= frame:GetParent().Menu
            f:set_texture_size()
            local icon= f.Texture:GetTexture()--设置，图片，如果没有
            if not icon or icon==0 then
                f.Texture:SetTexture(3847780)
            end
            GossipButton:update_gossip_frame()
    end})
    Menu.Size:SetPoint('TOP', Menu.Icon, 'BOTTOM', 0, -36)



    --修改，为中文，字体
    --if LOCALE_zhCN or LOCALE_zhTW then
      --  Save().Gossip_Text_Icon_cnFont=nil
    --elseif e.onlyChinese then
        Menu.font= CreateFrame("CheckButton", nil, Frame, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
        Menu.font:SetPoint('TOPLEFT', Menu.Size, 'BOTTOMLEFT', 0, -12)
        Menu.font:SetChecked(Save().Gossip_Text_Icon_cnFont)
        Menu.font.Text:SetText('修改字体')
        Menu.font.Text:SetFont('Fonts\\ARHei.ttf', 12)
        Menu.font:SetScript('OnLeave', GameTooltip_Hide)
        Menu.font:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName , addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('ARHei.ttf', '黑体字')
            e.tips:Show()
        end)
        Menu.font:SetScript('OnMouseDown', function()
            Save().Gossip_Text_Icon_cnFont= not Save().Gossip_Text_Icon_cnFont and true or nil
            GossipButton:update_gossip_frame()
            Frame.Menu:set_list()
            if not Save().Gossip_Text_Icon_cnFont then
                print(e.addName, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '需要重新加载UI' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, RELOADUI))
            end
        end)
    --end

    --已打开，对话，列表
    --Menu.chat= WoWTools_ButtonMixin:Cbtn(Frame, {size={22, 22}, atlas='transmog-icon-chat'})
    Menu.chat=WoWTools_ButtonMixin:CreateMenu(Frame, {hideIcon=true})
    Menu.chat:SetNormalAtlas('transmog-icon-chat')
    Menu.chat:SetPoint('LEFT', Menu.Name, 'RIGHT', 2, 0)
    Menu.chat:SetScript('OnLeave', GameTooltip_Hide)
    Menu.chat:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '当前对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, ENABLE_DIALOG), e.onlyChinese and '添加' or ADD)
        e.tips:Show()
    end)
    Menu.chat:SetupMenu(Chat_Menu)

    --GossipFrame 有多少对话
    Menu.chat.Text= WoWTools_LabelMixin:CreateLabel(Menu.chat, {justifyH='CENTER'})
    Menu.chat.Text:SetPoint('CENTER', 1, 4.2)



    --默认，自定义，列表
    Menu.System= WoWTools_ButtonMixin:Cbtn(Frame, {size={22, 22}, icon='hide'})
    Menu.System:SetPoint('BOTTOMRIGHT', Menu.ID, 'TOPRIGHT', 0, 2)
    Menu.System.Text= WoWTools_LabelMixin:CreateLabel(Menu.System)
    Menu.System.Text:SetPoint('CENTER')
    function Menu.System:set_num()--默认，自定义，列表        
        local n=0
        for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
            n= n+1
        end
        self:SetNormalTexture(0)
        self.Text:SetText(n)
        self.num=n
    end
    Menu.System:set_num()
    Menu.System:SetScript('OnShow', Menu.System.set_num)
    Menu.System:SetScript('OnLeave', GameTooltip_Hide)
    Menu.System:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '默认' or DEFAULT, self.num or 0))
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
        self:set_num()
    end)
    Menu.System:SetScript('OnClick', function(self)
        WoWTools_GossipMixin:GossipData_Menu(self)
    end)



    --导入数据
    Menu.DataFrame=WoWTools_EditBoxMixn:CreateMultiLineFrame(Frame,{
        instructions= 'text'
    })
    Menu.DataFrame:Hide()
    Menu.DataFrame:SetPoint('TOPLEFT', Frame, 'TOPRIGHT', 0, -10)
    Menu.DataFrame:SetPoint('BOTTOMRIGHT', 310, 8)

    Menu.DataFrame.CloseButton=CreateFrame('Button', nil, Menu.DataFrame, 'UIPanelCloseButton')
    Menu.DataFrame.CloseButton:SetPoint('TOPRIGHT',0, 13)
    Menu.DataFrame.CloseButton:SetScript('OnClick', function(self)
        local frame=self:GetParent()
        frame:Hide()
        frame:SetText("")
    end)

    Menu.DataFrame.enter= WoWTools_ButtonMixin:Cbtn(Menu.DataFrame, {size={100, 23}, type=false})
    Menu.DataFrame.enter:SetPoint('BOTTOM', Menu.DataFrame, 'TOP', 0, 5)
    Menu.DataFrame.enter:SetFormattedText('|A:Professions_Specialization_arrowhead:0:0|a%s', e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
    Menu.DataFrame.enter:Hide()
    function Menu.DataFrame.enter:set_date(tooltips)--导入数据，和提示
        local frame= self:GetParent()
        if not frame then
            return
        end

        local add, del, exist= {}, 0, 0
        local text= string.gsub(frame:GetText() or '', '(%[%d+]={.-})', function(t)
            --local num, icon, name, hex= t:match('(%d+).-icon=(.-), name=(.-), hex=(.-)}')
            local num, icon, name, hex= t:match('(%d+).-icon="(.-)", name="(.-)", hex="(.-)"}')
            if not num and not icon and not name and not hex then
                num, icon, name, hex= t:match('(%d+).-icon=(.-), name=(.-), hex=(.-)}')
            end
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
            Frame.Menu:set_list()
            print(e.addName, addName, '|n', format('%s|n%s|n%s', addText, delText, existText))
            frame:SetText(text)
            self:GetParent():SetInstructions(e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        else
            e.tips:AddLine(addText)
            e.tips:AddLine(delText)
            e.tips:AddLine(existText)
        end
    end
    Menu.DataFrame.enter:SetScript('OnLeave', GameTooltip_Hide)
    Menu.DataFrame.enter:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddDoubleLine(e.onlyChinese and '格式' or FORMATTING, '|cffff00ff[gossipOptionID]={icon=, name=, hex=}')
        e.tips:AddLine(' ')
        self:set_date(true)
        e.tips:Show()
    end)
    Menu.DataFrame.enter:SetScript('OnClick', function(self)--导入
       self:set_date()

    end)

    Menu.DataUscita= WoWTools_ButtonMixin:Cbtn(Frame, {size={22, 22}, atlas='bags-greenarrow'})
    Menu.DataUscita:SetPoint('LEFT', Menu.DeleteAllPlayerData, 'RIGHT', 22, 0)
    Menu.DataUscita:SetScript('OnLeave', GameTooltip_Hide)
    Menu.DataUscita:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
        e.tips:Show()
    end)
    Menu.DataUscita:SetScript('OnClick', function(self)
        local frame= self:GetParent().Menu.DataFrame
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
            --[[text=text..format('[%d]={icon=%s, name=%s, hex=%s}|n',
                            info.gossipID,
                            info.icon or '',
                            info.name or '',
                            info.hex or ''
                        )]]
            text=text..format('[%d]={icon="%s", name="%s", hex="%s"},|n',
                info.gossipID,
                info.icon or '',
                info.name or '',
                info.hex or ''
            )
        end
        frame:SetText(text)
        frame:SetInstructions(e.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
    end)

    Menu.DataEnter= WoWTools_ButtonMixin:Cbtn(Frame, {size={22, 22}, atlas='Professions_Specialization_arrowhead'})
    Menu.DataEnter:SetPoint('LEFT', Menu.DataUscita, 'RIGHT')
    Menu.DataEnter:SetScript('OnLeave', GameTooltip_Hide)
    Menu.DataEnter:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        e.tips:Show()
    end)
    Menu.DataEnter:SetScript('OnClick', function(self)
        local frame= self:GetParent().Menu.DataFrame
        frame:SetShown(true)
        frame.enter:SetShown(true)
        frame:SetText('')
    end)




    Menu.chat:SetShown(GossipFrame:IsShown())
    Menu:set_list()
    Menu:set_color()




    GossipFrame:HookScript('OnShow', function()--已打开，对话，列表
        Frame.Menu.chat:SetShown(true)
        Frame.Menu:set_list()
    end)
    GossipFrame:HookScript('OnHide', function()
        Frame.Menu.chat:SetShown(false)
        Frame.Menu:set_list()
    end)

    Frame:SetScript('OnHide', function(self)
        GossipButton:update_gossip_frame()
        self.Menu:set_list()
        if not GossipFrame.GreetingPanel.ScrollBox:GetView() then
            return
        end
        for _, b in pairs(GossipFrame.GreetingPanel.ScrollBox:GetFrames() or {}) do
            b:UnlockHighlight()
        end
    end)
    Frame:SetScript('OnShow', function(self)
        GossipButton:update_gossip_frame()
        self.Menu:set_list()
    end)
    GossipButton:update_gossip_frame()







--插件
    local tavFrame= _G['TAV_InfoPanel']
    if tavFrame and tavFrame.Name then
        local btn= WoWTools_ButtonMixin:Cbtn(Frame, {atlas='SpecDial_LastPip_BorderGlow', size=23})
        btn:SetPoint('RIGHT', tavFrame.Name, 'LEFT', -14, 0)
        btn.edit= tavFrame.Name
        btn:SetScript('OnClick', function(self)
            local text= self.edit:GetText()
            if text and text~='' then
                Menu.Icon:SetText(text)
            end
        end)
    end
end

















function WoWTools_GossipMixin:Init_Options_Frame()
    if not self.GossipButton then
        return
    end

    if Frame then
        Frame:SetShown(not Frame:IsShown())
    else
        addName= self.addName
        GossipButton= self.GossipButton
        Init()
    end
end