local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end
local fastButton







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
local function Init_Fast_Menu(frame, level, menuList)
    local self= frame:GetParent()
    local info
    if menuList then
        local newTab={}
        for subClass, tab in pairs(menuList.subClass) do
            table.insert(newTab, {subClass= subClass, num= tab.num, item= tab.item})
        end
        table.sort(newTab, function(a,b) return a.subClass< b.subClass end)

        for _, tab in pairs(newTab) do
            local tooltip
            for link, num in pairs(tab.item) do
                local icon= C_Item.GetItemIconByID(link)
                tooltip= (tooltip and tooltip..'|n' or '|n')..(icon and '|T'..icon..':0|t' or '')..link..'|cnGREEN_FONT_COLOR:#'..num..'|r'
            end
            local className= e.cn(C_Item.GetItemSubClassInfo(menuList.class, tab.subClass)) or ''
            local text =(tab.subClass<10 and ' ' or '')..tab.subClass..') '.. className
            info={
                text= text..' |cnGREEN_FONT_COLOR:#'..tab.num,
                keepShownOnClick= true,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= text,
                tooltipText= tooltip,
                arg1=menuList.class,
                arg2= tab.subClass,
                func= function(_, arg1, arg2)
                    self:set_PickupContainerItem(arg1, arg2, nil)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local className= C_Item.GetItemClassInfo(menuList.class)
        className= e.cn(className)
        if className then
            e.LibDD:UIDropDownMenu_AddButton({
                text= menuList.class..') '..className..' #'..menuList.num,
                notCheckable= true,
                isTitle= true,
            }, level)
        end
        if menuList.class==2 or menuList.class==4 then
            e.LibDD:UIDropDownMenu_AddButton({
                text= '|T132288:0|t'..format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '你还没有收藏过此外观' or TRANSMOGRIFY_STYLE_UNCOLLECTED),
                notCheckable= true,
                isTitle= true,
            }, level)

        end
        return
    end

    local tab={}
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info2 = C_Container.GetContainerItemInfo(bag, slot)
            if info2
                and info2.hyperlink
                and not info2.isLocked
                and not info2.isBound
            then
                local class, sub = select(6, C_Item.GetItemInfoInstant(info2.hyperlink))
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

    local newTab={}
    for class, tab2 in pairs(tab) do
        table.insert(newTab, {class=class, num=tab2.num, subClass= tab2.subClass})
    end
    table.sort(newTab, function(a,b) return a.class< b.class end)

    local find
    for _, tab2 in pairs(newTab) do
        local className=  C_Item.GetItemClassInfo(tab2.class) or ''
        className= e.cn(className)
        info={
            text= (tab2.class<10 and ' ' or '')..tab2.class..') '..className..((tab2.class==2 or tab2==4) and '|T132288:0|t' or ' ')..'|cnGREEN_FONT_COLOR:#'..tab2.num,
            keepShownOnClick= true,
            notCheckable=true,
            menuList= {class=tab2.class, subClass=tab2.subClass, num=tab2.num},
            hasArrow=true,
            tooltipOnButton= true,
            arg1=tab2.class,
            func= function(_, arg1)
                self:set_PickupContainerItem(arg1, nil, nil)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        find=true
    end
    if not find then
        info={
            text= e.onlyChinese and '无' or NONE,
            notCheckable= true,
            isTitle= true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
    
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '显示' or SHOW,
        checked= Save().fastShow,
        keepShownOnClick=true,
        func= function()
            Save().fastShow= not Save().fastShow and true or nil
            self:set_shown()
        end
    }, level)
end
















local function Init_Fast_Button_Menu(frame, level, menuList)
    local self= frame:GetParent()
    local icon= '|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'
    if menuList=='SELF' then
        local find
        local name= Save().fast[self.name]
        local tab= {}
        for guid, data in pairs(e.WoWDate) do
            local playerName= WoWTools_UnitMixin:GetFullName(nil, nil, guid)
            if playerName and data.region==e.Player.region then
                local realm= WoWTools_MailMixin:GetRealmInfo(playerName)
                local info= {
                    text= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                    checked= name and name==playerName,
                    icon= realm and 'quest-legendary-available',
                    tooltipOnButton=true,
                   tooltipTitle=icon..self.name,
                    tooltipText=playerName..(realm and '|n'..realm or ''),
                    arg1= self.name,
                    arg2= playerName,
                    func= function(_, arg1, arg2)
                        if arg2 then
                            Save().fast[arg1]= arg2
                            print(e.addName, WoWTools_MailMixin.addName, arg1, arg2)
                            self:set_Player_Lable()
                        end
                    end,
                }
                if realm then
                    table.insert(tab, info)
                else
                    table.insert(tab, 1, info)
                end
            end
        end
        for _, info in pairs(tab) do
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find=true
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        return
    end

    local playerName= Save().fast[self.name]
    local newName= WoWTools_UnitMixin:GetFullName(SendMailNameEditBox:GetText())
    e.LibDD:UIDropDownMenu_AddButton({
        text=icon..self.name..': '..(playerName and WoWTools_UnitMixin:GetPlayerInfo({name=playerName, reName=true}) or format('|cff9e9e9e%s|r', e.onlyChinese and '无' or NONE)),
        notCheckable=true,
        colorCode= not playerName and '|cff9e9e9e',
        isTitle=true,
    }, level)

    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '更新' or UPDATE,
        notCheckable=true,
        colorCode= (not newName or playerName==newName) and '|cff9e9e9e',
        tooltipOnButton=true,
        tooltipTitle= newName or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '需求' or NEED, e.onlyChinese and '收件人：' or MAIL_TO_LABEL),
        arg1=self.name,
        arg2=newName,
        func= function(_, arg1, arg2)
            if arg2 then
                Save().fast[arg1]= arg2
                print(e.addName, WoWTools_MailMixin.addName, arg1, arg2)
                self:set_Player_Lable()
            end
        end
    }, level)

    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        notCheckable=true,
        colorCode= not playerName and '|cff9e9e9e',
        arg1=self.name,
        func=function(_, arg1)
            Save().fast[arg1]=nil
            print(e.addName, WoWTools_MailMixin.addName, arg1, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            self:set_Player_Lable()
        end
    }, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
        hasArrow= true,
        notCheckable=true,
        menuList= 'SELF',
        keepShownOnClick=true,
    }, level)

end



























--####################
--快速，加载，物品，按钮
--####################
local function Init()
    fastButton= WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size={22, 22}, icon='hide'})
    fastButton:SetPoint('BOTTOMLEFT', MailFrameCloseButton, 'BOTTOMRIGHT',0, -2)
    fastButton.buttons={}
    fastButton.frame= CreateFrame('Frame', nil, fastButton)
    fastButton.frame:SetSize(1, 1)
    fastButton.frame:SetPoint('TOPLEFT', fastButton, 'BOTTOMLEFT')


    function fastButton:set_scale()
        self.frame:SetScale(Save().scaleFastButton or 1)
    end
    function fastButton:set_shown()
        self.frame:SetShown(Save().fastShow)
        self:SetAlpha(Save().fastShow and 1 or 0.3)
        self:SetNormalAtlas(Save().fastShow and 'NPE_ArrowDown' or 'NPE_ArrowRight')
    end
    function fastButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scaleFastButton or 1), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:Show()
    end
    fastButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        for _, btn in pairs(self.buttons) do
            btn:set_alpha()
        end
    end)
    fastButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
        for _, btn in pairs(self.buttons) do
            btn:SetAlpha(1)
        end
    end)
    fastButton:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Fast_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    fastButton:SetScript('OnMouseWheel', function(self, d)
        local num= Save().scaleFastButton or 1
        num= d==1 and num-0.05 or num
        num= d==-1 and num+0.05 or num
        num= num<0.4 and 0.4 or num
        num= num>4 and 4 or num
        Save().scaleFastButton= num
        self:set_scale()
        self:set_tooltips()
    end)
     
    fastButton:set_scale()
    fastButton:set_shown()





    function fastButton:get_send_max_item()--能发送，数量
        local tab={}
        for i= 1, ATTACHMENTS_MAX_SEND do
            if not HasSendMailItem(i) then
                table.insert(tab, i)
            end
        end
        self.canSendTab= tab
    end
    hooksecurefunc('SendMailFrame_Update', function() fastButton:get_send_max_item() end)

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






    local fast={
        {C_Spell.GetSpellTexture(3908) or 4620681, 7, 5, e.onlyChinese and '布'},--1
        {C_Spell.GetSpellTexture(2108) or 4620678, 7, 6, e.onlyChinese and '皮革'},--2
        {C_Spell.GetSpellTexture(2656) or 4625105, 7, 7, e.onlyChinese and '金属 矿石'},--3
        {C_Spell.GetSpellTexture(2550) or 4620671, 7, 8, e.onlyChinese and '烹饪'},--4
        {C_Spell.GetSpellTexture(2383) or 133939, 7, 9, e.onlyChinese and '草药'},--5
        {C_Spell.GetSpellTexture(7411) or 4620672, 7, 12, e.onlyChinese and '附魔'},--6
        {C_Spell.GetSpellTexture(45357) or 4620676, 7, 16, e.onlyChinese and '铭文'},--7
        {C_Spell.GetSpellTexture(25229) or 4620677, 7, 4, e.onlyChinese and '珠宝加工'},--8

        {"Interface/Icons/INV_Gizmo_FelIronCasing", 7, 1, e.onlyChinese and '零部'},--9
        {"Interface/Icons/INV_Elemental_Primal_Air", 7, 10, e.onlyChinese and '元素'},--10
        {"Interface/Icons/INV_Bijou_Green", 7, 18, e.onlyChinese and '可选材料'},--11
        {"Interface/Icons/INV_Misc_Rune_09", 7, 11, e.onlyChinese and '其它'},--12
        {"Interface/Icons/Ability_Ensnare", 7, 0, e.onlyChinese and '贸易品'},--13
        '-',
        {132690, 4, 1, e.onlyChinese and '布甲'},--1
        {132722, 4, 2, e.onlyChinese and '皮甲'},--2
        {132629, 4, 3, e.onlyChinese and '锁甲'},--3
        {132738, 4, 4, e.onlyChinese and '板甲'},--4
        {134966, 4, 6, e.onlyChinese and '盾牌'},--5
        {135317, 2, nil, e.onlyChinese and '武器'},--6
        {644389, 15, 2, e.onlyChinese and '宠物' or PET, 'Hbattlepet'},--7

        --{133035, 0, 0, e.onlyChinese and '装置'},
        {463931, 0, 1, e.onlyChinese and '药水'},
        {609902, 0, 3, e.onlyChinese and '合计'},
        --{609902, 0, 7, e.onlyChinese and '绷带'},
        {133974, 0, 5, e.onlyChinese and '食物'},
        {1528795, 0, 9, e.onlyChinese and '符文'},

        {466645, 3, nil, e.onlyChinese and '宝石'},
        {463531, 8, nil, e.onlyChinese and '附魔'},
    }

    local x, y=0, 0
    for _, tab in pairs(fast) do
        if tab~='-' then
            local btn= WoWTools_ButtonMixin:Cbtn(fastButton.frame, {size=22, texture=tab[1]})
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
                    if name and name~=e.Player.name_realm then
                         WoWTools_MailMixin:SetSendName(name)--设置，发送名称，文
                    end
                    self:GetParent():GetParent():set_PickupContainerItem(self.classID, self.subClassID, self.findString)--自动放物品
                elseif d=='RightButton' then
                    if not self.Menu then
                        self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                        e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Fast_Button_Menu, 'MENU')
                    end
                    e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
                end
            end)

            btn:SetScript('OnLeave', function(self) self:set_alpha() e.tips:Hide() self:settings() end)
            btn:SetScript('OnEnter', function(self)
                self:settings()
                local playerName= Save().fast[self.name]
                local playerNameInfo= WoWTools_MailMixin:GetNameInfo(playerName)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'..self.name, WoWTools_MailMixin:GetNameInfo(playerName))
                e.tips:AddDoubleLine((e.onlyChinese and '添加' or ADD)..e.Icon.left, playerName and playerName~=playerNameInfo and playerName)
                e.tips:AddLine(' ')
                if self.classID==2 or self.classID==4 then
                    e.tips:AddDoubleLine(format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '你还没有收藏过此外观' or TRANSMOGRIFY_STYLE_UNCOLLECTED))
                end
                e.tips:AddDoubleLine(self.classID and 'ClassID '..self.classID or '', self.subClassID and 'SubClassID '..self.subClassID or '')
                e.tips:AddDoubleLine(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, self.num)
                e.tips:AddDoubleLine(e.onlyChinese and '组数' or AUCTION_NUM_STACKS, self.stack)
                e.tips:AddLine(' ')
                e.tips:AddLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..e.Icon.right)
                e.tips:Show()
                self:SetAlpha(1)
            end)
            table.insert(fastButton.buttons, btn)
            y= y- 22
        else
            x= x+ 22
            y=0
        end
    end

    local texture= fastButton.frame:CreateTexture(nil, 'BACKGROUND')--添加，背景
    texture:SetAtlas('footer-bg')
    texture:SetPoint("TOPLEFT", fastButton.buttons[1],-2, 2)
    texture:SetPoint('BOTTOMRIGHT', fastButton.buttons[#fastButton.buttons], 2, -2)
end










function WoWTools_MailMixin:Init_Fast_Button()
    Init()
end
