# frozen_string_literal: true

module Admin
  class TicketsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :ticket, through: :conference

    def index
      authorize! :update, Ticket.new(conference_id: @conference.id)
      @tickets_sold_distribution = @conference.tickets_sold_distribution
      @tickets_turnover_distribution = @conference.tickets_turnover_distribution
    end

    def new
      @ticket = @conference.tickets.new
    end

    def create
      @ticket = @conference.tickets.new(ticket_params)
      if @ticket.save
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title),
                    notice: 'Ticket successfully created.'
      else
        flash.now[:error] = "Creating Ticket failed: #{@ticket.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @ticket.update(ticket_params)
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title),
                    notice: 'Ticket successfully updated.'
      else
        flash.now[:error] = "Ticket update failed: #{@ticket.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def give
      message = ''
      ticket_purchase = @ticket.ticket_purchases.new(gift_ticket_params)
      recipient = ticket_purchase.user
      old_ticket_purchases = TicketPurchase.unpaid.by_conference(@conference)
                                           .where(
                                             user_id:   gift_ticket_params[:user_id],
                                             ticket_id: @conference.registration_tickets
                                           )
      # We need to cancel any in progress ticket purchases
      # TODO-SNAPCON: Add tests, update existing DB records? Add pluralize
      if old_ticket_purchases.any?
        message = "(Removed #{old_ticket_purchases.count} unpaid ticket)."
        old_ticket_purchases.destroy_all
      end
      if ticket_purchase.save
        # We must pay for a ticket purchase to create a physical ticket.
        # Because there is no CC xact, the Payment does not need to be saved.
        ticket_purchase.pay(Payment.new)
        registration = @conference.register_user(recipient) if @ticket.registration_ticket?
        redirect_to(
          admin_conference_ticket_path(@conference.short_title, @ticket),
          notice: "#{recipient.name} was given a #{@ticket.title} ticket #{if registration
                                                                             'and registered'
                                                                           end}. #{message}"
        )
      else
        redirect_back(
          fallback_location: admin_conference_ticket_path(@conference.short_title, @ticket),
          error:             "Unable to give #{recipient.name} a #{@ticket.title} ticket: " +
                             ticket_purchase.errors.full_messages.to_sentence
        )
      end
    end

    def destroy
      if @ticket.destroy
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title),
                    notice: 'Ticket successfully deleted.'
      else
        redirect_to admin_conference_tickets_path(conference_id: @conference.short_title),
                    error: 'Deleting ticket failed! ' \
                           "#{@ticket.errors.full_messages.join('. ')}."
      end
    end

    private

    def ticket_params
      params.require(:ticket).permit(
        :conference, :conference_id,
        :title, :url, :description, :email_subject, :email_body,
        :price_cents, :price_currency, :price,
        :registration_ticket, :visible
      )
    end

    def gift_ticket_params
      response = params.require(:ticket_purchase).permit(:user_id)
      response.merge(paid: true, amount_paid: 0, conference: @conference, currency: @conference.tickets.first.price_currency)
    end
  end
end
