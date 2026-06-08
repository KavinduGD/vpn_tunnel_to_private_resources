# ssh-keygen -t rsa -b 4096 -f ~/.ssh/database_server_key
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/vpn_server_key

# create a key pair
resource "aws_key_pair" "vpn_server_keys" {
  key_name   = "vpn_server_key"
  public_key = file("~/.ssh/vpn_server_key.pub")
}

resource "aws_key_pair" "database_server_keys" {
  key_name   = "database_server_key"
  public_key = file("~/.ssh/database_server_key.pub")
}