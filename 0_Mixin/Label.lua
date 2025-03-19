



local e= select(2, ...)
WoWTools_LabelMixin={}




--[[function WoWTools_LabelMixin:Size(lable, size)
    if not lable or not size then
        return
    end
    local font, _, flag= lable:GetFont()
    lable:SetFont(font, size, flag)
end]]



function WoWTools_LabelMixin:Create(frame, tab)
    tab= tab or {}
    frame= frame or UIParent
    local name= tab.name
    local alpha= tab.alpha
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
    if copyFont then
        local fontName2, size2, fontFlag2 = copyFont:GetFont()
        font:SetFont(fontName2, size or size2, fontFlag2)
        font:SetTextColor(copyFont:GetTextColor())
        font:SetFontObject(copyFont:GetFontObject())
        font:SetShadowColor(copyFont:GetShadowColor())
        font:SetShadowOffset(copyFont:GetShadowOffset())
        if justifyH then font:SetJustifyH(justifyH) end
    else
        if e.onlyChinese or size then--THICKOUTLINE
            local fontName2, size2, fontFlag2= font:GetFont()
            if e.onlyChinese and not LOCALE_zhCN then
                fontName2= 'Interface\\AddOns\\WoWTools\\Sesource\\ARHei.TTF'--黑体字
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
            WoWTools_ColorMixin:Setup(font, {type='FontString'})
        elseif type(color)=='table' then
            font:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
        else
            font:SetTextColor(1, 0.82, 0, 1)
        end
    end
    if mouse then
        font:EnableMouse(true)
    end
    if wheel then
        font:EnableMouseWheel(true)
    end
    if alpha then
        font:SetAlpha(alpha)
    end
    return font
end















local framGameTooltipLabels
function WoWTools_LabelMixin:ItemCurrencyTips(settings)--物品升级界面，挑战界面，物品，货币提示
    local frame= settings.frame
    local point= settings.point
    local showName= settings.showName
    local showAll= settings.showAll
    local showTooltip= settings.showTooltip

    local R={}
    for _, tab in pairs(e.ItemCurrencyTips) do
        local text=''
        if tab.type=='currency' and tab.id and tab.id>0 then
            local info, num, totale, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(tab.id)
            if info and num and (num>0 or showAll or tab.show) then
                if isMax then
                    text= text..format('|cnRED_FONT_COLOR:%s|r', WoWTools_Mixin:MK(num,3))

                elseif percent then
                    text=text..format('|cnGREEN_FONT_COLOR:%s |cffffffff(%d%%)|r|r', WoWTools_Mixin:MK(num, 3), percent)
                else
                    text= text..format('|cnRED_FONT_COLOR:%s|r', WoWTools_Mixin:MK(num,3))
                end
                text= format('|T%d:0|t%s%s', info.iconFileID or 0, showName and info.name or '', text)
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
            local lable= frame.framGameTooltipLabels[index]
            if not lable then
                lable=WoWTools_LabelMixin:Create(frame, {mouse=true})
                if last then
                    lable:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, tab.line and -6 or -2)
                elseif point then
                    lable:SetPoint(point[1], point[2] or frame, point[3], point[4], point[5])
                end
                lable:SetScript("OnEnter",function(self)
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
                lable:SetScript("OnLeave",function(self)
                    GameTooltip:Hide()
                    self:SetAlpha(1)
                end)
                frame.framGameTooltipLabels[index]= lable
                last= lable
            end
            lable.id= tab.id
            lable.type= tab.type
            lable:SetText(tab.text)
        end

        for i= index+1, #frame.framGameTooltipLabels do
            local lable= frame.framGameTooltipLabels[i]
            if lable then
                lable:SetText("")
            end
        end
    end
end





