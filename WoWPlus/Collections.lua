local id, e = ...
local tips=GameTooltip
local addName=COLLECTIONS
local Icon={
    clock='socialqueuing-icon-clock',
}
local Save={
    --str925=true,
    Class = {
        [1]={['class']='WARRIOR'},
        [2]={['class']='PALADIN'},
        [4]={['class']='HUNTER'},
        [8]={['class']='ROGUE'},
        [16]={['class']='PRIEST'},
        [32]={['class']='DEATHKNIGHT'},
        [64]={['class']='SHAMAN'},
        [128]={['class']='MAGE'},
        [256]={['class']='WARLOCK'},
        [512]={['class']='MONK'},
        [1024]={['class']='DRUID'},
        [2048]={['class']='DEMONHUNTER'},
    }
}
local function Val(n)
    if n<10 then
        return n..'  '
    elseif n<100 then
        return n..' '
    else
        return n
    end
end

local function setWardrobe()--专属
    local sets =C_TransmogSets.GetAllSets()
    if not sets then return end
    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts();
    local a, h, o=0, 0, 0;
    for _,v in pairs(Save.Class) do
        if v.class==e.Player.class then
            v.c=0;--已收集
            v.baseC=numCollected;
            v.baseC2=numTotal
        else
            v.c=v.c or 0;
        end
        v.c2=0;--总数
    end

    for _, v in pairs(sets) do
        local c=v.classMask--bit.bor(v.classMask);
        if c then
            if Save.Class[c] then
                if v.collected and Save.Class[c].class==e.Player.class then
                    Save.Class[c].c=Save.Class[c].c +1;
                end
                Save.Class[c].c2=Save.Class[c].c2 and Save.Class[c].c2+1;
            end
        end

        if v.requiredFaction=='Alliance' then
            a=a+1;
        elseif v.requiredFaction=='Horde' then
            h=h+1
        else
            o=o+1
        end
    end

    local frame2=WardrobeCollectionFrame;
    if not frame2 then return end
    local frame=frame2.SetsCollectionFrame.DetailsFrame;
    if not Save.disabledWardrobe then
        local m=LFG_LIST_CROSS_FACTION:format(CLASS).. '\n';
        local m2='';
        local c1,c2=0,0;
        for _, v in pairs(Save.Class) do
            local col= '|c'..(select(4,GetClassColor(v.class)) or 'ffffffff');
            local class='|A:classicon-'..v.class..':0:0|a';
            m=m..col..(v.c>0 and v.c..'/' or '')..Val(v.c2)..'|r '..class..'\n'

            if v.baseC and v.baseC2 then
                m2=m2..'\n'..class..col..' '..v.baseC.. '/'..v.baseC2..' '..('%i%%'):format(v.baseC/v.baseC2*100)..'|r';
                c1=v.baseC+c1;
                c2=v.baseC2+c2;
            end
        end
        m=m..'\n'..' '..FACTION;
        m=m..'\n'..h..' |A:communities-create-button-wow-horde:0:0|a';
        m=m..'\n'..a..' |A:communities-create-button-wow-alliance:0:0|a';
        m=m..'\n'..o..' |A:communities-guildbanner-background:0:0|a';
        m=m..'\n\n'..#sets..' '..WARDROBE_SETS;
        if not frame.str2 then
            frame.str2=frame:CreateFontString(nil, 'OVERLAY');
            frame.str2:SetFontObject('GameFontNormal');
            frame.str2:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -5, -135);
            frame.str2:SetJustifyH('RIGHT');
        end
        frame.str2:SetText(m)

        if not frame.str3 then
            frame.str3=frame:CreateFontString(nil, 'OVERLAY');
            frame.str3:SetFontObject('GameFontNormal');
            frame.str3:SetPoint('TOPLEFT', frame, 'TOPLEFT', 5, -135);
            frame.str3:SetJustifyH('LEFT');
        end
        m2=COLLECTED..' '..c1..'/'..c2..' '..('%i%%'):format(c1/c2*100)..m2;
        frame.str3:SetText(m2);
    else
        if frame.str3 then frame.str3:SetText('') end
        if frame.str2 then frame.str2:SetText('') end
    end
end


hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(self, transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
        if not self or not self.Name or not self.item or not name then return end        
        local link=self.item:GetItemLink();
        if link then
            local t='';

            local s=select(4,GetItemInfoInstant(link));            
            if s and _G[s] then t='|cffffd000('.._G[s]..')|r '  end

            if isHiddenVisual then
                t=t..HIDE;
            else
                if slotState == 3 then
                    t=t..link..' |cffff0000'..NOT_COLLECTED..'|r';
                else 
                    t=t..name;
                end
            end

            if t~=name and t~=''then self.Name:SetText(t) end
        end
end);

hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)--试衣间
        if not self.item then return end
        local link=self.item:GetItemLink();
        if not link then return end

        tips:SetHyperlink(link,nil, nil, nil, true);

        if self.isHiddenVisual then return end
        local frame2=WardrobeCollectionFrame;
        if not frame2 then return end

        local frame= frame2.ItemsCollectionFrame;
        if not frame or not frame:IsShown() then return end

        local box=WardrobeCollectionFrameSearchBox
        --   if self and self.slotState~=3 then            
        local name=C_Item.GetItemNameByID(link);
        if not name or not box then return end

        box:SetText(name)
        local id=GetItemInfoInstant(link)
        if id then
            local _, sourceId = C_TransmogCollection.GetItemInfo(id);
            if sourceId then
                local category = C_TransmogCollection.GetAppearanceSourceInfo(sourceId)
                if ( category and frame:GetActiveCategory() ~= category ) then
                    frame:SetActiveCategory(category);
                end
            end
        end
        --local button=frame2.SlotsFrame.Buttons[self.slotID]                    
end)--DressUpFrames.lua


local Collected= function(setID)
    local info=C_TransmogSets.GetSetPrimaryAppearances(setID);
    local n,to=0,0;
    for _,v in pairs(info) do
        to=to+1;
        if v.collected then n=n+1 end;
    end;
    if to>0 then
        if n==to then
            return ' |A:transmog-icon-checkmark:6:6|a ', true, to;
        else
            return to <=9 and e.Icon.number:format(to-n) or to-n, false, to;
        end
    end
end
local function Sort(a, b)
    return a.uiOrder < b.uiOrder;
end
local function setSets(button, displayData)
    local setID=displayData.setID    
    local frame=WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame;

    local sets = C_TransmogSets.GetVariantSets(setID)
    if sets and type(sets)=='table' then
        table.insert(sets, C_TransmogSets.GetSetInfo(setID));
        table.sort(sets, Sort);
        local m='';
        local b='';
        local ver, Num, Limited;
        for k,v in pairs(sets) do
            local t, ok, to=Collected(v.setID);
            Num=to;
            if t then
                if k==1 then                                
                    m=m..v.name;
                    if v.label then m=m..'\n|cffffffff'..v.label..'|r' end--
                    if v.expansionID and _G['EXPANSION_NAME'..v.expansionID] then--版本
                        ver='|cff00ff00'.._G['EXPANSION_NAME'..v.expansionID]..'|r';
                        m=m..'\n'..ver;
                        if ver3~=v.expansionID then 
                            ver2=true;
                            ver3=v.expansionID;
                        else
                            ver2=nil;
                        end--版本图标提示
                        
                        if v.patchID then m=m..' toc v.'..v.patchID end
                    end
                    m=m..'\n';
                end;
                m=m..'\n';
                m=m..t;
                if v.description or v.name then--套装名称
                    if ok==false then
                        m=m..' '..RED_FONT_COLOR_CODE..(v.description or v.name)..'|r';
                    else
                        m=m..' '..(v.description or v.name);
                    end
                    if v.limitedTimeSet then--限时
                        m=m..'|A:'..clock..':0:0|a|cffff00ff'..TRANSMOG_SET_LIMITED_TIME_SET..'|r';
                        Limited=true;
                    end
                end
                m=m..' setID: '..v.setID..'|r';
                if b~='' then b=b..'  ' end
                b =b..'|r'..t;
            end
        end
        button:SetScript("OnEnter",function(self2)
                if Save.disabledWardrobe then
                    tips:SetOwner(self2, "ANCHOR_RIGHT");
                else
                    tips:SetOwner(WardrobeCollectionFrame, "ANCHOR_RIGHT",8,-300);
                end
                tips:ClearLines();
                tips:SetText(m);
                tips:Show();
        end);
        button:SetScript("OnLeave",function()
                tips:Hide();
        end)
        if button.Label then button.Label:SetText(b) end;
        button.tips=m
        --[[  button:SetScript("OnClick",function()
                if not Save.disabledWardrobe then
                    if not frame.str then
                        frame.str=frame:CreateFontString(nil, 'OVERLAY');
                        frame.str:SetFontObject('GameFontNormal');
                        frame.str:SetPoint('BOTTOMLEFT', 6, 60);
                        frame.str:SetJustifyH('LEFT');
                    end                            
                    local t=m:gsub('(.+\n\n)', '');
                    t=t:gsub('(setID: %d+)', '');
                    frame.str:SetText(t..(ver and '|n|n'..ver or ''));
                else
                    
                    if frame.str then frame.str:SetText('') end
                end
        end);]]

        if not button.tex then--套装数量
            button.tex=button:CreateTexture();
            button.tex:SetPoint('RIGHT',0, 0);
            button.tex:SetSize(18,18);
        end
        if Num and Num<10 then
            button.tex:SetAtlas('services-number-'..Num);
        else
            button.tex:SetTexture('');
        end
        
        if Limited and not button.tex2 then--套装数量
                button.tex2=button:CreateTexture(nil, 'OVERLAY');
                button.tex2:SetPoint('TOPRIGHT',0,0);
                button.tex2:SetSize(15,12);
                button.tex2:SetAtlas(clock);
        end
        if button.tex2 then button.tex2:SetShown(Limited) end
        
        if ver and ver2 then
            if not button.str then
                button.str=button:CreateFontString();
                button.str:SetFontObject('GameFontGreenSmall');
                button.str:SetPoint('BOTTOMRIGHT',0,3);
                button.str:SetTextScale(0.80);
            end
            button.str:SetText(ver);
        else
            if button.str then button.str:SetText('') end
        end
    end
end
local function setSetsOnClick(button, buttonName, down)
    local frame=WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
    if not button.tips or Save.disabledWardrobe or buttonName ~= "RightButton" then
        if frame.str then frame.str:SetText('') end
        return
    end
    if not frame.str then
        frame.str=frame:CreateFontString(nil, 'OVERLAY');
        frame.str:SetFontObject('GameFontNormal');
        frame.str:SetPoint('BOTTOMLEFT', 6, 60);
        frame.str:SetJustifyH('LEFT');
    end
    local t=button.tips:gsub('(.+\n\n)', '');
    t=t:gsub('(setID: %d+)', '');
    frame.str:SetText(t..(ver and '|n|n'..ver or ''));
end

local function itemLink(self, index2)--套装 物品 提示
    local sourceInfo = C_TransmogCollection.GetSourceInfo(self.sourceID);
    local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType);
    local sources = C_TransmogSets.GetSourcesForSlot(self:GetParent():GetParent():GetSelectedSetID(), slot);
    if ( #sources == 0 ) then
        tinsert(sources, sourceInfo);
    end
    CollectionWardrobeUtil.SortSources(sources, sourceInfo.visualID, self.sourceID);
    local index = CollectionWardrobeUtil.GetValidIndexForNumSources(index2, #sources);
    local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
    return link;
end
local function BTN(self, btn, link)
    if link then
        if not self[btn] then
            self[btn]=CreateFrame("Button", nil, self);
            if btn=='btn' then
                self[btn]:SetPoint('BOTTOM', self, 'TOP', 0 ,1);
            else
                self[btn]:SetPoint('TOP', self, 'BOTTOM', 0 ,-1);
            end
            local w=self:GetWidth();
            self[btn]:SetSize(w,10);
            self[btn]:SetHighlightAtlas('Forge-ColorSwatchSelection');
            self[btn]:SetNormalAtlas('adventure-missionend-line');
            self[btn]:SetAlpha(0.3);
        end
        self[btn]:SetScript("OnEnter",function(self2)
                if not link and not self.itemID then return end
                self2:SetAlpha(1);
                tips:ClearLines();
                tips:SetOwner(self2, "ANCHOR_RIGHT");
                if link then
                    tips:SetHyperlink(link);
                else
                    tips:SetItemByID(self.itemID)
                end
                tips:Show();
        end);
        self[btn]:SetScript("OnMouseDown", function()
                if ( link ) then
                    local chat=SELECTED_DOCK_FRAME;
                    ChatFrame_OpenChat((chat.editBox:GetText() or '')..link, chat);
                end
        end)
        self[btn]:SetScript("OnLeave",function(self2)
                self2:SetAlpha(0.3);
                tips:Hide();
        end);
        if not self[btn]:IsShown()  then self[btn]:Show() end
    else
        if self[btn] and self[btn]:IsShown()  then self[btn]:Hide() end
    end
end

local function InitWardrobe()
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', setSets)--列表
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'OnClick', setSetsOnClick)--列表

    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', function(self, itemFrame)
            local link, link2=itemLink(itemFrame, 1), itemLink(itemFrame, 2)
            BTN(itemFrame, 'btn', link);

            if link==link2 then
                BTN(itemFrame, 'btn2', nil);
            else
                BTN(itemFrame, 'btn2', link2);
            end
    end);--Blizzard_Wardrobe.lua
end

--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
            end)
            setWardrobe()--专属
    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then        
        local frame=WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame;
        frame.sel = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate");--隐藏选项
        frame.sel:SetPoint('TOPLEFT',2,-20);
        frame.sel:SetChecked(Save.disabledWardrobe);
        frame.sel.Text:SetText(DISABLE);
        frame.sel:SetScript("OnClick", function ()
                if Save.disabledWardrobe then
                    Save.disabledWardrobe=nil;
                else
                    Save.disabledWardrobe=true;
                    if frame.str then frame.str:SetText('') end
                end
                setWardrobe();
                print(id,addName,e.GetEnabeleDisable(not Save.disabledWardrobe),'/reload')
        end);
        setWardrobe();
        InitWardrobe()
    end
end)

