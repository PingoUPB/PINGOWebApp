class Statistics
  def self.avg(arr)
    arr.sum / arr.length
  end

  def self.median(arr)
    sorted = arr.sort
    if arr.length.odd?
      sorted[arr.length/2]
    else
      (sorted[arr.length/2 - 1] + sorted[arr.length/2]).to_f / 2
    end
  end

  def self.stdev(arr)
    if arr.size > 1
     arr.stdev
   else
    0
    end
  end

  def self.histogram(arr, no_buckets = 10)
    # TODO: find optimal no of buckets and filter outliers using Grubb's Test
      no_buckets = arr.length if no_buckets > arr.length
      bins, freqs = arr.histogram(no_buckets)
      bins.map! do |i|
       Statistics.sigfig_to_s(i,2) 
     end
      bins.zip freqs
  end

  def self.cluster(arr, threshold = nil)
    threshold = arr.flatten.group_by{|x|x}.values.map(&:size).sort.last unless threshold
    cl = Clusterer.new(arr)
    clusters = cl.clustering
    recursive_cluster(cl.clusters.first.items, threshold, []) 
  end 

   def self.sigfig_to_s(number, digits)
    f = sprintf("%.#{digits - 1}e", number).to_f
    i = f.to_i
    (i == f ? i : f).to_s
  end

  private

  def self.recursive_cluster(arr, threshold, agg)
    arr.each do |cluster|
        if cluster.respond_to? :flatten and cluster.flatten.size > threshold

          recursive_cluster(cluster, threshold, agg)
        else
          cluster = cluster.flatten if cluster.respond_to? :flatten
          agg << cluster
        end
      end
    
    agg.sort
  end


end