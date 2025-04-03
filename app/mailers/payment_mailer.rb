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
  def reminder_email(school)
    @school = school
    @user = User.find_by(id: school.id)
    mail(to: @user.email_address, subject: "Your subscription is ending soon")
  end
end
