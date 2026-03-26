#capture configs
#Client app.config.json
Copy-Item C:\OTS\Applications\LoanApp\SELoanClient\app.config.json -Destination "C:\Users\ktornow\Desktop\Client" -Force
Copy-Item C:\OTS\Applications\LoanApp\SELoanClient\web.config -Destination "C:\Users\ktornow\Desktop\Client" -Force
#Internal appsettings.JSON and all CU jsons
Copy-Item C:\OTS\Applications\LoanApp\seLoanExtSL\*.json -Destination "C:\Users\ktornow\Desktop" -Force
#Internal web.config and nlog.config
Copy-Item C:\OTS\Applications\LoanApp\seLoanExtSL\*.config -Destination "C:\Users\ktornow\Desktop" -Force