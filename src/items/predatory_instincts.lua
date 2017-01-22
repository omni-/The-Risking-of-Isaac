local predatory_instincts = {}

predatory_instincts.ID = Isaac.GetItemIdByName("Predatory Instincts")
predatory_instincts.tears_up_level = 0
predatory_instincts.tears_up_max_duration = 3 * 30 -- it seems like the game runs at 30 fps ?
predatory_instincts.tears_up_duration = 0

function predatory_instincts:OnUpdate(player, level, room, entities)
	if (self.tears_up_duration > 0) then
		self.tears_up_duration = self.tears_up_duration - 1
		if (self.tears_up_duration == 0) then
			self.tears_up_level = 0
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end
end

function predatory_instincts:OnEvaluateCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then -- CACHE_FIREDELAY doesn't work. so I'm misusing CACHE_DAMAGE which works for now..
	  player.MaxFireDelay = player.MaxFireDelay - self.tears_up_level
	end
end

function predatory_instincts:OnPlayerCrit(player, entity, base_damage, extra_damage)
	if player:HasCollectible(self.ID) then
		self.tears_up_duration = self.tears_up_max_duration
		if (self.tears_up_level < 3) then
			self.tears_up_level = self.tears_up_level + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
	
	return extra_damage
end

gameplay:RegisterOnCritEventHandler(predatory_instincts, predatory_instincts.OnPlayerCrit)

return predatory_instincts