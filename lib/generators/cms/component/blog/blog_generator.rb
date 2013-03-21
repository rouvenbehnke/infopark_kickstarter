module Cms
  module Generators
    module Component
      class BlogGenerator < ::Rails::Generators::Base
        include Migration

        source_root File.expand_path('../templates', __FILE__)

        class_option :cms_path,
          type: :string,
          default: nil,
          desc: 'CMS parent path where the example blog should be placed under.',
          banner: 'LOCATION'

        def add_gems
          gem('gravatar_image_tag')

          Bundler.with_clean_env do
            run('bundle --quiet')
          end
        end

        def create_migration
          begin
            validate_attribute(blog_disqus_shortname_attribute_name)

            Rails::Generators.invoke(
              'cms:attribute',
              [
                blog_disqus_shortname_attribute_name,
                '--type=string',
                '--title=Disqus Shortname',
                '--method_name=disqus_shortname'
              ]
            )
          rescue Cms::Generators::DuplicateResourceError
          end

          begin
            validate_attribute(blog_description_attribute_name)

            Rails::Generators.invoke(
              'cms:attribute',
              [
                blog_description_attribute_name,
                '--type=text',
                '--title=Description',
                '--method_name=description',
              ]
            )
          rescue Cms::Generators::DuplicateResourceError
          end

          begin
            validate_attribute(blog_entry_author_attribute_name)

            Rails::Generators.invoke(
              'cms:attribute',
              [
                blog_entry_author_attribute_name,
                '--type=string',
                '--title=Author',
                '--method_name=author',
              ]
            )
          rescue Cms::Generators::DuplicateResourceError
          end

          begin
            validate_obj_class(blog_class_name)

            Rails::Generators.invoke(
              'cms:model',
              [
                blog_class_name,
                "--attributes=#{blog_disqus_shortname_attribute_name}",
                blog_description_attribute_name,
                '--title=Page: Blog',
              ]
            )
          rescue Cms::Generators::DuplicateResourceError
          end

          begin
            validate_obj_class(blog_entry_class_name)

            Rails::Generators.invoke(
              'cms:model',
              [
                blog_entry_class_name,
                "--attributes=#{blog_entry_author_attribute_name}",
                '--title=Page: Blog Entry',
              ]
            )
          rescue Cms::Generators::DuplicateResourceError
          end
        end

        def add_discovery_link
          file = 'app/views/layouts/application.html.haml'
          insert_point = "%link{href: '/favicon.ico', rel: 'shortcut icon'}\n"

          data = []

          data << ''
          data << '    = render_cell(:blog, :discovery, @obj)'
          data << ''

          data = data.join("\n")

          insert_into_file(file, data, after: insert_point)
        end

        def create_example
          if example?
            migration_template('example_migration.rb', 'cms/migrate/create_blog_example.rb')
          end
        end

        def copy_app_directory
          directory('app', force: true)
        end

        def notice
          if behavior == :invoke
            log(:migration, 'Make sure to run "rake cms:migrate" to apply CMS changes')
          end
        end

        private

        def example?
          cms_path.present?
        end

        def cms_path
          options[:cms_path]
        end

        def blog_entry_author_attribute_name
          'blog_entry_author'
        end

        def blog_disqus_shortname_attribute_name
          'blog_disqus_shortname'
        end

        def blog_description_attribute_name
          'blog_description'
        end

        def blog_class_name
          'Blog'
        end

        def blog_entry_class_name
          'BlogEntry'
        end
      end
    end
  end
end