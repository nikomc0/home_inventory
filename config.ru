require 'sinatra'

require_relative './server'
require_relative './controllers/inventory_controller'

use InventoryController
run Application
