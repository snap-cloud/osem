# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_purchases
#
#  id                :bigint           not null, primary key
#  amount_paid       :float            default(0.0)
#  amount_paid_cents :integer          default(0)
#  currency          :string
#  paid              :boolean          default(FALSE)
#  quantity          :integer          default(1)
#  week              :integer
#  created_at        :datetime
#  conference_id     :integer
#  payment_id        :integer
#  ticket_id         :integer
#  user_id           :integer
#

class TicketPurchase < ApplicationRecord
  belongs_to :ticket
  belongs_to :user
  belongs_to :conference
  belongs_to :payment

  validates :ticket_id, :user_id, :conference_id, :quantity, :currency, presence: true
  validate :one_registration_ticket_per_user
  validate :registration_ticket_already_purchased, on: :create
  validates :quantity, numericality: { greater_than: 0 }

  delegate :title, to: :ticket
  delegate :description, to: :ticket
  delegate :price_cents, to: :ticket
  delegate :price_currency, to: :ticket

  has_many :physical_tickets

  monetize :amount_paid_cents, with_model_currency: :currency, as: 'purchase_price'

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }
  scope :by_conference, ->(conference) { where(conference_id: conference.id) }
  scope :by_user, ->(user) { where(user_id: user.id) }

  after_create :set_week

  def self.purchase(conference, user, purchases, currency)
    errors = []
    if count_purchased_registration_tickets(conference, purchases) > 1
      errors.push('You cannot buy more than one registration tickets.')
    else
      ActiveRecord::Base.transaction do
        conference.tickets.visible.each do |ticket|
          quantity = purchases[ticket.id.to_s].to_i
          # if the user bought the ticket and is still unpaid, just update the quantity
          purchase = if ticket.bought?(user) && ticket.unpaid?(user)
                       update_quantity(conference, quantity, ticket, user)
                     else
                       purchase_ticket(conference, quantity, ticket, user, currency)
                     end
          errors.push(purchase.errors.full_messages) if purchase && !purchase.save
        end
      end
    end
    errors.join('. ')
  end

  def self.purchase_ticket(conference, quantity, ticket, user, currency)
    converted_amount = CurrencyConversion.convert_currency(conference, ticket.price, ticket.price_currency, currency)
    if converted_amount < 0
      errors.push('Currency is invalid')
      purchase.pay(nil)
    end
    if quantity > 0
      purchase = new(ticket_id:         ticket.id,
                     conference_id:     conference.id,
                     user_id:           user.id,
                     quantity:          quantity,
                     amount_paid:       converted_amount.to_f,
                     amount_paid_cents: converted_amount.fractional,
                     currency:          currency)
      purchase.pay(nil) if converted_amount.zero?
    end
    purchase
  end

  def self.update_quantity(conference, quantity, ticket, user)
    purchase = TicketPurchase.where(ticket_id:     ticket.id,
                                    conference_id: conference.id,
                                    user_id:       user.id,
                                    paid:          false).first

    purchase.quantity = quantity if quantity > 0
    purchase
  end

  # Total amount
  def self.total
    sum('amount_paid * quantity')
  end

  # Total quantity
  def self.total_quantity
    sum('quantity')
  end

  def pay(payment)
    update(paid: true, payment: payment)
    PhysicalTicket.transaction do
      quantity.times { physical_tickets.create }
    end
    Mailbot.ticket_confirmation_mail(self).deliver_later
  end

  def one_registration_ticket_per_user
    if ticket.try(:registration_ticket?) && quantity != 1
      errors.add(:quantity, 'cannot be greater than one for registration tickets.')
    end
  end

  def registration_ticket_already_purchased
    if ticket.try(:registration_ticket?) && user.tickets.for_registration(conference).present?
      errors.add(:quantity, 'cannot be greater than one for registration tickets.')
    end
  end

  def render_email_data(event_template)
    parser = EmailTemplateParser.new(conference, user)
    values = parser.retrieve_values(nil, nil, quantity, ticket)
    EmailTemplateParser.parse_template(event_template, values)
  end
end

private

def set_week
  self.week = created_at.strftime('%W')
  save!
end

def count_purchased_registration_tickets(conference, purchases)
  # TODO: WHAT CAUSED THIS???
  return 0 unless purchases

  conference.tickets.for_registration.inject(0) do |sum, registration_ticket|
    sum + purchases[registration_ticket.id.to_s].to_i
  end
end
