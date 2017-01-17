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