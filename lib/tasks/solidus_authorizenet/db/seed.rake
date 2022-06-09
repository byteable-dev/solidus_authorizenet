# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Creates the AuthorizeNetPayment that can be used in your store'
    task solidus_authorizenet: :environment do
      seed_file = ::SolidusAuthorizenet::Engine.root.join('db', 'seed.rb')
      if seed_file.exist?
        puts "Seeding #{seed_file}..."
        load(seed_file)
      end
    end
  end
end
