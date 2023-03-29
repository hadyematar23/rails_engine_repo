class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  validates :name, presence: true, format: {with: /\A(?!^\d+$).*\z/m}

  validates :description, presence: true, format: {with: /\A[a-zA-Z\s,.;?!]+\z/}

  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0, only_float: true, message: "is not valid. Make sure it is a number with a decimal point" }

  def find_invoices_to_destroy 
    self.invoices.joins(:items).group("invoices.id").having("COUNT(items.id) =1")
  end

  def self.return_first_alphabetized(query)
    Item.where("name ILIKE?", "%#{query}%").order(:name).first
  end

  def self.return_all_items(query)
    Item.where("name ILIKE?", "%#{query}%")
  end
end
