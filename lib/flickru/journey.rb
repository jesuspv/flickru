# flickru
require 'flickru/ruby'

class Journey

  def initialize destination
    Ruby.assert("destination >= 0") { destination >= 0 }

    @distance    = destination
    @destination = destination
    @beginning   = Time.now
    @current     = Time.now
  end

  def take step
    Ruby.assert("@distance >= step") { @distance >= step }

    @distance -= step
    @current   = Time.now
  end

  def progress
    @destination - @distance
  end

  def distance
    @distance
  end

  def elapsed
    @current - @beginning
  end

  def eta # seconds
    @distance * elapsed / progress 
  end

end
