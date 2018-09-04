class Node
  class << self
    attr_accessor :nodes
  end

  attr_accessor :name

  def self.inherited klass
    klass.nodes = []
  end

  def self.initialize_from_file(path)
    n = self.new
    n.instance_eval(File.read(path))
    @nodes << n
    n
  end

  def self.get name
    @nodes.find{|f| f.name == name}
  end

end
