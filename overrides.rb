Array.class_eval do
  # c = [1, 2, 3, 4, 5, 10, 6, "1"]
  # pr = [6, 7, 8, 9, "10", "1", 1, "2"]
  # pn = pr.shuffle_contain(c)
  # p pn.shuffle_contain(c)
  # => [1, 6, "1"]
  def shuffle_contain(arr)
    arr - self
  end

  def shuffle_contain?(arr)
    shuffle_contain(arr).empty?
  end

  def shuffle_contain_each_other?(arr)
    shuffle_contain(arr).empty? && arr.shuffle_contain(self).empty?
  end
end

String.class_eval do
  def parse_datetime
    ['%d/%m/%Y %H:%M:%S', '%d/%m/%Y %H:%M', '%d/%m/%Y %H', '%d/%m/%Y'].each do |format_time|
      tmp = Time.strptime(self, format_time) rescue nil
      return tmp if tmp
    end

    raise ArgumentError, 'invalid strptime format'
  end
end

Time.class_eval do
  def unix_time
    strftime('%s')
  end

  def beginning_of_day
    Time.strptime(self.strftime('%d/%m/%Y'), '%d/%m/%Y') rescue nil
  end

  def end_of_day
    Time.strptime("#{self.strftime('%d/%m/%Y')} 23:59:59", '%d/%m/%Y %H:%M:%S') rescue nil
  end
end

Integer.class_eval do
  def calc_time_during(key, value)
    case key
    when 'seconds'
      value.to_f
    when 'minutes'
      value.to_f * 60
    when 'hours'
      value.to_f * 60 * 60
    when 'days'
      value.to_f * 60 * 60 * 24
    end
  end

  %w[seconds minutes hours days].each do |time|
    define_method("#{time}_from_now") do
      Time.now.getlocal('+07:00') + calc_time_during(time, self)
    end

    define_method("#{time}_ago") do
      Time.now.getlocal('+07:00') - calc_time_during(time, self)
    end
  end
end

