local BulkEntry = {}

function BulkEntry:OnInit()
    print("BulkEntry Mobile Init")
end

function BulkEntry:OnEnter()
    print("BulkEntry Mobile Enter")
end

function BulkEntry:SelectBuilding(thing)
    if thing == nil or thing.def == nil then return end
    if thing.def.Name ~= "Building_BookShelf_CangJing" then return end

    thing:RemoveBtnData("一键录入秘籍")
    thing:AddBtnData(
        "一键录入秘籍",
        "res/Sprs/ui/icon_luru01",
        "GameMain:GetMod('BulkEntry'):OnClick(bind,0)",
        "快速录入并清除当前地图上的全部秘籍",
        nil
    )

    thing:RemoveBtnData("一键录入功法")
    thing:AddBtnData(
        "一键录入功法",
        "res/Sprs/ui/icon_luru01",
        "GameMain:GetMod('BulkEntry'):OnClick(bind,1)",
        "快速录入已解锁但还未录入的全部功法",
        nil
    )
end

function BulkEntry:OnClick(t, type)
    local npc = nil

    local npcs = CS.XiaWorld.ThingMgr.Instance:GetNpcs()
    if npcs ~= nil then
        for i = 0, npcs.Count - 1 do
            local n = npcs[i]
            if n ~= nil and n.IsDisciple and n.CanDoDiscipleWork and n.GongKind ~= 1 and n.GongKind ~= 2 then
                npc = n
                break
            end
        end
    end

    if npc == nil then
        CS.XiaWorld.WorldLuaHelper():ShowMsgBox("ไม่พบศิษย์ที่ใช้งานได้", "BulkEntry")
        return
    end

    self:Execute(t, type, npc)
end

function BulkEntry:Execute(t, type, npc)
    local helper = CS.XiaWorld.WorldLuaHelper()

    if type == 0 then
        local things = CS.XiaWorld.ThingMgr.Instance:GetThingList(2)
        if things == nil then return end

        local full = false

        for i = 0, things.Count - 1 do
            local item = things[i]

            if item ~= nil and item.IsValid and item.Key ~= 0 and item.IsEsoterica and item.FreeCount > 0 then
                local esoId = item.EsotericaID

                if CS.XiaWorld.CangJingGeMgr.Instance:CheckEso(esoId) then
                    helper:FlyLineEffect(item.Key, t.Key, 1, nil, nil, nil, nil, "Effect/System/FlyLine")
                    CS.XiaWorld.ThingMgr.Instance:RemoveThing(item, false, false)
                else
                    local sysEso = CS.XiaWorld.EsotericaMgr.Instance:GetSysEsoterica(esoId, true)
                    if sysEso ~= nil then
                        local esoDef = CS.XiaWorld.EsotericaMgr.Instance:GetEsotericaDef(sysEso.TID, true)
                        if esoDef ~= nil and esoDef.Hide == 0 then
                            if sysEso.Difficulty > CS.XiaWorld.CangJingGeMgr.Instance.GetFreeMemorySize then
                                full = true
                                break
                            end

                            CS.XiaWorld.CangJingGeMgr.Instance:AddEsoterica(esoId, npc)
                            helper:FlyLineEffect(item.Key, t.Key, 1, nil, nil, nil, nil, "Effect/System/FlyLine")
                            CS.XiaWorld.ThingMgr.Instance:RemoveThing(item, false, false)
                        end
                    end
                end
            end
        end

        if full then
            helper:ShowMsgBox("容量不足，只录入了部分秘籍。", "提示")
        else
            helper:ShowMsgBox("录入秘籍完成。", "提示")
        end

    else
        local msg = "成功录入以下功法：\n"
        local count = 0
        local full = false

        local gongList = CS.XiaWorld.SchoolMgr.Instance.GongList

        for i = 0, gongList.Count - 1 do
            local gongName = gongList[i]
            local gongDef = CS.XiaWorld.PracticeMgr.Instance:GetGongDef(gongName)

            if gongDef ~= nil and gongDef.Hide ~= 3 and gongDef.GongKind ~= 1 and gongDef.GongKind ~= 2 then
                if not CS.XiaWorld.CangJingGeMgr.Instance:CheckGongHas(gongName) then
                    count = count + 1

                    if CS.XiaWorld.CangJingGeMgr.Instance:GetGongEsoInfos(gongName, nil, false) > CS.XiaWorld.CangJingGeMgr.Instance.GetFreeMemorySize then
                        full = true
                        break
                    end

                    CS.XiaWorld.CangJingGeMgr.Instance:AddGong(gongName, npc)
                    msg = msg .. "∟" .. gongDef.DisplayName .. "\n"
                end
            end
        end

        if count < 1 then
            msg = "没有需要录入功法"
        elseif full then
            msg = msg .. "由于容量不足停止录入"
        end

        helper:ShowMsgBox(msg, "提示")
    end
end

return BulkEntry