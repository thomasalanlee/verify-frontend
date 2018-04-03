module Display
  class RpDisplayData < ::Display::DisplayData
    prefix :rps
    content :other_ways_description
    content :name
    content :rp_name
    content :other_ways_text
    content :analytics_description
    content :tailored_text
    content :custom_heading, default: nil
    content :custom_what_next_content, default: nil
  end
end
