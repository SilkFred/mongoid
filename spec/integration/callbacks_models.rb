# rubocop:todo all
class Galaxy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :age, type: Integer
  field :was_touched, type: Mongoid::Boolean, default: false
  before_validation :set_age

  embeds_many :stars

  set_callback(:touch, :before) do |document|
    self.was_touched = true
  end

  private

  def set_age
    self.age ||= 100_000
  end
end

class Star
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :galaxy, touch: true

  field :age, type: Integer
  field :was_touched_after_parent, type: Mongoid::Boolean, default: false

  before_validation :set_age

  embeds_many :planets

  set_callback(:touch, :before) do |document|
    self.was_touched_after_parent = true if galaxy.was_touched
  end

  private

  def set_age
    self.age ||= 42_000
  end
end

class Planet
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :star, touch: true

  field :age, type: Integer
  field :was_touched_after_parent, type: Mongoid::Boolean, default: false

  before_validation :set_age

  set_callback(:touch, :before) do |document|
    self.was_touched_after_parent = true if star.was_touched_after_parent
  end

  private

  def set_age
    self.age ||= 2_000
  end
end

class Emission
  include Mongoid::Document

  field :frequency

  after_save do
    @previous = attribute_was(:frequency)
  end

  attr_reader :previous
end

class Country
  include Mongoid::Document

  field :age

  before_validation :set_age

  embeds_one :president

  private

  def set_age
    self.age ||= 245
  end
end

class President
  include Mongoid::Document

  embedded_in :country

  field :age

  field :name

  before_validation :set_age

  embeds_one :first_spouse

  private

  def set_age
    self.age ||= 79
  end
end

class FirstSpouse
  include Mongoid::Document

  embedded_in :president

  field :name
  field :age, type: Integer

  before_validation :set_age

  private

  def set_age
    self.age ||= 70
  end
end

class Architect
  include Mongoid::Document

  has_and_belongs_to_many :buildings, after_add: :after_add_callback,
    after_remove: :after_remove_callback, dependent: :nullify

  field :after_add_num_buildings, type: Integer
  field :after_remove_num_buildings, type: Integer

  def after_add_callback(obj)
    self.after_add_num_buildings = self.buildings.length
  end

  def after_remove_callback(obj)
    self.after_remove_num_buildings = self.buildings.length
  end
end

class Building
  include Mongoid::Document

  has_and_belongs_to_many :architects, dependent: :nullify
end
