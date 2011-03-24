class CommitMessageBuilder
  attr_reader :message
  
  def initialize(adds, subs)
    message_parts = []
    message_parts << "ADDS: #{adds.join(', ')}" unless adds.empty?
    message_parts << "SUBS: #{subs.join(', ')}" unless subs.empty?
    
    @message = message_parts.empty? ? 'Minor changes.' : message_parts.join(' - ')
  end
end