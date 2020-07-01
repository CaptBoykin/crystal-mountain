require "./serv.cr"
require "./auth.cr"


AGENT.agent_create("myagent","127.0.0.1",9999,"myagent_cookie")
AGENT.create_cookie_file("myagent_cookie","127.0.0.1")
MASTER.run_server(MASTER.init_server("localhost",9999))
