require 'azure/storage/blob'

###
# Delete worklfow start event data.
# STRICTLY FOR DEV PURPOSES ONLY.
#
# Arguments:
# 1. Tenant ID (required)
# 2. Instance ID (required)
#
# Example:
# delete_start_event_data test-tenant 023df016-7d1a-4fb7-9f6b-dbc52799e3b4

def guard_env_var(*env_vars)
  env_vars.each do |env_var|
    raise ArgumentError, "#{env_var} expected" unless ENV.include?(env_var)
  end
end

def guard_args_count(count)
  raise ArgumentError, "Expecting #{count} arguments. #{ARGV.count} given." if count > ARGV.count
end

guard_env_var('AZURE_STORAGE_ACCOUNT', 'AZURE_STORAGE_ACCESS_KEY')
guard_args_count(2)

@tenant_id = ARGV[0]
@instance_id = ARGV[1]

@container_name = 'workflow-execution-data'
@azure_blob_service = Azure::Storage::Blob::BlobService.create(
  storage_account_name: ENV["AZURE_STORAGE_ACCOUNT"],
  storage_access_key: ENV["AZURE_STORAGE_ACCESS_KEY"]
)


def blob_name(tenant_id, instance_id, name)
  fields = [tenant_id, instance_id].map do |field|
    Digest::MD5.hexdigest field
  end << name
  fields.join('/')
end

def delete_blob(blob_name)
  begin
    puts "Deleting start event data of instance id (#{@instance_id}) started in (#{@tenant_id}) tenant..."
    @azure_blob_service.delete_blob(@container_name, blob_name)
    puts "Start event data deleted successfully"
  rescue Azure::Core::Http::HTTPError => e
    puts e.message
  end
end

blob_name = blob_name(@tenant_id, @instance_id, 'startdata')
delete_blob(blob_name)
