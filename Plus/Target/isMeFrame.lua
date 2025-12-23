--提示，目标是我


local function Save()
    return WoWToolsSave['Plus_Target']
end



local EventTab= {
    'PLAYER_REGEN_DISABLED',
    'UNIT_TARGET',
    'UNIT_SPELLCAST_CHANNEL_START',
}
--[[
'PLAYER_REGEN_ENABLED',
'NAME_PLATE_UNIT_ADDED',
'NAME_PLATE_UNIT_REMOVED',
'FORBIDDEN_NAME_PLATE_UNIT_ADDED',
'FORBIDDEN_NAME_PLATE_UNIT_REMOVED',
'CVAR_UPDATE',
]]


--设置，参数
local function Set_Texture(plate)
    local unit =plate:GetUnit()
    local frame= C_NamePlate.GetNamePlateForUnit(unit, issecure())
    
if not frame then
    return
end
    --local frame= plate.UnitFrame
    if not frame.CreateTexture or not plate.CreateTexture then
        print(frame.CreateTexture , plate.CreateTexture)
    end
    if not frame.UnitIsMe then
        frame.UnitIsMe= plate:CreateTexture(nil, 'OVERLAY')
    else
        frame.UnitIsMe:ClearAllPoints()
    end
    local parent= Save().unitIsMeParent=='name' and frame.name or frame.healthBar
    if Save().unitIsMePoint=='TOP' then
        frame.UnitIsMe:SetPoint("BOTTOM", parent, 'TOP', Save().unitIsMeX,Save().unitIsMeY)
    elseif Save().unitIsMePoint=='TOPRIGHT' then
        frame.UnitIsMe:SetPoint("BOTTOMRIGHT", parent, 'TOPRIGHT', Save().unitIsMeX,Save().unitIsMeY)
    elseif Save().unitIsMePoint=='LEFT' then
        frame.UnitIsMe:SetPoint("RIGHT", parent, 'LEFT', Save().unitIsMeX,Save().unitIsMeY)
    elseif Save().unitIsMePoint=='RIGHT' then
        frame.UnitIsMe:SetPoint("LEFT", parent, 'RIGHT', Save().unitIsMeX,Save().unitIsMeY)
    else--TOPLEFT
        frame.UnitIsMe:SetPoint("BOTTOMLEFT", parent, 'TOPLEFT', Save().unitIsMeX,Save().unitIsMeY)
    end
    local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save().unitIsMeTextrue)
    if isAtlas or not texture then
        frame.UnitIsMe:SetAtlas(texture or 'auctionhouse-icon-favorite')
    else
        frame.UnitIsMe:SetTexture(texture)
    end
    frame.UnitIsMe:SetVertexColor(Save().unitIsMeColor.r, Save().unitIsMeColor.g, Save().unitIsMeColor.b, Save().unitIsMeColor.a)
    frame.UnitIsMe:SetSize(Save().unitIsMeSize, Save().unitIsMeSize)
end


--设置, Plate
local function Set_Plate(plate, unit)
    unit= unit or (plate and plate.UnitFrame.unit)
    
    plate=  unit and C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if not plate then
        return
    end

        local isMe= WoWTools_UnitMixin:UnitIsUnit(unit, 'player')

        if not plate.UnitIsMe then
            Set_Texture(plate)--设置，参数
        end
        
    if plate.UnitIsMe then
        plate.UnitIsMe:SetShown(isMe)
    end
end


--检查，所有
local function Set_All_Plates()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        Set_Plate(plate, nil)--设置
    end
end
















local function Init()
    if not Save().unitIsMe then
        return
    end

    local isMeFrame= CreateFrame('Frame', 'WoWToolsTarget_IsMeFrame')

    if NamePlateBaseMixin.OnAdded then--12.0没有了
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'OnAdded', function(_, unit)
            Set_Plate(nil, unit)
        end)
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'OnOptionsUpdated', function(plate)
            Set_Plate(plate, nil)
        end)
    else
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'Init', function(_, unit)
            Set_Plate(nil, unit)
        end)
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'SetUnit', function(plate)
            Set_Plate(plate, nil)
        end)
    end

    isMeFrame:SetScript('OnEvent', function(_, event, arg1)
        if event=='PLAYER_REGEN_DISABLED' then--颜色
            Set_All_Plates()--检查，所有

        elseif arg1 then
            if arg1=='player' or arg1=='pet' then
                Set_All_Plates()--检查，所有
            else
                Set_Plate(nil, arg1)
            end
        end
    end)

    function isMeFrame:hide_plate(plate)
        if plate and plate.UnitFrame and plate.UnitFrame.UnitIsMe then--隐藏，Plate
            plate.UnitFrame.UnitIsMe:SetShown(false)
        end
    end

    function isMeFrame:Settings()
        self:UnregisterAllEvents()

        if Save().unitIsMe then
            FrameUtil.RegisterFrameForEvents(isMeFrame, EventTab)

            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do--初始，数据
                if plate.UnitFrame then
                    if plate.UnitFrame.UnitIsMe then--修改
                        Set_Texture(plate)--设置，参数
                    end
                    Set_Plate(plate, nil)--设置
                end
            end

        else--禁用
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                self:hide_plate(plate)
            end
        end
    end

    isMeFrame:Settings()

    Init= function()
        _G['WoWToolsTarget_IsMeFrame']:Settings()
    end
end












function WoWTools_TargetMixin:Init_isMeFrame()
    Init()
end