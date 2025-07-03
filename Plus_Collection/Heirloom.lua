--传家宝, 按钮，提示 4
--Blizzard_HeirloomCollection.lua


local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end




















local function UpdateButton(_, button)
    if not HeirloomsJournal:IsVisible() then
        return
    end

    if Save().hideHeirloom then
        if button.isPvP then
            button.isPvP:SetShown(false)
        end
        if button.upLevel then
            button.upLevel:SetShown(false)
        end
        if button.itemLevel then
            button.itemLevel:SetText('')
        end
        for index=1 ,4 do
            local text=button['statText'..index]
            if text then
                text:SetText('')
            end
        end
        return
    end
    local _, _, isPvP, _, upgradeLevel = C_Heirloom.GetHeirloomInfo(button.itemID)
    --local _, _, isPvP, _, upgradeLevel, _, _, _, _, maxLevel = C_Heirloom.GetHeirloomInfo(button.itemID)
    local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) or 0
    local level= maxUp-(upgradeLevel or 0)
    local has = C_Heirloom.PlayerHasHeirloom(button.itemID)
    if has then--需要升级数
        if not button.upLevel then
            button.upLevel = button:CreateTexture(nil, 'OVERLAY')
            button.upLevel:SetPoint('TOPLEFT', -4, 4)
            button.upLevel:SetSize(26,26)
            button.upLevel:SetVertexColor(1,0,0)
            button.upLevel:EnableMouse(true)
            button.upLevel:SetScript('OnLeave', GameTooltip_Hide)
            button.upLevel:SetScript('OnEnter', function(self2)
                if self2.maxUp and self2.upgradeLevel then
                    GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '传家宝升级等级：%d/%d' or HEIRLOOM_UPGRADE_TOOLTIP_FORMAT, self2.upgradeLevel, self2.maxUp))
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
                    GameTooltip:Show()
                end
            end)
            button.upLevel:SetScript('OnMouseDown', function(self2)
                local itemID= self2:GetParent().itemID
                if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                    C_Heirloom.CreateHeirloom(itemID)
                end
            end)
        end
    end
    if button.upLevel then
        button.upLevel.maxUp= maxUp
        button.upLevel.upgradeLevel= upgradeLevel
        button.upLevel:SetShown(has and level>0)
        if level>0 then
            button.upLevel:SetAtlas('services-number-%d'..level)
        else
            button.upLevel:SetTexture(0)
        end
    end

    if isPvP and not button.isPvP then
        button.isPvP=button:CreateTexture(nil, 'OVERLAY')
        button.isPvP:SetPoint('TOP')
        button.isPvP:SetSize(14, 14)
        button.isPvP:SetAtlas('honorsystem-icon-prestige-6')
        button.isPvP:EnableMouse(true)
        button.isPvP:SetScript('OnLeave', GameTooltip_Hide)
        button.isPvP:SetScript('OnEnter', function(self2)
            GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '竞技装备' or ITEM_TOURNAMENT_GEAR)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
            GameTooltip:Show()
        end)
        button.isPvP:SetScript('OnMouseDown', function(self2)
            local itemID= self2:GetParent().itemID
            if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                C_Heirloom.CreateHeirloom(itemID)
            end
        end)
    end
    if button.isPvP then
        button.isPvP:SetShown(isPvP)
    end
    if not button.moved and button.level then--设置，等级数字，位置
        button.level:ClearAllPoints()
        button.level:SetPoint('TOPRIGHT', button, 'TOPRIGHT')

        button.levelBackground:ClearAllPoints()
        button.levelBackground:SetPoint('TOPRIGHT', button, 'TOPRIGHT',-2,-2)
        button.levelBackground:SetAlpha(0.5)

        button.slotFrameCollected:SetTexture(0)--外框架
        button.slotFrameCollected:SetShown(false)
        button.slotFrameCollected:SetAlpha(0)
        button.moved= true
    end
    if level==0 then
        button.level:SetText('')
    end
    button.levelBackground:SetShown(level>0 and has)

    WoWTools_ItemMixin:SetItemStats(button, C_Heirloom.GetHeirloomLink(button.itemID), {point=button.iconTexture, itemID=button.itemID, hideSet=true, hideLevel=not has, hideStats=not has})--设置，物品，4个次属性，套装，装等，
end





















local ListButton
local function Init_ClassListButton()

    ListButton= WoWTools_ButtonMixin:Cbtn(HeirloomsJournal, {
        size=22,
        texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
        name='WoWTools_PlusHeirloomsClassListButton'
    })

    function ListButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)

        if UnitAffectingCombat('player') then
            GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        end

        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().Heirlooms_Class_Scale or 0), WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '全职业' or ALL_CLASSES, WoWTools_DataMixin.Icon.left)

        GameTooltip:Show()
    end
    ListButton:SetScript('OnClick',function (self, d)
        if d=='LeftButton' then
            HeirloomsJournal:SetClassAndSpecFilters(0, 0)
        end
        self:set_tooltips()
    end)
    ListButton:SetScript("OnMouseWheel", function(self, d)
        local n
        n= Save().Heirlooms_Class_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n<0.4 and 0.4 or n
        n= n>4 and 4 or n
        if n==1 then
            n=nil
        end
        Save().Heirlooms_Class_Scale=n
        self:Settings()
        self:set_tooltips()
    end)

    ListButton:SetPoint('TOPLEFT', HeirloomsJournal.iconsFrame, 'TOPRIGHT', 8, 0)
    ListButton:SetScript('OnLeave', GameTooltip_Hide)
    ListButton:SetScript('OnEnter', ListButton.set_tooltips)


    --过滤，按钮
    ListButton.frame= CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('TOPLEFT', ListButton, 'BOTTOMLEFT',0 -80)
    ListButton.frame:SetSize(26, 1)


    ListButton.classButton={}
    ListButton.specButton={}

    function ListButton:cereate_button(classID, specID, texture, atlas)
        local btn= WoWTools_ButtonMixin:Cbtn(self.frame, {
            size=26,
            text=texture,
            atlas=atlas,
            isType2=true,
        })
        function btn:set_select(class, spec)
            if class==self.classID and spec==self.specID then
                self:LockHighlight()
            else
                self:UnlockHighlight()
            end
        end
        btn:SetScript('OnClick', function(f)
            HeirloomsJournal:SetClassAndSpecFilters(f.classID, f.specID)
        end)
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(f)
            if UnitAffectingCombat('player') then
                GameTooltip:SetOwner(f, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
                GameTooltip:Show()
            end
        end)

        btn.classID= classID
        btn.specID= specID
        return btn
    end

    function ListButton:init_spce(classID, spec)
        classID= classID or 0
        spec= spec or 0
        local num= classID>0 and C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0
        for i = 1, num, 1 do
            local specID, _, _, icon, role = GetSpecializationInfoForClassID(classID, i, WoWTools_DataMixin.Player.Sex)
            local btn= self.specButton[i]
            if not btn then
                btn= self:cereate_button(classID, specID, nil, nil)
                btn.roleTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
                btn.roleTexture:SetSize(15,15)
                btn.roleTexture:SetPoint('LEFT', btn, 'RIGHT', -4, 0)
                if i==1 then
                    local texture= btn:CreateTexture()
                    texture:SetPoint('RIGHT', btn, 'LEFT')
                    texture:SetSize(10, 10)
                    texture:SetAtlas('common-icon-rotateleft')
                end
                self.specButton[i]= btn
            end

            btn.classID= classID
            btn.specID= specID
            btn.texture:SetTexture(icon)

            role= role=='DAMAGER' and 'DPS' or role
            btn.roleTexture:SetAtlas('UI-LFG-RoleIcon-'..role..'-Micro')

            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', self.classButton[classID], 'TOPRIGHT', 7 ,0)
            else
                btn:SetPoint('TOP', self.specButton[i-1], 'BOTTOM')
            end
            btn:SetShown(true)
            btn:set_select(classID, spec)
        end
        for i=num+1, #self.specButton, 1 do
            self.specButton[i]:SetShown(false)
        end
    end


    for i = 1, GetNumClasses() do--设置，职业
        local classFile, classID= select(2, GetClassInfo(i))
        local atlas
        if classFile==WoWTools_DataMixin.Player.Class then
            atlas= 'auctionhouse-icon-favorite'
        else
            atlas= WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile, {reAltlas=true})
        end
        if atlas then
            local btn= ListButton:cereate_button(classID, 0, nil, atlas)
            ListButton.classButton[i]=btn
            btn:SetPoint('TOPLEFT', ListButton.classButton[i-1] or ListButton.frame, 'BOTTOMLEFT')
        end
    end

    C_Timer.After(2, function()
        ListButton:init_spce(select(2, UnitClassBase('player')), PlayerUtil.GetCurrentSpecID() or 0)
    end)

    function ListButton:chek_select(Class, Spec)
        for _, btn in pairs(self.classButton) do
            btn:set_select(Class, Spec)
        end
        self:init_spce(Class, Spec)
    end


    hooksecurefunc(HeirloomsJournal, 'SetClassAndSpecFilters', function(self, Class, Spec)
        if self:IsVisible() then
            ListButton:chek_select(Class, Spec)
        end
    end)

    function ListButton:Settings()
        self.frame:SetScale(Save().Heirlooms_Class_Scale or 1)
        self.frame:SetShown(not Save().hideHeirloomClassList)
    end
end














local function Init()
    if PlayerGetTimerunningSeasonID() or Save().hideHeirloom or ListButton then--10.2.7
        if ListButton then
            ListButton:Settings()
        end
        return
    end

    hooksecurefunc(HeirloomsJournal, 'UpdateButton', UpdateButton)

    HeirloomsJournalSearchBox:SetPoint('LEFT', HeirloomsJournal.progressBar, 'RIGHT', 12,0)

    Init_ClassListButton()
end














function WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
    Init()
end