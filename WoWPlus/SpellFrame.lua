local id, e = ...
local addName= SPELLS..'Frame'
local Save={}

--######
--初始化
--######
local function Init()
    local Vstr=function(t)--垂直文字
        local len = select(2, t:gsub("[^\128-\193]", ""))
        if(len == #t) then
            return t:gsub(".", "%1\n")
        else
            return t:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1\n")
        end
    end
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self, reason)
            if self.spellID then
                local spellName = GetSpellInfo(self.spellID);
                local petName = select(2, GetCallPetSpellInfo(self.spellID));
                if petName=='' then petName=nil end

                local text=petName or spellName;
                if text then
                    if not self.Text then
                        self.Text=e.Cstr(self);
                    else
                        self.Text:ClearAllPoints();
                    end
                    text=text:match('%-(.+)') or text
                    text=text:match('：(.+)') or text
                    text=text:match(':(.+)') or text
                    text=text:gsub(' %d','')
                    text=text:gsub(SUMMONS,'');
                    local p=self:GetPoint(1);
                    if p=='TOP' or p=='BOTTOM' then
                        self.Text:SetPoint('RIGHT', self, 'LEFT', -2, 0);
                    else
                        self.Text:SetPoint('BOTTOM', self, 'TOP', 0, 4);
                        text=Vstr(text);
                    end
                    self.Text:SetText(text);
                    return
                end
            end
            if self.Text then self.TextSetText('') end
    end)
                    
    hooksecurefunc('ActionButton_UpdateRangeIndicator', function(self, checksRange, inRange)--ActionButton.lua
        if checksRange then
            if not inRange then
                self.icon:SetVertexColor(RED_FONT_COLOR:GetRGB());
            elseif self.action then
                local isUsable, notEnoughMana = IsUsableAction(self.action);
                if ( isUsable ) then
                    self.icon:SetVertexColor(1.0, 1.0, 1.0);
                elseif ( notEnoughMana ) then
                    self.icon:SetVertexColor(0.5, 0.5, 1.0);
                else
                    self.icon:SetVertexColor(0.4, 0.4, 0.4);
                end
            end
        end
    end)
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '法术Frame' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(e.onlyChinse and '法术距离' or SPELLS..TRACKER_SORT_PROXIMITY, e.onlyChinse and '颜色' or COLOR)
                e.tips:AddDoubleLine(e.onlyChinse and '法术弹出框' or SPELLS..' Flyout', e.onlyChinse and '名称' or LFG_LIST_TITLE)
                e.tips:Show();
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
