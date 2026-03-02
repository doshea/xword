class Admin::BaseController < ApplicationController
  before_action :ensure_admin
  before_action :find_object, only: [:edit, :update, :destroy]

  def edit; end

  def update
    if found_object.update(resource_params)
      redirect_to url_for(action: :index), flash: { success: "#{resource_name} updated." }
    else
      redirect_to url_for(action: :edit, id: found_object.id), flash: { error: "Error updating #{resource_name.downcase}." }
    end
  end

  def destroy
    if found_object.destroy
      redirect_to url_for(action: :index), flash: { success: "#{resource_name} deleted." }
    else
      redirect_to url_for(action: :index), flash: { error: "Error deleting #{resource_name.downcase}." }
    end
  end

  private

  def resource_name
    controller_name.classify
  end

  def resource_params
    raise NotImplementedError, "#{self.class} must implement #resource_params"
  end
end
