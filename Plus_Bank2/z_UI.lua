if BankFrameTab2 then
    return
end
--[[
Enum.BankType.Character
Enum.BankType.Guild
Enum.BankType.Account
]]

local function Save()
    return WoWToolsSave['Plus_Bank2'] or {}
end

local function Init_Move(self)
    WoWTools_MoveMixin:Setup(BankFrame)

end

function WoWTools_MoveMixin.Frames:BankFrame()
    if Save().disabled then
        self:Setup(BankFrame)
    end
end


function WoWTools_TextureMixin.Frames:BankFrame()
    self:SetTabButton(BankFrame)
    self:SetButton(BankFrameCloseButton)
--钱
    self:HideFrame(BankPanel.MoneyFrame.Border)

--搜索框
    WoWTools_TextureMixin:SetEditBox(BankItemSearchBox)
    self:HideTexture(BankFrame.TopTileStreaks)

--背景
    self:HideFrame(BankFrame, {show={[BankFrame.Background]=true}})
    self:HideFrame(BankPanel)
    self:SetNineSlice(BankPanel, 0)
    self:HideFrame(BankPanel.EdgeShadows)

    self:HideFrame(BankPanel.MoneyFrame)

    self:Init_BGMenu_Frame(BankFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            BankFrame.Background:SetAlpha(alpha)
        end
    })
end







local function Init(self)

    Init_Move(self)
    Init=function()end
end

function WoWTools_BankMixin:Init_UI2()
    Init()
end