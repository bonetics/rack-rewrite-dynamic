module Rack
  class Rewrite
    module Dynamic
      class RailsRouteGenerator
        def self.route_for slug
          Rails.application.routes.url_helpers.send("#{slug[:sluggable_type].underscore}_path", slug[:sluggable_id])
        end
      end
    end
  end
end
