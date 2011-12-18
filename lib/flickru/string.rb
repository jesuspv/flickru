class String
  def | what
    self.strip.empty? ? what : self
  end
end
