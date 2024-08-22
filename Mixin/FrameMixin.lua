local e= select(2, ...)

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


WoWTools_FrameMixin= {
    index=0,
}

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
        frame= self:CreateFrame('WoWTools_EditBoxFrame')
        frame.ScrollBox=WoWTools_EditBoxMixn:CreateMultiLineFrame(frame, {font='GameFontNormal', isShowLinkTooltip=true})
        frame.ScrollBox:SetPoint('TOPLEFT', 11, -32)
        frame.ScrollBox:SetPoint('BOTTOMRIGHT', -6, 12)
    end

    frame.ScrollBox:SetText(text or '')
    frame.Header:Setup(headerText or '' )
    frame:SetShown(true)
end



function WoWTools_FrameMixin:CreateFrame(name, tab)
    if not name then
        name= 'WoWTools_EditBoxFrame'..self.index
    end

    tab= tab or {}
    local w, h= 580, 370
    if tab.size then
        if type(tab.size)=='table' then
            w=tab.size[1]
            h=tab.size[2]
        else
            w,h= tab.size, tab.size
        end
    end

    local frame= CreateFrame('Frame', name, tab.parent or UIParent, tab.template, tab.setID)

    frame:SetSize(w,h)
    frame:SetFrameStrata(tab.strata or 'HIGH')
    frame:SetPoint('CENTER')


    frame.Border= CreateFrame('Frame', nil, frame,'DialogBorderTemplate')
    frame.Header= CreateFrame('Frame', nil, frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    local CloseButton=CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
    CloseButton:SetPoint('TOPRIGHT')

    e.Set_Alpha_Frame_Texture(frame.Border, {alpha=0.5})
    e.Set_Alpha_Frame_Texture(frame.Header, {alpha=0.7})

    frame.width= w
    frame.height= h
    e.Set_Move_Frame(frame, {
        needMove=true,
        minW=tab.minW or 370,
        minH=tab.minH or 240,
        notFuori=true,
        setSize=true,
        sizeRestFunc= tab.sizeRestFunc or function(btn)
            btn.target:SetSize(btn.target.width or 580, btn.target.height or 370)
        end,
    })
    e.Set_Move_Frame(frame.Header, {frame=frame})
    e.Set_Move_Frame(frame.Border, {frame=frame})

   frame.Border:SetScript('OnKeyDown', function(f, key)
        if key=='ESCAPE' then
            f:GetParent():Hide()
        end
    end)


    self.index= self.index+1
    return frame
end
