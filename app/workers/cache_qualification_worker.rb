class CacheQualificationWorker
	include Sidekiq::Worker
	include Sidekiq::Throttled::Worker
	
	sidekiq_throttle({
		:concurrency => { :limit => 1 },
		:threshold => { :limit => 50, :period => 1.hour }
	})

	def perform(member_id)
		if m = Member.find(member_id)
			m.cache_qualification()
		end
	end
end