module Cms
  module Generators
    module Widget
      class SliderGenerator < ::Rails::Generators::Base
        source_root File.expand_path('../templates', __FILE__)

        def create_migration
          Widget::ApiGenerator.new(behavior: behavior) do |widget|
            widget.name = obj_class_name
            widget.icon = 'slider'
            widget.description = 'Creates a rotating slider galerie from a list of images.'
            widget.attributes = [
              {
                name: 'images',
                type: :linklist,
                title: 'Images',
              },
            ]
          end

          directory('app', force: true)
        end

        def notice
          if behavior == :invoke
            log(:migration, 'Make sure to run "rake cms:migrate" to apply CMS changes')
          end
        end

        private

        def obj_class_name
          'SliderWidget'
        end
      end
    end
  end
end
