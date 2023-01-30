module MethodExplorer
  module Lookup
    def lookup(*args)
      return LookupProxy.new(self) if args.blank?

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

      def lookup_single_method(object, filter)
        object.each_target_level do |target, type|
          print_method(target.lookup_instance_method(filter), type)
        end
      end

      def lookup_matching_methods(object, filter)
        object.each_target_level do |target, type|
          methods = structured_method_hash(target.object, filter)
          next if methods.blank?

          puts " #{type.to_s.titleize} Methods ".center(ResponsiveConsole.width - 10, '-'), "\n"
          puts ResponsiveConsole::DisplayString.new(methods).output(:methods), "\n"
        end
      end

      # Creates a hash that defaults to a hash which defaults to an array. Seeds the key order using
      # the object's ancestors, but accepts anything.
      def structured_method_hash(target, filter)
        array_proc = proc { |h, k| h[k] = [] }
        method_hash = Hash.new { |h, k| h[k] = Hash.new(&array_proc) }
        target.ancestors.each(&method_hash.method(:default))

        METHOD_VISIBILITIES.each do |vis|
          target.send(:"#{vis}_instance_methods", true).grep(filter).sort.each do |method|
            method_hash[target.instance_method(method).owner][vis] << method
          end
        end
        method_hash.select { |_, v| v.present? }
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

