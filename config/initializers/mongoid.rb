# Monkey patch for cocoon:

module Mongoid
  module Association
    module Embedded
      class EmbedsMany
        def collection?
          true
        end
      end
    end
  end
end