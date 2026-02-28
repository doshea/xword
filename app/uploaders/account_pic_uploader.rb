# encoding: utf-8

class AccountPicUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # end
  def default_url
    ActionController::Base.helpers.asset_path('default_images/user.jpg');
  end

  def extension_allowlist
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
