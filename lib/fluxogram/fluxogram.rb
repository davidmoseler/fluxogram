class Fluxogram < Node
  def self.initialize_from_file(path)
    f = super(path)
    f.build_tree
  end

  attr_accessor :tree, :start_node, :nodes, :connections,
    :params, :before_process, :after_process

  def initialize(&block)
    @nodes = {}
    @connections = {}
    @params = {}
    instance_eval(&block) if block
    build_tree
  end

  def add_node name, step, params=nil
    @nodes[name] = step
    @params[name] = params if params
  end

  def connect node1, node2, connector
    @connections[node1] ||= {}
    @connections[node1][connector] = node2
  end

  def build_node symbol
    node = {}
    node[:name] = symbol
    node[:step] = @nodes[symbol]
    @connections[symbol].to_a.each do |answer, next_node|
      node[answer] = build_node(next_node)
    end
    return node
  end

  def build_tree
    @tree = build_node(@start_node)
  end

  def count_flux node_name
    flux = Flux.find_or_create(node_name)
    flux.count += 1
    flux.save
  end

  def process request
    @before_process.call(request) if @before_process

    tree = @tree
    while tree
      name, step = tree[:name], tree[:step]
      count_flux(name) if name
      node = self.class.get(step.to_s.camelize)

      if not node.respond_to?(:process)
        answer = name; break
      end

      params = @params[name]
      if params
        answer = node.process(request, params)
      else
        answer = node.process(request)
      end

      request.path_taken.append({name=>answer.to_s})
      tree = tree[answer] || tree[:default]
    end

    @after_process.call(request, answer) if @after_process
    return answer
  end
end
