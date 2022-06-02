Rails.application.routes.draw do
  mount SolidusAuthorizenet::Engine => "/solidus_authorizenet"
end
