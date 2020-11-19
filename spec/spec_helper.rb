if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require_relative '../lib/azure-armrest'

def setup_params
  @sub = 'abc-123-def-456'
  @res = 'my_resource_group'
  @cid = 'XXXXX'
  @key = 'YYYYY'
  @ten = 'ZZZZZ'
  @tok = 'TTTTT'

  @ver = "2015-01-01"

  provider1 = {
    'namespace'     => 'Microsoft.Compute',
    'resourceTypes' => [
      {
        'resourceType' => 'services',
        'locations'    => ['West US', 'East US'],
        'apiVersions'  => ['2016-03-25', '2015-01-01']
      },
      {
        'resourceType' => 'operations',
        'locations'    => ['West US', 'East US', 'Central US'],
        'apiVersions'  => ['2050-07-01', '2016-03-25', '2015-01-01']
      },
    ]
  }

  provider2 = {
    'namespace'     => 'Microsoft.Storage',
    'resourceTypes' => [
      {
        'resourceType' => 'stuff',
        'locations'    => ['West US', 'East US'],
        'apiVersions'  => ['2016-03-30-preview1', '2016-03-25', '2015-01-01']
      },
    ]
  }

  @providers_response = [
    Azure::Armrest::ResourceProvider.new(provider1),
    Azure::Armrest::ResourceProvider.new(provider2)
  ]

  series1 = {
    "name"                 => 'Standard_A0',
    "numberOfCores"        => 1,
    "osDiskSizeInMB"       => 1047552,
    "resourceDiskSizeInMB" => 20480,
    "memoryInMB"           => 768,
    "maxDataDiskCount"     => 1
  }

  series2 = {
    "name"                 => 'Standard_A1',
    "numberOfCores"        => 1,
    "osDiskSizeInMB"       => 1047552,
    "resourceDiskSizeInMB" => 71680,
    "memoryInMB"           => 1792,
    "maxDataDiskCount"     => 2
  }

  @series_response = [
    Azure::Armrest::VirtualMachineSize.new(series1),
    Azure::Armrest::VirtualMachineSize.new(series2)
  ]

  sku1 = {
    "resourceType" => "virtualMachines",
    "name"         => "Standard_B1ls",
    "tier"         => "Standard",
    "size"         => "B1ls",
    "family"       => "standardBSFamily",
    "locations"    => ["westus"],
    "locationInfo" => [
      {
        "location"    => "westus",
        "zones"       => [],
        "zoneDetails" => []
      }
    ],
    "capabilities" => [
      {
        "name"  => "MaxResourceVolumeMB",
        "value" => "4096"
      },
      {
        "name"  => "OSVhdSizeMB",
        "value" => "1047552"
      },
      {
        "name"  => "vCPUs",
        "value" => "1"
      },
      {
        "name"  => "HyperVGenerations",
        "value" => "V1,V2"
      },
      {
       "name"  => "MemoryGB",
       "value" => "0.5"
      },
      {
        "name"  => "MaxDataDiskCount",
        "value" => "2"
      },
    ],
    "restrictions" => []
  }

  sku2 = {
    "resourceType" => "virtualMachines",
    "name"         => "Standard_E96as_v4",
    "tier"         => "Standard",
    "size"         => "E96as_v4",
    "family"       => "standardEASv4Family",
    "locations"    => ["westus"],
    "locationInfo" => [
      {
        "location"    => "westus",
        "zones"       => [],
        "zoneDetails" => []
      }
    ],
    "capabilities" => [
      {
        "name"  => "MaxResourceVolumeMB",
        "value" => "1376256"
      },
      {
        "name"  => "OSVhdSizeMB",
        "value" => "1047552"
      },
      {
        "name"  => "vCPUs",
        "value" => "96"
        },
      {
        "name"  => "HyperVGenerations",
        "value" => "V1,V2"
      },
      {
        "name"  => "MemoryGB",
        "value" => "672"
      },
      {
        "name"  => "MaxDataDiskCount",
        "value" => "32"
      },
    ],
    "restrictions" => []
  }

  @skus_response = [
    Azure::Armrest::VirtualMachineSku.new(sku1),
    Azure::Armrest::VirtualMachineSku.new(sku2)
  ]

  @subscriptions = [
    Azure::Armrest::Subscription.new(:subscription_id => @sub, :state => 'Enabled')
  ]

  allow_any_instance_of(Azure::Armrest::Configuration).to receive(:fetch_providers).and_return(@providers_response)
  allow_any_instance_of(Azure::Armrest::Configuration).to receive(:fetch_subscriptions).and_return(@subscriptions)
  allow_any_instance_of(Azure::Armrest::Configuration).to receive(:validate_subscription).and_return(@sub)

  @conf = Azure::Armrest::Configuration.new(
    :subscription_id  => @sub,
    :resource_group   => @res,
    :client_id        => @cid,
    :client_key       => @key,
    :tenant_id        => @ten,
    :token            => @tok,
    :token_expiration => Time.now + 3600,
  )

  @req = {
    :method      => :get,
    :proxy       => nil,
    :ssl_verify  => nil,
    :ssl_version => 'TLSv1_2',
    :timeout     => 60,
    :headers => {
      :accept        => 'application/json',
      :content_type  => 'application/json',
      :authorization => @tok
    }
  }
end
