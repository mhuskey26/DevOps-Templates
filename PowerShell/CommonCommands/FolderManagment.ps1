"Creating New Folders and Files"

#Create a folder in D:\Temp\ with name "Test Folder"
New-Item -Path 'D:\temp\Test Folder' -ItemType Directory

#Create a file in D:\Temp\Test Folder with name "Test File.txt"
New-Item -Path 'D:\temp\Test Folder\Test File.txt' -ItemType File

"Copy folders or files"

#Copy a folder D:\Temp\Test Folder as D:\Temp\Test Folder1
Copy-Item 'D:\temp\Test Folder' 'D:\temp\Test Folder1'

#Copy a folder recursively D:\Temp\Test Folder to D:\Temp\Test Folder1
Copy-Item 'D:\temp\Test Folder' -Destination 'D:\temp\Test Folder1'

#Copy a folder D:\Temp\Test Folder\Test File.txt to D:\Temp\Test Folder1
Copy-Item 'D:\temp\Test Folder\Test File.txt' 'D:\temp\Test Folder1\Test File1.txt'

#Copy all text file recursively D:\Temp\Test Folder to D:\Temp\Test Folder1
Copy-Item -Filter *.txt -Path 'D:\temp\Test Folder' -Recurse -Destination 'D:\temp\Test Folder1'


"Moving files/folders"

#Move a folder D:\Temp\Test to D:\Temp\Test1
Move-Item D:\temp\Test D:\temp\Test1

#In this example, we'll move a folder D:\Temp\Test\Test.txt to D:\Temp\Test1
Move-Item D:\temp\Test\Test.txt D:\temp\Test1


"Deleting and removeing files/folders"

#Delete a folder D:\Temp\Test Folder1
Remove-Item 'D:\temp\Test Folder1'

#Remove the folder D:\Temp\Test Folder1 recursively. In first example, PowerShell confirms if directory is not empty. In this case, it will simply delete the item.
Remove-Item 'D:\temp\Test Folder' -Recurse

#Delete a file D:\Temp\Test Folder\Test.txt
Remove-Item 'D:\temp\Test Folder\test.txt'

#Remove the folder D:\Temp\Test Folder recursively deleting its all files. In first example, PowerShell confirms if directory is not empty. In this case, it will simply delete the item.
Remove-Item 'D:\temp\Test Folder' -Recurse




