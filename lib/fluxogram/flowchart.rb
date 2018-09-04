class Flowchart
  class << self
    attr_accessor :charts
  end

  def self.inherited klass
    klass.charts = []
  end

  def self.initialize_from_file(path)
    c = self.new
    c.instance_eval(File.read(path))
    @charts << c
  end

  def self.chart name
    @charts.find{|c| c.name == name}
  end

  attr_accessor :fluxogram, :flowchart, :flowchart_nodes,
    :flowchart_connections, :flowstate, :node_names,
    :directions, :end_node_counts, :name


  def initialize(&block)
    @node_names = {}
    @directions = {}
    @end_node_counts = {}
    instance_eval(block) if block
  end

  def set_fluxogram fluxogram
    @fluxogram = fluxogram
  end

  def node_name node, name, yes_dir='bottom', no_dir='right'
    @node_names[node] = name
    @directions[node] = {:yes=>yes_dir, :no=>no_dir}
  end

  def node_box(node, box_type, i=nil)
    node = node.to_sym
    count = Flux.where(node_name: node).last.try(:count).to_i
    if i
      @flowchart_nodes += "#{node}#{i}=>#{box_type}: #{@node_names[node]}\n(#{count})|#{node}:>\n"
    else
      @flowchart_nodes += "#{node}=>#{box_type}: #{@node_names[node]}\n(#{count})|#{node}:>\n"
    end
    if box_type == 'condition'
      yestext = @fluxogram.connections[node].try(:keys).try(:[],0)
      yestext = 'sim' if yestext == true
      yestext = 'n/a' if yestext.nil?
      yestext = ' ' if yestext == :default
      yestext = 'APROVADO' if yestext == :approved
      notext = @fluxogram.connections[node].try(:keys).try(:[],1)
      notext = 'não' if notext == false
      notext = 'n/a' if notext.nil?
      notext = ' ' if notext == :default
      notext = 'Aprovado' if notext == :soft_approved
      @flowstate += "\"#{node}\" : { \"yes-text\" : \"#{yestext}\", \"no-text\" : \"#{notext}\" },\n"
    end
  end

  def define_nodes
    nodes = @fluxogram.nodes.keys
    end_nodes = @fluxogram.connections.map{|c| c[1].values}.flatten.uniq - nodes
    nodes.each do |node|
      node_box(node,'condition')

      con = @fluxogram.connections[node]
      next unless con

      node1 = con.values[0]
      next unless node1
      if end_nodes.include? node1
        end_node_counts[node1] = 0 if !end_node_counts[node1]
        i = end_node_counts[node1]
        @flowchart_connections += "#{node}(yes,#{@directions[node][:yes]})->#{node1}#{i}\n"
        node_box("#{node1}",'operation',i)
        end_node_counts[node1] += 1
      else
        @flowchart_connections += "#{node}(yes,#{@directions[node][:yes]})->#{node1}\n"
      end

      node2 = con.values[1]
      next unless node2
      if end_nodes.include? node2
        end_node_counts[node2] = 0 if !end_node_counts[node2]
        i = end_node_counts[node2]
        @flowchart_connections += "#{node}(no,#{@directions[node][:no]})->#{node2}#{i}\n"
        node_box("#{node2}",'operation',i)
        end_node_counts[node2] += 1
      else
        @flowchart_connections += "#{node}(no,#{@directions[node][:no]})->#{node2}\n"
      end
    end

    @flowstate = @flowstate[0...-2]
    @flowstate = "{ #{@flowstate} }"
  end

  def update_flowchart
    @flowchart_nodes = ''
    @flowchart_connections = ''
    @flowstate = ''

    define_nodes

    @flowchart = "#{@flowchart_nodes}\n#{@flowchart_connections}"
  end

  def flowchart
    return @flowchart if @flowchart
    update_flowchart
  end

  def flowstate
    return @flowstate
  end
end
