module SwitchHelper

  def switch_tag(obj, attribute, label = false, hint = false)
    checked = obj.send(attribute)
    form_with(model: obj, html: { class: 'switch-form' }) do |f|
      f.label attribute, class: (checked ? 'on' : 'off') do
        tag.div(class: 'switch') do
          tag.div(class: 'pip')
        end +
        f.check_box(attribute) +
        tag.span(label.presence || attribute.to_s.humanize)
      end
    end
  end
end
