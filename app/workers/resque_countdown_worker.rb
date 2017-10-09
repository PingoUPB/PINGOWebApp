require "net/http"
require "uri"

if ENV["PLATFORM"] != "heroku"
  class ResqueCountdownWorker
    #used for own servers, i. e. at maxcluster

    @queue = :timer_workers

    def self.publish_synchronous(channel, message)
      url = URI.parse(ENV["PUSH_URL"])
      Net::HTTP.post_form(url, {message: {channel: channel, data: message}.to_json })
      if defined?(Juggernaut)
        Juggernaut.publish(channel.gsub("/", ""), message)
      end
    end

    def self.perform(sid, url=nil)
      iterations = 0
      
      if defined?(Juggernaut) && url
        Juggernaut.url = url
      end

      survey = Survey.find(sid).service

      if survey.running? && survey.ends

        loop {
          iterations += 1
          publish_synchronous("/s/"+survey.id.to_s,
            {:type => "countdown", :payload => survey.time_left(true), "iteration" => iterations}
          )
          if iterations % 5 == 0
            #break #################
            survey.reload
            publish_synchronous("/v/"+survey.id.to_s,
              {:type => "voter_count", :payload => survey.total_votes, "timestamp" => Time.new}
            )
            break unless survey.running? && survey.ends
          end
          sleep 0.5
        }

      end

    end

  end
end
