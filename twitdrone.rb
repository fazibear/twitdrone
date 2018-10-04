#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require
Dotenv.load

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

@output = UniMIDI::Output.use(:first)
@input = UniMIDI::Input.use(:first)

Thread.new {
  loop do
    puts @input.gets
  end
}

client.sample do |object|
  if object.is_a?(Twitter::Tweet)
    MIDI.using(@output) do
      chord = object.text.scan(/[CDEFGAB]/)
      melody = object.text.scan(/[cdefgab]/)

      Thread.new {
        channel 1
        play chord.first(1), melody.length * 0.2
      }

      melody.each { |n|
        channel 0
        play n, 0.2
      }
    end
  end
end

