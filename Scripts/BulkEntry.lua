require('Scripts/lib.lua')

local BulkEntry = GameMain:NewMod("BookSearch")

function BulkEntry:OnEnter()
    print("BookSearch OnEnter")

    local Event = GameMain:GetMod("_Event")
    if Event == nil then
        print("_Event not found")
        return
    end

    Event:RegisterEvent(g_emEvent.SelectItem,
    function(evt, thing, objs)
        self:SelectBuilding(thing)
    end, "BookSearch")
end

function BulkEntry:SelectBuilding(thing)
    if thing == nil or thing.def == nil then return end

    print("Select thing: " .. tostring(thing.def.Name))

    if thing.def.Name ~= "Building_BookShelf_CangJing" then return end

    thing:RemoveBtnData("บันทึกคัมภีร์")
    thing:AddBtnData(
        "บันทึกคัมภีร์",
        "res/Sprs/ui/icon_hand",
        "GameMain:GetMod('BookSearch'):OnClick(bind,0)",
        "บันทึกคัมภีร์ทั้งหมดบนแผนที่เข้าหอคัมภีร์",
        nil
    )

    thing:RemoveBtnData("บันทึกวิชา")
    thing:AddBtnData(
        "บันทึกวิชา",
        "res/Sprs/ui/icon_hand",
        "GameMain:GetMod('BookSearch'):OnClick(bind,1)",
        "บันทึกวิชาที่ปลดล็อกแล้วเข้าหอคัมภีร์",
        nil
    )
end

function BulkEntry:GetWorkNpc()
    local list = CS.XiaWorld.ThingMgr.Instance:GetThingList(g_emThingType.Npc)
    if list == nil then return nil end

    for i = 0, list.Count - 1 do
        local npc = list[i]
        if npc ~= nil and npc.IsDisciple and npc.CanDoDiscipleWork and npc.GongKind ~= 1 and npc.GongKind ~= 2 then
            return npc
        end
    end

    return nil
end

function BulkEntry:OnClick(t, type)
    local npc = self:GetWorkNpc()

    if npc == nil then
        CS.XiaWorld.WorldLuaHelper():ShowMsgBox("ไม่พบศิษย์ที่ใช้งานได้", "BookSearch")
        return
    end

    self:Execute(t, type, npc)
end

function BulkEntry:Execute(t, type, npc)
    local helper = CS.XiaWorld.WorldLuaHelper()

    if type == 0 then
        local things = CS.XiaWorld.ThingMgr.Instance:GetThingList(g_emThingType.Item)
        if things == nil then return end

        local full = false
        local count = 0

        for i = things.Count - 1, 0, -1 do
            local item = things[i]

            if item ~= nil and item.IsValid and item.Key ~= 0 and item.IsEsoterica and item.FreeCount > 0 then
                local esoId = item.EsotericaID

                if CS.XiaWorld.CangJingGeMgr.Instance:CheckEso(esoId) then
                    CS.XiaWorld.ThingMgr.Instance:RemoveThing(item, false, false)
                    count = count + 1
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
                            CS.XiaWorld.ThingMgr.Instance:RemoveThing(item, false, false)
                            count = count + 1
                        end
                    end
                end
            end
        end

        if full then
            helper:ShowMsgBox("容量不足，只录入了部分秘籍。", "提示")
        else
            helper:ShowMsgBox("录入秘籍完成，共录入/清除 " .. tostring(count) .. " 本秘籍。", "提示")
        end

    else
        local msg = "成功录入以下功法：\n"
        local count = 0
        local full = false

        local gongList = CS.XiaWorld.SchoolMgr.Instance.GongList
        if gongList == nil then
            helper:ShowMsgBox("ไม่พบรายการ功法", "提示")
            return
        end

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
                    msg = msg .. "∟" .. tostring(gongDef.DisplayName) .. "\n"
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