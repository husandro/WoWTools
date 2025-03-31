function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI(mixin)--挑战, 钥匙插入， 界面
    mixin:SetAlphaColor(ChallengesFrameInset.Bg)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(self2)--钥匙插入， 界面
        mixin:SetFrame(self2, {index=1})
        mixin:HideTexture(self2.InstructionBackground)
    end)
end