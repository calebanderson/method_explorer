module MethodExplorer
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Object.include(MethodExplorer::Lookup)
      # Needed because the delegate classes will try to pass everything it can up to the
      # object, leading to it being skipped in the list, since self points to the base
      # object, not the delegate class instance.
      Delegator.include(MethodExplorer::Lookup) if defined?(Delegator)
      IRB::Inspector.prepend(LookupProxy::InspectorExtension) if defined?(IRB)
    end
  end
end
