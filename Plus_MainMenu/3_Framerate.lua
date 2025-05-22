--每秒帧数 Plus

local function Save()
    return WoWToolsSave['Plus_MainMenu']
end

local FramerateButton











local function Init()
    if not Save().frameratePlus then
        return
    end

    FramerateButton= WoWTools_ButtonMixin:Cbtn(FramerateFrame, {size=14, name='WoWToolsPlusFramerateButton'})
    FramerateButton:SetPoint('RIGHT',FramerateFrame.FramerateText)

    FramerateButton:SetMovable(true)
    FramerateButton:RegisterForDrag("RightButton")
    FramerateButton:SetClampedToScreen(true)
    FramerateButton:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    FramerateButton:SetScript("OnDragStop", function()
        local self= FramerateFrame
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().frameratePoint={self:GetPoint(1)}
            Save().frameratePoint[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
    end)
    FramerateButton:SetScript("OnMouseUp", ResetCursor)
    FramerateButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)


    function FramerateButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE, (Save().framerateSize or 12)..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MainMenuMixin.addName)
        GameTooltip:Show()
    end
    FramerateButton:SetScript('OnLeave', GameTooltip_Hide)
    FramerateButton:SetScript('OnEnter', FramerateButton.set_tooltips)

    FramerateButton:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save().framerateSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        Save().framerateSize=size
        self:set_size()
        self:set_tooltips()
    end)

    function FramerateButton:set_size()--修改大小
        WoWTools_LabelMixin:Create(nil, {size=Save().framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save().size, nil , Labels.fpsms, true)    
    end
    FramerateButton:set_size()

    FramerateFrame.Label:SetText('')--去掉FPS
    FramerateFrame.Label:SetShown(false)
    FramerateFrame:SetMovable(true)
    FramerateFrame:SetClampedToScreen(true)
    FramerateFrame:HookScript('OnShow', function(self)
        if Save().frameratePoint and FramerateFrame then
            self:ClearAllPoints()
            self:SetPoint(Save().frameratePoint[1], UIParent, Save().frameratePoint[3], Save().frameratePoint[4], Save().frameratePoint[5])
        end
    end)
    FramerateFrame:SetFrameStrata('HIGH')

    if Save().framerateLogIn and not FramerateFrame:IsShown() then--自动，打开
        FramerateFrame:Toggle()
    end

    Init=function()end
end





function WoWTools_MainMenuMixin:Init_Framerate_Plus()
    Init()
end