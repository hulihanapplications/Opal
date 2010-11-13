# Add custom time helpers
class Time
  def to_mysql # add custom time formatting
   self.strftime("%Y-%m-%d %H:%M:%S")
  end
end