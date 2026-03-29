require "streamio-ffmpeg"

class VideoTranscoder
  def self.call(io)
    new(io).call
  end

  def initialize(io)
    @io = io
  end

  def call
    return @io unless video?
    return @io if already_transcoded?

    transcoded_io
  end

  private
    attr_reader :io

    def video?
      io.content_type&.starts_with?("video/")
    end

    def already_transcoded?
      io.content_type == "video/mp4"
    end

    def transcoded_io
      output_path = File.join(Dir.tmpdir, "transcoded_#{SecureRandom.hex}.mp4")

      movie = FFMPEG::Movie.new(io.path)

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

      transcoded = File.open(output_path)
      transcoded.content_type = "video/mp4"
      transcoded.original_filename = "#{File.basename(output_path, '.*')}.mp4"

      File.delete(output_path)
      transcoded
    rescue => e
      File.delete(output_path) if output_path && File.exist?(output_path)
      Rails.logger.error "Video transcoding failed: #{e.message}"
      raise
    end
end
