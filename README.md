# SolidusAuthorizenet

Authorize.Net payment method for solidius. It uses the AcceptJS solution so card details is never processed by your server.


## Installation

Add this gem to your Gemfile

```
gem 'solidus_authorizenet', github: 'https://github.com/byteable-dev/solidus_authorizenet'
```

Then run bundle install

```
bundle install
```

And then install migrations and setup the payment method

```
rails solidus_authorizenet:install
rake db:migrate
rails db:seed:solidus_authorizenet
```
