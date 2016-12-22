# RightScale API Client
[![Build Status](https://travis-ci.org/rightscale/right_api_client.svg?branch=master)](https://travis-ci.org/rightscale/right_api_client)
[![Coverage Status](https://img.shields.io/coveralls/rightscale/right_api_client.svg)](https://coveralls.io/r/rightscale/right_api_client?branch=master)

The right\_api\_client gem simplifies the use of RightScale's MultiCloud API. It provides
a simple object model of the API resources, and handles all of the fine details involved
in making HTTP calls and translating their responses.
It is assumed that users are already familiar with the RightScale API:

  - API Documentation: http://support.rightscale.com/12-Guides/RightScale_API_1.5
  - API Reference Docs: http://reference.rightscale.com/api1.5/index.html

Maintained by the RightScale QA ServerTemplate and Ivory Automation Team

## Installation
Ruby 2.0 or higher is required as of version 1.6

    gem install right_api_client

## Versioning
* Version 1.6.x
  - API 1.5
  - Ruby 2.0 and above
  - Patch level receives improvements and bug fixes moving forward.
* Version 1.5.x
  - API 1.5
  - Ruby 1.8, 1.9.3
  - Patch level receives only security or high priority fixes if requested.

## Usage Instructions
New users can start with the following few lines of code and navigate their way around the API by following
the available methods. You can find your account id by logging into the RightScale dashboard (https://my.rightscale.com),
navigate to the Settings > Account Settings page. The account is is at the end of the browser address bar.

    require 'right_api_client'
    @client = RightApi::Client.new(:email => 'my@email.com', :password => 'my_password', :account_id => 'my_account_id')
    puts "Available methods: #{@client.api_methods}"

The client makes working with and getting to know the API much easier. It spiders the API dynamically to
discover its resources on the fly. At every step, the user has the ability to query api\_methods(), which
indicates the potential methods that can be called. **The ```config/login.yml.example``` file provides
details of different login parameters, for example, oauth authentication.**

### Making API calls
Essentially, just follow the RightScale API documentation (available from http://support.rightscale.com)
and treat every resource in the paths as objects that can call other objects using the dot (.) operator:

Examples:

    # Index datacenters: GET /api/clouds/:cloud_id/datacenters
    @client.clouds(:id => 1).show.datacenters.index
   
    # Show server: GET /api/clouds/:cloud_id/datacenters/:id
    @client.clouds(:id => 1).show.datacenters(:id => 2).show
   
    # Create server: POST /api/deployments/:deployment_id/servers
    @client.deployments(:id => 3).show.servers.create
   
    # Update server: PUT /api/deployments/:deployment_id/servers/:id
    @client.deployments(:id => 3).show.servers(:id => 4).update
   
    # Destroy server: DELETE /api/deployments/:deployment_id/servers/:id
    @client.deployments(:id => 3).show.servers(:id => 4).destroy
   
    # A non-CRUD action: POST /api/servers/:server_id/launch
    @client.servers(:id => 4).show.launch
    
    # Get an resource by it's href
    @client.resource('/api/clouds/1/volumes/bfd53dbc005f').show

As seen above, whenever you need to chain methods, you must call .show before specifying the next method.

### Last HTTP Request

You can inspect all the information about the last HTTP request, including its response.
For more info: https://github.com/rest-client/rest-client

Examples:

    deployments = @client.deployments.index
    last_request = @client.last_request[:request]
    last_url = last_request.url
    last_method = last_request.method
    last_response = @client.last_request[:response]
    last_code = last_response.code
    last_headers = last_request.headers

### Parameters
Pass-in parameters to the method that they belong to. Lets say you want to filter on the index for deployments:

    @client.deployments.index(:filter => ['name==my_deployment'])

The filter is the parameter for the index call and not the deployment call.

### Logging HTTP Requests
The HTTP calls made by right\_api\_client can be logged in two ways.

Log to a file:

    @client.log('~/right_api_client.log')

Log to STDOUT:

    @client.log(STDOUT)

### Retrying HTTP Requests
HTTP calls can sometimes fail. To enable retrying idempotent requests automatically, enable the `:enable_retry` flag. By default, this value is `false`

    @client = RightApi::Client.new(:email => 'my@email.com', :password => 'my_password', :account_id => 'my_account_id', :enable_retry => true)

### Managing multiple accounts
Multiple accounts can be managed by using the api\_url and account\_id attributes on the client.

The api\_url attribute allows users to modify the shard which the client is being used to connect to.
This should not be required as the client will find the correct shard using the account id (except
when using a refresh\_token for authorization; in this case api\_url must be set to your shard
address).

Example:

    @client.api_url # https://my.rightscale.com
    @client.api_url = 'https://us-3.rightscale.com' # Update the client to make requests to shard 3

The account\_id switches which account is being managed by the client. This allows a user with
multiple accounts to perform actions whilst only having to authenticate once. This defaults to the
account which was used to create the client.

Example:

    @client.account_id = 1
    @client.users.index.count # The number of users in account with id 1
    @client.account_id = 2
    @client.users.index.count # The number of users in account with id 2

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

Run a script on the server. The API does not currently expose right\_scripts, hence, the script href has
to be retrieved from the dashboard and put in the following href format.

    script_href = "right_script_href=/api/right_scripts/382371"
    task = new_server.show.current_instance.show.run_executable(script_href + "&inputs[][name]=TEST_NAME&inputs[][value]=text:VALUE1")
    task.show.api_methods

Update the server's name

    params = { :server => {:name => 'New Server Name'}}
    @client.servers(:id => 'my_server_id').update(params)

Terminate the server (i.e. shutdown its current\_instance)

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

## RightLink10 and Instance Facing Calls:
Having RightLink10 installed on an instance allows 'instance facing calls' via a local
[proxy](http://docs.rightscale.com/rl10/reference/rl10_local_and_proxied_http_requests.html).  To use
the proxy on the instance, you will only need to provide the following parameter:

- ```:rl10``` Set this to ```true```

Setting this parameter to `true` will use the information in the proxy authentication file to create the client.

### Example
    @instance_client = RightApi::Client.new(:rl10 => true)

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

## Known issues:
 * Cookies are lost on follow redirect.  This is a bug introduced in rest-client. 
[Github issue #406](https://github.com/rest-client/rest-client/issues/406)
has already been filed for this.  To work around this, please lock the rest-client version 
to 1.7 until the issue is fixed.


## Wrong ruby version

* As of right\_api\_client gem version 1.6, only Ruby 2.0 or higher is supported.
* right\_api\_client version 1.5.28 was tested with ruby 1.9, but it no longer supported.

## Warning message: To disable read timeouts, please set timeout to nil instead of -1

To avoid this message you can set ```:timeout```  when creating your RightAp::Client object.  You will need
to use a different value depending on which version of rest-client is being used.

* **```:timeout => nil```, infinite timeout - no warning message.**
* ```:timeout => -1```, infinite timeout - plus the error message above being displayed.

