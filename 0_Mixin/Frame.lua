--[[
ScaleFrame(frame, delta, value, func)
CreateFrame(parent, tab)
]]
local Index=0
WoWTools_FrameMixin= {}



function WoWTools_FrameMixin:IsLocked(frame)
    local disabled= frame:IsProtected() or issecure()
    if WoWTools_DataMixin.Player.husandro and disabled then
        local name= frame.GetName and frame:GetName()
        print(name, 'IsProtected', frame:IsProtected() , 'issecure', issecure() )
    end
    return disabled
end







local function getSize(value)
    local w, h
    local t= type(value)
    if t=='table' then
        w, h=value[1], value[2]
    elseif t=='number' then
        w, h= value, value
    end
    return w or 580, h or 370
end

local function getIndex()
    Index= Index+1
    return Index
end



--缩放，Frame
function WoWTools_FrameMixin:ScaleFrame(frame, delta, value, func)
    local n= value
    if not frame:CanChangeAttribute() then
        print(WoWTools_DataMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
    end
    if IsAltKeyDown() then
        n= n or 1
        n= delta==1 and n-0.05 or n
        n= delta==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        if func then
            func(n)
        end
        if frame.set_scale then
            frame:set_scale()
        else
            frame:SetScale(n)
        end
        if frame.set_tooltip then
            frame:set_tooltip()
        end
    end
    return n
end
--Save.scale=WoWTools_FrameMixin:ScaleFrame(self, d, Save.scale, nil)





function WoWTools_FrameMixin:Create(parent, tab)
    tab= tab or {}

    local name= tab.name
    local size= tab.size
    local strata= tab.strata
    local template= tab.template
    local setID= tab.setID
    local point= tab.point

    local minW= tab.minW
    local minH= tab.minH
    local sizeRestFunc= tab.sizeRestFunc

    local w, h= getSize(size)
    local frame= CreateFrame('Frame', name or ('WoWTools_EditBoxFrame'..getIndex()), parent or UIParent, template, setID)
    frame:SetSize(w, h)
    frame:SetFrameStrata(strata or 'MEDIUM')
    if type(point)=='table' and point[1] then
        frame:SetPoint(point[1], point[2] or UIParent, point[3], point[4], point[5])
    else
        frame:SetPoint('CENTER')
    end


    frame.Border= CreateFrame('Frame', nil, frame,'DialogBorderTemplate')
    frame.Header= CreateFrame('Frame', nil, frame, 'DialogHeaderTemplate')--DialogHeaderMixin

    frame.CloseButton=CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
    frame.CloseButton:SetPoint('TOPRIGHT')

    WoWTools_TextureMixin:SetFrame(frame.Border, {alpha=0.5})
    WoWTools_TextureMixin:SetFrame(frame.Header, {alpha=0.7})

    frame.width= w
    frame.height= h
    WoWTools_MoveMixin:Setup(frame, {
        --needMove=true,
        minW=minW or 370,
        minH=minH or 240,
        notFuori=true,
        setSize=true,
        sizeRestFunc= sizeRestFunc or function(btn)
            btn.targetFrame:SetSize(btn.targetFrame.width, btn.targetFrame.height)
        end,
    })
    WoWTools_MoveMixin:Setup(frame.Header, {frame=frame})
    WoWTools_MoveMixin:Setup(frame.Border, {frame=frame})

   frame.Border:SetScript('OnKeyDown', function(f, key)
        if key=='ESCAPE' then
            f:GetParent():Hide()
        end
    end)


    return frame
end
--[[
WoWTools_FrameMixin:Create(name, {
    size={w, h} or numeri,
    parentFrame= frame or UIParent,
    setID=numeri, --SetID(1)
    strata='HIGH', BACKGROUND LOW MEDIUM HIGH DIALOG FULLSCREEN FULLSCREEN_DIALOG TOOLTIP

    minW=numeri or 370,
    mniH=numeri or 240

    sizeRestFunc=function(btn) btn:SetSize() end)
}
frame.Header:Setup(text)
--]]










--设置，提示
function WoWTools_FrameMixin:HelpFrame(tab)--WoWTools_FrameMixin:HelpFrame({frame=, topoint=, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=, y=-10, hideTime=3})
    if tab.show and not tab.frame.HelpTips then
        tab.frame.HelpTips= WoWTools_ButtonMixin:Cbtn(tab.frame, {layer='OVERLAY',size=tab.size and {tab.size[1], tab.size[2]} or {40,40}})-- button:CreateTexture(nil, 'OVERLAY')
        if tab.point=='right' then
            tab.frame.HelpTips:SetPoint('BOTTOMLEFT', tab.topoint or tab.frame, 'BOTTOMRIGHT',0, tab.y or -10)
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or WoWTools_DataMixin.Icon.toLeft)
        else--left
            tab.frame.HelpTips:SetPoint('BOTTOMRIGHT', tab.topoint or tab.frame, 'BOTTOMLEFT',0, tab.y or -10)
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or WoWTools_DataMixin.Icon.toRight)
        end
        if tab.color then
            SetItemButtonNormalTextureVertexColor(tab.frame.HelpTips, tab.color.r, tab.color.g, tab.color.b, tab.color.a or 1)
        end
        function tab.frame.HelpTips:set_hide()
            self.time=nil
            self.elapsed=nil
            self:SetShown(false)
        end
        tab.frame.HelpTips:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.5) + elapsed
            if self.elapsed>0.5 then
                self.elapsed=0
                self:SetScale(self:GetScale()==1 and 0.5 or 1)
            end
            if self.hideTime then
                self.time= (self.time or 0)+  elapsed
                if self.time>= self.hideTime then
                    self:set_hide()
                end
            end
        end)
        tab.frame.HelpTips:SetScript('OnEnter', tab.frame.HelpTips.set_hide)
        if tab.onlyOne then
            tab.frame.HelpTips.onlyOne=true
        end
        tab.frame.HelpTips.hideTime= tab.hideTime
    end
    if tab.frame.HelpTips and not tab.frame.HelpTips.onlyOne then
        tab.frame.HelpTips:SetShown(tab.show)
    end
end


--确认框架中心点，在屏幕内
function WoWTools_FrameMixin:IsInSchermo(frame)
    if not frame or not frame:IsVisible() then
        return false
    end
    
    frame= frame.TitleContainer or frame

    local isInSchermo= true

    local centerX, centerY = frame:GetCenter()

    local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()

    if not screenWidth or not screenHeight or not centerX or centerY then
        return false
    end

    if centerX < 0 or centerX > screenWidth or centerY < 0 or centerY > screenHeight then
        isInSchermo = false
    end

    return isInSchermo
end