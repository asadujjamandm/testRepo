class IphoneWalkthroughController < BaseController
  def index
    @menu 			  		= 'walkthroughs'
    @title 			  		= 'iPhone Walk-through Videos'
    @pageheader_image = 'iphone.png'
    set_menu_labels
  end
end