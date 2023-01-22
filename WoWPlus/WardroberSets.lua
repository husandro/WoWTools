local id, e = ...
local addName=WARDROBE_SETS
local Save={}
--外观保存数据wowSave={[1]={class=str,numCollected=number, numTotal=number}
local wowSave = {
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

--试衣间, 外观列表DressUpFrames.lua
hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(self, transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
    local link
    if not Save.disabledDressUpOutfit and transmogID then
        --link = self.item:GetItemLink()        
		if self.item then
			link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID));
		else
			link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID));
		end
    end
    if link and not self.btn then
        --e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
        self.btn=e.Cbtn(self, nil, true, nil, nil, nil,{20,20})
        --self.btn:RegisterForClicks("LeftButtonDown","RightButtonDown")
        self.btn:SetPoint('RIGHT')
        --self.btn:SetSize(20, 20)
        self.btn:SetAlpha(0.3)
        self.btn:SetScript('OnEnter', function(self2, d)
            if self2.link and self2.link:find('item') then
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:SetHyperlink(self2.link)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinse and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinse and '外观' or WARDROBE, e.Icon.right)
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
                    --C_TransmogCollection.SetSearch(1, name)
                   -- WardrobeCollectionFrame:SetSearch(C_Item.GetItemNameByID(link) or '')--Blizzard_Wardrobe.lua
                   WardrobeCollectionFrameSearchBox:SetText(self2.name or '')
                end
            end
        end)
    end
    if self.btn then
        self.btn.link=link
        self.btn.name=name
       -- self.btn.transmogID=self.btn.transmogID
        self.btn.transmogLocation=self.transmogLocation
        if icon then
            self.btn:SetNormalTexture(icon)
        end
        self.btn:SetShown(link and true or false)
    end
end)
local dupframe=DressUpFrame.OutfitDetailsPanel
dupframe.sel=e.Cbtn(dupframe)
dupframe.sel:SetPoint('BOTTOMRIGHT', -5, 10)
dupframe.sel:SetSize(16,16)
dupframe.sel:SetAlpha(0.3)
dupframe.sel:SetScript('OnMouseDown', function ()
    if Save.disabledDressUpOutfit then
        Save.disabledDressUpOutfit=nil
    else
        Save.disabledDressUpOutfit=true
    end
    print(id, addName, e.onlyChinse and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.disabledDressUpOutfit))
    dupframe.sel:SetNormalAtlas(Save.disabledDressUpOutfit and e.Icon.disabled or e.Icon.icon)
end)
dupframe.sel:SetScript('OnEnter', function (self2)
    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddDoubleLine(e.onlyChinse and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.disabledDressUpOutfit)..e.Icon.left)
    e.tips:Show()
end)
dupframe.sel:SetScript('OnLeave', function ()
    e.tips:Hide()
end)

--外观
local wowSave2=wowSave
local function SetSaveWardroberColleced()--收集所有角色套装数据
    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts()
    for _,v in pairs(wowSave) do
        if v.class==e.Player.class then
            v.numCollected=numCollected
            v.numTotal=numTotal
            break
        end
    end
    local frame2=WardrobeCollectionFrame--显示数据
    local frame=frame2 and frame2.SetsCollectionFrame.DetailsFrame
    if not frame or Save.disabled then
        if frame and frame.PlayerCoollectedStr then
            frame.PlayerCoollectedStr:SetText('')
        end
        return
    end

    numCollected,numTotal=0, 0
    local m=''
    for _, info in pairs(wowSave) do
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
        frame.PlayerCoollectedStr:SetJustifyH('LEFT');
    end
    frame.PlayerCoollectedStr:SetText(m)
end

local function InitWardrobe()
    local frame2=WardrobeCollectionFrame
    local frame=frame2.SetsCollectionFrame.DetailsFrame
    local list=WardrobeSetsScrollFrameButtonMixin

    hooksecurefunc(list, 'Init', function(button, displayData)--外观列表    
        local setID=displayData.setID
        local sets = C_TransmogSets.GetVariantSets(setID)
        if not sets or type(sets)~='table' or Save.disabled then
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
        button:SetScript("OnEnter",function(self2)
            e.tips:SetOwner(frame2, "ANCHOR_RIGHT",8,-300)
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

    hooksecurefunc(list, 'OnClick', function(button, buttonName, down)--点击，显示套装情况Blizzard_Wardrobe.lua
        if not button.tips or Save.disabled then
            if frame.str then frame.str:SetShown(false) end
            return
        end
        if buttonName == "LeftButton" then
            if not frame.str then
                frame.str=e.Cstr(frame)
                frame.str:SetPoint('BOTTOMLEFT', frame, 'LEFT', 8 , 0)
                frame.str:SetJustifyH('LEFT')
            end
            frame.str:SetText(button.tips)
            frame.str:SetShown(true)
        end
    end)

    --套装物品Link
    hooksecurefunc(frame2.SetsCollectionFrame, 'SetItemFrameQuality', function(self, itemFrame)
        if Save.disabled then
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
                btn=e.Cbtn(itemFrame,nil, true)
                btn:SetNormalAtlas('adventure-missionend-line');
                itemFrame['btn'..i]=btn
                if i==1 then
                    btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
                else
                    btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
                end
                btn:SetSize(26, 10)--32
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
    end)--Blizzard_Wardrobe.lua

    local function setAllSets()--所以有套装情况
        if Save.disabled then
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
                if info.collected and info.all and info.all>0 then
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

    frame.sel =e.Cbtn(frame, nil, not Save.disabled)--隐藏选项
    frame.sel:SetPoint('BOTTOMRIGHT',-16, 28)
    frame.sel:SetSize(18,18)
    frame.sel:SetAlpha(0.5)
    frame.sel:SetScript("OnMouseDown", function(self2)
            if Save.disabled then
                Save.disabled=nil;
            else
                Save.disabled=true;
                if frame.str then--点击，显示套装情况
                    frame.str:SetShown(false)
                end
            end
            print(id, addName, e.GetShowHide(not Save.disabled))
            setAllSets()--所以有套装情况
            SetSaveWardroberColleced()--收集所有角色套装数据
            self2:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
    end)
    frame.sel:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetShowHide(not Save.disabled), e.Icon.left)
        e.tips:Show()
    end)
    frame.sel:SetScript('OnLeave', function()
        e.tips:Hide()
    end)

end

--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            wowSave=WoWToolsSave and WoWToolsSave['WoW-CollectionWardrobeSets'] or wowSave
            SetSaveWardroberColleced()--收集所有角色套装数据
            dupframe.sel:SetNormalAtlas(Save.disabledDressUpOutfit and e.Icon.disabled or e.Icon.icon)--试衣间, 外观列表

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
            WoWToolsSave['WoW-CollectionWardrobeSets']=wowSave
        end
    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        InitWardrobe()
        SetSaveWardroberColleced()

    elseif event=='TRANSMOG_SETS_UPDATE_FAVORITE' then
        SetSaveWardroberColleced()
    end
end)