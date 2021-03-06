# MedicalCondition is the model that defines a generic medical condition.
class MedicalCondition < ApplicationRecord
  has_many :conditions, dependent: :delete_all
  has_many :unassigned_conditions, dependent: :delete_all
  has_many :users, through: :conditions
  has_many :medical_condition_funders, dependent: :delete_all
  has_many :funders, through: :medical_condition_funders
  has_many :removed_medical_fundings, dependent: :delete_all

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 65_536 }
  validates :archived, inclusion: [true, false]
  validates :reason_archived, length: { maximum: 255 }

  def archived?
    archived
  end
end
