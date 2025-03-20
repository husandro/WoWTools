
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end







local function Create_Texture_Tips(btn, data)--atlas, coord)
    if not btn then
        return
    end
    if data and not btn.Texture then
        btn.Texture= btn:CreateTexture(nil, 'BORDER')
        btn.Texture:SetSize(26, 26)--200, 36
        btn.Texture:SetPoint('RIGHT', btn, 'LEFT', 6,0)
        --btn.Texture:SetPoint('LEFT', btn, 'RIGHT', -6,0)
    end
    if btn.Texture then
        if data and data[1] then
            btn.Texture:SetAtlas(data[1])
        else
            btn.Texture:SetTexture(nil)
        end
        if data and data[2] then
            btn.Texture:SetTexCoord(1,0,1,0)
        end
    end

    local font= btn:GetFontString()
    local r, g, b
    if data and data[3] then
        r, g, b= data[3][1], data[3][2], data[3][3]
    elseif data then
        r, g, b= 1, 1, 1
    end
    font:SetTextColor(r or 1, g or 0.82, b or 0)

end


--添加 RELOAD 按钮
local function Init_Add_Reload_Button()
    if Save().not_Add_Reload_Button or SettingsPanel.AddOnsTab.reload then
        if SettingsPanel.AddOnsTab.reload then
            SettingsPanel.AddOnsTab.reload:SetShown(not Save().not_Add_Reload_Button)
        end
        return
    end

    --for _, frame in pairs({SettingsPanel.AddOnsTab}) do
        local frame= SettingsPanel.AddOnsTab
        if frame then
            frame.reload= CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
            frame.reload:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
            frame.reload:SetScript('OnLeave', GameTooltip_Hide)
            frame.reload:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_HyperLink.addName)
                GameTooltip:AddDoubleLine(e.onlyChinese and '重新加载UI' or RELOADUI, '|cnGREEN_FONT_COLOR:'..SLASH_RELOAD1)
                GameTooltip:Show()
            end)
            frame.reload:SetScript('OnClick', function() WoWTools_Mixin:Reload() end)
            Create_Texture_Tips(frame.reload, 'BattleBar-SwapPetIcon')
        end
    --end


    SettingsPanel.AddOnsTab.reload:SetPoint('RIGHT', SettingsPanel.ApplyButton, 'LEFT', -15,0)
    WoWTools_LabelMixin:Create(nil, {changeFont= SettingsPanel.OutputText, size=14})
    SettingsPanel.OutputText:ClearAllPoints()
    SettingsPanel.OutputText:SetPoint('BOTTOMLEFT', 20, 18)




--Blizzard_GameMenu/Standard/GameMenuFrame.lua
        local dataButton={--layoutIndex
            [GAMEMENU_OPTIONS]= {'mechagon-projects', false},--选项
            [HUD_EDIT_MODE_MENU]= {'UI-HUD-Minimap-CraftingOrder-Up', false},--编辑模式
            [MACROS]= {'NPE_Icon', false},--宏命令设置

            [ADDONS]= {'dressingroom-button-appearancelist-up', false},--插件
            [LOG_OUT]= {'perks-warning-large', false, {0,0.8,1}},--登出
            [EXIT_GAME]= {'Ping_Chat_Warning', false, {0,0.8,1}},--退出游戏
            [RETURN_TO_GAME]= {'poi-traveldirections-arrow', true, {0,1,0}},--返回游戏
        }
        hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
            for btn in self.buttonPool:EnumerateActive() do
                local data= dataButton[btn:GetText()]
                Create_Texture_Tips(btn, data)
            end

            self:AddSection()

            local btn = self:AddButton(e.onlyChinese and '重新加载UI' or RELOADUI, function()
                WoWTools_Mixin:Reload()
            end)
            Create_Texture_Tips(btn, {'BattleBar-SwapPetIcon', false, {1,1,1}})
        end)
    end


