function test() {
  $msg = [System.Text.Encoding]::ASCII.GetBytes("GET / HTTP/1.2`r`nHost: localhost`r`n`r`n")
  $c = New-Object System.Net.Sockets.TcpClient("services.deluxe.com",443)
  $str = $c.GetStream()
  $str.Write($msg, 0, $msg.Length)
  $buf = New-Object System.Byte[] 4096
  $count = $str.Read($buf, 0, 4096)
  [System.Text.Encoding]::ASCII.GetString($buf, 0, $count)
  $str.Close()
  $c.Close()
}
test


#https://optima-ims.deluxe.com/api/v1/optima/webenabler
#https://services.deluxe.com/oauth2/v1/token