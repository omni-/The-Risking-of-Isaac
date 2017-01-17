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