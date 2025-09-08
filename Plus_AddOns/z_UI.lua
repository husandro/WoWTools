
--插件，管理
function WoWTools_TextureMixin.Events:Blizzard_AddOnList()
    self:SetNineSlice(AddonList)
    self:SetScrollBar(AddonList)
    self:HideFrame(AddonList)

    self:SetNineSlice(AddonListInset)
    self:SetAlphaColor(AddonListInset.Bg, nil, nil, 0.3)

    self:SetMenu(AddonList.Dropdown)
    self:SetEditBox(AddonList.SearchBox)
    self:SetButton(AddonListCloseButton)
    self:SetAlphaColor(AddonList.Performance.Divider, true)


    self:Init_BGMenu_Frame(AddonList, {
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', AddonListCloseButton, 'LEFT', -23, 0)
        end,
    })
end









--插件
function WoWTools_MoveMixin.Events:Blizzard_AddOnList()
    AddonList.ScrollBox:ClearAllPoints()
    AddonList.ScrollBox:SetPoint('LEFT', 7, 0)
    AddonList.ScrollBox:SetPoint('TOP', AddonList.Performance, 'BOTTOM')
    AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)

    for _, text in pairs({AddonList.ForceLoad:GetRegions()}) do
        if text:GetObjectType()=="FontString" then
            text:SetText('')
            text:ClearAllPoints()
            AddonList.ForceLoad:HookScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '加载过期插件' or ADDON_FORCE_LOAD)
                GameTooltip:Show()
            end)
            AddonList.ForceLoad:HookScript('OnLeave', GameTooltip_Hide)

            AddonList.SearchBox:ClearAllPoints()
            AddonList.SearchBox:SetPoint('LEFT', AddonList.ForceLoad, 'RIGHT', 6,0)
            AddonList.SearchBox:SetPoint('RIGHT', -42, 0)
            break
        end
    end

    WoWTools_MoveMixin:Setup(AddonList, {minW=430, minH=120, setSize=true,
    sizeRestFunc=function()
        AddonList:SetSize(500, 480)
    end})

    AddonList.ForceLoad:ClearAllPoints()
    AddonList.ForceLoad:SetPoint('LEFT', AddonList.Dropdown, 'RIGHT', 23,0)
end
