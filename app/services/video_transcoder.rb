require "streamio-ffmpeg"

class VideoTranscoder
  def self.call(attachment)
    new(attachment).call
  end

  def initialize(attachment)
    @attachment = attachment
  end

  def call
    return unless video?
    return if already_transcoded?

    transcode
  end

  private
    attr_reader :attachment

    def video?
      attachment.video?
    end

    def already_transcoded?
      attachment.blob.content_type == "video/mp4" &&
        attachment.blob.metadata[:video]&.dig(:video_codec) == "h264"
    end

    def transcode
      input_path = attachment.blob.path
      output_path = File.join(Dir.tmpdir, "transcoded_#{attachment.blob.id}.mp4")

      movie = FFMPEG::Movie.new(input_path)

      options = {
        video_codec: "libx264",
        audio_codec: "aac",
        movflags: "+faststart",
        preset: "medium",
        crf: 23
      }

      movie.transcode(output_path, options) do |progress|
        Rails.logger.info "Transcoding progress: #{(progress * 100).round}%"
      end

      attachment.attachment.attach(
        io: File.open(output_path),
        filename: "#{attachment.blob.filename.base}.mp4",
        content_type: "video/mp4"
      )

      File.delete(output_path)
    rescue => e
      Rails.logger.error "Video transcoding failed: #{e.message}"
      raise
    end
end
