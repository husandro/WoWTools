WoWTools_LabelMixin={}
local IndexLabel=0



--[[
SharedFonts.xml

function WoWTools_LabelMixin:Size(label, size)
    if not label or not size then
        return
    end
    local font, _, flag= label:GetFont()
    label:SetFont(font, size, flag)
end
]]



function WoWTools_LabelMixin:Create(frame, tab)
    IndexLabel= IndexLabel+1

    tab= tab or {}
    frame= frame or UIParent
    local name= tab.name --or ((frame:GetName() or 'WoWTools')..'Label'..IndexLabel)
    local alpha= tab.alpha or 1
    local font= tab.changeFont
    local layer= tab.layer or 'OVERLAY'--BACKGROUND BORDER ARTWORK OVERLAY HIGHLIGHT
    local fontName= tab.fontName or 'ChatFontNormal'--'GameFontNormal'
    local copyFont= tab.copyFont
    local size= tab.size or 12
    local justifyH= tab.justifyH
    local notFlag= tab.notFlag
    local notShadow= tab.notShadow
    local color= tab.color
    local mouse= tab.mouse
    local wheel= tab.wheel

    font = font or frame:CreateFontString(name, layer, fontName)
    if copyFont and copyFont.GetFont then
        local fontName2, size2, fontFlag2 = copyFont:GetFont()
        if WoWTools_DataMixin.onlyChinese and not LOCALE_zhCN then
            fontName2= 'Fonts\\ARHei.ttf'--'Interface\\AddOns\\WoWTools\\Source\\ARHei.TTF'--黑体字
        end
        font:SetFont(fontName2, size or size2, fontFlag2)
        font:SetTextColor(copyFont:GetTextColor())
        font:SetFontObject(copyFont:GetFontObject())
        font:SetShadowColor(copyFont:GetShadowColor())
        font:SetShadowOffset(copyFont:GetShadowOffset())
        if justifyH then
            font:SetJustifyH(justifyH)
        end
    else
        if WoWTools_DataMixin.onlyChinese or size then--THICKOUTLINE
            local fontName2, size2, fontFlag2= font:GetFont()
            if WoWTools_DataMixin.onlyChinese and not LOCALE_zhCN then
                fontName2= 'Fonts\\ARHei.ttf'--'Interface\\AddOns\\WoWTools\\Source\\ARHei.TTF'--黑体字
            end
            font:SetFont(fontName2, size or size2, notFlag and fontFlag2 or 'OUTLINE')
        end

        font:SetJustifyH(justifyH or 'LEFT')
    end
    if not notShadow then
        font:SetShadowOffset(1, -1)
    end
    if color~=false then
        if color==true then--颜色
            WoWTools_ColorMixin:Setup(font, {type='FontString', alpha=alpha})
        elseif type(color)=='table' then
            font:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or alpha)
        else
            font:SetTextColor(1, 0.82, 0, alpha)
        end
    end
    if mouse then
        font:EnableMouse(true)
    end
    if wheel then
        font:EnableMouseWheel(true)
    end
    --[[if alpha then
        font:SetAlpha(alpha)
    end]]
    return font
end














local function Create_Tooltip_Label(frame, index, point, line, size)
    local label=WoWTools_LabelMixin:Create(frame, {mouse=true, size=size})
    if index==1 then
        if point and point[1] then
            label:SetPoint(point[1], point[2] or frame, point[3], point[4], point[5])
        else
            label:SetPoint('TOPLEFT', frame)
        end
    else
        label:SetPoint('TOPLEFT', frame.framGameTooltipLabels[index-1], 'BOTTOMLEFT',0, line and -6 or -2)
    end
    label:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if self.type=='currency' then
            GameTooltip:SetCurrencyByID(self.id)
        elseif self.type=='item' then
            GameTooltip:SetItemByID(self.id)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    label:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.framGameTooltipLabels[index]= label
    return label
end








local function ItemCurrencyTips(settings)--物品升级界面，挑战界面，物品，货币提示
    local frame= settings.frame
    local isClear= settings.frame and settings.isClear

    if isClear then
        if frame then
            for _, label in pairs(frame.framGameTooltipLabels or {}) do
                label:SetText("")
                label.id= nil
                label.type= nil
            end
        end
        return
    end

    local point= settings.point
    local showName= settings.showName
    local showAll= settings.showAll
    local showTooltip= settings.showTooltip
    local line= settings.line
    local size= settings.size


    local R={}
    for _, tab in pairs(WoWTools_DataMixin.ItemCurrencyTips) do
        local text=''
        if tab.type=='currency' and tab.id then
            local name, info= WoWTools_CurrencyMixin:GetName(tab.id, nil, nil)
            if info and name and info.discovered then
                text= name
            end

        elseif tab.type=='item' and tab.id then
            WoWTools_Mixin:Load({id=tab.id, type='item'})
            local num= C_Item.GetItemCount(tab.id, true, false, true)
            local itemQuality= C_Item.GetItemQualityByID(tab.id)
            if (showAll or tab.show or num>0) and itemQuality>=1 then
                WoWTools_Mixin:Load({id=tab.id, type='item'})
                local icon= C_Item.GetItemIconByID(tab.id)
                local name=showName and C_Item.GetItemNameByID(tab.id)
                text= ((icon and icon>0) and '|T'..icon..':0|t' or '')
                    ..(name and name..' |cnGREEN_FONT_COLOR:x|r' or '')
                    ..num
            end
        end
        if text~='' then
            table.insert(R, {text=text, id= tab.id, type= tab.type})
        end
    end

    if showTooltip then
        for _, tab in pairs(R) do
            GameTooltip:AddLine(tab.text)
        end

    elseif frame then
        frame.framGameTooltipLabels= frame.framGameTooltipLabels or {}
        local index=0
        local last

        for _, tab in pairs(R) do
            index= index +1
            local label= frame.framGameTooltipLabels[index] or Create_Tooltip_Label(frame, index, point, line, size)

            last= label
            label.id= tab.id
            label.type= tab.type
            label:SetText(tab.text)
        end

        for i= index+1, #frame.framGameTooltipLabels do
            local label= frame.framGameTooltipLabels[i]
            if label then
                label:SetText("")
                label.id= nil
                label.type= nil
            end
        end
        return last
    end
end






function WoWTools_LabelMixin:ItemCurrencyTips(settings)--物品升级界面，挑战界面，物品，货币提示
    return ItemCurrencyTips(settings or {})
end





