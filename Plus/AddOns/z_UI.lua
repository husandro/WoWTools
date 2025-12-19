
--插件，管理
function WoWTools_TextureMixin.Events:Blizzard_AddOnList()
    --AddonListCloseButton:SetFrameLevel(AddonList.TitleContainer:GetFrameLevel()+1)

    self:SetUIButton(AddonList.EnableAllButton)
    self:SetUIButton(AddonList.DisableAllButton)
    self:SetUIButton(AddonList.OkayButton)
    self:SetUIButton(AddonList.CancelButton)

    self:SetCheckBox(AddonList.ForceLoad)

    self:SetNineSlice(AddonList)
    self:SetScrollBar(AddonList)
    self:HideFrame(AddonList)

    self:SetNineSlice(AddonListInset)
    self:SetAlphaColor(AddonListInset.Bg, nil, nil, 0.3)

    self:SetMenu(AddonList.Dropdown)
    self:SetEditBox(AddonList.SearchBox)
    self:SetButton(AddonListCloseButton)
    self:SetAlphaColor(AddonList.Performance.Divider, true)

    WoWTools_DataMixin:Hook(AddonListEntryMixin, 'OnLoad', function(frame)
        self:SetCheckBox(frame.Enabled)
    end)

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



    WoWTools_MoveMixin:Setup(AddonList, {
        minW=430, minH=120,
    sizeRestFunc=function(frame)
        frame:SetSize(500, 480)
    end})

end
