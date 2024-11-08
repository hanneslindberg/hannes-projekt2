class App < Sinatra::Base

	def db
		return @db if @db

		@db = SQLite3::Database.new("db/todos.sqlite")
		@db.results_as_hash = true

		return @db
	end

	get '/' do
		@todos = db.execute('SELECT * FROM todos')
		erb(:"index")
	end

	post '/todo/add' do 
		name = params["name"]
		description = params["description"]

		db.execute("INSERT INTO todos (name, description) VALUES(?,?)", [name, description])
		redirect '/'
	end

	post '/todo/:id/delete' do | id |
		db.execute("DELETE FROM todos WHERE id =?", id)

		redirect("/")
	end

	get '/todo/:id/edit' do | id |
		# todo: Hämta info (från databasen) om frukten med id'
		db.execute("SELECT * FROM todos WHERE id =?", id)

		# todo: Visa infon i fruits/edit.erb
		erb(:"/edit")
	end

	# Routen sparar ändringarna från formuläret
	post "/todo/:id/update" do | id |
		# todo: Läs name & category från formuläret
		
		# todo: Kör SQL för att uppdatera datan från formuläret
		
		# todo: Redirect till /fruits
	end
end

