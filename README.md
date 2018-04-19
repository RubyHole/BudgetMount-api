# BudgetMount-api
This is a web api for management service that helps boss/leader better organize the usage of their budget, distribute the budget to its department, and trace the real expenditure. All the transaction records will be implemented on a block chain. If there are any problem on this project, please feel free to submit an issue.

## Installation
Clone this repo and run the command `bundle install` to install required gems listed in `Gemfile.lock`.

## Execution
Run this command `rackup` to start the API.

## Usage
- GET particular budget sheet info: `api/v1/budgetsheets/{sheet_id}`
- GET the whole budget sheet list: `api/v1/budgetsheets/`
- To create a new budget sheet, POST the following parameters to `api/v1/budgetsheets/`:
  - id (optional)
  - title
  - description
  - budget
  - expenditure_log
  
