# formato de chamada pelo terminal:
# ruby client.rb <IP_ADDRESS> <FILE_NAME>
ip = ARGV[0]
file_name = ARGV[1]

file_content = File.read(file_name)


def build_header(seq:nil, ack:nil, ctl:[])

	header = "<SEQ="
	if seq != nil
		header << seq
	end
	header << "><ACK="
	if ack != nil
		header << ack
	end
	header << "><CTL="
	ctl.each { |flag| header << "#{flag},"}
	header << ">\n"

	return header
end


def parse_header(header)

	elements = header.split(">")

	seq = elements[0].split("=", 2)[1]
	ack = elements[1].split("=", 2)[1]
	ctl = elements[2].split("=")[1].split(',')
	return [seq, ack, ctl]
end


# escreve cada elemento de content_array como uma linha em file_name
#aposto que nao vai usar mais; tais discorda
def write_file(file_name, content_array)

	output = File.new(file_name, 'w')
	content_array.each { |line| output.write line }
	output.close
end


debug_file = 'debug.txt'

connection_state = "LOST"

current_seq = 100
current_ack = nil

#sabendo que a conexao nao esta estabelecida
header = build_header(seq:current_seq.to_s, ack:nil, ctl:['SYN'])
output = header + "###" + file_content
File.write(file_name, output)

while connection_state != "ESTABLISHED"

	# executa script da camada física
	response = `./client.sh #{ip} #{file_name}`

	File.write(debug_file, response, mode:'a')

	# print response
	# connection_state = "ESTABLISHED"

	#response manipulation
	res_header = response.split("###")[0]
	res_payload = response.split("###")[1..-1].join('')

	seq, ack, ctl = parse_header(res_header)

	if ctl.include? 'ACK'
		if ack.to_i == (current_seq + 1)

			current_seq = current_seq + 1

			if ctl.include? 'SYN'

				current_ack = seq.to_i + 1

				connection_state = 'ESTABLISHED'
			end
		end
	end
end

# executa uma vez que a conexao esteja estabelecida
header = build_header(seq:current_seq.to_s, ack:current_ack.to_s, ctl:['ACK'])
output = header + "###" + file_content
File.write(file_name, output)

# executa script da camada física
response = `./client.sh #{ip} #{file_name}`

File.write(debug_file, response, mode:'a')

#response manipulation
res_header = response.split("###")[0]
res_payload = response.split("###")[1..-1].join('')

# retorna via stdout a resposta
print res_payload
