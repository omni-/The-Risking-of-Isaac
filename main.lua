local mod = RegisterMod("Risk", 1)

local text_to_render = ""

local function play_sound_at_pos(soundEffect, volume, pos)
    local soundDummy = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, pos, Vector(0,0), Isaac.GetPlayer(0));
    local soundDummyNPC = soundDummy:ToNPC();
    soundDummyNPC:PlaySound(soundEffect, volume, 0, false, 1.0);
    soundDummy:Remove();
end

function mod:init()
  if Game():GetFrameCount() == 1 then
  end
end

function mod:cacheUpdate(player, cacheFlag)
  --player = Isaac.GetPlayer(0)
end

function mod:update()
  --todo: move things here
end

function mod:draw()
  Isaac.RenderText(text_to_render, 50, 35, 255, 255, 255, 100)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheUpdate)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.draw)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)