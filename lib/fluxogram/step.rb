class Step < Node
  attr_accessor :process

  def process(request, params=nil)
    if @process
      if params
        @process.call(request, params)
      else
        @process.call(request)
      end
    end
  end
end
