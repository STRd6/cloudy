require "fog"
require "pry"

def set_cors(bucket)
  storage = Fog::Storage.new({
    :provider               => 'AWS',
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"],
    :path_style => true
  })

  cors = {
    'CORSConfiguration' => [{
      'AllowedHeader' => ['Content-*'],
      'AllowedMethod' => ['GET', 'POST', 'HEAD'],
      'AllowedOrigin' => ["*"],
      'MaxAgeSeconds' => 3000,
    }]
  }

  res = storage.put_bucket_cors(bucket, cors)

end

if __FILE__ == $0
    set_cors 'projects.pixieengine.com'
end
