local gameplay = {}

local lm_glasses_id = Isaac.GetItemIdByName("Lens-Maker's Glasses")
local ol_lopper_id = Isaac.GetItemIdByName("Ol' Lopper")

gameplay.base_crit_chance = 0.1
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
      if math.random() < self:get_crit_chance() or (player:HasCollectible(ol_lopper_id) and (enemy.HitPoints / enemy.MaxHitPoints) < .1) then
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
  if item == lm_glasses_id then
    self.crit_multiplier = self.crit_multiplier + .1
  end
end

function gameplay:OnDraw()
  Isaac.RenderText("crit chance: " .. tostring(self:get_crit_chance()), 5, 220, 255, 255, 255, 100)
end

return gameplay