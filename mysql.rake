require 'aws/s3'

namespace :mysql do
  desc "Backup database, send to S3"
  task :backup do
    backup_filename = "mysql.db.#{Time.now.strftime('%Y%d%m')}.tar.gz"
    system("mysqldump --opt --host=[HOST] --user=[USERNAME] --password=[PASSWORD] --databases [DATABASES] > #{RAILS_ROOT}/db/backups/dbBackup.sql")
    system("tar -czvf #{RAILS_ROOT}/db/#{backup_filename} #{RAILS_ROOT}/db/backups/")
    AWS::S3::Base.establish_connection!(:access_key_id => [ACCESS_KEY], :secret_access_key => [SECRET_ACCESS_KEY])
    AWS::S3::S3Object.store("#{backup_filename}", File.open("#{RAILS_ROOT}/db/#{backup_filename}").read, [BUCKET_NAME], :content_type => "application/x-compressed", :access => :private)
    AWS::S3::Base.disconnect!
    system("rm -f #{RAILS_ROOT}/db/backups/dbBackup.sql")
    system("rm -f #{RAILS_ROOT}/db/#{backup_filename}")
   end
end
