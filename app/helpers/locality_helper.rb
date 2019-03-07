module LocalityHelper

  def get_unit_types
    ['Minute', 'Hour'].to_a
  end

  def get_units_value(units)
    Utils.get_units_value units, get_units, get_unit_types
  end

  def get_units
    #(0..59).to_a
    return [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 99].to_a
  end

end
