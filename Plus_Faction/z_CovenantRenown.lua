local function Save()
	return WoWTools_ReputationMixin.Save
end















--盟约 9.0
local function Set_Covenant_Button(frame, covenantID)
    local info = C_Covenants.GetCovenantData(covenantID) or {}

    local btn=WoWTools_ButtonMixin:Cbtn(frame , {size={32,32}, atlas=format('SanctumUpgrades-%s-32x32', info.textureKit or '')})

    btn:SetHighlightAtlas('ChromieTime-Button-HighlightForge-ColorSwatchHighlight')

    if covenantID==1 then
        btn:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 5)
    else
        btn:SetPoint('LEFT', frame.CovenantButtons[covenantID-1], 'RIGHT')
    end
    btn:SetScript('OnClick', function(self)
        WoWTools_LoadUIMixin:CovenantRenown(self)
        self:settings()
    end)

    btn.Text=WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
    btn.Text:SetPoint('CENTER')
    btn.covenantID= covenantID
    frame.CovenantButtons[covenantID]=btn


    function btn:settings()
        local activityID = C_Covenants.GetActiveCovenantID() or 0

        local level=0
        local isMaxLevel

        if covenantID==activityID then
            btn:LockHighlight()
            level= C_CovenantSanctumUI.GetRenownLevel()
            isMaxLevel= C_CovenantSanctumUI.HasMaximumRenown()
        else
            btn:UnlockHighlight()
            local tab = C_CovenantSanctumUI.GetRenownLevels(covenantID) or {}
            local num= #tab
            for i=num, 1, -1 do
                if not tab[i].locked then
                    level= tab[i].level
                    isMaxLevel= i==num
                    break
                end
            end
        end

        btn.Text:SetText(isMaxLevel and format('|cnGREEN_FONT_COLOR:%d|r', level) or level)
        btn.renownLevel= level
    end

    btn:SetScript('OnShow', btn.settings)

    btn:settings()

    return btn
 end


















local function Init(frame)
    frame.CovenantButtons={}
    for covenantID=1, 4 do
        Set_Covenant_Button(frame, covenantID)
    end


    --[[frame:HookScript('OnShow', function(self)
        for _, btn in pairs(self.Buttons) do
            btn:SetShown(not Save().hide_MajorFactionRenownFrame_Button)
        end
    end)]]
end











--盟约 9.0
function WoWTools_ReputationMixin:Init_CovenantRenown(frame)
    Init(frame)
end
