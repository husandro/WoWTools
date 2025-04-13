--挑战, 钥匙插入， 界面
function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI()
    self:SetAlphaColor(ChallengesFrameInset.Bg)

    self:SetNineSlice(ChallengesFrameInset)
    self:SetFrame(ChallengesKeystoneFrame, {index=1})
    self:HideTexture(ChallengesKeystoneFrame.InstructionBackground)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(frame)--钥匙插入， 界面
        self:SetFrame(frame, {index=1})
        self:HideTexture(frame.InstructionBackground)
    end)
end