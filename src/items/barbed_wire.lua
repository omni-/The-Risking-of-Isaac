local barbed_wire = {}
barbed_wire.ID = Isaac.GetItemIdByName("Barbed Wire")
barbed_wire.radius = 85.0
barbed_wire.last_frame_hit = 0
barbed_wire.contact = false
barbed_wire.costume = Isaac.GetCostumeIdByPath("gfx/characters/barbed_wire.anm2")

function barbed_wire:OnUpdate(player, level, room, entities)
  player:AddNullCostume(self.costume)
  for i=1, #entities do
    local enemy = entities[i]:ToNPC()
    if enemy ~= nil and enemy:IsVulnerableEnemy() then
      local distance = player.Position:Distance(enemy.Position, player.Position)
      local frame = room:GetFrameCount()
      self.contact = false
      if distance ~= nil and distance <= self.radius and frame - self.last_frame_hit > 15 then
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

return barbed_wire