class UserRolesController < BaseController
  before_filter :authenticate

  def index

    # TODO: Rewrite.

    if (!NsiServices.hasPermission(NSI_SERVICE_USER, {'userid' => get_login, 'password' => get_pwd}) and !NsiServices.hasPermission(NSI_SERVICE_ROLE, {'userid' => get_login, 'password' => get_pwd}))
      redirect_to("/homes")
      return
    end

    set_view_properties('User and Role')
  end

  private

  def set_view_properties(title)
    @menu             = 'userandrole'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'users.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts()

    @localData = {}

    @localData['user_and_role_management'] = get_localized_text('User and Role Management', true)
    @localData['manage_users']             = get_localized_text('Manage Users', true)
    @localData['manage_roles']             = get_localized_text('Manage Roles', true)

  end

end