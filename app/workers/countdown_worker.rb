if ENV["PLATFORM"] == "heroku"
  class CountdownWorker < SimpleWorker::Base
    #used for Heroku, where we can launce SimpleWorkers in the cloud
    
    merge_gem "redis"
    merge_gem "juggernaut"
    merge_gem "mongo"
    merge_gem "mongoid", :require => "mongoid"
    merge_gem "mongoid_token"
  
    merge "../models/survey.rb"
    merge "../models/option.rb"
    merge "../models/event.rb"

    attr_accessor :sid, :url, :mongodb_settings
  
    # The run method is what SimpleWorker calls to run your worker
    def run
      init_mongodb
      iterations = 0
    
      Juggernaut.url = @url
      
      survey = Survey.find(@sid).worker_fields.service
    
      if survey.running? && survey.ends
      
        loop {
          iterations += 1
          Juggernaut.publish("s"+survey.id.to_s, 
            {:type => "countdown", :payload => survey.time_left(true), "iteration" => iterations}
          )
          if iterations % 5 == 0
            #break #################
            survey.reload
            Juggernaut.publish("v"+survey.id.to_s, 
              {:type => "voter_count", :payload => survey.total_votes, "timestamp" => Time.new}
            )
            break unless survey.running? && survey.ends
          end
          sleep 0.5
        }
      
      end
      
    end
  
    def init_mongodb
        Mongoid.configure do |config|
          config.from_hash(@mongodb_settings)
        end
    end

  end
end