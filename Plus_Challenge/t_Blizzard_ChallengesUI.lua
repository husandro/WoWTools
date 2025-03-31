local function Init(mixin)
    mixin:SetAlphaColor(ChallengesFrameInset.Bg)

    mixin:SetFrame(ChallengesKeystoneFrame, {index=1})
    mixin:HideTexture(ChallengesKeystoneFrame.InstructionBackground)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(self)--钥匙插入， 界面
        mixin:SetFrame(self, {index=1})
        mixin:HideTexture(self.InstructionBackground)
    end)

    Init=function()end
end







function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI(mixin)--挑战, 钥匙插入， 界面
   Init(mixin)
end