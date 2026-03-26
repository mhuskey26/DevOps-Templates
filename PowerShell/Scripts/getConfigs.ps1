#PS C:\Windows\system32> C:
cls
cd C:
#Internal  "C:\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json"
copy \\se-olb-ewscr1\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr1\blLoanIntSL\ -Force
copy \\se-olb-ewscr2\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr2\blLoanIntSL\ -Force
copy \\se-olb-ewscr3\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr3\blLoanIntSL\ -Force
copy \\se-olb-ewscr4\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr4\blLoanIntSL\ -Force
copy \\se-olb-ewscr5\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr5\blLoanIntSL\ -Force
copy \\se-olb-ewscr6\C$\OTS\Applications\LoanApp\seLoanIntSL\appsettings.json H:\LoanApp\Single\se-olb-ewscr6\blLoanIntSL\ -Force

#  CANNOT USE COMMANDS ON THE DMZ DOMAIAN
#Client
#copy \\se-olb-www6\C$\OTS\Applications\LoanApp\SELoanClient\app.config.json H:LoanApp\Single\se-old-www6\OTS\Applications\LoanApp\SELoanClient\ -Force
#copy \\se-olb-www7\C$\OTS\Applications\LoanApp\SELoanClient\app.config.json H:LoanApp\Single\se-old-www7\OTS\Applications\LoanApp\SELoanClient\ -Force
#copy \\se-olb-www11\C$\OTS\Applications\LoanApp\SELoanClient\app.config.json H:LoanApp\Single\se-old-www11\OTS\Applications\LoanApp\SELoanClient\ -Force
#copy \\se-olb-www12\C$\OTS\Applications\LoanApp\SELoanClient\app.config.json H:LoanApp\Single\se-old-www12\OTS\Applications\LoanApp\SELoanClient\ -Force
#External
#copy \\se-olb-www6\C$\OTS\Applications\LoanApp\seLoanExtSL\appsettings.json H:LoanApp\Single\se-old-www6\OTS\Applications\LoanApp\seLoanExtSL\ -Force
#copy \\se-olb-www7\C$\OTS\Applications\LoanApp\seLoanExtSL\appsettings.json H:LoanApp\Single\se-old-www7\OTS\Applications\LoanApp\seLoanExtSL\ -Force
#copy \\se-olb-www11\C$\OTS\Applications\LoanApp\seLoanExtSL\appsettings.json H:LoanApp\Single\se-old-www11\OTS\Applications\LoanApp\seLoanExtSL\ -Force
#copy \\se-olb-www12\C$\OTS\Applications\LoanApp\seLoanExtSL\appsettings.json H:LoanApp\Single\se-old-www12\OTS\Applications\LoanApp\seLoanExtSL\ -Force
