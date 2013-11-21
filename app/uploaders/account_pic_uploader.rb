# encoding: utf-8

class AccountPicUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper
  include Sprockets::Rails::Helper

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # end
  def default_url
    asset_path('images/default_user_img.jpg');
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process :resize_to_fill => [27, 27]
  end
  version :reply_size do
    process :resize_to_fill => [55, 55]
  end
  version :comment_size do
    process :resize_to_fill => [80, 80]
  end
  version :creator_pic do
    process :resize_to_fill => [95, 95]
  end
  version :search do
    process :resize_to_fill => [120, 120]
  end

end
