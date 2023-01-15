module MethodLookerUpper
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Object.include(MethodLookerUpper::Lookup)
      # Needed because the delegate classes will try to pass everything it can up to the
      # object, leading to it being skipped in the list, since self points to the base
      # object, not the delegate class instance.
      Delegator.include(MethodLookerUpper::Lookup) if defined?(Delegator)
      IRB::Inspector.prepend(LookupProxy::InspectorExtension)
    end
  end
end
