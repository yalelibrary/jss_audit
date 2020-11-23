
namespace :devise do

  desc "Load LIT and WG users"
  task load_users: :environment do

    netids = ['mikea', 'lrr36', 'kls25', 'ml672', 'yj33', 'fcr7', 'ed396', 'llz6', 'jl2864','haa37','rh469','ml672','sc457','ys394','tt434','mc2343','ecordes','amd243','lfg2','ed264','dm284','yn47', 'bs936', 'dlovins']
    netids.each do |uid|
      puts uid
      User.find_or_create_by(uid: uid, email: "#{uid}@yale.edu")
    end
  end

end
