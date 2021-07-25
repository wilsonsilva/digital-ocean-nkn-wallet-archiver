#!/usr/bin/env ruby

require 'dotenv'
require 'droplet_kit'
require 'pastel'
require 'pry'

Dotenv.load
Dotenv.require_keys('ACCESS_TOKEN', 'SSH_USERNAME')

ACCESS_TOKEN = ENV.fetch('ACCESS_TOKEN')
SSH_USERNAME = ENV.fetch('SSH_USERNAME')
BACKUP_DIRECTORY = 'backups'

client = DropletKit::Client.new(access_token: ACCESS_TOKEN)
droplets = client.droplets.all.sort_by(&:name)

# Colors the output
pastel = Pastel.new

# Ensure that the folder where the backups folder exists
Dir.mkdir(BACKUP_DIRECTORY) unless Dir.exist?(BACKUP_DIRECTORY)

droplets_backed_up, droplets_not_backed_up = droplets.partition do |droplet|
  wallet_filename   = "BACKUP_DIRECTORY/#{droplet.name}-wallet.json"
  password_filename = "BACKUP_DIRECTORY/#{droplet.name}-wallet.pswd"

  unless File.exist?(wallet_filename)
    `ssh #{SSH_USERNAME}@#{droplet.name} cat /home/nkn/nkn-commercial/services/nkn-node/wallet.json > #{wallet_filename}`
  end

  unless File.exist?(password_filename)
    `ssh #{SSH_USERNAME}@#{droplet.name} cat /home/nkn/nkn-commercial/services/nkn-node/wallet.pswd > #{password_filename}`
  end

  if File.size?(wallet_filename) > 200 && File.size(password_filename) > 20
    puts pastel.green("#{droplet.name} backed up")
    true
  else
    puts paste.red("#{droplet.name} not properly backed up")
    false
  end
end

puts pastel.green('All droplets backed up') if droplets_not_backed_up.none?

if ENV.fetch('DELETE_BACKED_UP_DROPLETS') == 'true'
  puts 'Deleting backed up droplets' if droplets_backed_up.any?

  droplets_backed_up.each do |droplet|
    droplet_deleted = client.droplets.delete(id: droplet.id)
  
    if droplet_deleted
      puts pastel.green("Deleted #{droplet.name}")
    else
      puts pastel.red("Unable to delete #{droplet.name}")
    end
  end
else
  puts "The environment variable DELETE_BACKED_UP_DROPLETS is either unset or not set to 'true'. No Droplets were deleted."
end