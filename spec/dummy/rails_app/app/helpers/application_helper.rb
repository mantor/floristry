module ApplicationHelper

  def format_time(t)

    return 'N/A' if t.nil?

    unless t.is_a? Time
      t = Time.parse(t.to_s)
    end

    t.strftime('%F %T')
  end
end
