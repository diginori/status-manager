require 'test_initializer'
require 'models/product'

class StatusManagerTest < Test::Unit::TestCase

	def test_current_status
		product = Product.first
		assert_equal true, product.status_onsale?
	end

	def test_status_scope
		products = Product.status_reject
		products.each do |product|
			assert product.status_reject?, "#{product.id} is not rejected product"
		end
	end

	def test_status_update
		product = Product.status_reject.first
		assert product.update_status_onsale
		assert product.status_onsale?
	end

	def test_status_group_scope
		products = Product.status_close
		products.each do |product|
			assert product.status_close?
		end
	end

end