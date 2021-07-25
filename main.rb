#!/usr/bin/env ruby

require 'dotenv'
require 'droplet_kit'
require 'pastel'
require 'pry'

Dotenv.load
Dotenv.require_keys('ACCESS_TOKEN', 'SSH_USERNAME')

ACCESS_TOKEN = ENV.fetch('ACCESS_TOKEN')
SSH_USERNAME = ENV.fetch('SSH_USERNAME')

client = DropletKit::Client.new(access_token: ACCESS_TOKEN)
droplets = client.droplets.all.sort_by(&:name)

# Colors the output
pastel = Pastel.new

droplets_backed_up, droplets_not_backed_up = droplets.partition do |droplet|
  unless File.exist?("backups/#{droplet.name}-wallet.json")
    `ssh #{SSH_USERNAME}@#{droplet.name} cat /home/nkn/nkn-commercial/services/nkn-node/wallet.json > backups/#{droplet.name}-wallet.json`
  end

  unless File.exist?("backups/#{droplet.name}-wallet.pswd")
    `ssh #{SSH_USERNAME}@#{droplet.name} cat /home/nkn/nkn-commercial/services/nkn-node/wallet.pswd > backups/#{droplet.name}-wallet.pswd`
  end

  if File.size?("backups/#{droplet.name}-wallet.json") > 200 && File.size("backups/#{droplet.name}-wallet.pswd") > 20
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