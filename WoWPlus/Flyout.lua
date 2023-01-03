local id, e = ...
local addName= SPELLS..'Flyout'
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
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
                Init()
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
