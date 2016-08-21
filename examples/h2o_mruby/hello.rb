class App
  RES_HEADER = { 'Content-Type' => 'application/json; charset=utf-8' }

  def self.init_db(host, user, password, table)
    MySQL::Database.new(host, user, password, table)
  end

  def initialize
    @db ||= App.init_db('localhost', 'root', '', 'authmysql')
    super
  end

  # @param [Array<String>, String] like ['select * from table where col1=?', 1]
  # @return [Array<Hash>] like [{col1: val1, col2: val2}, {col1: val3, col2: val4}]
  def select_db(query)
    results = []
    @db.execute(*query) do |row, fields|
      hash = {}
      fields.each_with_index { |field, i| hash[field.to_sym] = row[i] }
      results << hash
    end
    results
  end

  def response(status, msg)
    [status, RES_HEADER, [msg]]
  end

  def render(method, path, query, input, x_headers)
    id = x_headers['HTTP_X_ID'].to_i
    results = select_db(['select * from users where id=?', id])
    return response(404, "Not Found\n") if results.empty?

    user = results.first
    response(200, "id: #{user[:id]}\nname: #{user[:name]}\nuser_group: #{user[:user_group]}")

    #res_msg = "method: #{method}\npath: #{path}\nquery: #{query}\ninput: #{input}\nx_headers: #{x_headers}\n"
    #response(200, res_msg)
  end

  def call(env)
    req_method = env['REQUEST_METHOD']
    req_path = env['PATH_INFO']
    req_query = env['QUERY_STRING']
    req_input = env['rack.input'] ? env['rack.input'].read : ''
    req_x_headers = env.select { |k, v| k[0, 6] == 'HTTP_X' }
    render(req_method, req_path, req_query, req_input, req_x_headers)
  end
end

App.new

### YAML test
#puts 'YAML'
#yaml_str = <<EOS
#a1:
#  a2:
#    a3-1: 1
#    a3-2: 2
#b1: hoge
#EOS
#p YAML.load(yaml_str)


### MySQL test
#puts 'MySQL'
#mysql = MySQL::Database.new('localhost', 'root', '', 'authmysql')
#begin
#  mysql.execute_batch('drop table users')
#rescue ArgumentError
#  # do nothing
#ensure
#  create_table_sql = <<EOS
#create table users(
#  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
#  name varchar(191) NOT NULL,
#  user_group int(10) DEFAULT NULL,
#  PRIMARY KEY (id)
#)
#EOS
#  mysql.execute_batch(create_table_sql)
#end
#mysql.transaction
#10.times.each do |i|
#  mysql.execute_batch('insert into users(name, user_group) values(?, ?)', "hoge#{i%5}", i%3)
#end
#mysql.commit
#results = []
#mysql.execute('select * from users where user_group=?', 1) do |row, fields|
#  hash = {}
#  fields.each_with_index { |field, i| hash[field.to_sym] = row[i] }
#  results << hash
#end
#p results


### Redis test
#puts 'Redis'
#redis = Redis.new('127.0.0.1', 6379, 60)
#redis.select(1_000)
#redis.flushmysql
#redis['hoge'] = 'hogehoge'
#p redis['hoge']
