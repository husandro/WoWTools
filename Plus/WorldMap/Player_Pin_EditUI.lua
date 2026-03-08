local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end

local function SaveWoW()
    return WoWToolsPlayerDate.WorldMapPin
end

local Frame








local function Initializer(btn, data)
    if not btn.text then
        btn.text= btn:CreateFontString(nil, 'BORDER', 'WoWToolsWorldFont')
        btn.text:SetPoint('TOPLEFT')
        btn.text:SetPoint('TOPRIGHT')
    end
    btn.text:SetText(data.mapID..' '.. data.name)
    print(data.mapID, data.name)
end





local function Init(data)
    local Name= 'WoWToolsPlayerPinEditUIFrame'
    Frame= WoWTools_FrameMixin:Create(UIParent, {
        name= Name,
        size={580, 370},
        strata='HIGH',
        header= '|A:Ping_Wheel_Icon_Assist:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地图标记' or MAP_PIN),
    })

    Frame:Hide()

    Frame.list = CreateFrame("Frame", 'WoWToolslayerPinEditUIList', Frame, "WowScrollBoxList")
    Frame.list:SetPoint("TOPLEFT", 12, -30)
    Frame.list:SetPoint("BOTTOM", 0, 6)


    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.list, "TOPRIGHT", 8,0)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.list, "BOTTOMRIGHT",8,12)
    WoWTools_TextureMixin:SetScrollBar(Frame.list)

    Frame.list.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.list, Frame.ScrollBar, Frame.list.view)

    Frame.list.view:SetElementInitializer("WoWToolsButtonTemplate", Initializer)


    function Frame:Init()
        local dataProvider = CreateDataProvider()

        for mapID, info in pairs(SaveWoW()) do
            for name, pinData in pairs(info) do
                dataProvider:Insert({
                    mapID= mapID,
                    name= name,
                    pin= pinData,--[[
                        icon= 'Warfronts-FieldMapIcons-Horde-Banner-Minimap',
                        x= 50.02,
                        y= 74.76,
                        color={r=0.87, g=0.8, b=0.61},
                        --note='b拍卖行a',
                    ]]
                })
            end
        end
        dataProvider:SetSortComparator(function(a, b)
            if a and b then
                if a.mpaID==b.mpaID then
                    return #a.name> #b.name
                else
                    return a.mpaID> b.mpaID
                end
            else
                return false
            end
        end)
        self.list.view:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    end









    function Frame:settings(info)
        local show= not self:IsShown()
        self:SetShown(show)
        --print(self:IsShown())
    end

    Frame:SetScript('OnShow', function(self)
        self:Init()
    end)

    
    Init=function(...)
        Frame:settings(...)
    end
end

function WoWTools_WorldMapMixin:Init_PlayerPin_EditUI(data)
    Init(data)
end