# frozen_string_literal: true

module ReportsHelper
  def format_currency(amount)
    number_to_currency(amount, precision: 2)
  end

  def format_percentage(value)
    number_to_percentage(value, precision: 2)
  end

  def trend_indicator(growth_rate)
    if growth_rate > 0
      content_tag(:span, class: 'text-green-600 flex items-center') do
        concat(inline_svg('arrow-up', class: 'h-4 w-4 mr-1'))
        concat("#{growth_rate}%")
      end
    elsif growth_rate < 0
      content_tag(:span, class: 'text-red-600 flex items-center') do
        concat(inline_svg('arrow-down', class: 'h-4 w-4 mr-1'))
        concat("#{growth_rate.abs}%")
      end
    else
      content_tag(:span, class: 'text-gray-600') do
        '0%'
      end
    end
  end

  def category_color_badge(category_name, amount)
    content_tag(:div, class: 'flex items-center justify-between p-2 bg-gray-50 rounded') do
      concat(content_tag(:span, category_name, class: 'text-sm font-medium text-gray-700'))
      concat(content_tag(:span, format_currency(amount), class: 'text-sm text-gray-900'))
    end
  end

  def inline_svg(name, options = {})
    case name
    when 'arrow-up'
      raw('<svg class="' + options[:class].to_s + '" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"></path></svg>')
    when 'arrow-down'
      raw('<svg class="' + options[:class].to_s + '" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"></path></svg>')
    else
      ''
    end
  end
end
