# frozen_string_literal: true

require 'roda'
require 'json'
require 'base64'

require_relative 'models/budgetsheet'

module BudgetMount
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      BudgetSheet.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'BudgetMountAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'budgetsheets' do
            # GET api/v1/budgetsheets/[ID]
            routing.get String do |id|
              BudgetSheet.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'BudgetSheet not found' }.to_json
            end

            # GET api/v1/budgetsheets
            routing.get do
              output = { budgetsheet_ids: BudgetSheet.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/budgetsheets
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_sheet = BudgetSheet.new(new_data)

              if new_sheet.save
                response.status = 201
                { message: 'BudgetSheet saved', id: new_sheet.id }.to_json
              else
                routing.halt 400, { message: 'Could not save budget sheet' }.to_json
              end
            end
          end
        end
      end
    end
  end
end