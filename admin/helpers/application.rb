# encoding: utf-8
Rozario::Admin.helpers do

  def menu_entries
    #p project_modules
    show_in_menu = ["/complects","/pages","/categories","/products","/news","/articles","/contacts","/delivery","/regions","/clients","/tags","/seo", "/payment", "/grunt"]
    project_modules.select { |x| show_in_menu.include? x.path }
  end

end
