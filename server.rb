require "sinatra/base"
require "pg"
require "bcrypt"
require "pry"
require "redcarpet"

module Forum
  class Server < Sinatra::Base
    enable :sessions
    @@db = PG.connect({dbname: "gettitdb"})
    
    def current_user
      if session["user_id"]
        @current_user = @current_user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
          SELECT * FROM users WHERE id = $1
        SQL
      else
        # user not logged in -- empty brackets returned true, fix below:
        false
      end
    end

    get "/" do
      if current_user
        redirect "/products"
      else
        redirect "/login"
      end
    end

    get "/login" do
      # binding.pry
      erb :login
    end
# WRITE POSTS FOR LOGIN AND SIGNUP
    post "/login" do
      @user = @@db.exec("SELECT * FROM users WHERE username = $1",[params[:username]]).first
      if @user
        if BCrypt::Password.new(@user["password_digest"]) == params[:password]
          session["user_id"] = @user["id"]
          @login_success = "Sign-in: successful. Welcome back, #{@user["username"]}!"
          erb :products
        else
          @error = "Invalid password!"
          erb :login
        end
      else
        @error = "Invalid username!"
        erb :login
      end
    end

    get "/signup" do
      erb :signup
    end

    post "/signup" do 
      password_digest = BCrypt::Password.create(params["password"])
      new_user = @@db.exec_params(<<-SQL, [params["username"], params["email"], password_digest])
        INSERT INTO users (username, email, password_digest)
        VALUES ($1, $2, $3) RETURNING id;
      SQL
      session["user_id"]=new_user.first["id"].to_i
      @success = "Signup: success!"
      erb :products
    end
    
    get "/products" do
      erb :products
    end

    get "/new_product" do
      if current_user
        erb :product
      else
        @error = "You need to be logged in to do that!"
        erb :login
      end
    end

    post "/products" do
      cat = params["topic_id"]
      brand = params["brand"]
      name = params["name"]
      description = params["description"]

      new_prod = @@db.exec_params(<<-SQL, [cat, brand, name, description, 0])
          INSERT INTO products (topic_id, brand, name, description, votes, ptime)
          VALUES ($1, $2, $3, $4, $5, CURRENT_DATE) RETURNING id;
        SQL
      
      prod_id = new_prod.first['id']

      redirect "/products"
    end

    get "/products/:id" do
      p_id = params[:id].to_i
      @product = @@db.exec_params("SELECT products.votes, products.name, products.brand, products.description, products.ptime, products.id, topics.title FROM products INNER JOIN topics ON products.topic_id=topics.id WHERE products.id = $1", [p_id]).first

      erb :product_page
    end

    post "/products/:id" do
      
      erb :product_page
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


    # functions
    def prod_list
      @@db.exec("SELECT * FROM products ORDER BY votes DESC")
    end
    def prods_w_cats
      @@db.exec("SELECT products.votes, products.name, products.brand, products.ptime, products.id, topics.title FROM products INNER JOIN topics ON products.topic_id=topics.id ORDER BY products.votes DESC")
    end
    def cat_list
      @@db.exec("SELECT * FROM topics")
    end
 
  end

end
