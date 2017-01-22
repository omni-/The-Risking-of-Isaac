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

local gameplay = require("gameplay")
local heaven_cracker = require("items.heaven_cracker")
local tesla_coil = require("items.tesla_coil")
local ol_lopper = require("items.ol_lopper")
local hit_list = require("items.hit_list")
local lm_glasses = require("items.lm_glasses")
local barbed_wire = require("items.barbed_wire")
local predatory_instincts = require("items.predatory_instincts")

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