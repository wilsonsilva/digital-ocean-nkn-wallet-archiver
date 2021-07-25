# Digital Ocean NKN Wallet Archiver

A script to backup my NKN wallets from VPS hosted in Digital Ocean.

## Installation

The script assumes that your SSH client is configured to access droplets via SSH:

```
# ~/.ssh/config

Host nkn-commercial-ubuntu-s-1vcpu-1gb-sgp1-01 # name of the droplet
  HostName 188.166.223.104
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/digital_ocean
Host nkn-commercial-ubuntu-s-1vcpu-1gb-sgp1-02 # name of the droplet
  HostName 188.166.220.118
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/digital_ocean

# ...
```

1. Create an `Access Token` with `Write` permissions [in Digital Ocean](https://cloud.digitalocean.com/account/api/tokens)
2. Create an `.env`file with the contents `ACCESS_TOKEN=your-digital-ocean-access-token`
3. Set the environment variable `SSH_USERNAME` to the name of the SSH user that has access to the droplet
3. If you wish to delete the backed up droplets, add `DELETE_BACKED_UP_DROPLETS=true` to `.env`
4. Install the dependencies `bundle install`

## Usage

Run `./main.rb`