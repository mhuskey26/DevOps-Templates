What is PowerShell Start Process? How to Execute a File from a Command Line in Windows
ALEXANDRA ALTVATERJUNE 26, 2017DEVELOPER TIPS, TRICKS & RESOURCES

PowerShell is an incredible tool; you can even extend its powers with Azure PowerShell to control Azure’s robust functionality, allowing you to use cmdlets to provision VMs, create cloud services, and carry out a number of other complex processes.

At Stackify, we’re big fans of Azure, but that’s not to say it’s the best choice for everyone (check out our Azure vs. AWS comparison here if you’re on the fence). Regardless of whether you intend to extend to Azure or just want to use the plain-old Windows variety, you’ll need to understand the basics, and that’s why we wrote this post. Read on for more.

Definition of PowerShell Start-Process
The PowerShell Start-Process cmdlet opens an executable file — such as a script file. If it’s not an executable file; it starts the program associated with the file.

How It Works
PowerShell is a scripting language that allows users to automate and manage Windows and Windows Server systems. It can be executed in text-based shell or saved scripts. Start-Process is a cmdlet — a.k.a. command.

If you think of PowerShell as a car, then the Start-Process would be the ignition key that starts the car. The task or tasks specified in a line would be like taking a ride in your vehicle.

The Start-Process executes the specified file or files on the local computer (which is a feature that helps protect against remote hacks). The cmdlet allows users to specify parameters that trigger options.

How to Access the Command-Line Interface (CLI)
Here’s how to access the CLI:

Click on Windows PowerScreen from the Start screen or taskbar.
Run PowerShell as an administrator:
Right-click Windows PowerShell in the Start screen or taskbar.
Click Run as Administrator.
How to Use It
When using the PowerShell CLI, the basic syntax of a Power-Start cmdlet is:

PS C:\> Start-Process <String>
To start a program called notepad on the C drive, use:

PS C:\> Start-Process notepad.exe
Start-Process Parameters
Parameters add more power to the cmdlet. For example, this will start Notepad, maximize the window, and keep it until the user is done with Notepad:

PS C:\> Start-Process -FilePath "notepad" -Wait -WindowStyle Maximized
The parameters that can be used include:

-ArgumentList — Parameters or parameter values to use.
-Credential — Specify the user account to perform the process. The default credential is the current user.
-FilePath (required) — Specify the file path and file name of the program or document to be executed.
-LoadUserProfile — Load the Windows user profile for the current user.
-NoNewWindow — Start the process in the current console window otherwise a new window is created by default.
-PassThru — Return a process object for each process without generating any output.
-RedirectStandardError — Send error messages to a file specified by path and file name instead of displaying error in the console by default.
-RedirectStandardInput — Read input from a file specified by path and file name.
-RedirectStandardOutput — Send output to a file specified by path and file name.
-UseNewEnvironment — Use new environment variables instead of the default environment variables for the computer and user.
-Verb — Perform an action that is available to the file name extension of the file specified.
-Wait — Wait for the process to be finished before accepting any more inputs.
-WindowStyle — Change the state of the window for the new process. Available options:
Normal
Hidden
Minimized
Maximized
-WorkingDirectory — Specify the location of the file that will be executed. The default is the current directory.
CommonParameters — Parameters that can be used by any cmdlet.
Try Stackify’s free code profiler, Prefix, to write better code on your workstation. Prefix works with .NET, Java, PHP, Node.js, Ruby, and Python.

Examples of cmdlets
With a Variable
PS C:\> $Browser = "C:\Program Files (x86)\Internet Explorer\IEXPLORE.EXE"

PS C:\> Start-Process $Browser
With Maximum Width Window
PS C:\> $Path = "C:\Program Files\Internet Explorer"

PS C:\> Start-Process -WorkingDirectory $Path iexplore.exe -WindowStyle Maximized
Opens File with Notepad
PS C:\> Start-Process notepad.exe OpenThisFile.txt
With WaitForExit and Variable
PS C:\> Start-Process notepad.exe

PS C:\> $NotepadProc = Get-Process -Name notepad

PS C:\> $NotepadProc.WaitForExit()

PS C:\> $Path = "C:\Program Files\Internet Explorer"

PS C:\> Start-Process -WorkingDirectory $Path iexplore.exe
With Printing a File
PS C:\> start-process PrintThisFile.txt -verb Print
With Running as an Administrator
PS C:\> Start-Process -FilePath "powershell" -Verb runAs
Benefits of PowerShell Start-Process
Script files only can be opened locally. This is a security benefit that prevents remote attacks using PowerShell scripts.
Cmdlet runs in an environment and scripting language supported by Microsoft. It will dedicate resources to keep the language current, troubleshoot and answer questions.
There is a robust developer community that readily shares knowledge.
Cmdlets and system data stores use common, consistent syntax and naming conventions so data can be shared easily.
The command-based navigation of the operating system is simplified, which lets users familiar with the file system navigate the registry and other data stores
Objects can be manipulated directly or sent to other tools or databases.
Software vendors and developers can build custom tools.