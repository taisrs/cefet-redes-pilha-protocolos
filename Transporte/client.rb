# formato de chamada pelo terminal:
# ruby client.rb <IP_ADDRESS> <FILE_NAME>
ip = ARGV[0]
file = ARGV[1]

# executa script da camada física
# response = `ruby ./teste.rb #{ip} #{file}`
response = `./client.sh #{ip} #{file}`

# retorna via stdout a resposta
puts response