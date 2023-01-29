module MethodExplorer
  class LookupProxy < SimpleDelegator
    def method_missing(method_name, *)
      __getobj__.lookup(method_name) unless __intercepted__
      super
    end

    def __intercepted__
      @__intercepted__
    ensure
      @__intercepted__ = true
    end

    def __irb_inspect__
      @__irb_inspect__
    ensure
      @__irb_inspect__ = true
    end

    def inspect
      __getobj__.lookup(__irb_inspect__ ? nil: :inspect) unless __intercepted__
      __getobj__.inspect
    end

    # IRB calls #inspect when showing return values. In order to differentiate between those
    # implicit calls and explicit calls, this causes a detectable change on the object.
    module InspectorExtension
      def inspect_value(v)
        v.__irb_inspect__ if MethodExplorer::LookupProxy === v
        super
      end
    end
  end
end
