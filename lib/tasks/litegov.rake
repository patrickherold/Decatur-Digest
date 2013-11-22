namespace :litegov do
  desc 'Make a user super admin'
  task :make_super_admin, [:id] => :environment do |t, args|
    user = User.find_by_id(args[:id])
    if user
      user.update_attribute(:role, :super_admin)
      puts 'User made super_admin'
    else
      puts 'User not found. Exiting'
    end
  end

  desc 'Fix geocoding'
  task :fix_geocoding => :environment do
    threads_count = 1
    threads = []
    lots = Lot.all
    c = lots.length / threads_count
    threads_count.times { |i|
      threads << Thread.new(i) { |par|
        puts "THREAD #{par}: #{(par * c)}..#{((par+1) * c)}"
        lots[(par * c)..((par+1) * c)].map(&:geolocate_by_address!)
      }
    }
    threads.map(&:join)
  end
end
