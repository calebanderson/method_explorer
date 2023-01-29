module MethodExplorer
  class LookupObject
    attr_reader :object, :base
    delegate :name, :ancestors, to: :base

    def initialize(obj)
      @object = obj
      @base = obj.is_a?(Module) ? obj : obj.class
    end

    def each_target_level
      yield(instance_level, :instance)
      yield(class_level, :class)
    end

    def instance_level
      @instance_level ||= LookupObject.new(base)
    end

    def class_level
      @class_level ||= LookupObject.new(base.singleton_class)
    end

    def lookup_instance_method(method)
      method.nil? ? default_method : object.instance_method(method)
    rescue NameError
      nil
    end

    def default_method
      return @default_method if defined?(@default_method)

      methods = object.instance_methods(false).map(&object.method(:instance_method))
      method_sources = methods.group_by { |m| m.source_location&.first }
      file_key = best_fit_default_file(method_sources.keys)
      @default_method = method_sources[file_key]&.first || methods.first
    end

    def best_fit_default_file(files)
      file_name = name.to_s.underscore
      files = files.compact
      files.find { |f| f.match?(/\b#{file_name}.rb$/) } ||
        files.find { |f| f.match?(/#{file_name}.rb$/) } ||
        files.find { |f| f.match?(/\b#{file_name}/) } ||
        files.find { |f| f.include?(file_name) } ||
        files.first
    end
  end
end
