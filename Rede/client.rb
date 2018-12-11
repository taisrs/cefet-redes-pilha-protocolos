# formato de chamada pelo terminal:
# ruby client.rb <IP_ADDRESS> <FILE_NAME>
ip = ARGV[0]
file_name = ARGV[1]

file_content = File.read(file_name)


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


# escreve cada elemento de content_array como uma linha em file_name
#aposto que nao vai usar mais; tais discorda
def write_file(file_name, content_array)

	output = File.new(file_name, 'w')
	content_array.each { |line| output.write line }
	output.close
end


debug_file = 'debug.txt'

connection_state = "LOST"

current_seq = 100 + rand(200)
current_ack = nil

available_buffer = 3000

#sabendo que a conexao nao esta estabelecida
header = build_header(seq:current_seq.to_s, ack:nil, ctl:['SYN'], win:available_buffer.to_s)
output = header + "###" + file_content
File.write(file_name, output)

while connection_state != "ESTABLISHED"

	File.write(debug_file, "CLIENT: connection not yet established\n", mode:'a')

	# executa script da camada física
	response = `python client.py #{ip} #{file_name}`

	# manipulacao da resposta
	res_header = response.split("###")[0]
	res_payload = response.split("###")[1..-1].join('')

	File.write(debug_file, "CLIENT: packet received\n\theader - #{res_header}\n\tpayload - #{res_payload}", mode:'a')

	available_buffer -= res_payload.bytesize()

	seq, ack, ctl, win = parse_header(res_header)

	File.write(debug_file, "CLIENT: packet received\n\theader - #{res_header}\n\tpayload - #{res_payload}", mode:'a')

	if ctl.include? 'ACK'

		# if ack.to_i == (current_seq + res_payload.bytesize())

		File.write(debug_file, "CLIENT: server acknowledging packet\n", mode:'a')

		current_seq = current_seq + res_payload.bytesize()

		if ctl.include? 'SYN'

			File.write(debug_file, "CLIENT: server requesting connection\n", mode:'a')

			current_ack = seq.to_i + res_payload.bytesize()

			connection_state = 'ESTABLISHED'
		end
		# end
	end
end

# executa uma vez que a conexao esteja estabelecida
header = build_header(seq:current_seq.to_s, ack:current_ack.to_s, ctl:['ACK'], win:available_buffer.to_s)
output = header + "###" + file_content
File.write(file_name, output)

# executa script da camada física
response = `python client.py #{ip} #{file_name}`

#response manipulation
res_header = response.split("###")[0]
res_payload = response.split("###")[1..-1].join('')


available_buffer -= res_payload.bytesize()

File.write(debug_file, "CLIENT: packet received\n\theader - #{res_header}\n\tpayload - #{res_payload}", mode:'a')

seq, ack, ctl, win = parse_header(res_header)
current_ack = seq.to_i + "ok, thanks".bytesize()
header = build_header(seq:current_seq.to_s, ack:current_ack.to_s, ctl:['ACK'], win:available_buffer.to_s)
output = header + "###" + "ok, thanks"
File.write(file_name, output)
response = `python client.py #{ip} #{file_name}`

# retorna via stdout a resposta
print res_payload
