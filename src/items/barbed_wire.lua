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