# encoding: utf-8

class PreviewUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process :resize_to_fill => [27, 27]
  end
  version :og do
    process :resize_to_fill => [75, 75]
  end
  version :large do
    process :resize_to_fill => [150, 150]
  end

end