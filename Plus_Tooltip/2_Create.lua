
local function Save()
    return WoWToolsSave['Plus_Tootips']
end









function WoWTools_TooltipMixin:Set_PlayerModel(tooltip)
    if not tooltip.playerModel then
        tooltip.playerModel= CreateFrame("PlayerModel", tooltip:GetName()..'PlayerModel', tooltip)--PlayerModel ModelScene DressUpModel PlayerModel
    else
        tooltip.playerModel:ClearAllPoints()
    end
    if Save().modelLeft then
        tooltip.playerModel:SetPoint("RIGHT", tooltip, 'LEFT', Save().modelX, Save().modelY)
    else
        tooltip.playerModel:SetPoint("BOTTOM", tooltip, 'TOP', Save().modelX, Save().modelY)
    end
    tooltip.playerModel:SetSize(Save().modelSize, Save().modelSize)
    tooltip.playerModel:SetFacing(Save().modelFacing)
end








local function Create(tooltip)
    local name= not tooltip.textLeft and tooltip:GetName()
    if not name then
        return
    end

    tooltip.textLeft= tooltip:CreateFontString(name..'TextLeft', 'ARTWORK', 'ChatFontNormal')
    tooltip.textLeft:SetFontHeight(16)
    tooltip.textLeft:SetJustifyH('LEFT')
    tooltip.textLeft:SetShadowOffset(2, -2)
    tooltip.textLeft:SetPoint('BOTTOMLEFT', tooltip.CompareHeader or tooltip, 'TOPLEFT', 3, 0)

    --[[tooltip.textLeftBg= tooltip:CreateTexture(nil, 'BACKGROUND')
    tooltip.textLeftBg:SetAllPoints(tooltip.textLeft)
    tooltip.textLeftBg:SetColorTexture(0,0,0,0.5)]]

--左上角字符2
    tooltip.text2Left= tooltip:CreateFontString(name..'Text2Left', 'ARTWORK', 'ChatFontNormal')
    tooltip.text2Left:SetFontHeight(16)
    tooltip.text2Left:SetJustifyH('LEFT')
    tooltip.text2Left:SetShadowOffset(2, -2)
    tooltip.text2Left:SetPoint('LEFT', tooltip.textLeft, 'RIGHT', 5, 0)
    --[[tooltip.text2LeftBg= tooltip:CreateTexture(nil, 'BACKGROUND')
    tooltip.text2LeftBg:SetAllPoints(tooltip.text2Left)
    tooltip.text2LeftBg:SetColorTexture(0,0,0,0.5)]]

--右上角字符
    tooltip.textRight= tooltip:CreateFontString(name..'textRight', 'ARTWORK', 'ChatFontNormal')
    tooltip.textRight:SetFontHeight(12)
    tooltip.textRight:SetJustifyH('RIGHT')
    tooltip.textRight:SetShadowOffset(2, -2)
    if tooltip.CloseButton then
        tooltip.textRight:SetPoint('BOTTOMRIGHT', tooltip, 'TOPRIGHT', -3, 3)
    else
        tooltip.textRight:SetPoint('BOTTOMRIGHT', tooltip, 'TOPRIGHT', -3, 0)
    end
    --[[tooltip.textRightBg= tooltip:CreateTexture(nil, 'BACKGROUND')
    tooltip.textRightBg:SetAllPoints(tooltip.textRight)
    tooltip.textRightBg:SetColorTexture(0,0,0,0.5)]]

--右上角字符2
    tooltip.text2Right= tooltip:CreateFontString(name..'text2Right', 'ARTWORK', 'ChatFontNormal')
    tooltip.text2Right:SetFontHeight(12)
    tooltip.text2Right:SetJustifyH('RIGHT')
    tooltip.text2Right:SetShadowOffset(2, -2)
    tooltip.text2Right:SetPoint('BOTTOMRIGHT', tooltip.textRight, 'TOPRIGHT', 0, 2)
    --[[tooltip.text2RightBg= tooltip:CreateTexture(nil, 'BACKGROUND')
    tooltip.text2RightBg:SetAllPoints(tooltip.text2Right)
    tooltip.text2RightBg:SetColorTexture(0,0,0,0.5)]]

--背景颜色
    tooltip.backgroundColor= tooltip:CreateTexture(name..'BackgroundColor', 'BACKGROUND', nil, 1)
    tooltip.backgroundColor:SetPoint('TOPLEFT')
    tooltip.backgroundColor:SetPoint('BOTTOMRIGHT')
    tooltip.backgroundColor:Hide()



    function tooltip:Set_BG_Color(r, g, b, a)
        local show= r and g and b
        r,g,b,a= r or 1, g or 1, b or 1, a or 0.5
        self.backgroundColor:SetColorTexture(r,g,b,a)
        if self.NineSlice then
            self.NineSlice:SetBorderColor(r,g,b,a)
        end
        self.backgroundColor:SetShown(show)
    end

    function tooltip:Set_TopLabel(textLeft, text2Left, textRight, text2Right)--嵌入式
        if self.IsEmbedded then
            self:AddLine(textLeft)
            self:AddLine(text2Left)
            self:AddLine(textRight)
            self:AddLine(text2Right)
        else
            self.textLeft:SetText(textLeft or '')
            self.text2Left:SetText(text2Left or '')
            self.textRight:SetText(textRight or '')
            self.text2Right:SetText(text2Right or '')
        end
    end

    if not tooltip.Portrait then
        tooltip.Portrait= tooltip:CreateTexture(name..'Portrait', 'BACKGROUND', nil, 2)--右上角图标
        if tooltip.CloseButton then
            tooltip.Portrait:SetPoint('TOPRIGHT', tooltip.CloseButton, 'BOTTOMRIGHT', -6, 0)
        else
            tooltip.Portrait:SetPoint('TOPRIGHT',-6, -24)
        end
        tooltip.Portrait:SetSize(40,40)
        WoWTools_ButtonMixin:AddMask(tooltip, false, tooltip.Portrait)
    end
    function tooltip.Portrait:settings(icon)
        if icon then
            if C_Texture.GetAtlasInfo(icon) then
                self:SetAtlas(icon)
            else
                self:SetTexture(icon)
            end
        else
            self:SetTexture(0)
        end
    end

    tooltip:HookScript("OnHide", function(self)--隐藏
        WoWTools_TooltipMixin:Set_Rest_Item(self)--清除，数据
    end)

--缩放
    tooltip:HookScript("OnShow", function(self)
        local scale= Save().scale or 1
        if scale~=self:GetScale() then
            self:SetScale(scale)
        end
    end)
end







function WoWTools_TooltipMixin:Set_Init_Item(tooltip)--创建，设置，内容
    if not tooltip then
        return
    end

    Create(tooltip)

    if not tooltip.playerModel and not Save().hideModel then
        WoWTools_TooltipMixin:Set_PlayerModel(tooltip)
        tooltip.playerModel:SetShown(false)
    end
end







--清除，数据
function WoWTools_TooltipMixin:Set_Rest_Item(tooltip)
    if not tooltip.textLeft then
        return
    end

    tooltip.textLeft:SetText('')
    tooltip.text2Left:SetText('')
    tooltip.textRight:SetText('')
    tooltip.text2Right:SetText('')

    tooltip.textLeft:SetTextColor(1, 0.82, 0)
    tooltip.text2Left:SetTextColor(1, 0.82, 0)
    tooltip.textRight:SetTextColor(1, 0.82, 0)
    tooltip.text2Right:SetTextColor(1, 0.82, 0)

    --tooltip.Portrait:SetShown(false)
    tooltip.Portrait:SetTexture(0)
    tooltip:Set_BG_Color()
    if tooltip.playerModel then
        tooltip.playerModel:ClearModel()
        tooltip.playerModel:SetShown(false)
        tooltip.playerModel.id=nil
    end
    if tooltip.WoWHeadButton then
        tooltip.WoWHeadButton:rest()
        tooltip.AchievementButton:rest()
    end
end











--###########
--设置, 3D模型
--###########
function WoWTools_TooltipMixin:Set_Item_Model(tooltip, tab)--WoWTools_TooltipMixin:Set_Item_Model(tooltip, {unit=, guid=, creatureDisplayID=, animID=, appearanceID=, visualID=})--设置, 3D模型
    if Save().hideModel or not tooltip.playerModel then
        return
    end
    if tab.unit then
        if tooltip.playerModel.id~=tab.guid then--and tooltip.playerModel:CanSetUnit(tab.unit) then
            tooltip.playerModel:SetUnit(tab.unit)
            tooltip.playerModel.guid=tab.guid
            tooltip.playerModel.id=tab.guid
            tooltip.playerModel:SetShown(true)
        end

    elseif tab.creatureDisplayID  then
        if tooltip.playerModel.id~= tab.creatureDisplayID then
            tooltip.playerModel:SetDisplayInfo(tab.creatureDisplayID)
            if tab.spellVisualKitID then
                tooltip.playerModel:ApplySpellVisualKit(tab.spellVisualKitID)
            end
            if tab.animID then
                tooltip.playerModel:SetAnimation(tab.animID)
                tooltip.playerModel:PlayAnimKit(tab.animID, true)
            end
            tooltip.playerModel.id=tab.creatureDisplayID
            tooltip.playerModel:SetShown(true)

        end

    elseif tab.itemID then
        if tooltip.playerModel.id~=tab.itemID then
            if  tab.appearanceID and tab.visualID then
                tooltip.playerModel:SetItemAppearance(tab.visualID, tab.appearanceID)
            else
                tooltip.playerModel:SetItem(tab.itemID, tab.appearanceID, tab.visualID)
            end
            tooltip.playerModel.id= tab.itemID
            tooltip.playerModel:SetShown(true)
        end
    end
end
