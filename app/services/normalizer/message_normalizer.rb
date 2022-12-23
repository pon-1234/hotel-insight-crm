# frozen_string_literal: true

class Normalizer::MessageNormalizer
  def initialize(message_content, data = nil)
    @message_content = message_content
    @data = data
  end

  def perform
    return if @message_content.nil?
    Normalizer::PostbackNormalizer.new(@message_content).perform
    inject_variables(@message_content, @data) if @data.present?
    # Return normalized content
    @message_content
  end

  def inject_variables(content, data)
    content['text'].gsub! '{name}', data.name || '' if content['text']
  end
end
