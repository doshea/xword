# Only configure S3 uploads when AWS credentials are present (skipped in dev/CI without keys).
if ENV['AWSKEY'].present? && ENV['AWSSEC'].present?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['AWSKEY'],
      :aws_secret_access_key  => ENV['AWSSEC'],
      :region                 => 'us-east-1'
    }
    config.fog_public     = false  # Signed URLs only — prevents public listing of S3 bucket
  end

  CarrierWave.configure {|config| config.fog_directory = 'crossword-cafe-dev'} if Rails.env.development?
  CarrierWave.configure {|config| config.fog_directory = 'crossword-cafe-test'} if Rails.env.test?
  CarrierWave.configure {|config| config.fog_directory = 'crossword-cafe'} if Rails.env.production?
end
