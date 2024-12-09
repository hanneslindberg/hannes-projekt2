class App < Sinatra::Base
	def db
		return @db if @db

		@db = SQLite3::Database.new("db/todos.sqlite")
		@db.results_as_hash = true

		return @db
	end

	configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  get '/' do
    if session[:user_id]
      erb(:"admin/index")
    else
      erb(:"index")
    end
  end

  get '/admin' do
    if session[:user_id]
      erb(:"admin/index")
    else
      status 401
      redirect '/unauthorized'
    end
  end

	post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]

    user = db.execute("SELECT * FROM users WHERE username = ?", request_username).first

    unless user
      status 401
      redirect '/unauthorized'
    end

    db_password_hashed = user["password"].to_s
    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

    if bcrypt_db_password == request_plain_password
      session[:user_id] = user["id"].to_i
			@todos = 
      redirect '/todos'
    else
      status 401
      redirect '/unauthorized'
    end
	end

	get '/unauthorized' do
    erb(:unauthorized)
  end

	get '/logout' do
    session.clear
    redirect '/'
  end

  get '/create_account' do
    erb(:create_account)
  end

  post '/create_account' do
    form_username = params[:username]
    form_password = BCrypt::Password.create(params[:password])

    all_usernames = db.execute('SELECT username FROM users')

    all_usernames.each do | user |
      if user['username'] == form_username
        redirect '/unauthorized'
      end
    end

    db.execute("INSERT INTO users (username, password) VALUES(?, ?)", [form_username, form_password])

    user = db.execute("SELECT * FROM users WHERE username = ?", form_username).first
    session[:user_id] = user["id"].to_i

    redirect '/todos'
  end

	get '/todos' do
		@todos = db.execute('SELECT * FROM todos')
		@user = db.execute('SELECT * FROM users WHERE id = ?', session[:user_id]).first

		erb(:"admin/index")
	end

	post '/todos' do
		name = params["name"]
		description = params["description"]

		db.execute("INSERT INTO todos (name, description, user_id) VALUES(?, ?, ?)", [name, description, session[:user_id]])
		redirect '/todos'
	end

	post '/todos/:id/delete' do | id |
		db.execute("DELETE FROM todos WHERE id =?", id)

		redirect("/todos")
	end

	get '/todos/:id/edit' do | id |
		@todo = db.execute("SELECT * FROM todos WHERE id =?", id).first

		erb(:"edit")
	end

	post "/todos/:id/update" do | id |
		name = params['name']
		description = params['description']
		query = "UPDATE todos SET name = ?, description = ? WHERE id=?"
		
		db.execute(query, [name, description, id])
		
		redirect("/todos")
	end
end