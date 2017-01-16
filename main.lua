local mod = RegisterMod("The Risking of Isaac", 1)

local ol_lopper_id = Isaac.GetItemIdByName("Ol' Lopper")

local base_crit_chance = 0.01
local crit_counter = 0

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

function mod:init()
  if Game():GetFrameCount() == 1 then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ol_lopper_id, Vector(300, 400), Vector(0, 0), nil)
  end
end

function mod:cacheUpdate(player, cacheFlag)
  --player = Isaac.GetPlayer(0)
end

function mod:update()
  --todo: move things here
end

function mod:check_crit(entity, damage, damageflag, damage_source, damage_frames)
  local player = Isaac.GetPlayer(0)
  local enemy = entity.ToNPC()
  if enemy ~= nil and damage ~= 0 and damage_source.ToPlayer() == player then --preliminary check
    if bitand(damageflag, DamageFlag.DAMAGE_TIMER) ~= DamageFlag.DAMAGE_TIMER then --flag check to ensure no recursion
      if (math.random() < base_crit_chance) or (player:HasCollectible(ol_lopper_id) and (enemy.HitPoints / enemy.MaxHitPoints) < .1) then
        entity:TakeDamage(damage, DamageFlag.DAMAGE_TIMER, player, 0) --deal double crit damage
        crit_counter = crit_counter + 1
      end
    end
  end
end

function mod:draw()
  Isaac.RenderText("crit counter: " .. crit_counter, 5, 220, 255, 255, 255, 100)
  Isaac.RenderText(text_to_render, 50, 35, 255, 255, 255, 100)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheUpdate)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.draw)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.check_crit)