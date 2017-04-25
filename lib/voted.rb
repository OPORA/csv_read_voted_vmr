require_relative 'db'

class VoteEvent
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :name,         Text
  property :number,       String
  property :rada_id,      Integer
  property :date_caden,   Date
  property :date_vote,    DateTime
  property :date_created, Date

  has n, :votes
end

class Vote
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :voter_id,     Integer
  property :result,       String

  belongs_to :vote_event

end

DataMapper.finalize
