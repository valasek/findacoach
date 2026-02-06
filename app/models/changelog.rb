class Changelog
  include YamlLoadable

  def self.all
    @change ||= load_yaml("changelog").sort.reverse.to_h
  end
end
