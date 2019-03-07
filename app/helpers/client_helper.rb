module ClientHelper
  def is_new_client
    @title == @localData['new_client']
  end

end