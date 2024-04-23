# frozen_string_literal: true

class TicketPurchasesController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  authorize_resource

  def create
    current_user.ticket_purchases.by_conference(@conference).unpaid.destroy_all

    selected_currency = params[:currency]

    # Create a ticket purchase which can be paid or unpaid
    count_registration_tickets_before = current_user.count_registration_tickets(@conference)
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets].try(:first), selected_currency)
    # The new ticket_purchase has been added to the database. current_user.ticket_purchases contains the new one.
    count_registration_tickets_after = current_user.count_registration_tickets(@conference)

    # Failed to create ticket purchase
    if message.present?
      redirect_to conference_tickets_path(@conference.short_title),
                  error: "Oops, something went wrong with your purchase! #{message}"
      return
    end

    # Current user already paid for a registration ticket and the current ticket purchase contains one
    if count_registration_tickets_before == 1 && count_registration_tickets_after > 1
      redirect_to conference_physical_tickets_path,
                  error: 'You already have one registration ticket for the conference.'
      return
    end

    # User needs to pay for tickets if any of them is not free.
    if current_user.ticket_purchases.by_conference(@conference).unpaid.any?
      has_registration_ticket = count_registration_tickets_before.zero? && count_registration_tickets_after == 1
      redirect_to new_conference_payment_path(has_registration_ticket: has_registration_ticket, currency: selected_currency),
                  notice: 'Please pay here to get tickets.'
      return
    end

    # Automatically register the user after purchasing a registration ticket.
    if count_registration_tickets_before.zero? && count_registration_tickets_after == 1
      registration = @conference.register_user(current_user)
      if registration
        redirect_to conference_physical_tickets_path,
                    notice: "Thanks! Your ticket is booked successfully & you have been registered for #{@conference.title}"
      else
        redirect_to new_conference_conference_registration_path(@conference.short_title),
                    notice: 'Thanks! Your ticket is booked successfully. Please register for the conference.'
      end
    else
      redirect_to conference_physical_tickets_path,
                  notice: 'Thanks! Your ticket is booked successfully.'
    end
  end

  def index
    @unpaid_ticket_purchases = current_user.ticket_purchases.by_conference(@conference).unpaid
  end

  def destroy
    @ticket_purchase = TicketPurchase.find(params[:id])
    authorize! :delete, @ticket_purchase
    @ticket_purchase.delete
    redirect_to admin_conference_ticket_path(@conference, @ticket_purchase.ticket.id),
                notice: "Ticket for user #{@ticket_purchase.user.name} successfully removed."
  end

  private

  def ticket_purchase_params
    params.require(:ticket_purchase).permit(:ticket_id, :user_id, :conference_id, :quantity)
  end
end
