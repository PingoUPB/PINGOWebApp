if ENV["PLATFORM"] != "heroku"
  class ResqueCountdownWorker
    #used for own servers, i. e. at maxcluster
  
    @queue = :timer_workers
  
    def self.perform(sid, url)
      iterations = 0
    
      Juggernaut.url = url
      
      survey = Survey.find(sid).service
    
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
  
  end
end