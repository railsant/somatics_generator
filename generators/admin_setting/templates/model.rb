class <%= model_name %> < ActiveRecord::Base
  GENERAL = 'General'
  CATEGORIES = [GENERAL]
  FIELD_TYPES = ['integer', 'string', 'float', 'text', 'boolean']
  
  attr_protected :name, :field_type, :description, :category, :mce_editable
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :field_type
  validates_inclusion_of :field_type, :in => FIELD_TYPES
  validates_presence_of :category
  validates_inclusion_of :category, :in => CATEGORIES
  validates_presence_of :value, :allow_blank => true
  validates_numericality_of :value, :if => Proc.new {|setting| ['integer', 'float'].include?(setting.field_type) }
  
  def self.[](name)
    raise SettingNotFound unless <%= singular_name %> = <%= model_name %>.find_by_name(name)
    setting.parsed_value
  end
  
  def self.[]=(name, value)
    raise SettingNotFound unless <%= singular_name %> = <%= model_name %>.find_by_name(name)
    <%= singular_name %>.update_attribute(:value, value)
  end

  def parsed_value
    case self.field_type
    when 'integer'
      self.value.to_i
    when 'float'
      self.value.to_f
    when 'boolean'
      self.value == '1'
    else
      self.value
    end
  end
  
  def input_field_type
    case self.field_type
    when 'integer', 'string', 'float'
      'text_field'
    when 'text'
      self.mce_editable ? 'tinymce' : 'text_area'
    when 'boolean'
      'check_box'
    else
      'text_field'
    end
  end

  class SettingNotFound < Exception; end
end