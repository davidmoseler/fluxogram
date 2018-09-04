class Step < Node
  attr_accessor :process

  def process(request)
    @process.call(request) if @process
  end
end
