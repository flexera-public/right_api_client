# CHANGELOG.md

## Next
 - Your info here

## 1.6.3
 - \#109 Update json version requirement for ruby2.4 compatibility

## 1.6.2
 - \#108 Raise a specific error if the API returns an empty 200 response
 - \#106 Bump mime-types version to resolve dependencies with fog-azure-rm gem
 - \#104 Switch to a more bundlerish dev workflow
 - \#102 Rework README to reflect gem version not tied to api version

## 1.6.1
 - Disassociate API version number from gem version number

## 1.6.0
 - \#101 Deprecate support for ruby 1.x
 - \#100 Add support for using local proxy with RightLink10

## 1.5.28
 - \#98 Update do_put to add text/plain Content-type
 - \#97 Added put action for the runnable_binding resource

## 1.5.27
 - \#96 Set default timeout to 6 minutes since the RightScale API has a timeout of 5 minutes for calls
 - \#94 Updating the README and config/login.yml.example with oauth info
 - \#93 Work around getting ASCII-8BIT for audit entry detail.
 - \#91 Fix for issue #83 instance facing client should support tags
 - \#90 Allow GET /api/right_scripts/:id/source to work since it comes back as text/plain
 - \#88 Update maintainer info, and add description to bypass the timeout warning

## 1.5.26
 - \#87 Use the actual response code to determine if re-login is appropriate

## 1.5.25
 - \#85 Fix bug causing useless and malformed login if client is passed an access token with no expiry timestamp

## 1.5.24
 - \#81 Pass ssl_version option of TLSv1 to rest-client

## 1.5.23
 - \#78 Prevent logging of credentials during login requests
 - \#77 Add support for OAuth2 authentication via refresh token

## 1.5.22
 - \#76 Add ability to directly access attributes of a ResourceDetail
 - \#74 Add coveralls support

## 1.5.21
 - \#71 Stop locking rest-client to 1.6.x and return to locking it to 1.x

## 1.5.20
 - \#67 Fix bug preventing configuration from setting nil for :timeout.
 - \#67 Lock rest-client to 1.6.x due to requirement for Ruby 1.8.7 support.
 - \#66 Add [TravisCI support](https://travis-ci.org/rightscale/right_api_client).
 - \#64 Jewelerize the project to make maintenance easier.

## 1.5.19
 - \#38 Specify `:allow_nan => true` in calls to `JSON.parse` so we don't choke on NAN values.
 - \#60 Make exception [namespace change](https://github.com/rightscale/right_api_client/commit/84f477907eef0a583ee5bec0ee5336309d933c75) fully backwards compatible.

## 1.5.18
 - \#62 Implement to_ary in Resource class to avoid method_missing transforming it into a post call
   (for example, when doing something like 'puts @client.clouds' in Ruby 1.9+)

## 1.5.17
 - \#61 Fix for REST client timeouts changing on redirect.
 - \#61 Also added rest_client_class initializer parameter to enable using different REST client implementations with better logging.

## 1.5.16
- \#57 Sapphire added optional support for querying a (detailed) resource with params, example: client.resource(href, :view => 'full')

## 1.5.15
- \#50 Ivory 14 02 acu148161 Harden client against spotty networks

## 1.5.14
- \#51 Add type aliases for some Exception subclasses whose name changed; restores interface compatibility with 1.5.9

## 1.5.13
- \#44 Charcoal 13 18 account id in header acu103549
- \#42 Salmon 13 17 acu135785 add current url
- \#41 Add '/index.html' to the api ref url due to 404
- \#39 acu119168 fix markup
- \#37 acu111022 fix readme ownership string

## 1.5.12
- \#35 acu104862 remove activesupport dependency and replace inflector

## 1.5.11
- \#33 fix specs and readme
- \#32 fix nested array of hashes params
- \#30 README markdown formatting
- \#29 rename read me and add mandatory ownership string

## 1.5.10
- \#28 Preserve the last request made and make it accessible
- \#26 Fix specs. Separate out unit tests and functional tests.
- \#25 Add support for other RightScale endpoints.
- \#23 Fix child_account update href.
- \#20 Always store the latest cookies. Also includes a jump from rspec 1.3.0 to 2.9.0 and spec infrastructure reorganization.

## 1.5.9
- Downgrade even further to Ruby 1.8.7. Should still work in Ruby 1.9.x.

## 1.5.8
- Fix invalid gemspec by downgrading to Ruby 1.9.2 when building gem.

## 1.5.7
- Enforce Ruby 1.9 interpreter.
- Remove the default 60 second timeout on requests.

## 1.5.6
- Remove unused constant. Fix license and read me.
- Refs #11682 - allow all methods on resource classes and post them to rightapi.

## 1.5.5
- Fix crash on audit_entry.detail.show (text and not JSON).

## 1.5.4
- Fix singular for audit_entries resources. Update rest-client gem version to 1.6.7.

## 1.5.3
- Add support for audit_entries resources. Update RConf ruby version to ruby-1.9.2-p290.

## 1.5.2
- Fix issues with client when using Ruby 1.8.7 (note that right_api_client has not been fully tested with 1.8.7 yet).

## 1.5.1
- Initial public release, supports all of the calls in RightScale API 1.5.
