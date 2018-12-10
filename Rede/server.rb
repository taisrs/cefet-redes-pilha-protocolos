require 'socket'

def build_header(seq:nil, ack:nil, ctl:[], win:nil)

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

	header << "><WIN="
	if win != nil
		header << win
	end

	header << ">"

	return header
end


def parse_header(header)

	elements = header.split(">")

	seq = elements[0].split("=", 2)[1]
	ack = elements[1].split("=", 2)[1]
	ctl = elements[2].split("=")[1]
		if ctl != nil
			ctl = ctl.split(',')
		else
			ctl = []
		end
	win = elements[3].split("=", 2)[1]
	return [seq, ack, ctl, win]
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
MYPORT = 3009
MYIP = '127.0.0.1'
PORT = 3012

server = TCPServer.open(MYIP, MYPORT)

current_seq = 300 + rand(200)
current_ack = nil
syn_seq = nil

available_buffer = 3000

connection_state = "LOST"

debug_file = 'debug.txt'

loop do

	client = server.accept

	file_content = File.read(file_name_in)
	header = file_content.split("###")[0]
	payload = file_content.split("###")[1..-1].join('')

	available_buffer -= payload.bytesize()

	seq, ack, ctl, win = parse_header(header)

	File.write(debug_file, "SERVER: packet received\n\theader - #{header}\n\tpayload - #{payload}", mode:'a')

	if connection_state != "ESTABLISHED"

		File.write(debug_file, "SERVER: connection not yet established\n", mode:'a')

		if ctl.include? 'SYN'

			File.write(debug_file, "SERVER: client requesting connection\n", mode:'a')

			current_ack = seq.to_i + payload.bytesize()
			syn_seq = current_seq

			res_header = build_header(seq:current_seq.to_s, ack:current_ack.to_s, ctl:['SYN', 'ACK'], win:available_buffer.to_s)
			output = res_header + "###" + payload

			client.puts output
			client.close

		elsif ctl.include? 'ACK'

			# if ack.to_i == (current_seq + payload.bytesize())

			File.write(debug_file, "SERVER: client acknowledging packet\n", mode:'a')

			current_seq = current_seq + payload.bytesize()

			# if ack.to_i == (syn_seq + payload.bytesize())

			connection_state = "ESTABLISHED"

			File.write(file_name_out, payload)

			socket = TCPSocket.open(MYIP, PORT)
			response = socket.gets.chomp
			socket.close

			res_header = build_header(seq:current_seq.to_s, ack:nil, ctl:[], win:available_buffer.to_s)
			output = res_header + "###" + response

			client.puts output
			client.close
			# end
			# end
		end
	else

		if ctl.include? 'ACK'

			connection_state = "LOST"
			client.puts ' '
			client.close
		else
			File.write(debug_file, "SERVER: connection established, requesting service\n", mode:'a')

			File.write(file_name_out, payload)

			socket = TCPSocket.open(MYIP, PORT)
			response = socket.gets.chomp
			socket.close

			client.puts response
			client.close
		end
	end
end
