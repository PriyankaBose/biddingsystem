class SellersController < UsersController
    before_action :authenticate_user!

    def bid
        @product_id = params[:product_id]
        render "start_bid"
    end
    
    def sold
        cache_key = "sold_by_#{current_user.id}"
        user_sold_record = CACHE.get(cache_key)
        if (user_sold_record)
            @products = user_sold_record
            puts "user sould record from cache"
        else
            @products = Product.where(:user_id => current_user.id).joins('INNER JOIN products_under_bids ON products.product_id = products_under_bids.product_id').where('products_under_bids.sell_status' => true)
            CACHE.set(cache_key, @products, 3600)
            puts "user sold record from database"
        end
    end
    
    #TODO: Checking product_id generated by the seller or not
    def start_bid
        product_id = params[:products_under_bid][:product_id]
        minimum_bidding_price = params[:products_under_bid][:minimum_bidding_price]
        now = params[:products_under_bid][:now]
        
        if now == "true"
            bid_start_date = nil
            bid_start_time = nil
        else
            bid_start_date = Date.civil(params[:products_under_bid][:"bid_start_date(1i)"].to_i,
                         params[:products_under_bid][:"bid_start_date(2i)"].to_i,
                         params[:products_under_bid][:"bid_start_date(3i)"].to_i)
            bid_start_time = params[:products_under_bid][:"bid_start_time(4i)"] + ":" +
                         params[:products_under_bid][:"bid_start_time(5i)"]
        end
        
        bid_end_date = Date.civil(params[:products_under_bid][:"bid_end_date(1i)"].to_i,
                         params[:products_under_bid][:"bid_end_date(2i)"].to_i,
                         params[:products_under_bid][:"bid_end_date(3i)"].to_i)
        bid_end_time = params[:products_under_bid][:"bid_end_time(4i)"] + ":" +
                         params[:products_under_bid][:"bid_end_time(5i)"]

        ProductsUnderBid.start_bid?(product_id, minimum_bidding_price, bid_start_date, bid_start_time, bid_end_date, bid_end_time)
        
        @products = Product.paginate(page: params[:page], per_page: 10)
        @products_under_bid = ProductsUnderBid.all
        redirect_to :controller => 'products', :action => 'my_products' and return
    end
    
    def stop_bid
        product_bid_id = params[:product_bid_id]
        ProductsUnderBid.stop_bid?(product_bid_id)
        redirect_to :controller => 'products', :action => 'my_products' and return
    end
    
    private
    # Use callbacks to share common setup or constraints between actions.
    def set_products_under_bid
      @products_under_bid = ProductsUnderBid.find(params[:product_bid_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def products_under_bid_params
      params.require(:products_under_bid).permit(:product_bid_id, :product_id, :minimum_bidding_price, :bid_status, :sell_status, :bid_start_date, :bid_start_time, :bid_end_date, :bid_end_time)
    end
end
