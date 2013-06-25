# RightScale API Client

The right\_api\_client gem simplifies the use of RightScale's MultiCloud API. It provides
a simple object model of the API resources, and handles all of the fine details involved
in making HTTP calls and translating their responses.
It is assumed that users are already familiar with the RightScale API:

  - API Documentation: http://support.rightscale.com/12-Guides/RightScale_API_1.5
  - API Reference Docs: http://reference.rightscale.com/api1.5

Maintained by the RightScale "Yellow_team" 

## Installation
Ruby 1.8.7 or higher is required.

    gem install right_api_client

## Versioning
The right\_api\_client gem is versioned using the usual X.Y.Z notation, where X.Y is the
RightScale API version, and Z is the client version. For example, if you want to use
RightScale API 1.5, you should use the latest version of the 1.5 gem. This will ensure
that you get the latest bug fixes for the client that is compatible with that API version.

## Usage Instructions
New users can start with the following few lines of code and navigate their way around the API by following
the available methods. You can find your account id by logging into the RightScale dashboard (https://my.rightscale.com),
navigate to the Settings > Account Settings page. The account is is at the end of the browser address bar.

    require 'right_api_client'
    @client = RightApi::Client.new(:email => 'my@email.com', :password => 'my_password', :account_id => 'my_account_id')
    puts "Available methods: #{@client.api_methods}"

The client makes working with and getting to know the API much easier. It spiders the API dynamically to
discover its resources on the fly. At every step, the user has the ability to query api_methods(), which
indicates the potential methods that can be called. The ```config/login.yml.example``` file provides
details of different login parameters.

### Making API calls
Essentially, just follow the RightScale API documentation (available from http://support.rightscale.com)
and treat every resource in the paths as objects that can call other objects using the dot (.) operator:

Examples:

   - Index:     /api/clouds/:cloud_id/datacenters             =>  @client.clouds(:id => :cloud_id).show.datacenters.index
   - Show:      /api/clouds/:cloud_id/datacenters/:id         =>  @client.clouds(:id => :cloud_id).show.datacenters(:id => :datacenter_id).show
   - Create:    /api/deployments/:deployment_id/servers       =>  @client.deployments(:id => :deployment_id).show.servers.create
   - Update:    /api/deployments/:deployment_id/servers/:id   =>  @client.deployments(:id => :deployment_id).show.servers(:id => :server_id).update
   - Destroy:   /api/deployments/:deployment_id/servers/:id   =>  @client.deployments(:id => :deployment_id).show.servers(:id => :server_id).destroy
   - An action: /api/servers/:server_id/launch                =>  @client.servers(:id => :server_id).show.launch

As seen above, whenever you need to chain methods, you must call .show before specifying the next method.

### Parameters
Pass-in parameters to the method that they belong to. Lets say you want to filter on the index for deployments:

    @client.deployments.index(:filter => ['name==my_deployment'])

The filter is the parameter for the index call and not the deployment call.

### Logging HTTP Requests
The HTTP calls made by right\_api\_client can be logged in two ways:
1. Log to a file

    @client.log('~/right_api_client.log')

2. Log to STDOUT

    @client.log(STDOUT)

## Examples
Get a list of all servers (aka doing an Index call)

    @client.servers.index

Get a list of all servers in a deployment

    @client.deployments(:id => 'my_deployment_id').show.servers.index

Get a particular server (aka doing a Show call)

    @client.servers(:id => 'my_server_id').show

Creating a server involves setting up the required parameters, then calling the create method

    server_template_href = @client.server_templates.index(:filter => ['name==Base ServerTemplate']).first.href
    cloud = @client.clouds(:id => 'my_cloud_id').show
    params = { :server => {
        :name => 'Test Server',
        :deployment_href => @client.deployments(:id => 'my_deployment_id').show.href,
        :instance => {
            :server_template_href => server_template_href,
            :cloud_href           => cloud.href,
            :security_group_hrefs => [cloud.security_groups.index(:filter => ['name==default']).first.href],
            :ssh_key_href         => cloud.ssh_keys.index.first.href,
            :datacenter_href      => cloud.datacenters.index.first.href
        }}}
    new_server = @client.servers.create(params)
    new_server.api_methods

Launch the newly created server. Inputs are a bit tricky so they have to be set in a long string

    inputs = "inputs[][name]=NAME1&inputs[][value]=text:VALUE1&inputs[][name]=NAME2&inputs[][value]=text:VALUE2"
    new_server.show.launch(inputs)

Run a script on the server. The API does not currently expose right_scripts, hence, the script href has
to be retrieved from the dashboard and put in the following href format.

    script_href = "right_script_href=/api/right_scripts/382371"
    task = new_server.show.current_instance.show.run_executable(script_href + "&inputs[][name]=TEST_NAME&inputs[][value]=text:VALUE1")
    task.show.api_methods

Update the server's name

    params = { :server => {:name => 'New Server Name'}}
    @client.servers(:id => 'my_server_id').update(params)

Terminate the server (i.e. shutdown its current_instance)

    @client.servers(:id => 'my_server_id').show.terminate

Destroy the server (i.e. delete it)

    @client.servers(:id => 'my_server_id').destroy

## Object Types
The client returns 3 types of objects:

- <b>Resources</b>: returned when you are querying a collection of resources, e.g.: ```client.deployments```
- <b>Resource</b>: returned when you specify an id and therefore a specific resource, e.g.: ```@client.deployments(:id => :deployment_id)```
  - When the content-type is type=collection then an array of Resource objects will be returned, e.g.: ```@client.deployments.index```
  - When the content-type is not a collection then a Resource object will be returned, e.g.: ```@client.deployments(:id => deployment_id).show```
- <b>ResourceDetail</b>: returned when you do a .show on a Resource, e.g.: ```client.deployments(:id => deployment_id).show```

 <b>On all 3 types of objects you can query ```.api_methods``` to see a list of available methods, e.g.: ```client.deployments.api_methods```</b>

### Exceptions:
- ```inputs.index``` will return an array of ResourceDetail objects since you cannot do a .show on an input
- ```session.index``` will return a ResourceDetail object since you cannot do a .show on a session
- ```tags.by_resource, tags.by_tag``` will return an array of ResourceDetail objects since you cannot do a .show on a resource_tag
- ```monitoring_metrics(:id => :m_m_id).show.data``` will return a ResourceDetail object since you cannot do
  a .show on a monitoring_metric_data

## Instance Facing Calls:
The client also supports 'instance facing calls', which use the instance\_token to login.
Unlike regular email-password logins, instance-facing-calls are limited in the amount of allowable calls.
Since in most of the cases, the calls are scoped to the instance's cloud (or the instance itself), the cloud_id and
the instance_id will be automatically recorded by the client, so that the user does not need to specify it.

### Examples

    @instance_client = RightApi::Client.new(:instance_token => 'my_token', :account_id => 'my_account_id')
    @instance_client.volume_attachments     links to /api/clouds/:cloud_id/volume_attachments
    @instance_client.volumes_snapshots      links to /api/clouds/:cloud_id/volumes_snapshots
    @instance_client.volumes_types          links to /api/clouds/:cloud_id/volumes_types
    @instance_client.volumes                links to /api/clouds/:cloud_id/volumes
    @instance_client.backups                links to /api/backups
    @instance_client.live_tasks(:id)        links to /api/clouds/:cloud_id/instances/:instance_id/live/tasks/:id

### Notes
For volume\_attachments and volumes\_snapshots you can also go through the volume:

    @instance_client.volumes(:id => :volume_id).show.volume_attachments
    which maps to:
    /api/clouds/:cloud_id/volumes/:volume_id/volume_attachment

The instance's volume\_attachments can be accessed using:

    @instance_client.get_instance.volume_attachments
    which maps to:
    /api/clouds/:cloud_id/instances/:instance_id/volume_attachments

Because the ```cloud_id``` and the ```instance_id``` are automatically added by the client, scripts that work for regular
email-password logins will have to be modified for instance-facing calls. The main reason behind this is the
inability for instance-facing calls to access the clouds resource (i.e.: ```@instance_client.clouds(:id=> :cloud_id).show``` will fail)

When you query ```api_methods```, it will list all of the methods that one sees with regular email-password logins.
Due to the limiting scope of the instance-facing calls, only a subset of these methods can be called
(see the API Reference Docs for valid methods). If you call a method that instance's are not authorized to access,
you will get a 403 Permission Denied error.


# Design Decisions
In the code, we only hard-code CRUD operations for resources. We use the .show and .index methods to make the client
more efficient. Since it dynamically creates methods it needs to query the API at times. The .show and the .index make
it explicit that querying needs to take place. Without them a GET would have to be queried every step of the way
(i.e.: the index call would be client.deployments, and the create call would be client.deployments.create which would
first do an index call).

<b>In general, when a new API resource is added, you need to indicate in the client whether index, show, create, update
and delete methods are allowed for that resource.</b>

## Special Cases
### Returning resource\_types that are not actual API resources:
  - tags:
    - by\_resource, by\_tag: both return a COLLECTION of resource\_type = RESOURCE\_TAG
      - no show or index is defined for that resource_type, therefore return a collection of ResourceDetail objects
  - data:
    - querying .data for monitoring\_metrics:
      - no show is defined for that resource\_type, therefore return a ResourceDetail object

### Index call does not act like an index call
  - session:
    - session.index should act like a show call and not like an index call (since you cannot query show).
      Therefore it should return a ResourceDetail object
  - inputs
    - inputs.index cannot return a collection of Resource objects since .show is not allowed. Therefore it should
      return a collection of ResourceDetail objects

### Having a resource\_type that cannot be accurately determined from the URL:
  - In server\_arrays.show: resource\_type = current\_instance(s) (although it should be instance(s))
  - In multi\_cloud\_images.show: resource\_type = setting(s) (although it should be multi\_cloud\_image\_setting)
  
Put these special cases in the ```RightApi::Helper::INCONSISTENT_RESOURCE_TYPES``` hash.

### Method defined on the generic resource\_type itself
  - 'instances' => {:multi\_terminate => 'do\_post', :multi\_run\_executable => 'do\_post'},
  - 'inputs'    => {:multi\_update => 'do\_put'},
  - 'tags'      => {:by\_tag => 'do\_post', :by\_resource => 'do\_post', :multi\_add => 'do\_post', :multi\_delete =>'do\_post'},
  - 'backups'   => {:cleanup => 'do\_post'}

Put these special cases in the ```RightApi::Helper::RESOURCE_TYPE_SPECIAL_ACTIONS``` hash.

### Resources are not linked together
  - In ResourceDetail, resource\_type = Instance, need live\_tasks as a method.


# Testing

## Unit Testing
bundle exec rspec spec/unit

## Functional Testing
See Usage Instructions for how to configure functional testing.

bundle exec rspec spec/functional

# Troubleshooting

## Wrong ruby version

Ruby 1.8.7 or higher is required.
