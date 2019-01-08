require_relative 'environment.rb'

class ApiCaller
  include Environment

  def self.trello_boards
    # Demo on trello get all boards
    get('members/me/boards')
  end
end

puts ApiCaller.first_call

