require "fog"
require "pry"

# TODO: Create bucket
# TODO: Enable static website hosting on bucket

bucket = "projects.pixieengine.com"
domain = "projects.pixieengine.com"
comment = "PixieEngine Projects Archive"

# Create a cloudfront distribution for a bucket hosting a static website
def create_cdn(bucket, comment, domain)
  puts "Creating client..."

  cdn = Fog::CDN.new({
    :provider               => 'AWS',
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"]
  })

  bucket_domain = "#{bucket}.s3-website-us-east-1.amazonaws.com"
  puts "Creating distribution\n#{bucket_domain} -> #{domain}\n#{comment}"

  data = cdn.post_distribution({
    "Enabled" => true,
    "CNAME" => domain,
    "Comment" => comment,
    "CustomOrigin" => {
      'DNSName' => bucket_domain,
      'OriginProtocolPolicy' => 'match-viewer'
    }
  })

  cdn_domain_name = data.body['DomainName']

  puts "Created #{cdn_domain_name}"

  return {
    "DNSName" => cdn_domain_name,
    "HostedZoneId" => "Z2FDTNDATAQYW2"
  }
end

# Create a DNS alias record for the cloudfront domain
def create_alias(alias_target, domain)
  dns = Fog::DNS.new({
    :provider     => 'AWS',
    :aws_access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
  })

  # TODO: Get or create zone by base domain
  zone = dns.zones.first

  puts "Creating DNS alias"

  record = zone.records.create(
    :name => domain,
    :alias_target => alias_target,
    :type => 'A'
  )

  puts "#{domain} -> #{alias_target["DNSName"]}"
end

# alias_target = create_cdn(bucket, comment, domain)
# create_alias alias_target, domain
