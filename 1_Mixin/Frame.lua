--[[
ScaleFrame(frame, delta, value, func)
CreateFrame(parent, tab)
]]
local Index=0
WoWTools_FrameMixin= {}



function WoWTools_FrameMixin:IsLocked(frame)
    if not frame or not frame.IsProtected then
        return
    end
    local isProtected, isProtectedExplicitly= frame:IsProtected()
    if isProtectedExplicitly then
        return true
    end

    local disabled= isProtected and InCombatLockdown()-- or issecure()

    if WoWTools_DataMixin.Player.husandro and disabled then
        local name= frame.GetName and frame:GetName()
        print(name, '|cnGREEN_FONT_COLOR:IsProtected|r', frame.IsProtected and frame:IsProtected() , '|cnGREEN_FONT_COLOR:issecure|r', issecure() )
    end
    return disabled
end


--确认框架中心点，在屏幕内
function WoWTools_FrameMixin:IsInSchermo(frame)
    if not frame or not frame:IsVisible() then
        return false
    end

    frame= frame.TitleContainer or frame.Header or frame

    local isInSchermo= true

    local centerX, centerY = frame:GetCenter()

    local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()

    if not centerX or not centerY then
        return false
    end

    if centerX < 0 or centerX > screenWidth or centerY < 0 or centerY > screenHeight then
        isInSchermo = false
    end

    return isInSchermo
end





local function Get_Size(value)
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
    if WoWTools_FrameMixin.IsLocked(frame) then
        print(WoWTools_DataMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)..'|r')
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

    local name= tab.name or ((parent:GetName() or 'WoWTools')..'Frame'..getIndex())
    local size= tab.size
    --local strata= tab.strata
    local template= tab.template-- or 'BasicFrameTemplate'-- or 'BaseBasicFrameTemplate'
    local setID= tab.setID
    local point= tab.point

    local minW= tab.minW
    local minH= tab.minH
    local sizeRestFunc= tab.sizeRestFunc
    local restPointFunc= tab.restPointFunc

    local frame= CreateFrame('Frame', name or ('WoWTools_EditBoxFrame'..getIndex()), parent or UIParent, template, setID)

--Esc 键
    tinsert(UISpecialFrames, name)

    frame:SetToplevel(true)
--设置大小
    local w, h= Get_Size(size)
    frame:SetSize(w, h)
    frame.width= w
    frame.height= h
--Strata

    frame:SetFrameStrata('MEDIUM')

--设置，位置
    if restPointFunc then
        frame.restPointFunc= restPointFunc
    else
        function frame:restPointFunc()
            if type(point)=='table' and point[1] then
                self:SetPoint(point[1], point[2] or UIParent, point[3], point[4], point[5])
            else
                self:SetPoint('CENTER')
            end
        end
    end
    frame:restPointFunc()


--Border
    frame.Border= CreateFrame('Frame', name..'Border', frame, 'DialogBorderTemplate')
    frame.Border.Bg:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga')


--Header
    frame.Header= CreateFrame('Frame', name..'Header', frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    if tab.header then
        frame.Header:Setup(tab.header)
    end

--CloseButton
    frame.CloseButton=CreateFrame('Button', name..'CloseButton', frame, 'UIPanelCloseButton')--SharedUIPanelTemplates.xml
    frame.CloseButton:SetPoint('TOPRIGHT')

--移动
    WoWTools_MoveMixin:Setup(frame, {
        --needMove=true,
        minW=minW or 370,
        minH=minH or 240,
        sizeRestFunc= sizeRestFunc or function()
            if not self:IsLocked(frame) then
                frame:SetSize(w, h)
            end
        end,
        restPointFunc= restPointFunc or function()
            frame:restPointFunc()
        end,
    })
    WoWTools_MoveMixin:Setup(frame.Header, {frame=frame})
    WoWTools_MoveMixin:Setup(frame.Border, {frame=frame})

--材质
    WoWTools_TextureMixin:SetButton(frame.CloseButton)
    --[[WoWTools_TextureMixin:SetFrame(frame.Border, {show={[frame.Border.Bg]=true}})
    WoWTools_TextureMixin:SetFrame(frame.Header)]]

    WoWTools_TextureMixin:Init_BGMenu_Frame(frame, {
        enabled=true,
        isNewButton=true,
        nineSliceAlpha=0,
        portraitAlpha=0.5,
        alpha=0.5,
        settings=function(_, texture, alpha)
            frame.Border.Bg:SetAlpha(texture and 0 or alpha or 0.5)
        end
    })

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
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or 'common-icon-rotateleft')
        else--left
            tab.frame.HelpTips:SetPoint('BOTTOMRIGHT', tab.topoint or tab.frame, 'BOTTOMLEFT',0, tab.y or -10)
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or 'common-icon-rotateright')
        end
        if tab.color then
            SetItemButtonNormalTextureVertexColor(tab.frame.HelpTips, tab.color.r, tab.color.g, tab.color.b, tab.color.a or 1)
        end
        function tab.frame.HelpTips:set_hide()
            self.time=nil
            self.elapsed=nil
            self:SetShown(false)
        end
        tab.frame.HelpTips:SetScript('OnUpdate', function(f, elapsed)
            f.elapsed= (f.elapsed or 0.5) + elapsed
            if f.elapsed>0.5 then
                f.elapsed=0
                f:SetScale(f:GetScale()==1 and 0.5 or 1)
            end
            if f.hideTime then
                f.time= (f.time or 0)+  elapsed
                if f.time>= f.hideTime then
                    f:set_hide()
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

