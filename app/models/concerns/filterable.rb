module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filtered(filters: {})
      filters.compact_blank!

      return self.all if filters.blank?

      filters.reduce(self) do |s, (filter, value)|
        s.public_send("filter_by_#{filter}", value)
      end
    end
  end
end
