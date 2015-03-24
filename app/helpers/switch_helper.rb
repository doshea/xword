# app/helpers/switch_helper.rb
module SwitchHelper

  def switch_tag(obj, attribute, label=false, hint=false)
    checked = obj.send(attribute)
    capture_haml do
      form_for obj, html: {class: 'switch-form'} do |f|
        f.label attribute, class: "#{checked ? 'on' : 'off'}" do
          haml_tag :div, class: 'switch' do
            haml_tag :div, class: 'pip'
          end
          haml_concat "#{f.check_box attribute}".html_safe
          haml_tag :span do
            haml_concat label ? label : attribute.to_s.humanize
          end
        end
      end
    end
  end
end