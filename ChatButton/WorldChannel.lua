local id, e =...
if not e.Player.zh then--仅限中文
    return
end
local Save={}
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel


--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info={
        text=ALL,
        func=function()
        end
    }
    UIDropDownMenu_AddButton(info, level)
    UIDropDownMenu_AddSeparator(level)
end
--####
--初始
--####
local function Init()  
    panel.texture:SetAtlas('WildBattlePetCapturable')

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown',function(self, d)
       
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
            return
        end
        Save= WoWToolsSave and WoWToolsSave[addName] or Save
        Init()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
