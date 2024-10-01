---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field
--[[

'|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
'|A:PetJournal-FavoritesIcon:0:0|a'..(e.onlyChinese and '收藏' or FAVORITES)
'|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL)
'|A:characterundelete-RestoreButton:0:0|a'..(e.onlyChinese and '重置位置' or RESET_POSITION)

e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
e.onlyChinese and '打开选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS)

HUD_EDIT_MODE_EXPAND_OPTIONS = "展开选项 |A:editmode-down-arrow:16:11:0:-7|a";
HUD_EDIT_MODE_COLLAPSE_OPTIONS = "收起选项 |A:editmode-up-arrow:16:11:0:3|a";
]]