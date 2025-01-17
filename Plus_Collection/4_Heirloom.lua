--传家宝, 按钮，提示 4
--Blizzard_HeirloomCollection.lua
local e= select(2, ...)

local function Save()
    return WoWTools_PlusCollectionMixin.Save
end


















local function Init()
    if e.Is_Timerunning then--10.2.7
        return
    end
    hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
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
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddLine(format(e.onlyChinese and '传家宝升级等级：%d/%d' or HEIRLOOM_UPGRADE_TOOLTIP_FORMAT, self2.upgradeLevel, self2.maxUp))
                        e.tips:AddDoubleLine(e.addName, WoWTools_PlusCollectionMixin.addName)
                        e.tips:Show()
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
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '竞技装备' or ITEM_TOURNAMENT_GEAR)
                e.tips:AddDoubleLine(e.addName, WoWTools_PlusCollectionMixin.addName)
                e.tips:Show()
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

        WoWTools_ItemStatsMixin:SetItem(button, C_Heirloom.GetHeirloomLink(button.itemID), {point=button.iconTexture, itemID=button.itemID, hideSet=true, hideLevel=not has, hideStats=not has})--设置，物品，4个次属性，套装，装等，
    end)









    local check= WoWTools_ButtonMixin:Cbtn(HeirloomsJournal, {size={22,22}, icon='hide'})
    function check:set_alpha()
        self:SetAlpha(Save().hideHeirloom and 0.3 or 1)
    end
    function check:set_texture()
        self:SetNormalAtlas(Save().hideHeirloom and e.Icon.disabled or e.Icon.icon)
    end
    function check:set_filter_shown()
        self.frame:SetShown(not Save().hideHeirloom)
    end
    function check:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_PlusCollectionMixin.addName)
        if UnitAffectingCombat('player') then
            e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '传家宝' or HEIRLOOMS).. ' '..e.GetEnabeleDisable(not Save().hideHeirloom), e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().Heirlooms_Class_Scale or 0), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '全职业' or ALL_CLASSES, e.Icon.left)
        e.tips:Show()
    end
    check:SetScript('OnClick',function (self, d)
        if d=='RightButton' then
            Save().hideHeirloom= not Save().hideHeirloom and true or nil
            self:set_tooltips()
            self:set_alpha()
            self:set_texture()
            self:set_filter_shown()
            HeirloomsJournal:FullRefreshIfVisible()
        else
            HeirloomsJournal:SetClassAndSpecFilters(0, 0)
        end
    end)
    check:SetScript("OnMouseWheel", function(self, d)
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
        self:set_frame_scale()
        self:set_tooltips()
    end)

    check:SetPoint('TOPLEFT', HeirloomsJournal.iconsFrame, 'TOPRIGHT', 8, 0)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', check.set_tooltips)


    --过滤，按钮
    check.frame= CreateFrame('Frame', nil, check)
    check.frame:SetPoint('TOPLEFT', check, 'BOTTOMLEFT',0 -80)
    check.frame:SetSize(26, 1)
    function check:set_frame_scale()
        self.frame:SetScale(Save().Heirlooms_Class_Scale or 1)
    end

    check.classButton={}
    check.specButton={}

    function check:cereate_button(classID, specID, texture, atlas)
        local btn= e.Cbtn2({parent=self.frame, notSecureActionButton=true, size=26, showTexture=true, click=true})
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
                e.tips:SetOwner(f, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, WoWTools_PlusCollectionMixin.addName)
                e.tips:AddLine(' ')
                e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
                e.tips:Show()
            end
        end)
        if texture then
            btn.texture:SetTexture(texture)
        else
            btn.texture:SetAtlas(atlas)
        end
        btn.classID= classID
        btn.specID= specID
        return btn
    end

    function check:init_spce(classID, spec)
        classID= classID or 0
        spec= spec or 0
        local num= classID>0 and C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0
        for i = 1, num, 1 do
            local specID, _, _, icon, role = GetSpecializationInfoForClassID(classID, i, e.Player.sex)
            local btn= self.specButton[i]
            if not btn then
                btn= self:cereate_button(classID, specID, icon, nil)
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
            else
                btn.classID= classID
                btn.specID= specID
                btn.texture:SetTexture(icon)
            end
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
        if classFile==e.Player.class then
            atlas= 'auctionhouse-icon-favorite'
        else
            atlas= WoWTools_UnitMixin:GetClassIcon(nil, classFile, true)
        end
        if atlas then
            local btn= check:cereate_button(classID, 0, nil, atlas)
            check.classButton[i]=btn
            btn:SetPoint('TOPLEFT', check.classButton[i-1] or check.frame, 'BOTTOMLEFT')
        end
    end

    C_Timer.After(2, function()
        check:init_spce(select(2, UnitClassBase('player')), PlayerUtil.GetCurrentSpecID() or 0)
    end)

    function check:chek_select(Class, Spec)
        for _, btn in pairs(self.classButton) do
            btn:set_select(Class, Spec)
        end
        self:init_spce(Class, Spec)
    end


    hooksecurefunc(HeirloomsJournal, 'SetClassAndSpecFilters', function(_, Class, Spec)
        check:chek_select(Class, Spec)
    end)

    check:set_alpha()
    check:set_texture()
    check:set_filter_shown()
    check:set_frame_scale()


    HeirloomsJournalSearchBox:SetPoint('LEFT', HeirloomsJournal.progressBar, 'RIGHT', 12,0)
end

















function WoWTools_PlusCollectionMixin:Init_Heirloom()--传家宝 4
    Init()
end