class Dir
  def self.actual_entries(dirname) # get entries without . or ..
    entries = Dir.entries(dirname)
    entries.delete(".")
    entries.delete("..")
    return entries
  end
end