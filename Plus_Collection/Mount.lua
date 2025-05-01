


local function Save()
    return WoWToolsSave['Plus_Collection']
end










local function UpdateMountDisplay()
    if not MountJournal:IsVisible() then
        return
    end
    
    if not MountJournal.MountDisplay.tipButton then
        MountJournal.MountDisplay.tipButton= WoWTools_ButtonMixin:Cbtn(MountJournal.MountDisplay, {size=22, atlas='QuestNormal'})
        MountJournal.MountDisplay.tipButton:SetPoint('BOTTOMRIGHT', MountJournal.MountDisplay.ModelScene.TogglePlayer, 'TOPRIGHT',0, 2)
        MountJournal.MountDisplay.tipButton.text= WoWTools_LabelMixin:Create(MountJournal.MountDisplay, {copyFont= MountJournal.MountCount.Label, color=false, justifyH='LEFT'})
        MountJournal.MountDisplay.tipButton.text:SetPoint('BOTTOMLEFT', 2, 2)

        function MountJournal.MountDisplay.tipButton:set_Alpha()
            self:SetAlpha(Save().ShowMountDisplayInfo and 0.2 or 1)
        end
        function MountJournal.MountDisplay.tipButton:set_Tooltips()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '显示信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INFO), WoWTools_TextMixin:GetShowHide(not Save().ShowMountDisplayInfo))
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
            GameTooltip:Show()
        end
        function MountJournal.MountDisplay.tipButton:set_Text()
            local text
            if Save().ShowMountDisplayInfo then
                local creatureDisplayInfoID, _, _, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)
                text= 'mountID '..MountJournal.selectedMountID
                    ..'|nanimID '..(animID or '')
                    ..'|nisSelfMount '.. (isSelfMount and 'true' or 'false')
                    ..'|nmountTypeID '..(mountTypeID or '')
                    ..'|nspellVisualKitID '..(spellVisualKitID or '')
                    ..'|nuiModelSceneID '..(uiModelSceneID or '')
                    ..'|ncreatureDisplayInfoID '..(creatureDisplayInfoID or '')

                    local _, spellID, icon, _, _, sourceType= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                    text= text..'|nspellID '..(spellID or '')
                                ..'|nicon '..(icon and '|T'..icon..':0:0|t'..icon or '')
                                ..'|nsourceType '..(WoWTools_TextMixin:CN(sourceType) or '').. (sourceType and WoWTools_TextMixin:CN(_G['BATTLE_PET_SOURCE_'..sourceType]) and ' ('..WoWTools_TextMixin:CN(_G['BATTLE_PET_SOURCE_'..sourceType])..')' or '')
            end
            self.text:SetText(text or '')
        end
        MountJournal.MountDisplay.tipButton:SetScript('OnClick', function(self)
            Save().ShowMountDisplayInfo= not Save().ShowMountDisplayInfo and true or nil
            self:set_Text()
            self:set_Alpha()
            self:set_Tooltips()
        end)
        MountJournal.MountDisplay.tipButton:SetScript('OnLeave', GameTooltip_Hide)
        MountJournal.MountDisplay.tipButton:SetScript('OnEnter', MountJournal.MountDisplay.tipButton.set_Tooltips)
        MountJournal.MountDisplay.tipButton:set_Alpha()
    end
    MountJournal.MountDisplay.tipButton:set_Text()
end















--#########
--坐骑, 界面
--#########
local function Init()
    hooksecurefunc('MountJournal_UpdateMountDisplay', UpdateMountDisplay)--坐骑

    --总数
    MountJournal.MountCount.Count:SetPoint('RIGHT', -4,0)
    hooksecurefunc('MountJournal_UpdateMountList', function()
        if not MountJournal:IsVisible() then
            return
        end
        local numMounts = C_MountJournal.GetNumMounts() or 0
        if numMounts>1 then
            local mountIDs = C_MountJournal.GetMountIDs() or {}
            MountJournal.MountCount.Count:SetText(MountJournal.numOwned..'/'..#mountIDs)
        end
    end)
end














function WoWTools_CollectionMixin:Init_Mount()--坐骑 1
    Init()
end