module Api
  class PhysicalSwitchesController < BaseController
    def refresh_resource(type, id, _data = nil)
      raise BadRequestError, "Must specify an id for refreshing a #{type} resource" unless id

      ensure_resource_exists(type, id) if single_resource?

      api_action(type, id) do |klass|
        physical_switch = resource_search(id, type, klass)
        api_log_info("Refreshing #{physical_switch_ident(physical_switch)}")
        refresh_physical_switch(physical_switch)
      end
    end

    private

    def ensure_resource_exists(type, id)
      raise NotFoundError, "#{type} with id:#{id} not found" unless collection_class(type).exists?(id)
    end

    def refresh_physical_switch(physical_switch)
      desc = "#{physical_switch_ident(physical_switch)} refreshing"
      task_id = queue_object_action(physical_switch, desc, :method_name => "refresh_ems", :role => "ems_operations")
      action_result(true, desc, :task_id => task_id)
    rescue => err
      action_result(false, err.to_s)
    end

    def physical_switch_ident(physical_switch)
      "Physical Switch id:#{physical_switch.id} name: '#{physical_switch.name}'"
    end
  end
end
