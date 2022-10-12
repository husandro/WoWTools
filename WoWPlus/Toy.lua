local id, e = ...
local addName = TOY
local Save = {}

--玩具,是不可用Blizzard_ToyBox.lua
local function Init()
    local function ToyFun(self)
        if Save.disabledToy then
           --[[ if self.notUasble then
                self.notUasble:SetShown(false)
            end]]
            self:SetAlpha(1)
            return
        end
        local has=PlayerHasToy(self.itemID)
        local isUas=C_ToyBox.IsToyUsable(self.itemID)
      --[[if not isUas and not self.notUasble then
            self.notUasble=self:CreateTexture(nil, 'OVERLAY')
            self.notUasble:SetPoint('TOPRIGHT', -4, -4)
            self.notUasble:SetSize(20,20)
            self.notUasble:SetAtlas(e.Icon.disabled)
        end
        if self.notUasble then
            self.notUasble:SetShown(not isUas)
        end]]
        local _, duration, enable = GetItemCooldown(self.itemID)
        if not isUas then
            self:SetAlpha(0.1)
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
    toyframe.sel=e.Cbtn(toyframe, nil, not Save.disabledToy)
    toyframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    toyframe.sel:SetSize(18,18)
    toyframe.sel:SetAlpha(0.5)
    toyframe.sel:SetScript('OnClick',function (self2)
        if Save.disabledToy then
            Save.disabledToy=nil
        else
            Save.disabledToy=true
        end
        print(id, addName,e.GetEnabeleDisable(not Save.disabledToy))
        self2:SetNormalAtlas(Save.disabledToy and e.Icon.disabled or e.Icon.icon)
    end)
    toyframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabledToy), e.Icon.left)
        e.tips:Show()
    end)
    toyframe.sel:SetScript('OnLeave', function ()
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
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        Init()
    end
end)