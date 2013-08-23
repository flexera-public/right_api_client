# CHANGELOG.md

## 1.5.11
\#33 fix specs and readme
\#32 fix nested array of hashes params
\#30 README markdown formatting
\#29 rename read me and add mandatory ownership string

## 1.5.10
\#28 Preserve the last request made and make it accessible
\#26 Fix specs. Separate out unit tests and functional tests.
\#25 Add support for other RightScale endpoints.
\#23 Fix child_account update href.
\#20 Always store the latest cookies. Also includes a jump from rspec 1.3.0 to 2.9.0 and spec infrastructure reorganization.

## 1.5.9
Downgrade even further to Ruby 1.8.7. Should still work in Ruby 1.9.x.

## 1.5.8
Fix invalid gemspec by downgrading to Ruby 1.9.2 when building gem.

## 1.5.7
Enforce Ruby 1.9 interpreter.
Remove the default 60 second timeout on requests.

## 1.5.6
Remove unused constant. Fix license and read me.
Refs #11682 - allow all methods on resource classes and post them to rightapi.

## 1.5.5
Fix crash on audit_entry.detail.show (text and not JSON).

## 1.5.4
Fix singular for audit_entries resources. Update rest-client gem version to 1.6.7.

## 1.5.3
Add support for audit_entries resources. Update RConf ruby version to ruby-1.9.2-p290.

## 1.5.2
Fix issues with client when using Ruby 1.8.7 (note that right_api_client has not been fully tested with 1.8.7 yet).

## 1.5.1
Initial public release, supports all of the calls in RightScale API 1.5.
