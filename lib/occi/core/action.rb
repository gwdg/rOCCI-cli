require 'occi/core/category'

module OCCI
  module Core
    class Action < OCCI::Core::Category

      def to_text
        text = super
        text << ';attributes=' + @attributes.combine.join(' ').inspect if @attributes.any?
        text
      end

    end
  end
end