lblInfo= UI.Label("-- [[ UTILIDADES ]] --")
lblInfo:setColor("green")

UI.Separator() 

---------bug map com auto escada

Stairs = {}
Stairs.Exclude = {12099}
Stairs.Click = {1948, 435, 7771, 5542, 8657, 6264, 1646, 1648, 1678, 5291, 1680, 6905, 6262, 1664, 13296, 1067, 13861, 11931, 12097, 1949, 11932, 11115}	

--



OutfitCheck = function()
	return player:getOutfit().type == tonumber(OutfitBijuu)
end

function Keys(x)
	return modules.corelib.g_keyboard.isKeyPressed(x)
end

Stairs.postostring = function(pos)
    return(pos.x .. ',' .. pos.y .. ',' .. pos.z)
end

Stairs.getTiles = function(distance)
	if not read then return end
    local tiles = {}
    if not distance then distance = 9 end
    for posX = pos().x - distance, pos().x + distance do
        for posY = pos().y - distance, pos().y + distance do
            local tile = g_map.getTile({x = posX, y = posY, z = pos().z})
            if tile then
                table.insert(tiles, tile)
            end
        end
    end
    return tiles
end

function Stairs.accurateDistance(c)
	if not read then return end
    if type(c) == 'userdata' then
        c = c:getPosition()
    end
    if c then
        if c.x and not c.y then
            return(math.abs(c.x-pos().x))
        elseif c.y and not c.x then
            return(math.abs(c.y-pos().y))
        end
        return(math.abs(pos().x-c.x) + math.abs(pos().y-c.y))
    end
    return false
end

Stairs.Check = {}

Stairs.checkTile = function(tile)
	if not read then return end
    if not tile then
        return false
    elseif type(Stairs.Check[Stairs.postostring(tile:getPosition())]) == 'boolean' then
        return Stairs.Check[Stairs.postostring(tile:getPosition())]
    elseif not tile:getTopUseThing() then
        return false
    end
    local cor = (g_map.getMinimapColor(tile:getPosition()))
    for _, x in pairs(tile:getItems()) do
        if table.find(Stairs.Click, x:getId()) then
            tile.Click = true
        elseif table.find(Stairs.Exclude, x:getId()) then
			Stairs.Check[Stairs.postostring(tile:getPosition())] = false
			return false
		end
    end
    checkcolor = (cor >= 210 and cor <= 213)
    if (checkcolor and not tile:isPathable() and tile:isWalkable()) or tile.Click then
		Stairs.Check[Stairs.postostring(tile:getPosition())] = true
        return true
	else
		Stairs.Check[Stairs.postostring(tile:getPosition())] = false
        return false
    end
end


Stairs.checkAll = function()
	if not read then return end
    local tiles = Stairs.getTiles(9)
    table.sort(tiles, function(a, b)
        return Stairs.accurateDistance(a:getPosition()) < Stairs.accurateDistance(b:getPosition())
    end)
    for y, z in ipairs(tiles) do
        if Stairs.checkTile(z) and findPath(pos(), z:getPosition(), 9, { ignoreCreatures = false, precision = 0, ignoreNonWalkable = true, ignoreNonPathable = true, allowUnseen = true, allowOnlyVisibleTiles = false }) then
            return z
        end
    end
	return false
end



macro(1, 'Auto-Escadas', function()
	if not read then return end
	if modules.game_console:isChatEnabled() then return end
    if Stairs.postostring(pos()) == Stairs.lastPosition then
        if Keys('F2') and Stairs.See then
			Stairs.distance = getDistanceBetween(pos(), Stairs.See:getPosition())
            Stairs.See:getTopUseThing():setMarked('#00FF00')
            if Stairs.See:isWalkable() and not Stairs.See:isPathable() and autoWalk(Stairs.See:getPosition(), 1) then Stairs.See = false return delay(300) end
			if (Stairs.distance <= 4 or (Stairs.tryWalk and Stairs.tryWalk >= now)) and Stairs.See:canShoot() then
				g_game.use(Stairs.See:getTopUseThing())
				player:stopAutoWalk()
			else
				player:autoWalk(Stairs.See:getPosition())
				Stairs.tryWalk = now + 300
			end
        elseif Stairs.See and Stairs.See:getTopUseThing() then
            Stairs.See:getTopUseThing():setMarked('#FF0000')
		end
        return
    end
    if Stairs.See and Stairs.See:getTopUseThing() then
        Stairs.See:getTopUseThing():setMarked('')
    end
    Stairs.See = Stairs.checkAll()
    Stairs.lastPosition = Stairs.postostring(pos())
end)

function getClosest(table)
	local closest
	if table and table[1] then
		for v, x in pairs(table) do
			if not closest or getDistanceBetween(closest:getPosition(), player:getPosition()) > getDistanceBetween(x:getPosition(), player:getPosition()) then
				closest = x
			end
		end
	end
	if closest then
		return getDistanceBetween(closest:getPosition(), player:getPosition())
	else
		return false
	end
end

function hasNonWalkable(direc)
	tabela = {}
	for i = 1, #direc do
		local tile = g_map.getTile({x = player:getPosition().x + direc[i][1], y = player:getPosition().y + direc[i][2], z = player:getPosition().z})
		if tile and (not tile:isWalkable() or tile:getTopThing():getName():len() > 0) and tile:canShoot() then
			table.insert(tabela, tile)
		end
	end
	return tabela
end

function getClosestBetween(x, y)
	if x or y then
		if x and not y then
			return 1
		elseif y and not x then
			return 2
		end
	else
		return false
	end
	if x < y then
		return 1
	else
		return 2
	end
end

function getDash(dir)
	local dirs
	local tiles = {}
	if not dir then
		return false
	elseif dir == 'n' then
		dirs = {{0, -1}, {0, -2}, {0, -3}, {0, -4}, {0, -5}, {0, -6}, {0, -7}, {0, -8}}
	elseif dir == 's' then
		dirs = {{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}, {0, 7}, {0, 8}}
	elseif dir == 'w' then
		dirs = {{-1, 0}, {-2, 0}, {-3, 0}, {-4, 0}, {-5, 0}, {-6, 0}}
	elseif dir == 'e' then
		dirs = {{1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}}
	end
	for i = 1, #dirs do
		local tile = g_map.getTile({x = player:getPosition().x + dirs[i][1], y = player:getPosition().y + dirs[i][2], z = player:getPosition().z})
		if tile and Stairs.checkTile(tile) and tile:canShoot() then
			table.insert(tiles, tile)
		end
	end
	if not tiles[1] or getClosestBetween(getClosest(hasNonWalkable(dirs)), getClosest(tiles)) == 1 then
		return false
	else
		return true
	end
end

function checkPos(x, y)
	xyz = g_game.getLocalPlayer():getPosition()
	xyz.x = xyz.x + x
	xyz.y = xyz.y + y
	tile = g_map.getTile(xyz)
	if tile then
		return g_game.use(tile:getTopUseThing())  
	else
		return false
	end
end


read = true


UI.Separator()
UI.Separator()


lblInfo= UI.Label("-- [[ COMBO ]] --")
lblInfo:setColor("green")


UI.Separator()
UI.Separator()

----------Combo

comboss = macro(200, "COMBO PVP",  function()
if parar and parar >= now then return end
if g_game.isAttacking() then
say(storage.ComboText)
say(storage.Combo1Text)
say(storage.Combo2Text)
say(storage.Combo3Text)
say(storage.Combo4Text)
say(storage.Combo5Text)
say(storage.Combo6Text)
end

end)
addTextEdit("ComboText", storage.ComboText or "magia 1", function(widget, text) storage.ComboText = text
end)
addTextEdit("Combo1Text", storage.Combo1Text or "magia 2", function(widget, text) storage.Combo1Text = text
end)
addTextEdit("Combo2Text", storage.Combo2Text or "magia 3", function(widget, text) storage.Combo2Text = text
end)
addTextEdit("Combo3Text", storage.Combo3Text or "magia 4", function(widget, text) storage.Combo3Text = text
end)
addTextEdit("Combo4Text", storage.Combo4Text or "magia 5", function(widget, text) storage.Combo4Text = text
end)
addTextEdit("Combo5Text", storage.Combo5Text or "magia 6", function(widget, text) storage.Combo5Text = text
end)
addTextEdit("Combo6Text", storage.Combo6Text or "magia 7", function(widget, text) storage.Combo6Text = text
end)

comboss = addIcon("COMBO PVP", {item =2660, text = "COMBO PVP"}, comboss )
comboss:breakAnchors()
comboss:move(50, 50)

-------configuracao das keys de fuga

onKeyPress(function(keys)
 if keys == 'F1' then
  parar = now + 900
  say('Mokuton HiJutsu Jukai Koutan')
 end
end)



UI.Separator()
UI.Separator()

------------------autopill

UI.Label("-- [[ PILL ]] --"):setColor('green')
if type(storage.pillitem1) ~= "table" then
  storage.pillitem1 = {on=false, title="HP%", item=9796, min=0, max=100}
end
--use pill percent box
for i, pillInfo in ipairs({storage.pillitem1}) do
  local pillmacro = macro(40000, function()
    local hp = i <= 2 and player:getHealthPercent()
    if pillInfo.max >= hp then
      if TargetBot then 
        TargetBot.useItem(pillInfo.item, pillInfo.subType, player) -- sync spell with targetbot if available
      else
        local thing = g_things.getThingType(pillInfo.item)
        local subType = g_game.getClientVersion() >= 860 and 0 or 1
        if thing and thing:isFluidContainer() then
          subType = pillInfo.subType
        end
        g_game.useInventoryItemWith(pillInfo.item, player, subType)
      end
    end
  end)
  pillmacro.setOn(pillInfo.on)
  
  UI.DualScrollItemPanel(pillInfo, function(widget, newParams) 
    pillInfo = newParams
    pillmacro.setOn(pillInfo.on and pillInfo.item >= 100)
  end)
end


UI.Separator()
UI.Separator()

lblInfo= UI.Label("-- [[ AUTOFUGA ]] --")
lblInfo:setColor("green")


local hpPercent = 50 macro(1, "KAWA", function() if (hppercent() <= hpPercent) then say ('Kawarimi no jutsu') end end)
local hpPercent = 35 macro(1, "BIJUU", function() if (hppercent() <= hpPercent) then say ('bijuu furie') end end)
local hpPercent = 15 macro(1, "BLOCK", function() if (hppercent() <= hpPercent) then say ('Mokuton Daijurin Shichuro') end end)

UI.Separator()
UI.Separator()

lblInfo= UI.Label("-- [[ MACROS ]] --")
lblInfo:setColor("green")

UI.Separator()

macro(900, "bunshin", function()
say('bunshin no jutsu')
end)


inviteList = {'Fudeubaia'}

macro(100, 'Invite & Accept', function()
    if player:isPartyMember() and not player:isPartyLeader() then return end
    for _, spectator in ipairs(getSpectators(true)) do
        if spectator:getEmblem() == 1 or table.find(inviteList, spectator:getName(), true) then
            if spectator:getShield() > 0 and not player:isPartyLeader() then
                g_game.partyJoin(spectator:getId())
            elseif player:isPartyLeader() and spectator:getShield() == 0 then
                g_game.partyInvite(spectator:getId())
             end
         end
    end
end)


macro(1500, "Pot Ally", function()
  if g_game.isOnline() then
  local p = g_game.getLocalPlayer()
  if p:getHealth()/p:getMaxHealth() > 0.5 then
  for i,v in pairs(g_map.getSpectators(p:getPosition())) do 
  if v:getId() ~= p:getId() and v:getHealthPercent() <= 90 and (v:getShield() == 3 or v:getEmblem() == 1) then 
  g_game.useInventoryItemWith(13179, v)
  end
  end
  end 
  end 
  end)


UI.Separator()
UI.Separator()



lblInfo= UI.Label("-- [[ ANTI - PUSH ]] --")
lblInfo:setColor("green")

addSeparator() local dropItems = { 3031, 3035 }
local maxStackedItems = 10
local dropDelay = 600

gpAntiPushDrop = macro(dropDelay , "Anti-Push", "shift+d", function ()
  antiPush()
end)

onPlayerPositionChange(function()
    antiPush()
end)

function antiPush()
  if gpAntiPushDrop:isOff() then
    return
  end

  local tile = g_map.getTile(pos())
  if tile and tile:getThingCount() < maxStackedItems then
    local thing = tile:getTopThing()
    if thing and not thing:isNotMoveable() then
      for i, item in pairs(dropItems) do
        if item ~= thing:getId() then
            local dropItem = findItem(item)
            if dropItem then
              g_game.move(dropItem, pos(), 2)
            end
        end
      end
    end
  end
end 




UI.Separator() 
UI.Separator() 


lblInfo= UI.Label("-- [[ FOLLOW ]] --")
lblInfo:setColor("green")
followName = "autofollow"
if not storage[followName] then storage[followName] = { player = 'name'} end
local toFollowPos = {}

UI.Separator()
UI.Label("Auto Follow")

followTE = UI.TextEdit(storage[followName].player or "name", function(widget, newText)
    storage[followName].player = newText
end)



followMacro = macro(20, "Parar", function()
    local target = getCreatureByName(storage[followName].player)
    if target then
        local tpos = target:getPosition()
        toFollowPos[tpos.z] = tpos
    end
    if player:isWalking() then
        return
    end
    local p = toFollowPos[posz()]
    if not p then
        return
    end
    if autoWalk(p, 20, { ignoreNonPathable = true, precision = 1 }) then
        delay(100)
    end
end)
UI.Separator()
onPlayerPositionChange(function(newPos, oldPos)
  if (g_game.isFollowing()) then
    tfollow = g_game.getFollowingCreature()

    if tfollow then
      if tfollow:getName() ~= storage[followName].player then
        followTE:setText(tfollow:getName())
        storage[followName].player = tfollow:getName()
      end
    end
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
    if creature:getName() == storage[followName].player and newPos then
        toFollowPos[newPos.z] = newPos
    end
end)

--------------------------------------------------------------------------
if not storage.doorIds then
    storage.doorIds = { 5129, 5102, 5111, 5120, 11246, 6262 }
end

local moveTime = 1000     -- Wait time between Move, 2000 milliseconds = 2 seconds
local moveDist = 2        -- How far to Walk
local useTime = 5000     -- Wait time between Use, 2000 milliseconds = 2 seconds
local useDistance = 1     -- How far to Use

local function properTable(t)
    local r = {}
    for _, entry in pairs(t) do
        table.insert(r, entry.id)
    end
    return r
end

local doorContainer = UI.Container(function(widget, items)
    storage.doorIds = items
    doorId = properTable(storage.doorIds)
end, true)

doorContainer:setHeight(35)
doorContainer:setItems(storage.doorIds)
doorId = properTable(storage.doorIds)

clickDoor = macro(1000, function()
   if not g_game.isFollowing() then return end
    for i, tile in ipairs(g_map.getTiles(posz())) do
        local item = tile:getTopUseThing()
        if item and table.find(doorId, item:getId()) then
            local tPos = tile:getPosition()
            local distance = getDistanceBetween(pos(), tPos)
            if (distance <= useDistance) then
                use(item)
                return delay(useTime)
            end

            if (distance <= moveDist and distance > useDistance) then
                if findPath(pos(), tPos, moveDist, { ignoreNonPathable = true, precision = 1 }) then
                    autoWalk(tPos, moveTime, { ignoreNonPathable = true, precision = 1 })
                    return delay(waitTime)
                end
            end
        end
    end
end)




UI.Separator()
UI.Separator()

