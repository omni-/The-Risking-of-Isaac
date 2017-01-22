local mod = RegisterMod("The Risking of Isaac", 1)

local LaserType = {
	LASER_BRIMSTONE = 1,
	LASER_TECHNOLOGY = 2,
	LASER_SHOOPDAWHOOP = 3,
	LASER_PRIDE = 4,
	LASER_ANGEL = 5,
	LASER_MEGA = 6,
	LASER_TRACTORBEAM = 7,
	LASER_ANGEL_SMALL = 8,
	LASER_BRIMSTONE_TECH = 9
}

local gameplay = (function()

local gameplay = {}

local lm_glasses_id = Isaac.GetItemIdByName("Lens-Maker's Glasses")
local ol_lopper_id = Isaac.GetItemIdByName("Ol' Lopper")

gameplay.base_crit_chance = 0.8
gameplay.crit_modifier = 0.0
gameplay.crit_multiplier = 1.0
gameplay.on_crit_handler_list = {} -- those are function (EntityPlayer player, Entity entity, float baseDamage, float extra_damage) returns float extra_damage

local function bitand(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

function gameplay:get_crit_chance()
  return (self.base_crit_chance + self.crit_modifier) * self.crit_multiplier
end

function gameplay:OnEntityTakeDamage(entity, damage, damageflag, sourceRef, damage_frames)
  local player = Isaac.GetPlayer(0)
  local enemy = entity:ToNPC()
  if (enemy ~= nil) and (damage ~= 0) and (sourceRef.Entity.Parent ~= nil) and (sourceRef.Entity.Parent.Type == EntityType.ENTITY_PLAYER) then --preliminary check
    if bitand(damageflag, DamageFlag.DAMAGE_TIMER) ~= DamageFlag.DAMAGE_TIMER then --flag check to ensure no recursion
      if math.random() < self:get_crit_chance() or (player:HasCollectible(ol_lopper_id) and (enemy.HitPoints / enemy.MaxHitPoints) < .9) then
		local extra_damage = damage
		for i=1, #self.on_crit_handler_list do
			extra_damage = self.on_crit_handler_list[i].handler(self.on_crit_handler_list[i].target, player, entity, damage, extra_damage)
			if (extra_damage == nil) then
				extra_damage = damage
			end
		end
	  
        entity:TakeDamage(extra_damage, DamageFlag.DAMAGE_TIMER, EntityRef(player), 0) --deal double crit damage
        enemy:PlaySound(SoundEffect.SOUND_DIMEDROP, 1.0, 0, false, 1.0)
      end
    end
  end
end

function gameplay:RegisterOnCritEventHandler(target, handler)
	table.insert(self.on_crit_handler_list, { target = target, handler = handler })
end

function gameplay:OnItemPickup(player, item)
  self.crit_multiplier = self.crit_multiplier + (player:GetCollectibleNum(lm_glasses_id) * 0.1)
end

function gameplay:OnDraw()
  Isaac.RenderText("crit chance: " .. tostring(self:get_crit_chance()), 5, 220, 255, 255, 255, 100)
end

return gameplay

end)() 
local heaven_cracker = (function()

local heaven_cracker = {}

heaven_cracker.ID = Isaac.GetItemIdByName("Heaven Cracker")
heaven_cracker.tear_counter = 0
heaven_cracker.count = 0

function heaven_cracker:OnEntityDead(player, entity)
  if (self.count > 0) then
    if (entity.Type == EntityType.ENTITY_TEAR) and (entity.Parent.Type == EntityType.ENTITY_PLAYER) then
      self.tear_counter = self.tear_counter + 1
      if (self.tear_counter == (5 - self.count)) then
        local laser = EntityLaser.ShootAngle(LaserType.LASER_TECHNOLOGY, entity.Position, math.random(360), 10, Vector(0,0), player)
        laser.DisableFollowParent = true
	    self.tear_counter = 0
      end
    end
  end
end

function heaven_cracker:OnItemPickup(player, item)
  self.count = math.min(player:GetCollectibleNum(self.ID), 4)
  Isaac.DebugString("count: " .. self.count)
end


return heaven_cracker

end)() 
local tesla_coil = (function()

local tesla_coil = {}

tesla_coil.ID = Isaac.GetItemIdByName("Tesla Coil")
tesla_coil.max_targets = 1
tesla_coil.zap_chance = 0.05
tesla_coil.max_distance = 120
tesla_coil.zap_chance_multiplier = 1

function tesla_coil:OnPlayerInit(player)
  self.max_targets = 1
  self.zap_chance_multiplier = 1
end

function tesla_coil:OnItemPickup(player, item)
  self.max_targets = 1
  self.zap_chance_multiplier = 1
  if (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)) then
    self.zap_chance_multiplier = self.zap_chance_multiplier * 1.5
    self.max_targets = self.max_targets + 1
  end
  if (player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)) then
    self.zap_chance_multiplier = self.zap_chance_multiplier * 2
    self.max_targets = self.max_targets + 2
  end
  if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
    self.zap_chance_multiplier = self.zap_chance_multiplier * 1.25
    self.max_targets = self.max_targets + 1
  end
end

function tesla_coil:OnUpdate(player, level, room, entities)
  if (player:HasCollectible(self.ID)) then
	  local fire = math.random() < (self.zap_chance * self.zap_chance_multiplier)
	  if (fire == true) then
	    local remaining_targets = self.max_targets
      for i=1, #entities do
        if (remaining_targets > 0) then
          if (entities[i]:IsVulnerableEnemy()) then
				    local distance = player.Position:Distance(entities[i].Position, player.Position)
			      if (distance < self.max_distance) then
				      local angle = entities[i].Position:__sub(player.Position):GetAngleDegrees()
					    local laser = EntityLaser.ShootAngle(LaserType.LASER_TECHNOLOGY, player.Position, angle, 2, Vector(0,0), player)
					    laser:SetMaxDistance(distance)
					    laser:SetColor(Color(0,0,0,255,1,1,1), 10, 0, false, false) -- tint white
					    laser:SetOneHit(true)
					    remaining_targets = tesla_remaining_targets - 1
					  end
          end
        else
				  break
				end
      end
    end
  end
end
		

return tesla_coil

end)() 
local ol_lopper = (function()

local ol_lopper = {}

ol_lopper.ID = Isaac.GetItemIdByName("Ol' Lopper")

function ol_lopper:OnEvaluateCache(player, cacheFlag)
  if player:HasCollectible(self.ID) then
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
	  player.Damage = player.Damage + 1
	end
  end
end

return ol_lopper

end)() 
local hit_list = (function()

local hit_list = {}

hit_list.ID = Isaac.GetItemIdByName("The Hit List")
hit_list.counter = 0
hit_list.init_frame_counter = 360
hit_list.frame_counter = 240
hit_list.target = nil
hit_list.target_alive = false
hit_list.sprite = Sprite()

function hit_list:OnPlayerInit(player)
  -- you need to load an anm2 file!
  --self.sprite:Load("hit_list_mark.png", false)
end

function hit_list:OnEvaluateCache(player, cacheFlag)
  if player:HasCollectible(self.ID) then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + (self.counter * 0.5)
    end
  end
end

function hit_list:OnEntityTakeDamage(entity, damage, flags, sourceRef, damage_frames)
  local enemy = entity:ToNPC()
  if enemy ~= nil then
    if enemy.HitPoints - damage <= 0 and entity == self.target then
      self.counter = self.counter + 1
    end
  end
end

function hit_list:OnDraw()
  if self.target ~= nil then
    self.sprite:Render(self.target.Position, Vector(0, 0), Vector(32, 32))
  end
end

return hit_list

end)() 
local lm_glasses = (function()

local lm_glasses = {}

lm_glasses.ID = Isaac.GetItemIdByName("Lens-Maker's Glasses")

return lm_glasses

end)() 
local barbed_wire = (function()

local barbed_wire = {}
barbed_wire.ID = Isaac.GetItemIdByName("Barbed Wire")
barbed_wire.radius = 5.0
barbed_wire.last_frame_hit = 0
barbed_wire.contact = false

function barbed_wire:OnUpdate(player, level, room, entities)
  for i=1, #entities do
    local enemy = entities[i]:ToNPC()
    if enemy ~= nil and enemy:IsVulnerableEnemy() then
      local distance = player.Position:Distance(enemy.Position, player.Position)
      local frame = room:GetFrameCount()
      self.contact = false
      if distance ~= nil and distance <= self.radius and frame - self.last_frame_hit < 30 then
        enemy:TakeDamage(player.Damage / 3, 0, EntityRef(player), 0)
        self.last_frame_hit = frame
        self.contact = true
      end
    end
  end
end

function barbed_wire:OnItemPickup(player, item)
  if item == self.ID and player:GetCollectibleCount(self.ID) then
    self.radius = self.radius * 1.2
  end
end

function barbed_wire:OnDraw()
  local text = "hit"
  Isaac.RenderText(self.contact and text or "", 400, 100, 255, 100, 100, 100)
end

return barbed_wire

end)() 
local predatory_instincts = (function()

local predatory_instincts = {}

predatory_instincts.ID = Isaac.GetItemIdByName("Predatory Instincts")
predatory_instincts.tears_up_level = 0
predatory_instincts.tears_up_max_duration = 3 * 30
predatory_instincts.tears_up_duration = 0

--local output = ""

function predatory_instincts:OnDraw()
  --Isaac.RenderText(output, 100, 150, 255, 0, 255, 100)
end

function predatory_instincts:OnUpdate(player, level, room, entities)
	if (self.tears_up_duration > 0) then
		self.tears_up_duration = self.tears_up_duration - 1
		output = self.tears_up_level .. ", " .. self.tears_up_duration
		if (self.tears_up_duration == 0) then
			self.tears_up_level = 0
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end
end

function predatory_instincts:OnEvaluateCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then -- CACHE_FIREDELAY doesn't work. so I'm misusing CACHE_DAMAGE which works for now..
	  player.MaxFireDelay = player.MaxFireDelay - self.tears_up_level
	end
end

function predatory_instincts:OnPlayerCrit(player, entity, base_damage, extra_damage)
	if player:HasCollectible(self.ID) then
		self.tears_up_duration = self.tears_up_max_duration
		if (self.tears_up_level < 3) then
			self.tears_up_level = self.tears_up_level + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
	
	return extra_damage
end

gameplay:RegisterOnCritEventHandler(predatory_instincts, predatory_instincts.OnPlayerCrit)

return predatory_instincts

end)() 

local mod_objects =
{
  gameplay, heaven_cracker, tesla_coil, ol_lopper, hit_list, lm_glasses, barbed_wire, predatory_instincts
}

local game = Game()

local text_to_render = ""

local last_active_item = 0
local last_leave_door = -1
local last_room_index = 0
local last_collectible_count = 0
local last_stage = 0

local player_items = {}

local room_is_clear = false

local collectible_pickups = { 
    [PickupVariant.PICKUP_HEART] = true, 
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_GRAB_BAG] = true, 
    [PickupVariant.PICKUP_PILL] = true, 
    [PickupVariant.PICKUP_LIL_BATTERY] = true, 
    [PickupVariant.PICKUP_TAROTCARD] = true, 
    [PickupVariant.PICKUP_TRINKET] = true 
}

local chest_pickups = { 
    [PickupVariant.PICKUP_CHEST] = true, 
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true, 
    [PickupVariant.PICKUP_REDCHEST] = true
}

-- function mod:OnBeforeRoomChanged(int current_room_index, int new_room_index)
function mod:OnBeforeRoomChanged(current_room_index, new_room_index)
    for _, object in pairs(mod_objects) do
        if (object.OnBeforeRoomChanged ~= nil) then
            object:OnBeforeRoomChanged(current_room_index, new_room_index)
        end
    end
end

-- function eventMod:OnRoomChanged(int old_room_index, int new_room_index)
function mod:OnRoomChanged(old_room_index, new_room_index)
    for _, object in pairs(mod_objects) do
        if (object.OnRoomChanged ~= nil) then
            object:OnRoomChanged(old_room_index, new_room_index)
        end
    end
end

-- function mod:OnRoomClear(int room_index, Entity[] dropped_consumables)
function mod:OnRoomClear(room_index, dropped_consumables)
    for _, object in pairs(mod_objects) do
        if (object.OnRoomClear ~= nil) then
            object:OnRoomClear(room_index, dropped_consumables)
        end
    end
end

-- function mod:OnStageChanged(old_stage, new_stage)
function mod:OnStageChanged(old_stage, new_stage)
    for _, object in pairs(mod_objects) do
        if (object.OnStageChanged ~= nil) then
            object:OnStageChanged(old_stage, new_stage)
        end
    end
end

-- function mod:OnEntitySpawn(EntityPlayer player, Entity entity)
function mod:OnEntitySpawn(player, entity)
    for _, object in pairs(mod_objects) do
        if (object.OnEntitySpawn ~= nil) then
            object:OnEntitySpawn(player, entity)
        end
    end
end

-- function mod:OnEntityDead(EntityPlayer player, Entity entity)
function mod:OnEntityDead(player, entity)
    for _, object in pairs(mod_objects) do
        if (object.OnEntityDead ~= nil) then
            object:OnEntityDead(player, entity)
        end
    end
end

-- function mod:OnConsumableCollected(EntityPickup consumable)
function mod:OnConsumableCollected(consumable)
    for _, object in pairs(mod_objects) do
        if (object.OnConsumableCollected ~= nil) then
            object:OnConsumableCollected(consumable)
        end
    end
end

-- function mod:OnChestOpen(EntityPickup chest)
function mod:OnChestOpen(chest)
    for _, object in pairs(mod_objects) do
        if (object.OnChestOpen ~= nil) then
            object:OnChestOpen(chest)
        end
    end
end

-- function mod:OnActiveItemChange(CollectibleType old_item, CollectibleType new_item)
function mod:OnActiveItemChange(old_item, new_item)
    for _, object in pairs(mod_objects) do
        if (object.OnActiveItemChange ~= nil) then
            object:OnActiveItemChange(old_item, new_item)
        end
    end
end

-- function mod:OnItemPickup(EntityPlayer player, CollectibleType item)
function mod:OnItemPickup(player, item)
    for _, object in pairs(mod_objects) do
        if (object.OnItemPickup ~= nil) then
            object:OnItemPickup(player, item)
        end
    end
end

-- function mod:OnUpdate(EntityPlayer player, Level level, Room room, Entity[] room_entities)
function mod:OnUpdate(player, level, room, room_entities)
    for _, object in pairs(mod_objects) do
        if (object.OnUpdate ~= nil) then
            object:OnUpdate(player, level, room, room_entities)
        end
    end
end

-- function mod:OnPlayerInit(EntityPlayer player)
function mod:OnPlayerInit(player)
    for _, object in pairs(mod_objects) do
        if (object.OnPlayerInit ~= nil) then
            object:OnPlayerInit(player)
        end
    end
end

-- function mod:OnUsePill(PillEffect pill)
function mod:OnUsePill(pill)
    for _, object in pairs(mod_objects) do
        if (object.OnUsePill ~= nil) then
            object:OnUsePill(pill)
        end
    end
end

-- function mod:OnUseCard(Card card)
function mod:OnUseCard(card)
    for _, object in pairs(mod_objects) do
        if (object.OnUseCard ~= nil) then
            object:OnUseCard(card)
        end
    end
end

-- function mod:OnActiveItemChange(CollectibleType item, RNG rng)
function mod:OnActiveItemUse(item, rng)
    for _, object in pairs(mod_objects) do
        if (object.OnActiveItemUse ~= nil) then
            object:OnActiveItemUse(item, rng)
        end
    end
end

-- function mod:OnEntityTakeDamage(Entity entity, float damage, int flags, EntityRef sourceRef, int damage_frames)
function mod:OnEntityTakeDamage(entity, damage, flags, sourceRef, damage_frames)
    local result = nil
    for _, object in pairs(mod_objects) do
        if (object.OnEntityTakeDamage ~= nil) then
            local tmpResult = object:OnEntityTakeDamage(entity, damage, flags, sourceRef, damage_frames)
            if (tmpResult ~= nil) then
                result = tmpResult
            end
        end
    end
	
    return result
end

-- function mod:OnEvaluateCache(EntityPlayer player, CacheFlag flag)
function mod:OnEvaluateCache(player, flag)
    for _, object in pairs(mod_objects) do
        if (object.OnEvaluateCache ~= nil) then
            object:OnEvaluateCache(player, flag)
        end
    end
end

-- function mod:OnDraw()
function mod:OnDraw()
    for _, object in pairs(mod_objects) do
        if (object.OnDraw ~= nil) then
            object:OnDraw()
        end
    end
end

function mod:update()
    local level = game:GetLevel()
    local room = game:GetRoom()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac:GetRoomEntities()
    
    -- OnUpdate
    self:OnUpdate(player, level, room, entities)
    
    -- OnBeforeRoomChanged
    local current_room_index = level:GetCurrentRoomIndex()
    if (last_leave_door ~= level.LeaveDoor) then
        local door = room:GetDoor(level.LeaveDoor)
        if (door ~= nil) then
            self:OnBeforeRoomChanged(current_room_index, door.TargetRoomIndex)
        else
            self:OnBeforeRoomChanged(current_room_index, -1)
        end
        last_leave_door = level.LeaveDoor
    end
    
    -- OnRoomChanged
    if (last_room_index ~= current_room_index) then
        self:OnRoomChanged(last_room_index, current_room_index)
        last_room_index = current_room_index
        room_is_clear = room:IsClear()
    end
    
    -- OnStageChanged
    local current_stage = level:GetStage()
    if (last_stage ~= current_stage) then
        self:OnStageChanged(last_stage, current_stage)
        last_stage = current_stage
        last_room_index = 0
    end
    
    -- OnActiveItemChange
    local current_active_item = player:GetActiveItem()
    if ((last_active_item ~= current_active_item) and (current_active_item ~= 0)) then
        self:OnActiveItemChange(last_active_item, current_active_item)
        last_active_item = current_active_item
    end
    
    local spawned_entities = {}
    for i=1, #entities do
        if (entities[i] ~= nil) then
            local sprite = entities[i]:GetSprite()
            
            -- OnEntitySpawn
            if (entities[i].FrameCount == 1) then
                self:OnEntitySpawn(player, entities[i])
                table.insert(spawned_entities, entities[i])
            -- OnEntityDead, OnConsumableCollected
            elseif (entities[i]:IsDead()) then
                if (entities[i].Type == EntityType.ENTITY_PICKUP) then
                    if ((collectible_pickups[entities[i].Variant]) and sprite:IsPlaying("Collect") and (sprite:GetFrame() == 0)) then
                        self:OnConsumableCollected(entities[i]:ToPickup())
                    end
                else
                    self:OnEntityDead(player, entities[i])
                end
            end
            
            -- OnChestOpen
            if ((entities[i].Type == EntityType.ENTITY_PICKUP) and (chest_pickups[entities[i].Variant]) and (sprite:IsPlaying("Open")) and (sprite:GetFrame() == 0)) then
                self:OnChestOpen(entities[i]:ToPickup())
            end
            
            -- OnItemPickup
            if (player:GetCollectibleCount() > last_collectible_count) then
                for i=1, #player_items do
                    local item_count = player:GetCollectibleNum(i)
                    if (item_count > player_items[i] and item_count < 100) then
                        self:OnItemPickup(player, i)
                        player_items[i] = item_count
                    end
                end
                last_collectible_count = player:GetCollectibleCount()
            end
        end
    end
    
    -- OnRoomClear
    if (last_room_index == current_room_index) and (not room_is_clear) and (room:IsClear()) and (room:GetFrameCount() > 2) then
        self:OnRoomClear(current_room_index, spawned_entities)
        room_is_clear = true
    end
end

function mod:init_player_items(cacheSize)
    player_items = {}
    for i=1, cacheSize do
        table.insert(player_items, 0)
    end
end

function mod:player_init(player)
    last_room_index = game:GetLevel():GetCurrentRoomIndex()
    last_stage = 0
    last_collectible_count = player:GetCollectibleCount()
    last_active_item = player:GetActiveItem()
    self:init_player_items(1000)
    
    -- OnPlayerInit
    self:OnPlayerInit(player)
end

function mod:use_pill(pill)
    -- OnUsePill
    self:OnUsePill(pill)
end

function mod:use_card(card)
    -- OnUseCard
    self:OnUseCard(card)
end

function mod:use_item(item, rng)
    -- OnActiveItemUse
    self:OnActiveItemUse(item, rng)
end

function mod:entity_take_damage(entity, damage, flags, sourceRef, damage_frames)
    -- OnEntityTakeDamage
    return self:OnEntityTakeDamage(entity, damage, flags, sourceRef, damage_frames)
end

function mod:evaluate_cache(player, flag)
    -- OnEvaluateCache
    self:OnEvaluateCache(player, flag)
end

function mod:draw() 
    Isaac.RenderText(text_to_render, 50, 35, 255, 255, 255, 100)
    -- OnDraw
    self:OnDraw()
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.player_init)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.draw)
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.use_pill)
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.use_card)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.use_item)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.entity_take_damage)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evaluate_cache)
