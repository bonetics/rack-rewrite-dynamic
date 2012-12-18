module Rack
  class Rewrite
    module Dynamic
      class RailsRouteGenerator
        def self.route_for slug
          if slug.kind_of?(Slug)
            Rails.application.routes.url_helpers.send("#{slug[:sluggable_type].underscore}_path", slug[:sluggable_id])
          else
            Rails.application.routes.url_helpers.send("#{slug.class.name.underscore}_path", slug.id)
          end
        end
      end
    end
  end
end
