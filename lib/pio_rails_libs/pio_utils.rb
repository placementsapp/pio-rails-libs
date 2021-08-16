# Miscellaenous utilities that would otherwise not have a home.
module PioUtils
  # Safely navigate a hashmap via dot-notation, similar to lodash#get.
  # May return nil; Assumes string keys, will not work for symbols!
  #
  # Example Usage:
  # got(line_item_targeting, 'tech_targeting.operating_systems.targeted_operating_systems')
  def got(object, dot_notation_path, default_value = nil)
    PioUtils.got(object, dot_notation_path, default_value)
  end

  def self.got(object, dot_notation_path, default_value = nil)
    # FIXME: Does not support OpenStruct!    -uly, july 2016
    keys = dot_notation_path.split('.')
    while !keys.empty? && !object.nil?
      object = object.is_a?(Array) ? nil : object.try(:fetch, keys.shift, nil)
    end
    object.nil? ? default_value : object
  end

  # The symbol version of the same damn thing...
  def self.got_sym(object, dot_notation_path, default_value = nil)
    keys = dot_notation_path.split('.').map(&:to_sym)
    while !keys.empty? && !object.nil?
      object = object.is_a?(Array) ? nil : object.try(:fetch, keys.shift, nil)
    end
    object.nil? ? default_value : object
  end
end
