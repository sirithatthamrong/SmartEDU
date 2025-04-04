class PaymentMailer < ApplicationMailer
  default from: "smarteduccc@gmail.com"
    def receipt_email(payment)
      @payment = payment
      @user = payment.user
      @school = @user.school

      # Make sure we have a valid email
      recipient_email = @payment.email

      if recipient_email.present?
        mail(
          to: recipient_email,
          subject: "Payment Receipt"
        )
      else
        Rails.logger.error("Cannot send receipt email: No valid email address for payment ##{payment.id}")
      end
    end
  def reminder_email(school, user)
    @school = school
    @user = user
    # Rails.logger.debug("Sending reminder email for #{@user.email_address}")
    mail(to: @user.personal_email, subject: "Your subscription is ending soon")
  end
end
