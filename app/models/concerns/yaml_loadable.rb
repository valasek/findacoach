module YamlLoadable
  extend ActiveSupport::Concern

  class_methods do
    def load_yaml(filename)
      YAML.load_file(
        Rails.root.join("config", "data", "#{filename}.yml"),
        permitted_classes: [ Date ]
      )
    end
  end
end
