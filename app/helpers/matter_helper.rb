module MatterHelper
  def is_new_matter
    @title == @localData['new_matter']
  end
end