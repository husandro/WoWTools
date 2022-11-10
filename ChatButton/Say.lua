local id, e = ...

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function setType(text)--使用,提示
    if not panel.typeText then
        panel.typeText=e.Cstr(panel, 10, nil, nil, true)
        panel.typeText:SetPoint('BOTTOM',0,2)
    end
    if panel.type and text:find('%w') then--处理英文
        text=panel.type:gsub('/','')
    else
        text=e.WA_Utf8Sub(text, 1)
    end
    
    panel.typeText:SetText(text)
    panel.typeText:SetShown(IsInGroup())
end
--#####
--主菜单
--#####
local chatType={
    {text= SAY, type= SLASH_SAY1},--/s
    {text= YELL, type= 	SLASH_YELL1},--/p
}
local function InitMenu(self, level, type)--主菜单

    local info
    for _, tab in pairs(chatType) do
        info={
            text=tab.text,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=tab.type,
            func=function()
                e.Say(tab.type)
                panel.type=tab.type
                setType(tab.text)--使用,提示
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end
--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')


    panel.type=SLASH_SAY1
    setType(SAY)--使用,提示
    

    panel.texture:SetAtlas('PlayerPartyBlip')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and panel.type then
            e.Say(panel.type)
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:SetShown(false)
            panel:UnregisterAllEvents()
        else
            Init()
        end
    end
end)