require "fog"
require "pry"

# Create a cloudfront distribution for a bucket

bucket = "projects.pixieengine.com"
domain = "projects.pixieengine.com"
comment = "PixieEngine Projects Archive"

def create_cdn(bucket, comment, domain)
  puts "Creating client..."

  cdn = Fog::CDN.new({
    :provider               => 'AWS',
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"]
  })

  bucket_domain = "#{bucket}.s3.amazonaws.com"
  puts "Creating distribution\n#{bucket_domain} -> #{domain}\n#{comment}"

  data = cdn.post_distribution({
    "Enabled" => true,
    "CNAME" => domain,
    "Comment" => comment,
    "S3Origin" => {
      'DNSName' => bucket_domain
    }
  })

  cdn_domain_name   = data.body['DomainName']

  puts "Created #{cdn_domain_name}"

  return cdn_domain_name
end

def create_alias(cdn_domain_name, domain)
  dns = Fog::DNS.new({
    :provider     => 'AWS',
    :aws_access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
  })

  # TODO: Get zone by base domain
  zone = dns.zones.first

  puts "Creating DNS alias"

  record = zone.records.create(
    :value   => cdn_domain_name,
    :name => domain,
    :type => 'CNAME'
  )

  puts "#{domain} CNAME #{cdn_domain_name}"

  binding.pry
end

# create_alias "d2hbj2zpp4a9op.cloudfront.net", domain
