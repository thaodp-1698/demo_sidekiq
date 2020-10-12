class ImportCsvWorker
  include Sidekiq::Worker

  def perform
    User.import_file "user.csv"
  end
end
