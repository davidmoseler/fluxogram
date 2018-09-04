class Flux
  @@fluxes = []

  attr_accessor :name, :count

  def initalize(name)
    @name = name
    @count = 0
    @@fluxes.append(self)
  end

  def find_or_create(name)
    flux = @@fluxes.find{|f| f.name == name}
    self.new(name) if !flux
  end

  def save
  end
end
