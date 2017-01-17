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