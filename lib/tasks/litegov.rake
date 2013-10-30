namespace :litegov do
  desc 'Make a user super admin'
  task :make_super_admin, [:id] => :environment  do |t, args|
    user = User.find_by_id(args[:id])
    if user
      user.update_attribute(:role, :super_admin)
      puts 'User made super_admin'
    else
      puts 'User not found. Exiting'
    end
  end
end
