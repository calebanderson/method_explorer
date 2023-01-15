module MethodLookerUpper
  module Lookup
    # TODO: Possibly make this return a proxy if no args are given? Somehow allow this.that.the_other to have #lookup
    #   injected like this.lookup.that.the_other, and both print info about #that, and continue on.
    def lookup(*args)
      target = LookupObject.new(args.size == 1 ? self : args.shift)
      filter = args.first

      if filter.is_a?(Regexp)
        Lookup.lookup_matching_methods(target, filter)
      else
        Lookup.lookup_single_method(target, filter)
      end
      nil
    end
    alias ls lookup

    class << self
      METHOD_VISIBILITIES = [:public, :protected, :private].freeze
      METHOD_HASH_BASE = Hash.new do |outer_hash, outer_key|
        outer_hash[outer_key] = Hash.new { |inner_hash, inner_key| inner_hash[inner_key] = [] }
      end

      def lookup_single_method(object, filter)
        object.each_target_level do |target, type|
          print_method(target.lookup_instance_method(filter), type)
        end
      end

      def lookup_matching_methods(object, filter)
        object.each_target_level do |target, type|
          methods = structured_method_hash(target.object, filter)
          next if methods.blank?

          puts " #{type.to_s.titleize} Methods ".center(ReactiveConsole.width - 10, '-'), "\n"
          puts ReactiveConsole::DisplayString.new(methods).output(:methods), "\n"
        end
      end

      def structured_method_hash(target, filter)
        method_hash = METHOD_HASH_BASE.dup
        METHOD_VISIBILITIES.each do |visibility|
          target.send(:"#{visibility}_instance_methods", true).grep(filter).sort.each do |method_name|
            owner = target.instance_method(method_name).owner
            method_hash[owner][visibility] << method_name
          end
        end
        method_hash.sort_by { |key, _| target.ancestors.index(key) }.to_h
      end

      def each_target_level(target)
        super_klass, klass = normalize_target_levels(target)

        yield(klass, :instance)
        yield(super_klass, :class)
      end

      def normalize_target_levels(target)
        target.is_a?(Module) ? [target.singleton_class, target] : normalize_target_levels(target.singleton_class)
      rescue TypeError
        normalize_target_levels(target.class)
      end

      def lookup_instance_method(method, target, mod_name)
        return default_instance_method(target, mod_name) if method.nil?

        target.instance_method(method)
      rescue NameError
        nil
      end

      def default_instance_method(target, mod_name)
        methods = target.instance_methods(false).map(&target.method(:instance_method))
        method_sources = methods.group_by { |m| m.source_location&.first }
        file_key = best_fit_default_file(method_sources.keys, mod_name)
        method_sources[file_key]&.first || methods.first
      end

      def best_fit_default_file(files, mod_name)
        file_name = mod_name.to_s.underscore
        files = files.compact
        files.find { |f| f.match?(/\b#{file_name}.rb$/) } ||
          files.find { |f| f.match?(/#{file_name}.rb$/) } ||
          files.find { |f| f.match?(/\b#{file_name}/) } ||
          files.find { |f| f.include?(file_name) } ||
          files.first
      end

      def print_method(method, level)
        return if method.nil?

        puts ":#{method.name} method at the #{level} level:"
        loop do
          print_method_location(method)
          method = method.super_method
          break if method.nil?
        end
      end

      def print_method_location(method)
        print '  '
        SharedHelpers.print_file_link(*method.source_location, 'unknown')
      end
    end
  end
end

