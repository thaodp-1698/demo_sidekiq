require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_SERVER']}:6379", namespace: Rails.application.class.parent_name.underscore
  }

  schedule_file = "config/schedule.yml"

  if File.exist? schedule_file
    old_enqueued_jobs = Sidekiq::Cron::Job.all.select do |job|
      JSON.parse(job.message)["queue"].match?(/critical|default/)
    end
    new_jobs = YAML.load_file schedule_file
    (old_enqueued_jobs.map(&:name) - new_jobs.keys).each { |name| Sidekiq::Cron::Job.destroy(name) }

    Sidekiq::Cron::Job.load_from_hash new_jobs
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_SERVER']}:6379", namespace: Rails.application.class.parent_name.underscore
  }
end

Sidekiq::Extensions.enable_delay!
