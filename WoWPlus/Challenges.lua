local id, e = ...
local addName= CHALLENGES
local Save= {}
local panel=CreateFrame("Frame")


local function getBagKey(self, point, x, y) --KEY链接
    local find=point:find('LEFT')    
    local i=1;
    for bagID=0, NUM_BAG_SLOTS do 
        for slotID=1,C_Container.GetContainerNumSlots(bagID) do
            local icon, itemLink, itemID 
            local info= C_Container.GetContainerItemInfo(bagID, slotID);
            if info then
                icon=info.iconFileID
                itemLink=info.hyperlink
                itemID= info.itemID
            end
            if itemID and itemLink and C_Item.IsItemKeystoneByID(itemID) then
                if not self['key'..i] then
                    self['key'..i] = CreateFrame("Button", nil, self);
                    self['key'..i]:SetHighlightAtlas('Forge-ColorSwatchSelection');
                    self['key'..i]:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');
                    self['key'..i]:SetSize(16, 16);                        
                    self['key'..i]:SetNormalTexture(icon);                    
                    self['key'..i].item=itemLink;
                    if i==1 then                        
                        self['key'..i]:SetPoint(point,x, y);
                    else
                        if find then
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPLEFT', 0, 0);
                        else
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPRIGHT', 0, 0);
                        end
                    end
                    self['key'..i]:SetScript("OnMouseDown",function(self2, d2)--发送链接
                            if d2=='LeftButton' then
                                e.Chat(self2.item);
                            else
                                if not ChatEdit_InsertLink(self2.item) then
                                    ChatFrame_OpenChat(self2.item);
                                end                                    
                            end                        
                    end);
                    self['key'..i]:SetScript("OnEnter",function(self2)
                            GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                            GameTooltip:ClearLines();
                            GameTooltip:SetHyperlink(self2.item);
                            GameTooltip:AddDoubleLine(SEND_MESSAGE, e.Icon.left);
                            GameTooltip:AddDoubleLine(COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.right);
                            GameTooltip:Show();
                    end)
                    self['key'..i]:SetScript("OnLeave",function()
                            GameTooltip:Hide();
                    end)
                    self['key'..i].bag=e.Cstr(self);
                    if point:find('LEFT') then
                        self['key'..i].bag:SetPoint('LEFT', self['key'..i], 'RIGHT', 0, 0);          
                    else
                        self['key'..i].bag:SetPoint('RIGHT', self['key'..i], 'LEFT', 0, 0);          
                    end
                    self['key'..i].bag:SetText(itemLink);
                end                
                i=i+1;
            end
        end
    end
end    

--##################
--挑战,钥石,插入,界面
--##################
local function Party(frame)--队友位置
    if IsInRaid() or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        frame.party:SetText('')
        return
    end
    
    local name, uiMapID=e.GetUnitMapName('player')
    local text
    for i=1, GetNumGroupMembers() do
        local unit='party'..i;
        if i==GetNumGroupMembers() then
            unit='player'
        end
        local guid=UnitGUID(unit)
        if guid then
            text= text and text..'\n' or ''

            local tab =e.GroupGuid[guid]--职责
            print(guid,unit,tab)
            if tab and tab.combatRole then
                text= text.. e.Icon[tab.combatRole]..text
                print( e.Icon[tab.combatRole])
            end
            tab= e.UnitItemLevel[guid]--装等
            if tab then
                if tab.itemLeve then
                    text= tab.itemLeve..text
                elseif CheckInteractDistance(unit, 1) then--取得装等
                    NotifyInspect(unit);
                end
            end
            text= text..e.GetPlayerInfo(nil, guid, true)
            name2, uiMapID2=e.GetUnitMapName(unit);
            if (name and name==name2) or (uiMapID and uiMapID==uiMapID2) then
                text=text..e.Icon.select2
            elseif name2 then
                text=text ..e.Icon.map2..name2
            end
        end            
    end
    frame.party:SetText(text or '')
end

local function set_Blizzard_ChallengesUI()--挑战,钥石,插入,界面
    local frame=ChallengesKeystoneFrame;
    
    frame.ready = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate');--就绪
    frame.ready:SetText(READY..e.Icon.select2);    
    frame.ready:SetPoint('LEFT', frame.StartButton, 'RIGHT',2, 0);    
    frame.ready:SetSize(100,24);
    frame.ready:SetScript("OnClick",function() 
            DoReadyCheck();
    end);
    
    frame.mark = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate');--标记
    frame.mark:SetText(e.Icon['TANK']..EVENTTRACE_MARKER..e.Icon['HEALER']);    
    frame.mark:SetPoint('RIGHT', frame.StartButton, 'LEFT',-2, 0);    
    frame.mark:SetSize(100,24);
    frame.mark:SetScript("OnClick",function()             
        local n=GetNumGroupMembers();
        for i=1,n  do
            local u='party'..i;
            if i==n then u='player' end
            if CanBeRaidTarget(u) then
                local r=UnitGroupRolesAssigned(u);
                local index=GetRaidTargetIndex(u);
                if r=='TANK' then
                    if index~=2 then SetRaidTarget(u, 2) end
                elseif r=='HEALER' then
                    if index~=1 then SetRaidTarget(u, 1) end
                else
                    if index and index>0 then SetRaidTarget(u, 0) end
                end
            end            
        end         
    end);
    
    frame.clear = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate');--清除KEY
    frame.clear:SetPoint('RIGHT', -15, -50);
    frame.clear:SetSize(70,24);
    frame.clear:SetText(CLEAR or KEY_NUMLOCK_MAC);
    frame.clear:SetScript("OnClick",function()             
            C_ChallengeMode.RemoveKeystone();            
            frame:Reset();
            ItemButtonUtil.CloseFilteredBags(frame)
            ClearCursor();
    end);
    
    frame.ins = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate');--插入
    frame.ins:SetPoint('BOTTOMRIGHT', frame.clear, 'TOPRIGHT', 0, 2);
    frame.ins:SetSize(70,24);
    frame.ins:SetText(COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN);
    frame.ins:SetScript("OnClick",function()
            ItemButtonUtil.OpenAndFilterBags(frame);
            if ItemButtonUtil.GetItemContext() == nil then return end
            for bagID=0, NUM_BAG_FRAMES do--ContainerFrame.lua
                local itemLocation = ItemLocation:CreateEmpty();
                for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
                    itemLocation:SetBagAndSlot(bagID, slotIndex);
                    if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
                        C_Container.UseContainerItem(bagID, slotIndex);
                        return;
                    end
                end
            end
            print(e.id..':|n'..CHALLENGE_MODE_KEYSTONE_NAME:format(RED_FONT_COLOR_CODE..TAXI_PATH_UNREACHABLE..'|r'));
    end);

    frame.party=e.Cstr(frame)--队伍信息
    frame.party:SetPoint('LEFT', 15, -50);    

    frame:HookScript('OnShow', function()
            getBagKey(frame, 'BOTTOMRIGHT', -15, 170);--KEY链接
            Party(frame);
    end);
    
    if frame.DungeonName then
        frame.DungeonName:ClearAllPoints();
        frame.DungeonName:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 15, 110)
        frame.DungeonName:SetJustifyH('LEFT');
    end
    if frame.TimeLimit then
        frame.TimeLimit:ClearAllPoints();
        frame.TimeLimit:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -15, 120)
        frame.TimeLimit:SetJustifyH('RIGHT')
    end
    
    
    hooksecurefunc(frame,'OnKeystoneSlotted',function()--插件KEY时, 说
            local mapID, affixes, powerLevel = C_ChallengeMode.GetSlottedKeystoneInfo();
            
            local name,_, timeLimit= C_ChallengeMode.GetMapUIInfo(mapID);
            local m=name..'('.. powerLevel..'): '
            for _,v in pairs(affixes) do 
                local name2=C_ChallengeMode.GetAffixInfo(v);
                if name2 then
                    m=m..name2..', '
                end 
            end
            m=m..SecondsToClock(timeLimit);
            e.Chat(m)
    end)

    local timeElapsed = 0
    frame:HookScript("OnUpdate", function (self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.8 then
            Party(frame)
            timeElapsed=0
        end
    end)
end
--####
--初始
--####
local function Init()

end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), '|cnGREEN_FONT_COLOR:'..REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ChallengesUI' then--挑战,钥石,插入界面
            set_Blizzard_ChallengesUI()--挑战,钥石,插入界面
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    
    end
end)