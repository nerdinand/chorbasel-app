# frozen_string_literal: true

module ComboboxHelper
  def combobox(form, field, choices, **kwargs)
    value = form.object.send(field)
    value = value.join(', ') if value.is_a? Array

    render(
      'combobox',
      { form:, field:, choices: choices.to_json, value:,
        filterable: true, multiselect: false, allow_custom_value: false }.merge(kwargs)
    )
  end
end
