

local function Save()
    return WoWToolsSave['Tools_OpenItems']
end










local function Set_Att(self, bag, slot, icon, itemID, spellID, isUseMacro)--设置属性
    if self.isDisabled then
        return
    elseif not self:CanChangeAttribute()  then
        self.isInCombat=true
        return
    end


    local num
    if bag and slot then
        if spellID then
            self:SetAttribute('type1', 'spell')
            self:SetAttribute('spell1', C_Spell.GetSpellName(spellID) or spellID)
            self:SetAttribute('target-item', bag..' '..slot)

        elseif isUseMacro then
            self:SetAttribute('type1', 'macro')
            self:SetAttribute("macrotext1", '/use '..bag..' '..slot)
            self:SetAttribute('target-item', nil)

        else
            self:SetAttribute('type1', 'item')
            self:SetAttribute('item1', (bag..' '..slot))
            self:SetAttribute('target-item', nil)
        end

        num = C_Item.GetItemCount(itemID)
        num= num~=1 and num or ''
        self:SetShown(true)
        self:SetBagAndSlot(bag, slot)

    else
        self:SetAttribute('type1', nil)
        self:SetAttribute('item1', nil)
        self:SetAttribute('spell1', nil)
        self:SetAttribute('macrotext1', nil)
        self:SetAttribute('target-item', nil)
        self:Clear()
    end




    self.count:SetText(num or '')

    if icon then
        self.texture:SetTexture(icon)
    else
        self.texture:SetAtlas('BonusLoot-Chest')
    end
    self.texture:SetAlpha(icon and 1 or 0.3)

    self:set_key(not bag or not slot)

    self.IsInCheck=nil
end
















local function Get_Items(self)--取得背包物品信息
    if self.IsInCheck then
        return
    elseif not self:CanChangeAttribute() then
        self.isInCombat=true
        return
    end

    self.IsEquipItem=nil--是装备时, 打开角色界面
    self.IsInCheck=nil
    self:Clear()


    local itemMinLevel, classID, subclassID, _, info
    local bagMax= Save().reagent and (NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES ) or NUM_BAG_FRAMES
    for bag= Enum.BagIndex.Backpack, bagMax do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            info = C_Container.GetContainerItemInfo(bag, slot)

            local duration, enable
            if info and info.itemID then
                itemMinLevel, _, _, _, _, _, _, classID, subclassID= select(5, C_Item.GetItemInfo(info.itemID))
                duration, enable = select(2, C_Container.GetContainerItemCooldown(bag, slot))
            end


            if info
                and info.itemID
                and info.hyperlink
                and not info.isLocked
                and info.iconFileID
                and (not Save().no[info.itemID] or Save().use[info.itemID])--禁用使用
                --and C_PlayerInfo.CanUseItem(info.itemID)--是否可使用
                and not (duration and duration>2 or enable==0) and classID~=8--冷却
                and ((itemMinLevel and itemMinLevel<=WoWTools_DataMixin.Player.Level) or not itemMinLevel)--使用等级
                and classID~=13
            then
                --WoWTools_Mixin:Load({id=info.itemID, type='item'})
                if Save().use[info.itemID] then--自定义
                    if Save().use[info.itemID]<=info.stackCount then
                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                        return
                    end

                elseif C_Item.IsCosmeticItem(info.hyperlink) then--装饰品
                    if Save().mago then--and not C_Item.IsCosmeticItem(info.itemID) then --and info.quality then
                        local  isCollected, isSelf= select(2, WoWTools_CollectedMixin:Item(info.hyperlink, nil, nil, true))
                        if not isCollected and isSelf then
                            Set_Att(self, bag, slot, info.iconFileID, info.itemID, nil, true)
                            return
                        end
                    end

                elseif C_Item.IsCurioItem(info.hyperlink) then--珍玩 SPELL_FAILED_CUSTOM_ERROR_1042 = "你的收藏中已经有了这个珍玩。";
                    local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, text={SPELL_FAILED_CUSTOM_ERROR_1042}, onlyText=true})
                    if not dateInfo.text[SPELL_FAILED_CUSTOM_ERROR_1042] then
                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                        return
                    end


                elseif classID==4 or classID==2 then-- itemEquipLoc and _G[itemEquipLoc] then--幻化
                    if Save().mago then--and not C_Item.IsCosmeticItem(info.itemID) then --and info.quality then
                        local  isCollected, isSelf= select(2, WoWTools_CollectedMixin:Item(info.hyperlink, nil, nil, true))
                        if not isCollected and isSelf then
                            Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                            self.IsEquipItem= true
                            return
                        end
                    end

                else
                    local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, red=true, text={LOCKED}})
                    if not dateInfo.red and C_PlayerInfo.CanUseItem(info.itemID) then--是否可使用 then--不出售, 可以使用

                       if info.hasLoot then--可打开
                            if Save().open then
                                if dateInfo.text[LOCKED] and WoWTools_DataMixin.Player.Class=='ROGUE' then--DZ
                                    Set_Att(self, bag, slot, info.iconFileID, info.itemID, 1804)--开锁 Pick Lock
                                else--if not dateInfo.text[LOCKED] then
                                    Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                end
                                return
                            end

                        elseif classID==9 then--配方                    
                            if Save().ski then
                                if subclassID == 0 then
                                    if C_Item.GetItemSpell(info.hyperlink) then
                                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                    end
                                else
                                    Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                end
                                return
                            end

                        elseif classID==15 and  subclassID==5 then--坐骑
                            if Save().mount then
                                local mountID = C_MountJournal.GetMountFromItem(info.itemID)
                                if mountID then
                                    local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                                    if not isCollected then
                                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                        return
                                    end
                                end
                            end

                        elseif C_ToyBox.GetToyInfo(info.itemID) then
                            if Save().toy and not PlayerHasToy(info.itemID) then--玩具 
                                Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                return
                            end

                        elseif info.hyperlink:find('Hbattlepet:(%d+)') or (classID==15 and subclassID==2) then--宠物, 收集数量
                            if Save().pet then
                                local speciesID = info.hyperlink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(info.itemID))--宠物物品                        
                                if speciesID then
                                    local numCollected, limit= C_PetJournal.GetNumCollectedInfo(speciesID)
                                    if numCollected and limit and numCollected <  limit then
                                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                        return
                                    end
                                end
                            end

                        elseif Save().alt
                            and C_Item.IsUsableItem(info.hyperlink)
                            and ((classID~=12 and (classID==0 and subclassID==8 or classID~=0))
                           or (classID==15 and subclassID==4)
                        )
                        then-- 8 使用: 在龙鳞探险队中的声望提高1000点
                            local spell= select(2, C_Item.GetItemSpell(info.hyperlink))
                            if spell and not C_Item.IsAnimaItemByID(info.hyperlink) then
                                --and C_Spell.IsSpellUsable(spell)
                                if info.itemID==207002 then--封装命运
                                    if not WoWTools_AuraMixin:Get('player', {[415603]=true}) then
                                        Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                        return
                                    end
                                else
                                    Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
                            end
                        elseif WoWTools_DataMixin.Is_Timerunning and (info.itemID>=219256 and info.itemID<=219282) then--将帛线织入你的永恒潜能披风，使你获得的经验值永久提高12%。
                            Set_Att(self, bag, slot, info.iconFileID, info.itemID)
                            return
                        end
                    end
                end
            end
        end
    end

    Set_Att(self)

    self:set_key(true)
end













function WoWTools_OpenItemMixin:Get_Item()
    Get_Items(self.OpenButton)--取得背包物品信息
end

