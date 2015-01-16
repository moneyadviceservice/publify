# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

file = File.join(Rails.root, "config", "secret.token")

if File.exists?(file)
  token = File.open(file, "r") { |f| f.read.delete("\n") }

  Publify::Application.config.secret_key_base = token
  Publify::Application.config.secret_token = token
else
  Publify::Application.config.secret_key_base = $default_token
  Publify::Application.config.secret_token = $default_token
end
