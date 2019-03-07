class BlackberryWalkthroughController < BaseController
  def index
    @menu 			 		  = 'walkthroughs'
    @title 			  	  = 'Blackberry Walk-through Videos'
    @pageheader_image = 'blackberry.png'
    set_menu_labels
  end
end