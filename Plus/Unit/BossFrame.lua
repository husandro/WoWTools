--BossFrame
--EditModeManagerFrame:IsEditModeActive()


local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideBossFrame then
        return
    end


    for i=1, MAX_BOSS_FRAMES do
        local name= 'Boss'..i..'TargetFrame'
        local frame= _G[name]
        if frame then

            frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，颜色，材质

            --Create_BossButton(frame)--Boss图标，按钮
            WoWTools_UnitMixin:CreateUnitButton(frame, {
                name= name,
                point=function(btn, f)
                    btn:SetPoint('LEFT', f.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer, 'RIGHT')
                end,
            })

            local btn= WoWTools_UnitMixin:CreateUnitButton(frame, {
                name= name,
                size=23,
                isTarget= true,
            })
            local bar= _G[name..'SpellBar']
            if bar and btn then
                bar.TotButton= btn
                function bar:Set_TotPoint()
                    self.TotButton:ClearAllPoints()
                    if self.castBarOnSide then
                        self.TotButton:SetPoint('RIGHT', self, 'LEFT')
                        self.TotButton.texture:SetTexCoord(0,1,0,1)
                    else
                        self.TotButton:SetPoint('LEFT', self, 'RIGHT')
                        self.TotButton.texture:SetTexCoord(1,0,0,1)
                    end
                end

                WoWTools_DataMixin:Hook(bar, 'AdjustPosition', function(self)
                    if self.TotButton:CanChangeAttribute() then
                        self:Set_TotPoint()

                    elseif not self.batOwnerID then
                        self.batOwnerID= EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                            self:Set_TotPoint()
                            self.batOwnerID= nil
                            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
                        end)
                    end
                end)
            end
        end
    end


    Init=function()end
end




function WoWTools_UnitMixin:Init_BossFrame()--BOSS
    Init()
end