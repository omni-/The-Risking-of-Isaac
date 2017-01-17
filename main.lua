local mod = RegisterMod("The Risking of Isaac", 1)

local ol_lopper_id = Isaac.GetItemIdByName("Ol' Lopper")
local heaven_cracker_id = Isaac.GetItemIdByName("Heaven Cracker")
local tesla_coil_id = Isaac.GetItemIdByName("Tesla Coil")

local last_collectible_count = 0
local heaven_cracker_count = 0
local tear_counter = 0

local tesla_max_targets = 1
local tesla_zap_chance = 0.05
local tesla_max_distance = 120
local tesla_zap_chance_multiplicator = 1

local base_crit_chance = 0.01
local crit_counter = 0

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

local text_to_render = "base crit: " .. base_crit_chance .. "//crit counter: " .. crit_counter

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
  if Game():GetFrameCount() == 1 then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ol_lopper_id, Vector(300, 400), Vector(0, 0), nil)
  end
end

function mod:cacheUpdate(player, cacheFlag)
  --player = Isaac.GetPlayer(0)
end

function mod:update()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	
	if (player:GetCollectibleCount() ~= last_collectible_count) then -- player got an item
		heaven_cracker_count = math.min(player:GetCollectibleNum(heaven_cracker_id), 4)
		
		tesla_max_targets = 1
		tesla_zap_chance_multiplicator = 1
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)) then
			tesla_zap_chance_multiplicator = tesla_zap_chance_multiplicator * 1.5
			tesla_max_targets = tesla_max_targets + 1
		end
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)) then
			tesla_zap_chance_multiplicator = tesla_zap_chance_multiplicator * 2
			tesla_max_targets = tesla_max_targets + 2
		end
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
			tesla_zap_chance_multiplicator = tesla_zap_chance_multiplicator * 1.25
			tesla_max_targets = tesla_max_targets + 1
		end
		
		last_collectible_count = player:GetCollectibleCount()
	end
	
	local fire_tesla = math.random() < (tesla_zap_chance * tesla_zap_chance_multiplicator)
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
end

function mod:check_crit(entity, damage, damageflag, damage_source, damage_frames)
  local player = Isaac.GetPlayer(0)
  local enemy = entity:ToNPC()
  if enemy ~= nil and damage ~= 0 and damage_source.Entity:ToPlayer() == player then --preliminary check
    if bitand(damageflag, DamageFlag.DAMAGE_TIMER) ~= DamageFlag.DAMAGE_TIMER then --flag check to ensure no recursion
      if (math.random() < base_crit_chance) or (player:HasCollectible(ol_lopper_id) and (enemy.HitPoints / enemy.MaxHitPoints) < .9) then
        entity:TakeDamage(damage, DamageFlag.DAMAGE_TIMER, player, 0) --deal double crit damage
        crit_counter = crit_counter + 1
      end
    end
  end
end

function mod:draw()
  Isaac.RenderText("id: " .. ol_lopper_id, 5, 220, 255, 255, 255, 100)
  Isaac.RenderText(text_to_render, 50, 35, 255, 255, 255, 100)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheUpdate)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.draw)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check_crit)