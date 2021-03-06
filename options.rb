# Configuration options
require 'ostruct'
$options = OpenStruct.new

$options.datastore = 1
$options.global_prefix = 'tki-linkcheck' # changing this will orphan hundreds of redis keys.
$options.expiry = 691_200
$options.crawl_delay = 0.2
$options.check_delay = 0.2
$options.retry_count = 2
$options.crawl_limit = 5000

$options.avoid = []
$options.avoid << /\/(e|m|r)\// #legacy
$options.avoid << /\/index\.php\//
$options.avoid << /%23/
$options.avoid << /sympa\/archive\// # mailinglist archives
$options.avoid << /\/Rate-resource\//
$options.avoid << /\/\(redirect\)\// # mailinglist archives

$options.permanently_ignore = [ ]
$options.permanently_ignore << /Search=true&filter\[\]=/ # search
$options.permanently_ignore << /mailto:/ # mailto
$options.permanently_ignore << /\);\s?$/ # href javascript
$options.permanently_ignore << /javascript:/ # href javascript
$options.permanently_ignore << /www\.tki\.org\.nz\/(about|contact|help|accessibility|privacy|feedback)(\/|$)/ # footer
$options.permanently_ignore << /wws\/arc\// # mailinglist archives
$options.permanently_ignore << /sympa\/archive\// # mailinglist archives
$options.permanently_ignore << /\/Rate-resource\// # weird nzc url
$options.permanently_ignore << /arb\.nzcer/ # weird nzc url
$options.permanently_ignore << /\/\(redirect\)\// # weird nzc url
