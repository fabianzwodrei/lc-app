class CacheQualificationsWorker
	include Sidekiq::Worker
	def perform(*args)
	    
	    Member.all.each{ |m| CacheQualificationWorker.perform_async(m.id) }
	end
end