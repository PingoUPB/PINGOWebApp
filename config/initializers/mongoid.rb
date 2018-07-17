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

# Monkey patch for JSON id as string:
module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
      attrs["id"] = (attrs["_id"]||attrs["id"]).to_s if (attrs["_id"]||attrs["id"])
      attrs
    end
  end
end