class TranscodeVideoJob < ApplicationJob
  def perform(message_id)
    message = Message.find(message_id)
    return unless message.attachment?

    VideoTranscoder.call(message)
  end
end
