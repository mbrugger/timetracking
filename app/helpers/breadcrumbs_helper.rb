module BreadcrumbsHelper

  class Crumb
    def initialize(name, path)
      @name = name
      if path.nil?
        @path = ''
      else
        @path = path
      end
    end

    def name
      @name
    end

    def path
      @path
    end
  end

  def add_breadcrumb(name, path = nil)
    @breadcrumbs = [] if @breadcrumbs.nil?
    @breadcrumbs << Crumb.new(name, path)
  end

end
