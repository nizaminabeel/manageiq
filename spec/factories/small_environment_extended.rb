FactoryGirl.define do
  factory :small_environment_with_storages, :parent => :small_environment do
    after(:create) do |x|
      storages = [FactoryGirl.create(:storage, :name => "storage 1", :store_type => "VMFS"),
                  FactoryGirl.create(:storage, :name => "storage 2", :store_type => "VMFS")]

      ems  = x.ext_management_systems.first
      host = ems.hosts.first
      [ems, host].each { |ci| storages.each { |s| ci.storages << s } }

      ems.vms.each_with_index do |vm, idx|
        vm.update_attribute(:storage_id, storages[idx].id)
        vm.storages << storages[idx]
      end
    end
  end

  factory :small_environment_host_with_default_resource_pool, :parent => :small_environment_with_storages do
    after(:create) do |x|
      ems  = x.ext_management_systems.first
      host = ems.hosts.first
      default_res_pool = FactoryGirl.create(:resource_pool, :name => "Default for Host #{host.name}", :is_default => true)

      ems.resource_pools << default_res_pool
      default_res_pool.set_parent(host)
      ems.vms.each { |vm| default_res_pool.add_vm(vm) }
    end
  end
end
