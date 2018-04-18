# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl/libsodium'

module BudgetMount
  # Holds a full secret budget sheet
  class BudgetSheet
    STORE_DIR = 'db/'

    # Create a new budget sheet by passing in hash of data
    def initialize(new_data)
      @id              = new_data['id'] || new_id
      @title           = new_data['title']
      @description     = new_data['description']
      @budget          = encode_content(new_data['budget'] || 0)
      @expenditure_log = encode_content(new_data['expenditure_log'])
    end

    attr_reader :id, :title, :description, :budget, :expenditure_log

    def budget
      decode_content(@budget)
    end
      
    def expenditure_log
      decode_content(@expenditure_log)
    end

    def save
      File.open(STORE_DIR + id + '.txt', 'w') do |file|
        file.write(to_json)
      end

      true
    rescue StandardError
      false
    end

    # note: this is not the preferred format for JSON objects
    # see: http://jsonapi.org
    def to_json(options = {})
      JSON({ type: 'budgetsheet',
             id: @id,
             title: @title,
             description: @description,
             budget: @budget,
             expenditure_log: expenditure_log }, options)
    end

    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    def self.find(find_id)
      budgetsheet_file = File.read(STORE_DIR + find_id + '.txt')
      BudgetSheet.new JSON.parse(budgetsheet_file)
    end

    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |filename|
        filename.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end

    def encode_content(content)
      Base64.strict_encode64(content)
    end

    def decode_content(encoded_content)
      Base64.strict_decode64(encoded_content)
    end
  end
end