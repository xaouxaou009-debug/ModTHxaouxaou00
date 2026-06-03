require('Scripts/lib.lua')

local BookSearch = GameMain:NewMod("BookSearch");

function BookSearch:OnEnter()
	print("BookSearch OnEnter");
	self.mod_enable = true;

	local Event = GameMain:GetMod("_Event");

	Event:RegisterEvent(g_emEvent.SelectItem,
	function(evt, thing, objs)
		self:AddBtn2BookShelf(evt, thing, objs);
	end, "BookSearch");

	Event:RegisterEvent(g_emEvent.SelectThing,
	function(evt, thing, objs)
		self:AddBtn2BookShelf(evt, thing, objs);
	end, "BookSearch");

	Event:RegisterEvent(g_emEvent.SelectBuilding,
	function(evt, thing, objs)
		self:AddBtn2BookShelf(evt, thing, objs);
	end, "BookSearch");
end

function BookSearch:AddBtn2BookShelf(evt, thing, objs)
	if thing == nil then
		return;
	end

	print("BookSearch select thing");
	print(thing);

	if thing.def ~= nil then
		print("DefName = " .. tostring(thing.def.Name));
	end

	if thing.def == nil then
		return;
	end

	if thing.def.Name ~= "Building_BookShelf_CangJing" then
		return;
	end

	thing:RemoveBtnData("บันทึกคัมภีร์");
    thing:AddBtnData(
        "บันทึกคัมภีร์",
        "res/Sprs/ui/icon_hand",
        "GameMain:GetMod('BookSearch'):LuRuMiJi(bind)",
        "บันทึกคัมภีร์ทั้งหมดบนแผนที่เข้าหอคัมภีร์",
        nil
	);

    thing:RemoveBtnData("บันทึกวิชา");
    thing:AddBtnData(
        "บันทึกวิชา",
        "res/Sprs/ui/icon_hand",
        "GameMain:GetMod('BookSearch'):LuRuGongFa(bind)",
        "บันทึกวิชาที่ปลดล็อกแล้วเข้าหอคัมภีร์",
        nil
    );

	print("BookSearch button added");
end

function BookSearch:TestBtn(thing)
	CS.XiaWorld.WorldLuaHelper():ShowMsgBox("ปุ่มหอคัมภีร์ใช้ได้แล้ว", "BookSearch");
end

function BookSearch:LuRuMiJi(thing)
    CS.XiaWorld.WorldLuaHelper():ShowMsgBox(
        "ขั้นต่อไปคือใส่ระบบค้นหาคัมภีร์บนแผนที่แล้ว AddEsoterica",
        "BookSearch"
    );
end

function BookSearch:LuRuGongFa(thing)
    CS.XiaWorld.WorldLuaHelper():ShowMsgBox(
        "ขั้นต่อไปคือใส่ระบบวน GongList แล้ว AddGong",
        "BookSearch"
    );
end