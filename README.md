# SolidusAuthorizeNet

Authorize.Net payment method for solidius. It uses the AcceptJS solution so card details is never processed by your server.


## Installation

Add this gem to your Gemfile

```
gem 'solidus_authorizenet', github: 'byteable-dev/solidus_authorizenet', tag: '1.0.4'
```

Then run bundle install

```
bundle install
```

And then install migrations and setup the payment method

```
rails solidus_authorizenet:install:migrations
rake db:migrate
rails db:seed:solidus_authorizenet
```

When using sandbox credentials remember to enable testmod under payment settings in backend.

## Sandbox Account

To create a sandbox account go to https://developer.authorize.net/
