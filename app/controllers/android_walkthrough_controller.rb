class AndroidWalkthroughController < BaseController

  def index
    @menu 						= 'walkthroughs'
    @title 						= 'Android Walk-through Videos'
    @pageheader_image = 'android.png'
    set_menu_labels
  end

end