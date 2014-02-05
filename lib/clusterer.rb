class Clusterer
	@clusters = []
  attr_reader :clusters

	def initialize(arr)
		@clusters = []
		arr.sort.each do |f|
			@clusters.push Cluster.new(f)
		end
		
	end

	def minDist
    	min = distTo(@clusters[0],@clusters[1])
    	c1 = @clusters[1]
    	i=2
      j=0
    	while i<@clusters.length
      		if (min > distTo(@clusters[i],@clusters[i-1]))
      			c1 = @clusters[i] 
      			j=i-1
      			min = distTo(@clusters[i],@clusters[i-1])
      		end
      		i+=1
    	end
    	c1.merge(@clusters.delete_at(j))
    end	
  
  	def distTo (c1,c2)
  		(c1.to_d - c2.to_d).abs
  	end

  	def clustering 
  		while @clusters.size > 1
  			minDist
  		end
  		@clusters
  	end

  
end