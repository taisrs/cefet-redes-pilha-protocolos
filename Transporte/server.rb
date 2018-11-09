require 'socket'

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

# escreve cada elemento de content_array como uma linha em file_name_out
def write_file(file_name_out, content_array)

	output = File.new(file_name_out, 'w')
	content_array.each { |line| output.write line }
	output.close
end

file_name_in = 'segment.txt'
file_name_out = 'command.txt'

# execucao do servidor
MYPORT = 3010
MYIP = '127.0.0.3'

PORT = 3009
IP = '127.0.0.2'

server = TCPServer.open(MYIP, MYPORT)

current_seq = 300
current_ack = nil

connection_state = "ESTABLISHED"

loop {

	client = server.accept

	#header = File.open(file_name_in, &:readline) ### AQUI ESTÁ UM PROBLEMA: NÃO É O CABEÇALHO EM UMA LINHA E O PAYLOAD EM OUTRA
	#payload = File.readlines(file_name_in)[1..-1]

	file_content = File.read(file_name_in)
	header = file_content.split("###")[0]
	payload = file_content.split("###")[1..-1].join('')

	seq, ack, ctl = parse_header(header)

	#connection_state = File.read('server_connection.tcp')

	if connection_state != "ESTABLISHED"

		if ctl.include? 'SYN'

			current_ack = seq.to_i + 1

			res_header = build_header(seq:current_seq.to_s, ack:current_ack.to_s, ctl:['SYN', 'ACK'])
			output = res_header + "###" + payload

			client.puts output
			client.close

		elsif ctl.include? 'ACK'

			if ack.to_i == (current_seq + 1)

				current_seq = current_seq + 1
				connection_state = "ESTABLISHED"

				File.write(file_name_out, payload)

				s = TCPSocket.open(IP, PORT)
				server_response = s.gets.chomp
				s.close

				res_header = build_header(seq:current_seq.to_s, ack:nil, ctl:[])
				output = res_header + "###" + server_response

				connection_state = "LOST"

				client.puts output
				client.close
			end
		end
	end

	File.write(file_name_out, payload)

	s = TCPSocket.open(IP, PORT)
	puts "conectado ao node"
	# server_response = s.gets.chop
	# puts server_response
	server_response = ""
	while res = s.gets
		puts res.chop
		server_response << res.chop
	end
	puts server_response
	s.close

	output = server_response

	client.puts output
	client.close

	# write_file(file_name_out, payload)

	# s = TCPSocket.open(IP, PORT)
	# server_response = s.gets.chomp
	# s.close

	# current_seq = current_seq + 1
	# res_header = build_header(seq:current_seq.to_s, ack:nil, ctl:[])
	# file_lines = res_header << ')()()(' << server_response

	# client.puts file_lines
	# client.close
}
