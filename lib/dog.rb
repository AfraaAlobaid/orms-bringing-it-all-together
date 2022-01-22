class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize (name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
            SQL
        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(att)
        self.new(att).save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
            SQL
        self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog = self.new_from_db(dog[0])
        else
           dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name)[0]
        self.new_from_db(dog);
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, @name, @breed, @id);
    end

end
