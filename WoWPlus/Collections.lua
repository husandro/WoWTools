local id, e = ...
local addName= COLLECTIONS
local panel=CreateFrame("Frame")
local Save={}
--外观保存数据wowSave={[1]={class=str,numCollected=number, numTotal=number}
local wowSaveSets = {
    ['1']={['class']='WARRIOR'},
    ['2']={['class']='PALADIN'},
    ['4']={['class']='HUNTER'},
    ['8']={['class']='ROGUE'},
    ['16']={['class']='PRIEST'},
    ['32']={['class']='DEATHKNIGHT'},
    ['64']={['class']='SHAMAN'},
    ['128']={['class']='MAGE'},
    ['256']={['class']='WARLOCK'},
    ['512']={['class']='MONK'},
    ['1024']={['class']='DRUID'},
    ['2048']={['class']='DEMONHUNTER'},
    ['4096']={['class']='EVOKER'},
}
local wowSaveItems={}
local slots = {--wowSaveItems
    "|A:transmog-nav-slot-head:0:0|a",
    "|A:transmog-nav-slot-shoulder:0:0|a",
    "|A:transmog-nav-slot-back:0:0|a",
    "|A:transmog-nav-slot-chest:0:0|a",
    "|A:transmog-nav-slot-shirt:0:0|a",
    "|A:transmog-nav-slot-tabard:0:0|a",
    "|A:transmog-nav-slot-wrist:0:0|a",
    "|A:transmog-nav-slot-hands:0:0|a",
    "|A:transmog-nav-slot-waist:0:0|a",
    "|A:transmog-nav-slot-legs:0:0|a",
    "|A:transmog-nav-slot-feet:0:0|a",
    "|T135139:0|t",--魔杖
    '|T132392:0|t',--13单手斧
    '|A:transmog-nav-slot-mainhand:0:0|a',--14单手剑
    '|T133476:0|t',--15单手锤
    '|T132324:0|t',--16匕首
    '|T132965:0|t',--17拳套
    '|A:transmog-nav-slot-secondaryhand:0:0|a',--18副手
    '|T652302:0|t',--19副手物品    
    '|T132400:0|t',--20双手斧
    '|T135327:0|t',--21双手剑
    '|T133044:0|t',--22双手锤
    '|T135145:0|t',--23法杖
    '|T135129:0|t',--24长柄武器
    '|T135490:0|t',--25弓
    '|T135610:0|t',--26枪械
    '|T135530:0|t',--27弩
    nil,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}


--###############
--试衣间, 外观列表
--DressUpFrames.lua
local function Init_DressUpFrames()--试衣间, 外观列表
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(self, transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
        local link
        if not Save.hideDressUpOutfit and transmogID then
            if self.item then
                link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID));
            else
                link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID));
            end
        end
        if link and not self.btn then
            self.btn=e.Cbtn(self, {icon=true, size={20,20}})
            self.btn:SetPoint('RIGHT')
            self.btn:SetAlpha(0.3)
            self.btn:SetScript('OnEnter', function(self2, d)
                if self2.link and self2.link:find('item') then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:SetHyperlink(self2.link)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, e.Icon.left)
                    e.tips:AddDoubleLine(e.onlyChinese and '外观' or WARDROBE, e.Icon.right)
                    e.tips:Show()
                end
            end)
            self.btn:SetScript('OnLeave', function ()
                e.tips:Hide()
            end)
            self.btn:SetScript('OnMouseDown', function (self2, d)
                if self2.link then
                    if d=='LeftButton' then
                        local chat=SELECTED_DOCK_FRAME
                        ChatFrame_OpenChat(chat.editBox:GetText()..self2.link, chat)
                    elseif d=='RightButton' then
                        if not IsAddOnLoaded("Blizzard_Collections") then LoadAddOn('Blizzard_Collections') end
                        local wcFrame= WardrobeCollectionFrame
                        if not CollectionsJournal:IsVisible() or not wcFrame:IsVisible() then
                        ToggleCollectionsJournal(5)
                        end
                        if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                            wcFrame:ClickTab(wcFrame.ItemsTab);
                        end
                        if self2.transmogLocation then
                            WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(self2.transmogLocation)
                        end
                        WardrobeCollectionFrameSearchBox:SetText(self2.name or '')
                    end
                end
            end)
        end
        if self.btn then
            self.btn.link=link
            self.btn.name=name
            self.btn.transmogLocation=self.transmogLocation
            if icon then
                self.btn:SetNormalTexture(icon)
            end
            self.btn:SetShown(link and true or false)
        end
    end)

    if DressUpFrame and DressUpFrame.OutfitDetailsPanel then
        local sel= e.Cbtn(DressUpFrame.OutfitDetailsPanel, {icon=Save.hideDressUpOutfit, size={16,16}})
        sel:SetPoint('BOTTOMRIGHT', -5, 10)
        sel:SetAlpha(0.3)
        sel:SetScript('OnMouseDown', function ()
            Save.hideDressUpOutfit= not Save.hideDressUpOutfit and true or nil
            print(id, addName, e.onlyChinese and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.hideDressUpOutfit),e.onlyChinese and '需求刷新' or NEED..REFRESH)
            sel:SetNormalAtlas(Save.hideDressUpOutfit and e.Icon.disabled or e.Icon.icon)
        end)
        sel:SetScript('OnEnter', function (self2)
            e.tips:SetOwner(self2, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinese and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.hideDressUpOutfit)..e.Icon.left)
            e.tips:Show()
        end)
        sel:SetScript('OnLeave', function ()
            e.tips:Hide()
        end)
    end
end








--###############
--套装, 幻化, 界面
----Blizzard_Wardrobe.lua
local wowSave2=wowSaveSets
local function get_Sets_Colleced()--收集所有角色套装数据
    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts()
    if not numCollected or not numTotal or numTotal<=0 then
        return
    end
    for index, info in pairs(wowSaveSets) do
        if info.class==e.Player.class then
            wowSaveSets[index].numCollected= numCollected
            wowSaveSets[index].numTotal= numTotal
            break
        end
    end

    --显示数据
    local frame= (WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame) and WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
    if not frame or Save.hideSets or Save.disabled then
        if frame and frame.PlayerCoollectedStr then
            frame.PlayerCoollectedStr:SetText('')
        end
        return
    end

    numCollected,numTotal=0, 0
    local m=''
    for _, info in pairs(wowSaveSets) do
        if info.numCollected and info.numTotal and info.numTotal > 0 then
            numCollected = numCollected + info.numCollected
            numTotal = numTotal + info.numTotal
            local value=math.modf(info.numCollected/info.numTotal*100)
            local t='|A:classicon-'..info.class..':0:0|a'
            t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
            t=t..' '..info.numCollected..'/'..info.numTotal
            t = info.numCollected<info.numTotal and '|c'..select(4,GetClassColor(info.class))..t..'|r' or '|cnGREEN_FONT_COLOR:'..t..'|r'
            m=m..t..'\n'
        end
    end
    if numTotal>0 then
        m=m..ITEM_PET_KNOWN:format(numCollected, numTotal)..' '.. ('%i%%'):format(numCollected/numTotal*100)
    end
    if not frame.PlayerCoollectedStr then
        frame.PlayerCoollectedStr=e.Cstr(frame)
        frame.PlayerCoollectedStr:SetPoint('BOTTOMLEFT', 10, 60)
        --frame.PlayerCoollectedStr:SetJustifyH('LEFT');
    end
    frame.PlayerCoollectedStr:SetText(m)
end

local function Init_Wardrobe_Sets()
    local frame= (WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame) and WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(button, displayData)--外观列表    
        local setID=displayData.setID
        local sets = C_TransmogSets.GetVariantSets(setID)
        if not sets or type(sets)~='table' or Save.hideSets then
           if button.maxNum then
                button.maxNum:SetText('')
           end
           if button.limited then
                button.limited:SetShown(false)
           end
           if button.version then
                button.version:SetText('')
           end
           return
        end
        table.insert(sets, C_TransmogSets.GetSetInfo(setID))
        table.sort(sets, function(a, b)
            return a.uiOrder < b.uiOrder
        end)

        local header, Limited, version
        local lable, tip, buttonTip= '', '',''
        local maxNum=0
        for _, info in pairs(sets) do
            if info then
                local numCollected, _, numAll = e.GetSetsCollectedNum(info.setID)
                if numCollected and numAll then
                    maxNum= (not maxNum or maxNum<numAll) and numAll or maxNum
                    if not header then
                        header= info.name
                        header= info.limitedTimeSet and header..'\n'..e.Icon.clock2..'|cnRED_FONT_COLOR:'..TRANSMOG_SET_LIMITED_TIME_SET..'|r' or header
                        header = info.label and header..'\n|cnBRIGHTBLUE_FONT_COLOR:'..info.label..'|r' or header
                        version=info.expansionID and _G['EXPANSION_NAME'..info.expansionID]
                        header = header ..(version and '\n'..'|cnGREEN_FONT_COLOR:'..version..'|r' or '')..(info.patchID and ' toc v.'..info.patchID or '')

                    end
                    lable=lable..numCollected..' '

                    local num=numCollected..'/'..(numAll<=9 and e.Icon.number2:format(numAll) or numAll)
                    tip=tip..num..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..(info.setID and ' setID: '..info.setID or '')..'\n'
                    buttonTip=buttonTip..num..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..'\n'

                    Limited= info.limitedTimeSet and true or Limited
                end
            end
        end

        button.tips=(version and version..'\n\n' or '')..buttonTip--点击，显示套装情况

        tip=(header and header..'\n\n' or '').. tip
        button:SetScript("OnEnter",function()
            e.tips:SetOwner(WardrobeCollectionFrame, "ANCHOR_RIGHT",8,-300)
            e.tips:ClearLines()
            e.tips:SetText(tip)
            e.tips:Show()
        end)
        button:SetScript("OnLeave",function()
                e.tips:Hide()
        end)
        if button.Label then button.Label:SetText(lable) end

        if not button.maxNum then--套装最大数量
            button.maxNum=e.Cstr(button)
            button.maxNum:SetPoint('RIGHT',-5, 0)
        end
        button.maxNum:SetTextColor(button.Name:GetTextColor())
        button.maxNum:SetText(maxNum~=0 and maxNum or '')

        if Limited and not button.limited then--限时
            button.limited=button:CreateTexture(nil, 'OVERLAY')
            button.limited:SetPoint('TOPRIGHT',-5, -5)
            button.limited:SetSize(15,12)
            button.limited:SetAtlas(e.Icon.clock)
        end
        if button.limited then button.limited:SetShown(Limited) end
        if version and not button.version then--版本
            button.version=e.Cstr(button)
            button.version:SetPoint('BOTTOMRIGHT',-5, 5)
        end
        button.version:SetTextColor(button.Name:GetTextColor())
        button.version:SetText(version or '')
    end)

    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'OnClick', function(button, buttonName, down)--点击，显示套装情况Blizzard_Wardrobe.lua
        if not button.tips or Save.hideSets then
            if frame.str then frame.str:SetShown(false) end
            return
        end
        if buttonName == "LeftButton" then
            if not frame.str then
                frame.str=e.Cstr(frame)
                frame.str:SetPoint('BOTTOMLEFT', frame, 'LEFT', 8 , 0)
            end
            frame.str:SetText(button.tips)
            frame.str:SetShown(true)
        end
    end)

    --套装物品Link
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', function(self, itemFrame)
        if Save.hideSets then
            if itemFrame.indexbtn then
                for i = 1, itemFrame.indexbtn do
                    local btn=itemFrame['btn'..i]
                    if btn then
                        btn:SetShown(false)
                    end
                end
                itemFrame.indexbtn=nil
            end
            return
        end
        local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
        local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
        local sources = C_TransmogSets.GetSourcesForSlot(itemFrame:GetParent():GetParent():GetSelectedSetID(), slot)
        if ( #sources == 0 ) then
            tinsert(sources, sourceInfo)
        end
        CollectionWardrobeUtil.SortSources(sources, sourceInfo.visualID, itemFrame.sourceID)
        local numItems=#sources
        for i=1, numItems do
            local index = CollectionWardrobeUtil.GetValidIndexForNumSources(i, numItems)
            local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
            local btn=itemFrame['btn'..i]
            if not btn then
                btn=e.Cbtn(itemFrame, {icon=true, size={26,10}})
                btn:SetNormalAtlas('adventure-missionend-line');
                itemFrame['btn'..i]=btn
                if i==1 then
                    btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
                else
                    btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
                end
                btn:SetAlpha(0.2)
                btn:SetScript("OnEnter",function(self2)
                        if not self2.link then
                             return
                        end
                        self2:SetAlpha(1)
                        e.tips:ClearLines()
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:SetHyperlink(self2.link)
                        e.tips:Show()
                end)
                btn:SetScript("OnMouseDown", function(self2)
                        if ( self2.link ) then
                            local chat=SELECTED_DOCK_FRAME
                            ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)
                        end
                end)
                btn:SetScript("OnLeave",function(self2)
                        self2:SetAlpha(0.2)
                        e.tips:Hide()
                end)
            end
            btn.link=link
            btn:SetShown(true)
        end
        if itemFrame.indexbtn and itemFrame.indexbtn > numItems then
            for i = numItems+1, itemFrame.indexbtn do
                local btn=itemFrame['btn'..i]
                if btn then
                    btn:SetShown(false)
                end
            end
        end
        itemFrame.indexbtn=numItems
    end)

    local function setAllSets()--所以有套装情况
        if Save.hideSets then
            if frame.AllSets then
                frame.AllSets:SetText('')
            end
            return
        end
        local sets =C_TransmogSets.GetAllSets()
        if sets then
            local tempSave=wowSave2
            local a, h, o=0, 0, 0--联盟, 部落, 其它
            for _, info in pairs(sets) do
                if info and info.classMask and info.setID then
                    local c=info.classMask..''--bit.bor(v.classMask)
                    if tempSave[c] then
                        tempSave[c].collected=tempSave[c].collected or 0
                        if info.collected then
                            tempSave[c].collected=tempSave[c].collected+1
                        end
                        tempSave[c].all=tempSave[c].all and tempSave[c].all + 1 or 1
                    end
                    if info.requiredFaction=='Alliance' then
                        a=a+1
                    elseif info.requiredFaction=='Horde' then
                        h=h+1
                    else
                        o=o+1
                    end
                end
            end
            local m=''
            local collected, all=0 , 0
            for _, info in pairs(tempSave) do
                if info.collected and info.all and info.all>0 and info.class then
                    local value=math.modf(info.collected/info.all*100)
                    local t=info.collected..'/'..info.all..' '
                    t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
                    t=t..'|A:classicon-'..info.class..':0:0|a'
                    t='|c'..select(4,GetClassColor(info.class))..t..'|r'
                    m=m..t..'\n'
                    collected=info.collected + collected
                    all=info.all + all
                end
            end
            if all>0 then
                m=m..collected..'/'..all..' '..('%i%%'):format(collected/all*100)..' '..LFG_LIST_CROSS_FACTION:format(CLASS)
            end
            if a > 0 or h>0 or o>0 then
                m=m..'\n\n'..h..' |A:communities-create-button-wow-horde:0:0|a'
                m=m..'\n'..a..' |A:communities-create-button-wow-alliance:0:0|a'
                m=m..'\n'..o..' |A:communities-guildbanner-background:0:0|a'
                m=m..'\n'..#sets..' '..LFG_LIST_CROSS_FACTION:format(FACTION)
            end
            if not frame.AllSets then
                frame.AllSets=e.Cstr(frame)
                frame.AllSets:SetPoint('BOTTOMRIGHT', -6, 60)
                frame.AllSets:SetJustifyH('RIGHT')
            end
            frame.AllSets:SetText(m)
        end
    end
    setAllSets()--所以有套装情况

    frame.sel =e.Cbtn(frame, {icon=not Save.hideSets, size={18,18}})--隐藏选项
    frame.sel:SetPoint('BOTTOMRIGHT',-16, 28)
    frame.sel:SetAlpha(0.5)
    frame.sel:SetScript("OnMouseDown", function(self2)
            if Save.hideSets then
                Save.hideSets=nil;
            else
                Save.hideSets=true;
                if frame.str then--点击，显示套装情况
                    frame.str:SetShown(false)
                end
            end
            print(id, addName, e.GetShowHide(not Save.hideSets), e.onlyChinese and '需求刷新' or NEED..REFRESH)
            setAllSets()--所以有套装情况
            get_Sets_Colleced()--收集所有角色套装数据
            self2:SetNormalAtlas(Save.hideSets and e.Icon.disabled or e.Icon.icon)
    end)
    frame.sel:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetShowHide(not Save.hideSets), e.Icon.left)
        e.tips:Show()
    end)
    frame.sel:SetScript('OnLeave', function()
        e.tips:Hide()
    end)

    C_Timer.After(2, get_Sets_Colleced)--收集所有角色套装数据
end









--#####
--传家宝
--Blizzard_HeirloomCollection.lua
local function Init_Heirloom()
    hooksecurefunc( HeirloomsJournal, 'UpdateButton', function(self, button)
        if Save.hideHeirloom then
            if button.isPvP then
                button.isPvP:SetShown(false)
            end
            if button.upLevel then
                button.upLevel:SetShown(false)
            end
            return
        end
        local name, itemEquipLoc, isPvP, itemTexture, upgradeLevel, source, searchFiltered, effectiveLevel, minLevel, maxLevel = C_Heirloom.GetHeirloomInfo(button.itemID);
        local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) or 0;
        local level=maxUp-upgradeLevel
        local has = C_Heirloom.PlayerHasHeirloom(button.itemID)
        if level >0 and has then--需要升级数
            if not button.upLevel then
                button.upLevel = button:CreateTexture(nil, 'OVERLAY')
                button.upLevel:SetPoint('TOPLEFT', -1, 1)
                button.upLevel:SetSize(26,26)
            end
            button.upLevel:SetAtlas(e.Icon.number..level)
        end
        if button.upLevel then
            button.upLevel:SetShown(has and level>0)
        end

        if isPvP and not button.isPvP then
            button.isPvP=button:CreateTexture(nil, 'OVERLAY')
            button.isPvP:SetPoint('TOPRIGHT', 1, 1)
            button.isPvP:SetSize(14, 14)
            button.isPvP:SetAtlas('honorsystem-icon-prestige-6')
        end
        if button.isPvP then
            button.isPvP:SetShown(isPvP)
        end
    end)
    local Heirloomframe=HeirloomsJournal
    Heirloomframe.sel=e.Cbtn(Heirloomframe, {icon=not Save.hideHeirloom, size={18,18}})
    Heirloomframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    Heirloomframe.sel:SetAlpha(0.5)
    Heirloomframe.sel:SetScript('OnMouseDown',function (self2)
        Save.hideHeirloom= not Save.hideHeirloom and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.hideHeirloom), e.onlyChinese and '需求刷新' or NEED..REFRESH)
        self2:SetNormalAtlas(Save.hideHeirloom and e.Icon.disabled or e.Icon.icon)
    end)
    Heirloomframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideHeirloom), e.Icon.left)
        e.tips:Show()
    end)
    Heirloomframe.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)
end







--###############
--物品, 幻化, 界面
--###############
local function get_Items_Colleced()
    local List={}--保存数据
    for i=1, 29 do
        local all=C_TransmogCollection.GetCategoryTotal(i)
        local name= C_TransmogCollection.GetCategoryInfo(i)
        if name and all>0 then
            table.insert(List, {
                Name=name,
                Icon=slots[i] or e.Icon.icon,
                Collected=C_TransmogCollection.GetCategoryCollectedCount(i),
                All=all,
            })
        end
    end
    local visualsList=C_TransmogCollection.GetIllusions() or {}
    local totale = #visualsList;
    if totale>0 then
        local collected = 0;
        for i, illusion in ipairs(visualsList) do
            if ( illusion.isCollected ) then
                collected = collected + 1;
            end
        end
        table.insert(List, {
            Name=WEAPON_ENCHANTMENT,
            Icon='|A:transmog-nav-slot-enchant:0:0|a',
            Collected=collected,
            All=totale,
        })
    end
    wowSaveItems[e.Player.class]=List

    if Save.disabled then
        return
    end

    local Frame= WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame
    if not Frame then
        return
    elseif Save.hideItems then--禁用
        for class, type in pairs (wowSaveItems) do
            local str=Frame[addName..class]
            if str then
                str:SetText('')
                str.tip=nil
            end
        end
        local str=Frame[addName..'All']--总数字符
        if str then
            str:SetText('')
        end
        return
    end

    --设置内容
    local last, initStr
    local totaleCollected, totaleAll, totaleClass = 0, 0, 0--总数
    for class, type in pairs (wowSaveItems) do
        local tip={}--提示用
        local collected, all = 0, 0
        for _, info in pairs(type) do
            collected = collected + info.Collected
            all = all + info.All
            table.insert(tip,{
                name=info.Icon..(info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Name..'|r' or info.Name),
                num= info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Collected..'/'.. info.All..'|r' or info.Collected..'/'.. info.All
            })
        end
        local str=Frame[addName..class]
        if not str then
            str=e.Cstr(Frame)
            if not last then
                initStr=str--总数字符用
                str:SetPoint('BOTTOMRIGHT', 5, 80)
            else
                str:SetPoint('BOTTOMRIGHT', last, 'TOPRIGHT', 0, 2)
            end
            str:SetJustifyH('RIGHT')
            str:EnableMouse(true)
            str:SetScript('OnEnter', function(self2)--鼠标提示
                if self2.tip then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    local n=1
                    for _, info in pairs(self2.tip) do
                        if info.name then
                            if select(2, math.modf(n/2))==0 then
                                e.tips:AddDoubleLine(info.name, info.num, 1,0.5,0, 1, 0.5,0)
                            else
                                e.tips:AddDoubleLine(info.name, info.num)
                            end
                        else
                            e.tips:AddLine(' ')
                        end
                        n=n+1
                    end
                    e.tips:Show()
                end
            end)
            str:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        totaleCollected=totaleCollected+collected
        totaleAll=totaleAll+ all
        totaleClass=totaleClass+1

        local per=(' %i%%'):format(collected/all*100)
        collected, all = e.MK(collected,3), e.MK(all,3)

        local col='|c'..select(4,GetClassColor(class))
        str:SetText(col..collected..' '..per..'|A:classicon-'..class..':0:0|a|r')
        table.insert(tip,1,{})
        table.insert(tip,1,{
            name='|A:classicon-'..class..':0:0|a '..col..per..'|r',
            num=col..collected..'/'..all..'|r',
        })
        str.tip=tip

        Frame[addName..class]=str
        last=str
    end

    local str= Frame[addName..'All']--总数字符
    if not str and initStr then
        str=e.Cstr(Frame)
        str:SetPoint('TOPRIGHT', initStr, 'BOTTOMRIGHT', 0, -10)
        str:SetJustifyH('RIGHT')
        Frame[addName..'All']=str
    end
    if str and totaleAll>0 then
        str:SetText(totaleClass..CLASS..'  '..('%i%%'):format(totaleCollected/totaleAll*100)..'  '..e.MK(totaleCollected, 3)..'/'..e.MK(totaleAll,3)..e.Icon.wow2)
    end
end

local function Init_Wardrober_Items()--物品, 幻化, 界面
    local Frame=WardrobeCollectionFrame.ItemsCollectionFrame
    Frame.sel=e.Cbtn(Frame, {icon=not Save.hideItems, size={18,18}})
    Frame.sel:SetPoint('BOTTOMRIGHT',-19, 30)
    Frame.sel:SetAlpha(0.5)
    Frame.sel:SetScript('OnMouseDown',function (self2)
        Save.hideItems= not Save.hideItems and true or nil
        print(id, addName,e.GetEnabeleDisable(not Save.hideItems))
        self2:SetNormalAtlas(Save.hideItems and e.Icon.disabled or e.Icon.icon)
        get_Items_Colleced()
    end)
    Frame.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideItems), e.Icon.left)
        e.tips:Show()
    end)
    Frame.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)

    C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面

    hooksecurefunc(Frame, 'UpdateItems', function(self)--WardrobeItemsCollectionMixin:UpdateItems() Blizzard_Wardrobe.lua
        --local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
        for i = 1, self.PAGE_SIZE do
            local model = self.Models[i];
            if model:IsShown() then
                model.itemButton=model.itemButton or {}

                if not model.texture then
                    model.texture= model:CreateTexture(nil, 'OVERLAY')
                    model.texture:SetPoint('BOTTOMRIGHT')
                    model.texture:SetSize(20,20)
                    model.texture:EnableMouse(true)
                    model.texture:SetScript('OnLeave', function() e.tips:Hide() end)
                    model.texture:SetScript("OnEnter", function(self2)
                        if self2.link then
                            e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:SetHyperlink(self2.link)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, addName)
                            e.tips:Show()
                        end
                    end)
                end

                local itemLinks={}
                local findLinks={}
                if self.transmogLocation:IsIllusion() then--WardrobeItemsModelMixin:OnMouseDown(button)
                    local link = select(2, C_TransmogCollection.GetIllusionStrings(model.visualInfo.sourceID))
                    if link then
                        e.LoadDate({id=link, type='item'})----加载 item quest spell
                        table.insert(itemLinks, link)
                    end
                else
                    local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(model.visualInfo.visualID, self:GetActiveCategory(), self.transmogLocation) or {}
                    for index= 1, #sources do
                        local link = WardrobeCollectionFrame:GetAppearanceItemHyperlink(sources[index]);
                        if link and not findLinks[link] then
                            e.LoadDate({id=link, type='item'})----加载 item quest spell
                            table.insert(itemLinks, link)
                            findLinks[link]=true
                        end
                    end
                end
                findLinks=nil

                local y, x, h =0,0, 10.4
                for index, link in pairs(itemLinks) do
                    local btn= model.itemButton[index]
                    if not btn then
                        btn=e.Cbtn(model, {icon='hide', size={h,h}})
                        btn:SetPoint('BOTTOMLEFT', x, y)
                        if index>1 then
                            btn:SetAlpha(0.3)
                        end
                        btn:SetScript("OnEnter",function(self2)
                            if self2.link then
                                self2:SetAlpha(1)
                                e.tips:ClearLines()
                                e.tips:SetOwner(self2:GetParent():GetParent(), "ANCHOR_RIGHT")
                                e.tips:SetHyperlink(self2.link)
                                e.tips:AddDoubleLine(id, addName)
                                e.tips:AddDoubleLine(e.onlyChinese and '发送' or SEND_LABEL, e.Icon.left)
                                e.tips:Show()
                            end
                        end)
                        btn:SetScript("OnClick", function(self2)
                            if ( self2.link ) then
                                local chat=SELECTED_DOCK_FRAME
                                ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)
                            end
                        end)
                        btn:SetScript("OnLeave",function(self2)
                            if self2.index~=1 then
                                self2:SetAlpha(0.3)
                            end
                            e.tips:Hide()
                        end)
                        model.itemButton[index]=btn
                    end
                    if index~=1 and select(2, math.modf(index / 10))==0 then
                        x= x+ h
                        y=0
                    else
                        y=y+ h
                    end
                    if index==1 then
                        local icon = C_Item.GetItemIconByID(link)
                        if icon then
                            btn:SetNormalTexture(icon)
                        else
                            btn:SetNormalAtlas('adventure-missionend-line')
                        end
                    elseif index<=10 then
                        btn:SetNormalAtlas('services-number-'..(index-1))
                    else
                        btn:SetNormalAtlas('adventure-missionend-line')
                    end
                    btn.link=link
                    btn.index=index
                    btn:SetShown(true)
                end
                for index= #itemLinks+1, #model.itemButton do
                    model.itemButton[index]:SetShown(false)
                end
            end
        end
    end)
end






--###
--玩具
--###
local function Init_ToyBox()
    local function ToyFun(self)
        if Save.hideToyBox then
            self:SetAlpha(1)
            return
        end
        local isUas=C_ToyBox.IsToyUsable(self.itemID)
        local _, duration, enable = GetItemCooldown(self.itemID)
        if not isUas then
            self:SetAlpha(0.5)
        elseif enable==1 and duration>0 then
            self:SetAlpha(0.4)
            self.name:SetTextColor(1,0,0)
        else
            self:SetAlpha(1)
        end
    end

    hooksecurefunc('ToySpellButton_OnClick', ToyFun)
    hooksecurefunc('ToySpellButton_UpdateButton', ToyFun)

    local toyframe=ToyBox
    toyframe.sel=e.Cbtn(toyframe, {icon=not Save.hideToyBox, size={18,18}})
    toyframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    toyframe.sel:SetAlpha(0.5)
    toyframe.sel:SetScript('OnMouseDown',function (self2)
        Save.hideToyBox= not Save.hideToyBox and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.hideToyBox), e.onlyChinese and '需求刷新' or NEED..REFRESH)
        self2:SetNormalAtlas(Save.hideToyBox and e.Icon.disabled or e.Icon.icon)
    end)
    toyframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideToyBox), e.Icon.left)
        e.tips:Show()
    end)
    toyframe.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)
end




--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            wowSaveSets=WoWToolsSave['WoW-CollectionWardrobeSets'] or wowSaveSets
            wowSaveItems=WoWToolsSave['WoW-CollectionWardrobeItems'] or wowSaveItems

            --添加控制面板        
            local sel=e.CPanel('|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '收藏' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init_DressUpFrames()--试衣间, 外观列表
            end

            panel:RegisterEvent("TRANSMOGRIFY_ITEM_UPDATE")
            panel:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE")
            panel:RegisterEvent("PLAYER_LOGOUT")
            C_Timer.After(2, get_Sets_Colleced)--收集所有角色套装数据
            C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面

        elseif arg1=='Blizzard_Collections' then
            Init_ToyBox()--玩具
            Init_Heirloom()--传家宝
            Init_Wardrober_Items()--物品, 幻化, 界面
            Init_Wardrobe_Sets()--套装, 幻化, 界面

            hooksecurefunc('MountJournal_UpdateMountDisplay', function(forceSceneChange)--坐骑
                if not MountJournal.selectedMountID then
                    if MountJournal.MountDisplay.infoText then
                        MountJournal.MountDisplay.infoText:SetText('')
                    end
                    return
                end
                local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID,
                uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)

                local showPlayer = GetCVarBool("mountJournalShowPlayer");
				if not disablePlayerMountPreview and not showPlayer then
					disablePlayerMountPreview = true;
				end
                if not disablePlayerMountPreview then
                    if MountJournal.MountDisplay.infoText then
                        MountJournal.MountDisplay.infoText:SetText('')
                    end
                    return
                end
                if not MountJournal.MountDisplay.infoText then
                    MountJournal.MountDisplay.infoText= e.Cstr(MountJournal.MountDisplay)
                    MountJournal.MountDisplay.infoText:SetPoint('BOTTOMLEFT')
                end
                local text= 'mountID '..MountJournal.selectedMountID
                        ..'\nanimID '..(animID or '')
                        ..'\nisSelfMount '.. (isSelfMount and 'true' or 'false')
                        ..'\nmountTypeID '..(mountTypeID or '')
                        ..'\nspellVisualKitID '..(spellVisualKitID or '')
                        ..'\nuiModelSceneID '..(uiModelSceneID or '')
                        ..'\ncreatureDisplayInfoID '..(creatureDisplayInfoID or '')

                        local _, spellID, icon, _, _, sourceType= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                        text= text..'\n\nspellID '..(spellID or '')
                                  ..'\nicon '..(icon or '')
                                  ..'\nsourceType '..(sourceType or '').. (sourceType and _G['BATTLE_PET_SOURCE_'..sourceType] and ' ('.._G['BATTLE_PET_SOURCE_'..sourceType]..')' or '')


                MountJournal.MountDisplay.infoText:SetText(text)
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
            WoWToolsSave['WoW-CollectionWardrobeSets']=wowSaveSets
            WoWToolsSave['WoW-CollectionWardrobeItems']=wowSaveItems
        end

    elseif event=='TRANSMOG_SETS_UPDATE_FAVORITE' then
        C_Timer.After(2, get_Sets_Colleced)--收集所有角色套装数据

    elseif event=='TRANSMOGRIFY_ITEM_UPDATE' then
        C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面
    end
end)
