
local function Save()
    return WoWToolsSave['Plus_Tootips']
end









function WoWTools_TooltipMixin:Set_PlayerModel(tooltip)
    if not tooltip.playerModel then
        tooltip.playerModel= CreateFrame("PlayerModel", nil, tooltip)--PlayerModel ModelScene DressUpModel PlayerModel        
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
    if tooltip.textLeft then
        return
    end


    tooltip.textLeft=WoWTools_LabelMixin:Create(tooltip, {size=16})
    tooltip.textLeft:SetPoint('BOTTOMLEFT', tooltip, 'TOPLEFT')

    tooltip.text2Left=WoWTools_LabelMixin:Create(tooltip, {size=16})--左上角字符2
    tooltip.text2Left:SetPoint('LEFT', tooltip.textLeft, 'RIGHT', 5, 0)

    tooltip.textRight=WoWTools_LabelMixin:Create(tooltip, {size=12, justifyH='RIGHT'})--右上角字符
    if tooltip.CloseButton then
        tooltip.textRight:SetPoint('BOTTOMRIGHT', tooltip, 'TOPRIGHT', 0, 3)
    else
        tooltip.textRight:SetPoint('BOTTOMRIGHT', tooltip, 'TOPRIGHT')
    end

    tooltip.text2Right= WoWTools_LabelMixin:Create(tooltip, {size=12, justifyH='RIGHT'})--右上角字符2
    tooltip.text2Right:SetPoint('BOTTOMRIGHT', tooltip.textRight, 'TOPRIGHT', 0, 4)

    tooltip.backgroundColor= tooltip:CreateTexture(nil, 'BACKGROUND',nil, 1)--背景颜色
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
        --self:SetBackdropBorderColor(r,g,b,a)--SharedTooltipTemplates.lua
        self.backgroundColor:SetShown(show)
    end
    --tooltip.backgroundColor:SetAllPoints(tooltip)

    if not tooltip.Portrait then
        tooltip.Portrait= tooltip:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
        if tooltip.CloseButton then
            tooltip.Portrait:SetPoint('TOPRIGHT', tooltip.CloseButton, 'BOTTOMRIGHT', -6, 0)
        else
            tooltip.Portrait:SetPoint('TOPRIGHT',-2, -3)
        end
        tooltip.Portrait:SetSize(40,40)
    end

    tooltip:HookScript("OnHide", function(self)--隐藏
        WoWTools_TooltipMixin:Set_Rest_Item(self)--清除，数据
    end)

--function WoWTools_TextureMixin:SetNineSlice(frame, min, hide, notAlpha, notBg)
    --WoWTools_TextureMixin:SetNineSlice(tooltip, nil, true, true, true)

    --[[tooltip.IconMask= tooltip.IconMask or tooltip:CreateMaskTexture()
    tooltip.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')--'spellbook-item-spellicon-mask'
    tooltip.IconMask:SetPoint('TOPLEFT', tooltip, 0.5, -0.5)
    tooltip.IconMask:SetPoint('BOTTOMRIGHT', tooltip, -0.5, 0.5)
    tooltip.backgroundColor:AddMaskTexture(tooltip.IconMask)]]
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

    tooltip.Portrait:SetShown(false)
    --tooltip.backgroundColor:SetShown(false)
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
            if tab.animID then
                tooltip.playerModel:SetAnimation(tab.animID, true)
            end
            print(tab.animID)
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
