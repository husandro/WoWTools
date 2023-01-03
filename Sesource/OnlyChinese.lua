local id, e= ...
if e.Player.zh then
    return
end
local addName= 'OnlyChinese'
local Save={disabled== select(2, BNGetInfo())~='SandroChina#2690'}

local panel = CreateFrame("FRAME");
panel.parent =id
panel.panel = addName
InterfaceOptions_AddCategory(panel)

--####
--初始
--####
local function Init()
    local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check.Text:SetText(addName)
    check:SetChecked(e.onlyChinse)
    check:SetPoint('TOPLEFT')
    check:SetScript('OnMouseDown',function()
        e.onlyChinse= not e.onlyChinse and true or nil
        Save.disabled= not e.onlyChinse
        print(id, addName, e.GetEnabeleDisable(e.onlyChinse), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
    end)
    check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(LANGUAGE..'('..SHOW..')', LFG_LIST_LANGUAGE_ZHCN)
        e.tips:Show()
    end)
    check:SetScript('OnLeave', function() e.tips:Hide() end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            e.onlyChinse= not Save.disabled
            Init()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)