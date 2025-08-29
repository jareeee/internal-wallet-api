namespace :balance_snapshot do
  desc "Enqueue the monthly balance snapshot worker"
  task run: :environment do
    BalanceSnapshotWorker.perform_async
    puts "Enqueued BalanceSnapshotWorker"
  end
end
