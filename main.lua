local mod = RegisterMod("The Risking of Isaac", 1)

local ol_lopper_id = Isaac.GetItemIdByName("Ol' Lopper")
local heaven_cracker_id = Isaac.GetItemIdByName("Heaven Cracker")
local tesla_coil_id = Isaac.GetItemIdByName("Tesla Coil")
local lm_glasses_id = Isaac.GetItemIdByName("Lens-Maker's Glasses")
local hit_list_id = Isaac.GetItemIdByName("The Hit List")

local last_collectible_count = 0
local heaven_cracker_count = 0
local tear_counter = 0

local tesla_max_targets = 1
local tesla_zap_chance = 0.05
local tesla_max_distance = 120
local tesla_zap_chance_multiplier = 1

local hit_list_counter = 0
local hit_list_init_frame_counter = 360
local hit_list_frame_counter = 240
local hit_list_entity = nil
local hit_list_entity_alive = false
local hit_list_mark_image_path = "./gfx/hit_list_mark.png"
local hit_list_sprite = Sprite()
hit_list_sprite:Load(hit_list_mark_image_path, false)

local base_crit_chance = 0.01
local crit_modifier = 0.0
local crit_multiplier = 1.0

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

local text_to_render = ""

local function play_sound_at_pos(soundEffect, volume, pos)
    local soundDummy = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, pos, Vector(0,0), Isaac.GetPlayer(0));
    local soundDummyNPC = soundDummy:ToNPC();
    soundDummyNPC:PlaySound(soundEffect, volume, 0, false, 1.0);
    soundDummy:Remove();
end
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

function mod:init(player)
  last_collectible_count = player:GetCollectibleCount()
  tesla_max_targets = 1
end

function mod:cacheUpdate(player, cacheFlag)
  player = Isaac.GetPlayer(0)
  if cacheFlag == CacheFlag.CACHE_DAMAGE then
    if player:HasCollectible(ol_lopper_id) then
      player.Damage = player.Damage + 1
    end
    if player:HasCollectible(hit_list_id) then
      player.Damage = player.Damage + (hit_list_counter * 0.5)
    end
  end
end

function mod:check_hit_list(entity, damage, damageflag, source, frames)
  local player = Isaac.GetPlayer(0)
  local enemy = entity:ToNPC()
  if enemy ~= nil then
    if enemy.HitPoints - damage <= 0 and entity == hit_list_entity then
      hit_list_counter = hit_list_counter + 1
    end
  end
end

function mod:get_crit_chance()
  return (base_crit_chance + crit_modifier) * crit_multiplier
end

function mod:update()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
  
  --calculate crit chance
  crit_modifier = 0.06
  crit_multiplier = 1.0
  crit_multiplier = crit_multiplier + (player:GetCollectibleNum(lm_glasses_id) * 0.1)
  
  --update items
	if (player:GetCollectibleCount() ~= last_collectible_count) then -- player got an item
		heaven_cracker_count = math.min(player:GetCollectibleNum(heaven_cracker_id), 4)
		
		tesla_max_targets = 1
		tesla_zap_chance_multiplier = 1
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)) then
			tesla_zap_chance_multiplier = tesla_zap_chance_multiplier * 1.5
			tesla_max_targets = tesla_max_targets + 1
		end
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)) then
			tesla_zap_chance_multiplier = tesla_zap_chance_multiplier * 2
			tesla_max_targets = tesla_max_targets + 2
		end
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
			tesla_zap_chance_multiplier = tesla_zap_chance_multiplier * 1.25
			tesla_max_targets = tesla_max_targets + 1
		end
		
		last_collectible_count = player:GetCollectibleCount()
	end
	
  --fire tesla
	local fire_tesla = math.random() < (tesla_zap_chance * tesla_zap_chance_multiplier)
	local tesla_remaining_targets = tesla_max_targets
	
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if (entities[i] ~= nil) then
			if (heaven_cracker_count > 0) then
				if (entities[i].Type == EntityType.ENTITY_TEAR) and (entities[i].Parent.Type == EntityType.ENTITY_PLAYER) and (entities[i]:IsDead()) then
					tear_counter = tear_counter + 1
					if (tear_counter % (4 - (heaven_cracker_count-1)) == 0) then
						local laser = EntityLaser.ShootAngle(LaserType.LASER_TECHNOLOGY, entities[i].Position, math.random(360), 10, Vector(0,0), player)
						laser.DisableFollowParent = true
					end
				end
			end
			
			if (player:HasCollectible(tesla_coil_id) and (fire_tesla == true) and (tesla_remaining_targets > 0)) then
				if (entities[i]:IsVulnerableEnemy()) then
					local distance = player.Position:Distance(entities[i].Position, player.Position)
					if (distance < tesla_max_distance) then
						local angle = entities[i].Position:__sub(player.Position):GetAngleDegrees()
						local laser = EntityLaser.ShootAngle(LaserType.LASER_TECHNOLOGY, player.Position, angle, 2, Vector(0,0), player)
						laser:SetMaxDistance(distance)
						laser:SetColor(Color(0,0,0,255,1,1,1), 10, 0, false, false) -- tint white
						laser:SetOneHit(true)
						tesla_remaining_targets = tesla_remaining_targets - 1
					end
				end
			end
		end
	end
  
  --hit list
  --[[
  if  newroom then
    wait frames
    assign hitlist enemy
  end
  --]]
end

function mod:check_crit(entity, damage, damageflag, damage_source, damage_frames)
  local player = Isaac.GetPlayer(0)
  local enemy = entity:ToNPC()
  if enemy ~= nil and damage ~= 0 and damage_source.Entity.Parent.Type == EntityType.ENTITY_PLAYER then --preliminary check
    if bitand(damageflag, DamageFlag.DAMAGE_TIMER) ~= DamageFlag.DAMAGE_TIMER then --flag check to ensure no recursion
      if math.random() < mod.get_crit_chance() or (player:HasCollectible(ol_lopper_id) and (enemy.HitPoints / enemy.MaxHitPoints) < .9) then
        entity:TakeDamage(damage, DamageFlag.DAMAGE_TIMER, EntityRef(player), 0) --deal double crit damage
        enemy:PlaySound(SoundEffect.SOUND_DIMEDROP, 1.0, 0, false, 1.0)
      end
    end
  end
end

function mod:draw()
  Isaac.RenderText("crit chance: " .. tostring(mod.get_crit_chance()), 5, 220, 255, 255, 255, 100)
  Isaac.RenderText(text_to_render, 50, 35, 255, 255, 255, 100)
  
  if hit_list_entity ~= nil then
    hit_list_sprite.Render(hit_list_entity.Position, Vector(0, 0), Vector(32, 32))
  end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheUpdate)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.draw)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check_crit)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check_hit_list)