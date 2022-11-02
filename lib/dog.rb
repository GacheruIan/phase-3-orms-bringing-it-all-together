class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:, breed:, id: nil)
      @id=id
      @name = name
      @breed = breed
    end
     # drop table if exists
     def self.drop_table 
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)

    end
    
    #create table.
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end
       
    #mapping class instances into table rows
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES(?, ?)
        SQL
        #insert dog
        DB[:conn].execute(sql, self.name, self.breed)
        #assign id to rows to completely reflect in db
        self.id = DB[:conn].execute("SELECT * FROM dogs")[0][0]
        #return instance
        self

    end
    #creating and saving our instances
    def self.create(name:,breed:)
        dog=self.new(name:name,breed:breed)
        dog.save
    end
    #convert raw data into ruby object
    #retrive data but received as an array cast that data into approptiate attributes.
    def self.new_from_db(row)
        #or self.new
        Dog.new(id: row[0], name: row[1], breed:row[2])
    end
    #like @@all that stored our instace if app is still on, we need a off storage
    #return all songs from db store it in var.(SELECT*FROM...)
    #db connect and map through each row to return a new ruby object for each row.
    def self.all 
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
    DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
    end
    end
    #same as the all has name as a param(indicates name to search)
    #has where clause where name
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
     end.first
    end
     def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
     end
end
