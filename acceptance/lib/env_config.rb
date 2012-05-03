require 'yaml'

module EnvConfig
  @@config = YAML::load_file "#{File.dirname(__FILE__)}/config/#{ENVIRONMENT}.yml"

  def self.get parent, child
    parent = get_sub_tree @@config, parent
    return get_sub_tree parent, child
  end

  private

  def self.get_sub_tree root, item
    sub_tree = root[item.to_sym]
    raise "Could not locate '#{item}' in YAML config: '#{root}'" if sub_tree.nil?
    sub_tree
  end
end