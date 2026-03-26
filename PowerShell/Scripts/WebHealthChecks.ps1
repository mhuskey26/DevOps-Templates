$uri = $OctopusParameters['Uri']
$customHeaders =  $OctopusParameters['customHeaders']
$expectedCode = [int]$OctopusParameters['ExpectedCode']
$timeoutSeconds = [int]$OctopusParameters['TimeoutSeconds']
$Username = $OctopusParameters['AuthUsername']
$Password = $OctopusParameters['AuthPassword']
$UseWindowsAuth = [System.Convert]::ToBoolean($OctopusParameters['UseWindowsAuth'])
$ExpectedResponse = $OctopusParameters['ExpectedResponse']

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls10 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

Write-Host "Starting verification request to $uri"

$headers = @{}
if ($customHeaders)
{
    $customHeaders.Split("`n") |ForEach-Object {
        # Split each pair into key and value
        $key,$value = $_.Split(':')
        # Populate $headers
        $headers[$key] = $value
    }


    Write-Host "Using custom headers $customHeaders"
}

Write-Host "Expecting response code $expectedCode."
Write-Host "Expecting response: $ExpectedResponse."


$timer = [System.Diagnostics.Stopwatch]::StartNew()
$success = $false
do
{
    try
    {
        if ($Username -and $Password -and $UseWindowsAuth)
        {
            Write-Host "Making request to $uri using windows authentication for user $Username"
            $request = [system.Net.WebRequest]::Create($uri)
            $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $(ConvertTo-SecureString -String $Password -AsPlainText -Force)
            $request.Credentials = $Credential 
            
            if ($headers.ContainsKey("Host"))
            {
                $request.Host = $headers["Host"]
            }

            try
            {
                $response = $request.GetResponse()
            }
            catch [System.Net.WebException]
            {
                Write-Host "Request failed :-( System.Net.WebException"
                Write-Host $_.Exception
                $response = $_.Exception.Response
            }
            
        }
		elseif ($Username -and $Password)
        {
            Write-Host "Making request to $uri using basic authentication for user $Username"
            $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $(ConvertTo-SecureString -String $Password -AsPlainText -Force)
            if ($headers.Count -ne 0)
            {
                $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -Credential $Credential -Headers $headers
            }
            else 
            {
                $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -Credential $Credential
            }
        }
		else
        {
            Write-Host "Making request to $uri using anonymous authentication"
            if ($headers.Count -ne 0)
            {
                $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -Headers $headers
            }
            else 
            {
                $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing
            }
        }
        
        $code = $response.StatusCode
        $body = $response.Content;
        Write-Host "Received response code: $code"
        Write-Host "Received response: $body"
        Write-Host "Response code = ($response.StatusCode -eq $expectedCode)"        
        Write-Host "Success = ($body -Match $ExpectedResponse)"

        if($response.StatusCode -eq $expectedCode)
        {
            $success = $true
            Write-Host "Success true since the code matched"
        }
        if ($success -and $ExpectedResponse)
        {
            
            Write-Host "success and the reponse present"
            $success = $body -Match $ExpectedResponse
        }
        Write-Host "Success: $success"
    }
    catch
    {
        # Anything other than a 200 will throw an exception so
        # we check the exception message which may contain the 
        # actual status code to verify
        
        Write-Host "Request failed :-("
        Write-Host $_.Exception

        if($_.Exception -like "*($expectedCode)*")
        {
            $success = $true
        }
    }

    if(!$success)
    {
        Write-Host "Trying again in 10 seconds..."
        Start-Sleep -s 10
    }
}
while(!$success -and $timer.Elapsed -le (New-TimeSpan -Seconds $timeoutSeconds))

$timer.Stop()

# Verify result

if(!$success)
{
    throw "Verification failed - giving up."
}

Write-Host "Success! Found status code $expectedCode"