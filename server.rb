require "sinatra/base"
require "pg"
require "bcrypt"
require "pry"
require "redcarpet"

module Products

  class Server < Sinatra::Base
    enable :sessions
    @@db = PG.connect({dbname: "gettitdb"})
    def current_user
      if session["user_id"]
        @current_user = @current_user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
          SELECT * FROM users WHERE id = $1
          SQL
      else
        # user not logged in
        {}
      end
    end

    get "/" do 
      # @popular = @@db.exec("SELECT * FROM products LIMIT 3")

      # login form, including sign up button
      redirect "/login"
      # erb :index
    end
    get "/login" do
      erb :login
    end

    get "/signup" do
      erb :signup
    end

    post "/signup" do

    end

    get "/products" do
      #@products_t = @@db.exec("SELECT * FROM products")
      @products_t = tprods
      #binding.pry

      erb :products

    end

    get "/new_prod" do
      
      erb :new_product
    end

    post "/products" do
      cat = params["topic_id"]
      brand = params["brand"]
      name = params["name"]
      dscrp = params["dscrp"]

      new_prod = @@db.exec_params(<<-SQL, [cat, brand, name, dscrp, 0])
      INSERT INTO products (topic_id, brand, name, dscrp, votes, ptime)
      VALUES ($1, $2, $3, $4, $5, CURRENT_DATE) RETURNING id;
      SQL
      prod_id = new_prod.first['id']


      #@prod_vote = @@db.exec_params("UPDATE products SET votes = ")

      # binding.pry
      redirect "/products"
    end

    get "/products/:id" do
      p_id = params[:id].to_i
      # @product = @@db.exec_params("SELECT * FROM products WHERE id = $1", [p_id]).first
      @product = @@db.exec_params("SELECT products.votes, products.name, products.brand, products.ptime, products.id, products.dscrp, topics.title FROM products INNER JOIN topics ON products.topic_id=topics.id WHERE products.id = $1", [p_id]).first
      erb :product
    end

    get "/upvote/:id" do
      product_id = params["id"]
      @@db.exec_params("UPDATE products SET votes = votes + 1 WHERE id = $1", [product_id])
      redirect "/products"
    end

    get "/downvote/:id" do
      product_id = params["id"]
      @@db.exec_params("UPDATE products SET votes = votes - 1 WHERE id = $1", [product_id])
      redirect "/products"
    end


    def tprods
      @@db.exec("SELECT products.votes, products.name, products.brand, products.ptime, products.id, topics.title FROM products INNER JOIN topics ON products.topic_id=topics.id ORDER BY products.votes DESC")
    end
    def prod_list
      @@db.exec("SELECT * FROM products")
    end
    def topic_list
      @@db.exec("SELECT * FROM topics")
    end


  end

end
