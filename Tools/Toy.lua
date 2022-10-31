local id, e = ...
local addName= SLASH_RANDOM3:gsub('/','').. TOY
local Save={}
local panel=e.Cbtn2(id..addName..'button')
panel.items={}--存放有效

panel:SetPoint('BOTTOMLEFT', e.toolsFrame.last or e.toolsFrame, 'TOPLEFT',0, 5)


local function getToy()--生成, 有效表格
    panel.items={}
    local find
    for itemID ,_ in pairs(Save.items) do
        if PlayerHasToy(itemID) then
            if not C_Item.IsItemDataCachedByID(itemID) then
                C_Item.RequestLoadItemDataByID(itemID)
            end
            find=true
            table.insert(panel.items, itemID)
        end
    end
    if not find and GetItemCount( 6948)~=0 then
        panel.items={6948}
    end
end
local function setAtt(init)--设置属性
    if UnitAffectingCombat('player') and not init then
        return
    end
    local icon
    local num=#panel.items
    if num>0 then
        local index=math.random(1, num)
        local itemID=panel.items[index]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                panel.texture:SetTexture(icon)
            end
            panel:SetAttribute('item1', C_Item.GetItemNameByID(itemID) or itemID)
            
            panel.itemID=itemID
        end
    else
        panel:SetAttribute('item1', nil)
        panel.itemID=nil
    end
    panel.texture:SetShown(icon)
end

--#############
--玩具界面, 菜单
--#############
local function setToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
    if Save.disabled or not itemID then
        return
    end
    UIDropDownMenu_AddSeparator()
    local info={
            text=addName,
            checked=Save.items[itemID],
            func=function()
                if Save.items[itemID] then
                    Save.items[itemID]=nil
                else
                    Save.items[itemID]=true
                end
                getToy()--生成, 有效表格
                setAtt()--设置属性
                ToySpellButton_UpdateButton(anchorTo)
            end,
            tooltipOnButton=true,
            tooltipTitle=addName,
            tooltipText=id,
        }
    UIDropDownMenu_AddButton(info, 1)
end
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if Save.disabled or not self.itemID then
        return
    end
    local find = Save.items[self.itemID]
    if find and not self.hearthstone then
        self.hearthstone=self:CreateTexture(nil, 'ARTWORK')
        self.hearthstone:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT')
        self.hearthstone:SetTexture(134414)
        self.hearthstone:SetSize(12, 12)
    end
    if self.hearthstone then
        self.hearthstone:SetShown(find)
    end
end

local function Init()
    
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        Init()--初始

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
        hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)