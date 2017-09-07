class FeePaymentsController < ApplicationController

  load_and_authorize_resource
  before_action :set_fee_payment, only: [:update,:show]

  def reset_all
    if request.delete?
      for member in Member.all
        member.fee_payment.update(paid:false) if member.fee_payment
      end
      redirect_to fee_payments_path, notice: 'Die Zahlungsdaten aller Mitglieder wurden erfolgreich zurückgesetzt.'
    end
  end

  def email
      Member.with_open_payment do |m|
        ApplicationMailer.delay.info(m.id, params[:email_subject], params[:email_body])
      end
      head :ok, content_type: "text/html"
  end

  def index
    if params[:open] == 'true'
      @open = true
      @members = Member.with_open_payment
    else
      @members = Member.all
    end
  end

  def update
    if @fee_payment.update(fee_payment_params)
      redirect_to fee_payments_path, notice: 'Finanzdaten wurden erfolgreich aktualisiert.'
    end
  end

  def show
  end

  private

  def set_fee_payment
    @fee_payment = FeePayment.find(params[:id])
  end

  def fee_payment_params
    params.require(:fee_payment).permit(:account_details,:payment_history_notes,:paid,:direct_debit_allowed)
  end
end