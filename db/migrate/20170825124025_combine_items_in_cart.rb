class CombineItemsInCart < ActiveRecord::Migration[5.0]
	def up
		#replacemultipleitemsforasingleproductinacartwitha
		#singleitem
		Cart.all.each do |cart|
			#countthenumberofeachproductinthecart
			sums = cart.line_items.group(:product_id ).sum( :quantity)

			sums.each do |product_id, quantity|
				if quantity > 1
					#removeindividualitems
					cart.line_items.where(product_id: product_id).delete_all

					#replacewithasingleitem
					item = cart.line_items.build(product_id: product_id)
					item.quantity = quantity
					item.save!
				end
			end
		end
	end

	def down
		#splititemswithquantity>1intomultipleitems
		LineItem.where("quantity>1").each do |line_item|
			#addindividualitems
			line_item.quantity.times do
				LineItem.create(
					cart_id: line_item.cart_id,
					product_id: line_item.product_id,
					quantity: 1
				)
			end

			#removeoriginalitem
			line_item.destroy
		end
	end
end
