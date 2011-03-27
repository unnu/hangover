class WatchDir
  
  def initialize(dir)
    @dir = dir
    @fsevent = FSEvent.new
  end
  
  def on_change(&block)
    @fsevent.watch(@dir, :latency => 0.5, :no_defer => true) do |directories|
      directories.select { |dir| dir !~ /\.git|\.hangover/ }.each do |dir|
        yield dir 
      end
    end
    @fsevent.run
  end
end