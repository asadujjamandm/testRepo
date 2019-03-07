class WalkthroughsController < BaseController
  def index
    @menu 						= 'walkthroughs'
    @title 						= 'Walk-through Videos'
    @pageheader_image = 'walkthrough.png'
    set_menu_labels
  end
end