class Rack::Attack
  # set the memory store
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  # allow up to 300 requests during a 10 minute period
  # this is a reasonable amount for expected legitimate use
  throttle('req/ip', limit: 300, period: 10.minutes) do |req|
    req.ip # unless req.path.start_with?('/assets')
  end
end
