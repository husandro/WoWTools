local id, e = ...
local addName = HEIRLOOMS
local Save = {}

--传家宝Blizzard_HeirloomCollection.lua
local function Init()
    hooksecurefunc( HeirloomsJournal, 'UpdateButton', function(self, button)
        if Save.disabledHeirloom then
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
    Heirloomframe.sel=e.Cbtn(Heirloomframe, nil, not Save.disabledHeirloom)
    Heirloomframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    Heirloomframe.sel:SetSize(18,18)
    Heirloomframe.sel:SetAlpha(0.5)
    Heirloomframe.sel:SetScript('OnClick',function (self2)
        if Save.disabledHeirloom then
            Save.disabledHeirloom=nil
        else
            Save.disabledHeirloom=true
        end
        print(id, HEIRLOOMS, e.GetEnabeleDisable(not Save.disabledHeirloom))
        self2:SetNormalAtlas(Save.disabledHeirloom and e.Icon.disabled or e.Icon.icon)
    end)
    Heirloomframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, HEIRLOOMS)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabledHeirloom), e.Icon.left)
        e.tips:Show()
    end)
    Heirloomframe.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
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

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        Init()
    end
end)