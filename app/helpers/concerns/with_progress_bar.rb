module WithProgressBar

  def class_for_bar status
    case status.to_s
      when 'passed'
        'success'
      when 'PassedWithWarnings'
        'warning'
      when 'failed'
        'danger'
      else
        ''
    end
  end

  def width_for_bar status
    case status.to_s
      when 'unknown'
        0
      when 'pending'
        0
      else
        100
    end
  end

  def active_class exercise, actual
    exercise.id == actual.id ? 'active' : ''
  end

end
