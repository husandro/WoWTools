if GameLimitedMode_IsActive() then
    return
end


--快速，加载，物品，按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end

local fastButton
local Buttons= {}







--设置，快速选取，按钮
local function check_Enabled_Item(classID, subClassID, findString, bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info
        and info.itemID
        and info.hyperlink
        and not info.isLocked
        and not info.isBound
    then
        local class, sub = select(6, C_Item.GetItemInfoInstant(info.hyperlink))
        if (findString and info.hyperlink:find(findString))
            or (
                class==classID
                and (not subClassID or sub==subClassID)
            )
        then
            if class==2 or class==4 then--幻化
                local text, isCollected =WoWTools_CollectedMixin:Item(info.hyperlink)
                if text and not isCollected then
                    return info
                end
            else
                return info
            end
        end
    end
end

















--快速，加载，物品，菜单
local function Init_Menu(self, root)
    local sub, sub2, class, newSubTab
    local tab={}
    local newTab={}

--显示
    root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '显示' or SHOW,
    function()
        return Save().fastShow
    end, function()
        Save().fastShow= not Save().fastShow and true or nil
        self:set_shown()
    end)

--列表
    root:CreateDivider()
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info2 = C_Container.GetContainerItemInfo(bag, slot)
            if info2
                and info2.hyperlink
                and not info2.isLocked
                and not info2.isBound
            then
                class, sub = select(6, C_Item.GetItemInfoInstant(info2.hyperlink))
                if class and sub then
                    local find=true
                    if class==2 or class==4 then--幻化
                        local text, isCollected= WoWTools_CollectedMixin:Item(info2.hyperlink)
                        if not text or isCollected then
                            find= false
                        end
                    end
                    if find then
                        tab[class]= tab[class] or {
                                            num= 0,
                                            subClass= {
                                                        [sub]={num=0, item={}}
                                                    }
                                        }
                        tab[class].num= tab[class].num+ info2.stackCount


                        tab[class]['subClass'][sub]= tab[class]['subClass'][sub] or {num=0, item={}}

                        tab[class]['subClass'][sub]['num']= tab[class]['subClass'][sub]['num'] + info2.stackCount

                        tab[class]['subClass'][sub]['item'][info2.hyperlink]= (tab[class]['subClass'][sub]['item'][info2.hyperlink] or 0)+ info2.stackCount
                    end
                end
            end
        end
    end

    for class2, tab2 in pairs(tab) do
        table.insert(newTab, {class=class2, num=tab2.num, subClass= tab2.subClass})
    end
    table.sort(newTab, function(a,b) return a.class< b.class end)


    for _, tab2 in pairs(newTab) do
        sub=root:CreateButton(
            tab2.class..') '
            ..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(tab2.class) or tab2.class or ''))
            ..((tab2.class==2 or tab2==4) and '|T132288:0|t' or ' ')
            ..'|cnGREEN_FONT_COLOR:#'..tab2.num,
        function(data)
            self:set_PickupContainerItem(data.class, nil, nil)
            return MenuResponse.Open
        end, {class= tab2.class})

        newSubTab={}
        for subClass3, tab3 in pairs(tab2.subClass) do
            table.insert(newSubTab, {subClass=subClass3, num=tab3.num, item=tab3.item})
        end
        table.sort(newSubTab, function(a,b) return a.subClass< b.subClass end)

        for _, tab3 in pairs(newSubTab) do
            sub2=sub:CreateButton(
                tab3.subClass
                ..(WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(tab2.class, tab3.subClass)) or (tab2.class..' '..tab3.subClass))
                ..'|cnGREEN_FONT_COLOR:#'..tab3.num,
            function(data)
                self:set_PickupContainerItem(data.class, data.subClass, nil)
                return MenuResponse.Open
            end, {class=tab2.class, subClass=tab3.subClass, item=tab3.item})
            sub2:SetTooltip(function(tooltip, description)
                for link in pairs(description.data.item or {}) do
                    tooltip:AddLine(WoWTools_ItemMixin:GetName(nil, link))
                end
            end)
        end
    end

--打开选项
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scaleFastButton or 1
    end, function(value)
        Save().scaleFastButton= value
        self:set_scale()
    end, function(value)
        Save().scaleFastButton= value
        self:set_scale()
    end)
end
















local function Fast_Button_Set_Menu(self, root, showName, setName)
    local sub=root:CreateCheckbox(
        showName,
    function(data)
        return Save().fast[self.name]==data.name
    end, function(data)
        if Save().fast[self.name]==data.name then
            Save().fast[self.name]=nil
        else
            Save().fast[self.name]=data.name
        end
        self:set_Player_Lable()
    end, {name=setName})

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddLine(description.data.name)
        local findName= Save().fast[self.name]
        if findName==description.data.name then
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
        elseif findName then
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '替换' or REPLACE)
        else
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '添加' or ADD)
        end
        tooltip:AddLine(WoWTools_MailMixin:GetRealmInfo(description.data.name))
    end)
end
















local function Init_Fast_Button_Menu(self, root)
    local sub
    local num=0
    local playerName= Save().fast[self.name]
    local newName= WoWTools_UnitMixin:GetFullName(SendMailNameEditBox:GetText())

    root:CreateTitle(
        '|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'
        ..(WoWTools_Mixin.onlyChinese and '收件人：' or MAIL_TO_LABEL)
    )
    root:CreateDivider()

--已指定，收件人
    if playerName then
        Fast_Button_Set_Menu(
            self, root,
            WoWTools_UnitMixin:GetPlayerInfo({name=playerName, reName=true}),
            playerName
        )
    end

--输入框，收件人
    if newName and newName:gsub(' ', '')~='' and newName~=playerName then
        Fast_Button_Set_Menu(
            self, root,
            WoWTools_UnitMixin:GetPlayerInfo({name=newName, reName=true}),
            newName
        )
    end

--我
    sub= root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
    function()
        return MenuResponse.Open
    end)

    for guid, info in pairs(WoWTools_WoWDate) do
        Fast_Button_Set_Menu(
            self, sub,
            WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, level=info.level, faction=info.faction}),
            WoWTools_UnitMixin:GetFullName(nil, nil, guid)
        )
        num=num+1
    end

--SetGridMode
    WoWTools_MenuMixin:SetGridMode(sub, num)
end














local function Init_Button()
    local fast={
        {C_Spell.GetSpellTexture(3908) or 4620681, 7, 5, WoWTools_Mixin.onlyChinese and '布'},--1
        {C_Spell.GetSpellTexture(2108) or 4620678, 7, 6, WoWTools_Mixin.onlyChinese and '皮革'},--2
        {C_Spell.GetSpellTexture(2656) or 4625105, 7, 7, WoWTools_Mixin.onlyChinese and '金属 矿石'},--3
        {C_Spell.GetSpellTexture(2550) or 4620671, 7, 8, WoWTools_Mixin.onlyChinese and '烹饪'},--4
        {C_Spell.GetSpellTexture(2383) or 133939, 7, 9, WoWTools_Mixin.onlyChinese and '草药'},--5
        {C_Spell.GetSpellTexture(7411) or 4620672, 7, 12, WoWTools_Mixin.onlyChinese and '附魔'},--6
        {C_Spell.GetSpellTexture(45357) or 4620676, 7, 16, WoWTools_Mixin.onlyChinese and '铭文'},--7
        {C_Spell.GetSpellTexture(25229) or 4620677, 7, 4, WoWTools_Mixin.onlyChinese and '珠宝加工'},--8

        {"Interface/Icons/INV_Gizmo_FelIronCasing", 7, 1, WoWTools_Mixin.onlyChinese and '零部'},--9
        {"Interface/Icons/INV_Elemental_Primal_Air", 7, 10, WoWTools_Mixin.onlyChinese and '元素'},--10
        {"Interface/Icons/INV_Bijou_Green", 7, 18, WoWTools_Mixin.onlyChinese and '可选材料'},--11
        {"Interface/Icons/INV_Misc_Rune_09", 7, 11, WoWTools_Mixin.onlyChinese and '其它'},--12
        {"Interface/Icons/Ability_Ensnare", 7, 0, WoWTools_Mixin.onlyChinese and '贸易品'},--13
        '-',
        {132690, 4, 1, WoWTools_Mixin.onlyChinese and '布甲'},--1
        {132722, 4, 2, WoWTools_Mixin.onlyChinese and '皮甲'},--2
        {132629, 4, 3, WoWTools_Mixin.onlyChinese and '锁甲'},--3
        {132738, 4, 4, WoWTools_Mixin.onlyChinese and '板甲'},--4
        {134966, 4, 6, WoWTools_Mixin.onlyChinese and '盾牌'},--5
        {135317, 2, nil, WoWTools_Mixin.onlyChinese and '武器'},--6
        {644389, 15, 2, WoWTools_Mixin.onlyChinese and '宠物' or PET, 'Hbattlepet'},--7

        --{133035, 0, 0, WoWTools_Mixin.onlyChinese and '装置'},
        {463931, 0, 1, WoWTools_Mixin.onlyChinese and '药水'},
        {609902, 0, 3, WoWTools_Mixin.onlyChinese and '合计'},
        --{609902, 0, 7, WoWTools_Mixin.onlyChinese and '绷带'},
        {133974, 0, 5, WoWTools_Mixin.onlyChinese and '食物'},
        {1528795, 0, 9, WoWTools_Mixin.onlyChinese and '符文'},

        {466645, 3, nil, WoWTools_Mixin.onlyChinese and '宝石'},
        {463531, 8, nil, WoWTools_Mixin.onlyChinese and '附魔'},
    }

    local x, y=0, 0
    for _, tab in pairs(fast) do
        if tab~='-' then
            local btn= WoWTools_ButtonMixin:Cbtn(fastButton.frame, {
                size=22,
                texture=tab[1],
                name='WoWToolsFastItemClass'..tab[2]..'SubClass'..(tab[3] or '')..'Button'
            })
            btn:SetPoint('TOPLEFT', fastButton.frame,'BOTTOMLEFT', x, y)

            btn.classID= tab[2]
            btn.subClassID= tab[3]
            btn.name= tab[4] or not tab[3] and C_Item.GetItemClassInfo(tab[2]) or C_Item.GetItemSubClassInfo(tab[2], tab[3])
            btn.findString= tab[5]

            btn.Text= WoWTools_LabelMixin:Create(btn, {size=10})
            btn.Text:SetPoint('TOPLEFT')
            btn.Text2= WoWTools_LabelMixin:Create(btn, {size=10})
            btn.Text2:SetPoint('BOTTOMRIGHT')
            btn.playerTexture= btn:CreateTexture(nil, 'OVERLAY')
            btn.playerTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')
            btn.playerTexture:SetSize(22/2, 22/2)
            btn.playerTexture:SetPoint('BOTTOMLEFT')
            function btn:set_Player_Lable()--设置指定发送，玩家, 提示
                self.playerTexture:SetShown(Save().fast[self.name] and true or false)
            end
            btn:set_Player_Lable()
            function btn:set_alpha()
                self:SetAlpha(self.stack and self.stack>0 and 1 or 0.1)
            end
            function btn:settings()
                if self.checking then
                    return
                end
                self.checking=true
                local num, stack= 0, 0 --C_Item.GetItemMaxStackSizeByID(info.itemID)
                for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                    for slot=1, C_Container.GetContainerNumSlots(bag) do
                        local info= check_Enabled_Item(self.classID, self.subClassID, self.findString, bag, slot)
                        if info then
                            num= num+ info.stackCount
                            stack= stack+1
                        end
                    end
                end
                self.Text:SetText(num==stack and '' or num)
                self.Text2:SetText(stack>0 and stack or '' )
                self.num=num
                self.stack=stack
                self:set_alpha()
                self.checking=nil
            end
            function btn:set_event()
                if self:IsShown() then
                    self:settings()
                    self:RegisterEvent('BAG_UPDATE_DELAYED')
                    self:RegisterEvent('MAIL_SEND_INFO_UPDATE')
                else
                    self:UnregisterAllEvents()
                end
            end
            btn:SetScript('OnEvent', btn.settings)
            btn:SetScript('OnShow', btn.set_event)
            btn:SetScript('OnHide', btn.set_event)

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    local name= Save().fast[self.name]
                    if name and name~=WoWTools_DataMixin.Player.name_realm then
                         WoWTools_MailMixin:SetSendName(name)--设置，发送名称，文
                    end
                    self:GetParent():GetParent():set_PickupContainerItem(self.classID, self.subClassID, self.findString)--自动放物品
                elseif d=='RightButton' then
                    MenuUtil.CreateContextMenu(self, Init_Fast_Button_Menu)
                end
            end)

            btn:SetScript('OnLeave', function(self) self:set_alpha() GameTooltip:Hide() self:settings() end)
            btn:SetScript('OnEnter', function(self)
                self:settings()
                local playerName= Save().fast[self.name]
                local playerNameInfo= WoWTools_MailMixin:GetNameInfo(playerName)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine('|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'..self.name, WoWTools_MailMixin:GetNameInfo(playerName))
                GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '添加' or ADD)..WoWTools_DataMixin.Icon.left, playerName and playerName~=playerNameInfo and playerName)
                GameTooltip:AddLine(' ')
                if self.classID==2 or self.classID==4 then
                    GameTooltip:AddDoubleLine(format(WoWTools_Mixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, WoWTools_Mixin.onlyChinese and '你还没有收藏过此外观' or TRANSMOGRIFY_STYLE_UNCOLLECTED))
                end
                GameTooltip:AddDoubleLine(self.classID and 'ClassID '..self.classID or '', self.subClassID and 'SubClassID '..self.subClassID or '')
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, self.num)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '组数' or AUCTION_NUM_STACKS, self.stack)
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine((WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.right)
                GameTooltip:Show()
                self:SetAlpha(1)
            end)
            table.insert(Buttons, btn)
            y= y- 22
        else
            x= x+ 22
            y=0
        end
    end

--添加，背景
    local texture= fastButton.frame:CreateTexture(nil, 'BACKGROUND')
    texture:SetAtlas('footer-bg')
    texture:SetPoint("TOPLEFT", Buttons[1],-2, 2)
    texture:SetPoint('BOTTOMRIGHT', Buttons[#Buttons], 2, -2)
end












--快速，加载，物品，按钮
local function Init()
    fastButton= WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size=22, name='WoWToolsMailFastItemListButton'})
    fastButton:SetPoint('BOTTOMLEFT', MailFrameCloseButton, 'BOTTOMRIGHT',0, -2)
    
    fastButton.frame= CreateFrame('Frame', nil, fastButton)
    fastButton.frame:SetSize(1, 1)
    fastButton.frame:SetPoint('TOPLEFT', fastButton, 'BOTTOMLEFT')

    function fastButton:Settings()
        self:SetShown(not Save().hideItemButtonList)
    end
    function fastButton:set_scale()
        self.frame:SetScale(Save().scaleFastButton or 1)
    end
    function fastButton:set_shown()
        self.frame:SetShown(Save().fastShow)
        self:SetAlpha(Save().fastShow and 1 or 0.3)
        self:SetNormalAtlas(Save().fastShow and 'NPE_ArrowDown' or 'NPE_ArrowRight')
    end
    function fastButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, WoWTools_Mixin.onlyChinese and '物品快捷键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, SETTINGS_KEYBINDINGS_LABEL))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end
    fastButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        for _, btn in pairs(Buttons) do
            btn:set_alpha()
        end
    end)
    fastButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
        for _, btn in pairs(Buttons) do
            btn:SetAlpha(1)
        end
    end)
    fastButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)

    fastButton:set_scale()
    fastButton:set_shown()


    hooksecurefunc('SendMailFrame_Update', function()
        local tab={}
        for i= 1, ATTACHMENTS_MAX_SEND do
            if not HasSendMailItem(i) then
                table.insert(tab, i)
            end
        end
        fastButton.canSendTab= tab
    end)

    function fastButton:set_PickupContainerItem(classID, subClassID, findString)--自动放物品
        if #self.canSendTab>0 then
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    local info= check_Enabled_Item(classID, subClassID, findString, bag, slot)
                    if info then
                        C_Container.PickupContainerItem(bag, slot)
                        ClickSendMailItemButton(self.canSendTab[1])
                        if #self.canSendTab==0 or not self:IsShown() then
                            return
                        end
                    end
                end
            end
        end
    end


    

    Init_Button()
end










function WoWTools_MailMixin:Init_Fast_Button()
    if self.Save.hideItemButtonList or fastButton then
        if fastButton then
            fastButton:Settings()
        end
    else
        Init()
    end
end
