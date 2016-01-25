require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'pry'

require_relative 'server'

run Products::Server