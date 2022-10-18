local id, e = ...
local Save
local addName=UNWRAP..ITEMS
local Combat
local function clearAll()
    Save={use={}, no={}, pet=true, open=true, toy=true, mount=true, mago=true, ski=true, alt=true};
end
clearAll()

local panel= CreateFrame("Button", nil, CharacterReagentBag0Slot, "SecureActionButtonTemplate")
panel:SetSize(30,30)
panel:EnableMouseWheel(true)
panel:RegisterForDrag("RightButton");
panel:RegisterForClicks("LeftButtonDown");
panel:SetMovable(true);
panel:SetClampedToScreen(true);
panel:SetNormalAtlas('bag-reagent-border-empty')
panel:SetHighlightAtlas('bag-border');
panel:SetPushedAtlas('bag-border-highlight')
panel.texture=panel:CreateTexture(nil,'ARTWORK')
panel.texture:SetPoint('CENTER')
panel.texture:SetSize(20,20)
panel.texture:SetAtlas('bag-border')
panel.mask= panel:CreateMaskTexture(nil, 'OVERLAY')
panel.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
panel.mask:SetAllPoints(panel.texture)
panel.texture:AddMaskTexture(panel.mask)
panel.texture:SetShown(false)

local getTip=function(link,bag, slot)
    e.Tips =e.Tips or CreateFrame("GameTooltip", "ScannerTooltip", e.region, "GameTooltipTemplate");
    e.Tips:SetOwner(e.region, "ANCHOR_NONE")
    e.Tips:SetBagItem(bag,slot);
    for n=1, e.Tips:NumLines() do
        local line=_G['ScannerTooltipTextLeft'..n];
        if line then
            local rgb=e.HEX(line:GetTextColor());
            if rgb=='fefe1f1f' or rgb=='fefe7f3f' then
                return
            end
        end

        line=_G['ScannerTooltipTextRight'..n];
        if line and line:GetText() then
            local rgb=e.HEX(line:GetTextColor());
            if rgb=='fefe1f1f' or rgb=='fefe7f3f' then
                return;
            end
        end
    end
    return true;
end


local function setAtt(itemID, link, bag, slot, icon)
    if UnitAffectingCombat('player') then
        Combat=true
        return
    end
    local m='/use '..bag..' '..slot;
    Bag={id=itemID, link=link, bag=bag, slot=slot, icon=icon};
    if panel:GetAttribute('macrotext')~=m then
        panel:SetAttribute("type", "macro");
        panel:SetAttribute("macrotext", m);
    end
end

local function getItems()
    Bag=nil;
    if UnitAffectingCombat('player') then
        Combat=true
        return
    end
    for bag=0, NUM_BAG_SLOTS do 
        for slot=1,GetContainerNumSlots(bag) do             
            local icon, _, locked, quality, _, lootable, link, _, _, id = GetContainerItemInfo(bag, slot)
            if id and link and  not locked and not Save.no[link] then-- and not e.T3[link] and not e.T3[id] then
                local classID, subclassID = select(6, GetItemInfoInstant(link));
                
                --[[local zhu=(e.T2[link] or e.T2[id]);
                if zhu and GetItemCount(link)>=zhu then--组合物品
                     setAtt(id, link, bag, slot, icon) 
                    return
                    
                elseif Save.use[link] or e.T[link] or e.T[id] then--指定使用
                     setAtt(id, link, bag, slot, icon)
                    return
                    
                else]]
                    if link:find("Hbattlepet:(%d+)") or (classID==15 and  subclassID==2) then--PET
                    if Save.pet then
                        local sid;
                        if (classID==15 and  subclassID==2) then 
                            sid=select(13,C_PetJournal.GetPetInfoByItemID(id));
                        else
                            sid= link:match("Hbattlepet:(%d+)");
                        end                        
                        if sid then
                            local numCollected, limit = C_PetJournal.GetNumCollectedInfo(sid)--已收集数量
                            if numCollected and limit and numCollected <  limit then 
                                 setAtt(id, link, bag, slot, icon)
                                return
                            end
                        end                        
                    end
                    
                elseif id==187187 then--刻希亚军械
                    local avgItemLevel= GetAverageItemLevel();
                    if avgItemLevel<=190 then
                         setAtt(id, link, bag, slot, icon) return true;                                 
                    end
                    
                elseif quality and quality > 0 and classID and subclassID then
                    
                    
                    if classID==9 and subclassID and subclassID >0 then--配方                    
                        if Save.ski and getTip(link, bag, slot) then 
                             setAtt(id, link, bag, slot, icon) 
                            return
                        end
                        
                    elseif lootable then--可打开
                        if Save.open then
                            if (not quality or (quality and quality <=4)) and getTip(link, bag, slot) then                            
                                 setAtt(id, link, bag, slot, icon) 
                                return
                            end                        
                        end
                        
                    elseif classID==15 and  subclassID==5 then--坐骑
                        if Save.mount then
                            local mountID = C_MountJournal.GetMountFromItem(id);
                            if mountID then 
                                local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID));
                                if not isCollected then                                                    
                                     setAtt(id, link, bag, slot, icon) 
                                    return
                                end                                
                            end
                        end
                        
                    elseif (classID==2 or classID==4 ) then
                        if Save.mago then                            
                            if  quality>1 and not  C_TransmogCollection.PlayerHasTransmog(id) then                                
                                local sourceID=select(2,C_TransmogCollection.GetItemInfo(link));
                                if sourceID then 
                                    local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
                                    if hasItemData and canCollect then
                                        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
                                        if sourceInfo and not sourceInfo.isCollected then
                                             setAtt(id, link, bag, slot, icon) 
                                            return
                                        end                                        
                                    end
                                end
                            end
                        end
                        
                    elseif classID==15 and subclassID==4 then
                        if Save.alt and IsUsableItem(link) and not  C_Item.IsAnimaItemByID(link)  then                            
                             setAtt(id, link, bag, slot, icon) 
                            return
                        end
                        
                    elseif C_ToyBox.GetToyInfo(id) and not PlayerHasToy(id) then--玩具 
                        if Save.toy then
                             setAtt(id, link, bag, slot, icon) 
                            return
                        end
                    end
                end
            end
        end
    end
end

panel.Me=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate");
UIDropDownMenu_Initialize(panel.Me, function(self, level, menuList)
        local no,use= 0, 0;
        for _, _ in pairs(Save.no) do no=no+1 end
        for _,_ in pairs(Save.use) do use=use+1 end
        local t=UIDropDownMenu_CreateInfo();

        if menuList=='NO' or  menuList=='USE' then
            t.text= SLASH_STOPWATCH_PARAM_STOP2..e.Icon.X2..ALL;--清除所有
            t.notCheckable=true;
            t.func=function() setClear() end
            UIDropDownMenu_AddButton(t,level);

            if menuList=='NO' then
                for k,_ in pairs(Save.no) do
                    t=UIDropDownMenu_CreateInfo();
                    local icon=C_Item.GetItemIconByID(k);
                    t.text=icon and '|T'..icon..':0|t'..k..e.Icon.O2 or k..e.Icon.O2;
                    t.notCheckable=true;
                    t.func=function()
                        Save.no[k]=nil
                        print('|cff00ff00'..REMOVE..':|r  '..t.text..DISABLE)
                        getItems()
                        CloseDropDownMenus() 
                    end
                    t.tooltipOnButton=true;
                    t.tooltipTitle=REMOVE;
                    UIDropDownMenu_AddButton(t,level);
                end
            else
                for k,_ in pairs(Save.use) do
                    t=UIDropDownMenu_CreateInfo();
                    local icon=C_Item.GetItemIconByID(k);
                    t.text=icon and '|T'..icon..':0|t'..k or k;
                    t.notCheckable=true;
                    t.text=t.text..e.Icon.select2;
                    t.func=function()
                        Save.use[k]=nil
                        print('|cff00ff00'..REMOVE..':|r  '..t.text..USE)
                        getItems()
                        CloseDropDownMenus()
                    end
                    t.tooltipOnButton=true;
                    t.tooltipTitle=REMOVE;
                    UIDropDownMenu_AddButton(t,level);
                end
            end
        else
            if Bag and Bag.link then
                t.text=Bag.link;
                t.icon=Bag.icon;
                t.isTitle=true;
                t.notCheckable=true;
                UIDropDownMenu_AddButton(t);

                t=UIDropDownMenu_CreateInfo(); --禁用使用                
                t.text= e.Icon.O2..DISABLE..'|A:newplayertutorial-icon-mouse-middlebutton:0:0|a /'..USE..e.Icon.select2;
                if not Bag or  not Bag.link then t.disabled=true end
                t.notCheckable=true;
                t.func=function() 
                    setUse(Bag.link) 
                    getItems()
                end
                t.tooltipOnButton=true;
                t.tooltipTitle='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a'..KEY_MOUSEWHEELUP..e.Icon.O2..DISABLE;
                UIDropDownMenu_AddButton(t);
                UIDropDownMenu_AddSeparator();

            else
                t.text=USE..'|A:newplayertutorial-drag-slotgreen:0:0|a'..ITEMS;
                t.isTitle=true;
                t.notCheckable=true;
                UIDropDownMenu_AddButton(t);
            end

            if no>0 then
                t=UIDropDownMenu_CreateInfo();--自定义禁用列表
                t.text= CUSTOM..e.Icon.O2..DISABLE..' #'..no
                t.notCheckable=1;
                t.menuList='NO';
                t.hasArrow=true
                UIDropDownMenu_AddButton(t);
            end
            if use>0 then
                t=UIDropDownMenu_CreateInfo();--自定义使用列表
                t.text= CUSTOM..e.Icon.select2..USE..' #'..use;
                t.notCheckable=1;
                t.menuList='USE';
                t.hasArrow=true
                UIDropDownMenu_AddButton(t);
            end
            if no>0 or use>0 then UIDropDownMenu_AddSeparator() end

            t=UIDropDownMenu_CreateInfo();
            t.text=ITEM_OPENABLE;
            if Save.open then t.checked=true end
            t.func=function()
                if Save.open then
                    Save.open=false
                else
                    Save.open=true
                end
                getItems()
                --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=PET;
            if Save.pet then t.checked=true end
            t.func=function()
                if Save.pet then
                    Save.pet=false
                else
                    Save.pet=true
                end
                getItems()
                --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=TOY;
            if Save.toy then t.checked=true end
            t.func=function()
                if Save.toy then
                    Save.toy=false
                else
                    Save.toy=true
                end
                getItems()
                --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=MOUNTS;
            t.checked=Save.mount
            t.func=function()
                if Save.mount then
                    Save.mount=false
                else
                    Save.mount=true
                end
                getItems()
                --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=TRANSMOGRIFY;
            if Save.mago then t.checked=true end
            t.func=function()
                if Save.mago then
                    Save.mago=false
                else
                    Save.mago=true
                end
                getItems()
                --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=TRADESKILL_SERVICE_LEARN;
            if Save.ski then t.checked=true end
            t.func=function()
                if Save.ski then
                    Save.ski=false
                else
                    Save.ski=true
                end
                getItems()
                -- WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();
            t.text=BINDING_HEADER_OTHER;
            if Save.alt then t.checked=true end
            t.func=function()
                if Save.alt then
                    Save.alt=false
                else
                    Save.alt=true
                end
                getItems()
                --WeakAuras.ScanEvents('ENV_Open_Item');
            end
            UIDropDownMenu_AddButton(t);

            if no==0 and use==0 then
                UIDropDownMenu_AddSeparator();
                t=UIDropDownMenu_CreateInfo();
                t.text=DRAG_MODEL..'|A:newplayertutorial-drag-cursor:0:0|a'..ITEMS;
                t.isTitle=true;
                t.notCheckable=true;
                UIDropDownMenu_AddButton(t);
            end

            UIDropDownMenu_AddSeparator(); --清除所有数据
            t=UIDropDownMenu_CreateInfo();
            t.text=RED_FONT_COLOR_CODE..RESET;
            t.tooltipOnButton=true;
            t.notCheckable=true;
            t.tooltipTitle=CLEAR_ALL..'('..    SAVE..')';
            t.func=function()
                clearAll()
                print(id, addName, CLEAR_ALL, '|cff00ff00' ..DONE..'|r')
                getItems()
            end
            UIDropDownMenu_AddButton(t);

            t=UIDropDownMenu_CreateInfo();--还原位置
            t.text=RRESET_POSITION or HUD_EDIT_MODE_RESET_POSITION;
            t.func=function()
                Save.Point=nil;
                panel:ClearAllPoints();
                panel:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT')
            end
            t.tooltipOnButton=true;
            t.notCheckable=true;
            t.tooltipTitle='Alt +'..e.Icon.right..' '..NPE_MOVE
            UIDropDownMenu_AddButton(t);
        end
end, 'MENU');

panel:SetScript("OnEnter",function(self, d)
    local link=select(3,GetCursorInfo());
    if link then setUse(link) ClearCursor() return end

    

    if not (Bag and Bag.bag and Bag.slot) then return end
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:ClearLines();
    GameTooltip:SetBagItem(Bag.bag, Bag.slot);
    GameTooltip:Show();
end);
panel:SetScript("OnLeave",function()
    GameTooltip:Hide();
    ResetCursor();
end)
panel:SetScript("OnMouseDown", function(self,d)
    if d=='RightButton' and IsAltKeyDown() then
        SetCursor('UI_MOVE_CURSOR');
    elseif d=='RightButton' and not IsModifierKeyDown() then
        ToggleDropDownMenu(1,nil,panel.Me,self,self:GetWidth(),0);
    end
end);

panel:SetScript("OnDragStart", function(self,d )
    if IsAltKeyDown() and d=='RightButton' then
        self:StartMoving()
    end
end);
panel:SetScript("OnDragStop", function(self)
    ResetCursor();
    self:StopMovingOrSizing();
    Save.Point={self:GetPoint(1)};
end);
panel:SetScript("OnMouseUp", function(self,d)
    ResetCursor();
end);

panel:SetScript('OnMouseWheel',function(self,d)
    if d == 1 and not IsModifierKeyDown() then
        if Bag and Bag.link then
            local link,icon=Bag.link, (Bag.icon and '|T'..Bag.icon..':0|t' or '');
            Save.no[link]=true Save.use[link]=nil
            --WeakAurasSaved[e.id..'Save']=Save WeakAuras.ScanEvents('ENV_Open_Item') 
            print(id, addName, e.Icon.O2..'|cnRED_FONT_COLOR:'..DISABLE..'|r', link);
        end
    end
end)


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('BAG_UPDATE_DELAYED')

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save

            local p=Save.Point;
            if p and p[1] and p[3] and p[4] and p[5] then
                self:SetPoint(p[1],  UIParent, p[3], p[4], p[5]);
            else
                self:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT')
            end;
            getItems()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
            getItems()
    elseif event=='PLAYER_REGEN_DISABLED' then
        panel:SetShown(false)

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel:SetShown(true)
        if Combat then
            getItems()
        end
    end
end)
