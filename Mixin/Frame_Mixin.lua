--[[
ScaleFrame(frame, delta, value, func)
ShowText(data, headerText)
CreateFrame(parent, tab)
CreateBackground(frame, setPoint)
]]

local e= select(2, ...)
local Index=0
WoWTools_FrameMixin= {}


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
    if frame:CanChangeAttribute() and not UnitAffectingCombat('player') and IsAltKeyDown() then
        n= n or 1
        n= delta==1 and n-0.05 or n
        n= delta==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        if func then
            func()
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



function WoWTools_FrameMixin:ShowText(data, headerText)
    local text
    if type(data)=='table' then
        for _, str in pairs(data) do
            text= text and text..'\n' or ''
            text= text.. str
        end
    else
        text= data
    end
    local frame= _G['WoWTools_EditBoxFrame']
    if not frame then
        frame= self:CreateFrame(nil, {name='WoWTools_EditBoxFrame'})
        frame.ScrollBox=WoWTools_EditBoxMixn:CreateMultiLineFrame(frame, {font='GameFontNormal', isShowLinkTooltip=true})
        frame.ScrollBox:SetPoint('TOPLEFT', 11, -32)
        frame.ScrollBox:SetPoint('BOTTOMRIGHT', -6, 12)
    end
    frame.ScrollBox:SetText(text or '')
    frame.Header:Setup(headerText or '' )
    frame:SetShown(true)
end



function WoWTools_FrameMixin:CreateFrame(parent, tab)
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

    e.Set_Alpha_Frame_Texture(frame.Border, {alpha=0.5})
    e.Set_Alpha_Frame_Texture(frame.Header, {alpha=0.7})

    frame.width= w
    frame.height= h
    e.Set_Move_Frame(frame, {
        needMove=true,
        minW=minW or 370,
        minH=minH or 240,
        notFuori=true,
        setSize=true,
        sizeRestFunc= sizeRestFunc or function(btn)
            btn.target:SetSize(btn.target.width, btn.target.height)
        end,
    })
    e.Set_Move_Frame(frame.Header, {frame=frame})
    e.Set_Move_Frame(frame.Border, {frame=frame})

   frame.Border:SetScript('OnKeyDown', function(f, key)
        if key=='ESCAPE' then
            f:GetParent():Hide()
        end
    end)


    return frame
end
--[[
WoWTools_FrameMixin:CreateFrame(name, {
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



function WoWTools_FrameMixin:CreateBackground(frame, setPoint)
    frame.Background= frame:CreateTexture(nil, 'BACKGROUND')
    if setPoint==true then
        frame.Background:SetAllPoints()
    elseif type(setPoint)=='function' then
        setPoint(frame.Background)
    end
    frame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
    frame.Background:SetAlpha(0.5)
    frame.Background:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
end
--[[
--显示背景 Background
WoWTools_FrameMixin:CreateBackground(frame, function(texture)
    texture:SetPoint()
end)
]]





