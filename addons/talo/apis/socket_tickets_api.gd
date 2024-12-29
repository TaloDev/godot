class_name SocketTicketsAPI extends TaloAPI
## An interface for communicating with the Talo Socket Tickets API.
##
## This API is used to create tickets for connecting to the Talo Socket.
##
## @tutorial: https://docs.trytalo.com/docs/godot/socket

## Create a new socket ticket.
func create_ticket() -> String:
	var res = await client.make_request(HTTPClient.METHOD_POST, "")

	match res.status:
		200:
			return res.body.ticket
		_:
			push_error("Failed to get socket ticket")
			return ""
