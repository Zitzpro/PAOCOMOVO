lblInfo= UI.Label("-- [[ UTILIDADES ]] --")
lblInfo:setColor("green")

UI.Separator() 

---------bug map com auto escada

local bugMapMobile = {};

local cursorWidget = g_ui.getRootWidget():recursiveGetChildById('pointer');

local initialPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };

local availableKeys = {
    ['Up'] = { 0, -6 },
    ['Down'] = { 0, 6 },
    ['Left'] = { -7, 0 },
    ['Right'] = { 7, 0 }
};

function bugMapMobile.logic()
    local pos = pos();
    local keypadPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };
    local diffPos = { x = initialPos.x - keypadPos.x, y = initialPos.y - keypadPos.y };

    if (diffPos.y < 0.46 and diffPos.y > -0.46) then
        if (diffPos.x > 0) then
            pos.x = pos.x + availableKeys['Left'][1];
        elseif (diffPos.x < 0) then
            pos.x = pos.x + availableKeys['Right'][1];
        else return end
    elseif (diffPos.x < 0.46 and diffPos.x > -0.46) then
        if (diffPos.y > 0) then
            pos.y = pos.y + availableKeys['Up'][2];
        elseif (diffPos.y < 0) then
            pos.y = pos.y + availableKeys['Down'][2];
        else return; end
    end
    local tile = g_map.getTile(pos);
    if (not tile) then return; end

    g_game.use(tile:getTopUseThing());
end

bugMapMobile.macro = macro(1, "Bug Map", bugMapMobile.logic);


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

hotkey("F2", "Chase", function()
  if g_game.isAttacking() then
   g_game.setChaseMode(1)
  end
end) 


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

lblInfo= UI.Label("-- [[ Sense ]] --")
lblInfo:setColor("green")


macro(1, 'Sense', function()
    if storage.Sense then
        locatePlayer = getPlayerByName(storage.Sense)
        if not (locatePlayer and locatePlayer:getPosition().z == player:getPosition().z and getDistanceBetween(pos(), locatePlayer:getPosition()) <= 6) then
            say('sense "' .. storage.Sense)
            delay(1000)
        end
    end
end)


onTalk(function(name, level, mode, text, channelId, pos)
    if player:getName() == name then
        if string.sub(text, 1, 1) == 'x' then
            local checkMsg = string.sub(text, 2, 1000):trim()
            if checkMsg == '0' then
                storage.Sense = false
            else
                storage.Sense = checkMsg
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

------------HP

setDefaultTab("HP")

lblInfo= UI.Label("-- [[ HEAL ]] --")
lblInfo:setColor("green")
addSeparator()
Panels.Health () addSeparator() 

UI.Separator()
UI.Separator()

lblInfo= UI.Label("-- [[ POTS ]] --")
lblInfo:setColor("pink")
addSeparator()
addSeparator()Panels.HealthItem()
Panels.HealthItem()
Panels.ManaItem() 

UI.Separator()
UI.Separator()

lblInfo= UI.Label("-- [[ BUFF ]] --")
lblInfo:setColor("green")
addSeparator()
addSeparator()


buffz = macro(1000, "Buff", function()
if not hasPartyBuff() and not isInPz() then
 say(storage.buff)
schedule(1300, function() say(storage.buff2) end)
schedule(1300, function() say(storage.buff3) end)
end
end)



addTextEdit("buff", storage.buff or "buff", function(widget, text) storage.buff = text
end)

        color= UI.Label("Buff 2:",hpPanel4)
color:setColor("green")


addTextEdit("buff2", storage.buff2 or "buff 2", function(widget, text) storage.buff2 = text
end) UI.Separator()

        color= UI.Label("Buff 3:",hpPanel5)
color:setColor("green")

addTextEdit("buff3", storage.buff3 or "buff 3", function(widget, text) storage.buff3 = text
end) UI.Separator()

buffz = addIcon("Buff", {item=2660, text="Buff"},buffz)
buffz:breakAnchors()
buffz:move(70, 50)

UI.Separator ()


-- Magic wall & Wild growth timer

-- config
local magicWallId = 2128
local magicWallTime = 20000
local wildGrowthId = 2130
local wildGrowthTime = 45000

-- script
local activeTimers = {}

onAddThing(function(tile, thing)
  if not thing:isItem() then
    return
  end
  local timer = 0
  if thing:getId() == magicWallId then
    timer = magicWallTime
  elseif thing:getId() == wildGrowthId then
    timer = wildGrowthTime
  else
    return
  end
  
  local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
  if not activeTimers[pos] or activeTimers[pos] < now then    
    activeTimers[pos] = now + timer
  end
  tile:setTimer(activeTimers[pos] - now)
end)

onRemoveThing(function(tile, thing)
  if not thing:isItem() then
    return
  end
  if (thing:getId() == magicWallId or thing:getId() == wildGrowthId) and tile:getGround() then
    local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
    activeTimers[pos] = nil
    tile:setTimer(0)
  end  
end)





