local ol_lopper = {}

ol_lopper.ID = Isaac.GetItemIdByName("Ol' Lopper")

function ol_lopper:OnEvaluateCache(player, cacheFlag)
  if player:HasCollectible(self.ID) then
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
	  player.Damage = player.Damage + 1
	end
  end
end

return ol_lopper