local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={items={}}

local panel=e.Cbtn2(nil, WoWToolsMountButton, true, nil)
panel:SetAttribute("type", "item")
panel.itemID=5512--治疗石
if not C_Item.IsItemDataCachedByID(panel.itemID) then C_Item.RequestLoadItemDataByID(panel.itemID) end


local function set_Enter(self)
    self:SetScript("OnEnter",function(self2)
        if self2.itemID then
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetItemByID(self2.itemID)
            e.tips:AddLine(' ')
            e.tips:Show()
        end
    end)
    panel:SetScript("OnLeave",function() e.tips:Hide() end)
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
    set_Enter(panel)

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
    end
end)