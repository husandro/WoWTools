local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={items={}}

local panel=e.Cbtn2(nil, WoWToolsMountButton, true, nil)
panel:SetAttribute("type", "item")
panel.itemID=5512--治疗石
if not C_Item.IsItemDataCachedByID(panel.itemID) then C_Item.RequestLoadItemDataByID(panel.itemID) end

--#######
--图标冷却
--#######
local function set_Cooldown(self)--图标冷却
    if self.itemID then
        local start, duration = GetItemCooldown(self.itemID)
        e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
    end
end

local function set_Item_Count(self)
    self.count:SetText(GetItemCount(self.itemID))
    self.texture:SetDesaturated(self.count==0)
end

--#########
--提示, 事件
--#########
local function set_Button_Init(self)
    self:SetScript("OnEnter",function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self2.itemID)
        if self==panel then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        end
        e.tips:Show()
    end)
    self:SetScript("OnLeave",function() e.tips:Hide() end)

    self.count= e.Cstr(self,nil, nil,nil, true)
    self:RegisterEvent('BAG_UPDATE_DELAYED')
    self:RegisterEvent('BAG_UPDATE_COOLDOWN')
    if self~=panel then
        panel:SetScript("OnEvent", function(self2, event)
           if event=='BAG_UPDATE_DELAYED' then
                set_Item_Count(self2)
            elseif event=='BAG_UPDATE_COOLDOWN' then
                set_Cooldown(self2)--图标冷却
            end
        end)
    end

    set_Item_Count(self2)
    set_Cooldown(self)--图标冷却
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单

end

--####
--初始
--####
local function Init()
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('RIGHT', WoWToolsOpenItemsButton, 'LEFT')
    end
    local size=e.toolsFrame.size or 30
    panel:SetSize(size,size)
    panel:SetAttribute("item", C_Item.GetItemNameByID(panel.itemID))
    set_Button_Init(panel)--提示, 事件
    

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetScript("OnDragStart", function(self,d )
        self:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)
    panel:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Item_Count(self)

    elseif event=='BAG_UPDATE_COOLDOWN' then
        set_Cooldown(self)--图标冷却
    end
end)