class Hello
  def call(env)
    req_method = env['REQUEST_METHOD']
    req_path = env['PATH_INFO']
    req_query = env['QUERY_STRING']
    req_input = env['rack.input'] ? env['rack.input'].read : ''
    [
      200,
      { 'Content-Type' => 'application/json; charset=utf-8' },
      [
        "req_method: #{req_method}\n",
        "req_path: #{req_path}\n",
        "req_query: #{req_query}\n",
        "req_input: #{req_input}\n"
      ]
    ]
  end
end

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


Hello.new
