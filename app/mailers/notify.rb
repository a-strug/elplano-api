# frozen_string_literal: true

# Notify
#
#   Used to send all kinds of notification emails.
#
class Notify < ApplicationMailer
  include Emails::Invite

  def test_email(recipient_email, subject, body)
    mail(
      to: recipient_email,
      subject: subject,
      body: body.html_safe,
      content_type: 'text/html'
    )
  end

  private

  # Return an email address that displays the name of the sender.
  #
  # @param [Integer] sender_id - User ID
  #
  # @return
  #
  def sender(sender_id)
    sender = User.find_by(id: sender_id)

    return unless sender

    address = default_sender_address
    address.display_name = sender.username

    address.format
  end

  # Look up a User by their ID and return their email address
  #
  # @param [Integer] recipient_id - User ID
  #
  # @return [String] - a String containing the User's email address.
  #
  def recipient(recipient_id)
    @current_user = User.find(recipient_id)
    @current_user.email
  end

  # Formats arguments into a String suitable for use as an email subject
  #
  # @param [Array] extra - Extra Strings to be inserted into the subject
  #
  # @example Accepts single argument
  #   subject('Lorem ipsum') #=> "Lorem ipsum"
  #
  # @example Accepts multiple arguments
  #   subject('Lorem ipsum', 'Dolor sit amet') #=> "Lorem ipsum | Dolor sit amet"
  #
  # @return [String]
  #
  def subject(*extra)
    subject = []

    subject.concat(extra) if extra.present?

    if core_config['email_subject_suffix'].present?
      subject << core_config['email_subject_suffix']
    end

    subject.join(' | ')
  end
end
