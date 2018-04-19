require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app'
require_relative '../models/budgetsheet'

def app
  BudgetMount::Api
end

DATA = YAML.safe_load File.read('db/seeds/budgetsheet_seeds.yml')

describe 'Test Budget Mount Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob('db/*.txt').each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle Budget Sheets' do
    it 'should be able to get list of all sheets' do
      BudgetMount::BudgetSheet.new(DATA[0]).save
      BudgetMount::BudgetSheet.new(DATA[1]).save

      get 'api/v1/budgetsheets'
      result = JSON.parse last_response.body
      _(result['budgetsheet_ids'].count).must_equal 2
    end

    it 'should be able to get details of a single sheet' do
      BudgetMount::BudgetSheet.new(DATA[1]).save
      id = Dir.glob('db/*.txt').first.split(%r{[/\.]})[1]

      get "api/v1/budgetsheets/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'should be able to create new budget sheet' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/budgetsheets', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
