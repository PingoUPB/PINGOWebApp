class Cluster 
	include Comparable
	@items = []
	attr_reader:items

	def initialize (fl)
		@items = [BigDecimal(fl.to_s)]
	end

	def <=> (x)
		to_f<=>(x.to_f)
	end

	def points
		@items.flatten
	end

	def to_d
		Statistics.avg points
	end

	def merge(c)
		@items = [@items] << c.items
		self
	end

	def items
		@items
	end

end