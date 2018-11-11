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

loop do

	client = server.accept

	file_content = File.read(file_name_in)
	header = file_content.split("###")[0]
	payload = file_content.split("###")[1..-1].join('')

	seq, ack, ctl = parse_header(header)

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

				socket = TCPSocket.open(IP, PORT)
				response = socket.gets.chomp
				socket.close

				res_header = build_header(seq:current_seq.to_s, ack:nil, ctl:[])
				output = res_header + "###" + response

				connection_state = "LOST"

				client.puts output
				client.close
			end
		end
	end

	File.write(file_name_out, payload)

	socket = TCPSocket.open(IP, PORT)
	response = socket.gets.chomp
	socket.close

	client.puts response
	client.close
end
