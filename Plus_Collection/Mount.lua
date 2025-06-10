


local function Save()
    return WoWToolsSave['Plus_Collection']
end








local Button

local function UpdateMountDisplay()
    Button= WoWTools_ButtonMixin:Cbtn(MountJournal.MountDisplay, {size=22, atlas='QuestNormal'})
    Button:SetPoint('BOTTOMRIGHT', MountJournal.MountDisplay.ModelScene.TogglePlayer, 'TOPRIGHT',0, 2)

    Button.text= WoWTools_LabelMixin:Create(MountJournal.MountDisplay, {
        copyFont= MountJournal.MountCount.Label,
        color=false,
        justifyH='LEFT'
    })
    Button.text:SetPoint('TOPLEFT', MountJournalLore, 'BOTTOMLEFT',  0, -4)

    function Button:set_Alpha()
        self:SetAlpha(Save().ShowMountDisplayInfo and 0.2 or 1)
    end
    function Button:set_Tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '显示信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INFO), WoWTools_TextMixin:GetShowHide(not Save().ShowMountDisplayInfo))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
        GameTooltip:Show()
    end
    function Button:set_Text()
        local text
        if Save().ShowMountDisplayInfo then
            local creatureDisplayInfoID, _, _, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)
            text= 'mountID |cffffffff'..MountJournal.selectedMountID
                ..'|r|nanimID |cffffffff'..(animID or '')
                ..'|r|nisSelfMount |cffffffff'.. (isSelfMount and 'true' or 'false')
                ..'|r|nmountTypeID |cffffffff'..(mountTypeID or '')
                ..'|r|nspellVisualKitID |cffffffff'..(spellVisualKitID or '')
                ..'|r|nuiModelSceneID |cffffffff'..(uiModelSceneID or '')
                ..'|r|ncreatureDisplayInfoID |cffffffff'..(creatureDisplayInfoID or '')

                local _, spellID, icon, _, _, sourceType= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                text= text..'|n|rspellID |cffffffff'..(spellID or '')
                            ..'|n|ricon |cffffffff'..(icon and '|T'..icon..':0:0|t'..icon or '')
                            ..'|n|rsourceType |cffffffff'..(WoWTools_TextMixin:CN(sourceType) or '').. (sourceType and WoWTools_TextMixin:CN(_G['BATTLE_PET_SOURCE_'..sourceType]) and ' ('..WoWTools_TextMixin:CN(_G['BATTLE_PET_SOURCE_'..sourceType])..')' or '')
        end
        self.text:SetText(text or '')
    end
    Button:SetScript('OnClick', function(self)
        Save().ShowMountDisplayInfo= not Save().ShowMountDisplayInfo and true or nil
        self:set_Text()
        self:set_Alpha()
        self:set_Tooltips()
    end)
    Button:SetScript('OnLeave', GameTooltip_Hide)
    Button:SetScript('OnEnter', Button.set_Tooltips)
    Button:set_Alpha()

    Button:set_Text()

    UpdateMountDisplay=function()
        if MountJournal:IsVisible() then
            Button:set_Text()
        end
    end
end















--#########
--坐骑, 界面
--#########
local function Init()
    hooksecurefunc('MountJournal_UpdateMountDisplay',  function()--坐骑
        UpdateMountDisplay()
    end)

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