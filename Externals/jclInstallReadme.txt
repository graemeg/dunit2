You must create the JCL include files for your particular compiler version.
The steps below will guide you through that process

1) Open a command prompt window in the .\JCL folder

2) Determine the JCLidentity for your Delphi compiler in .\JCL\packages
   Examples:
   D2010 -> d14
   D2009 -> d12
   All supported versions are listed in  .\JCL\install.txt
   
3) Run the install.bat script for your chosen compiler
   Example: 
   for D2009...  .\install.bat d12
   
4) The Project Jedi Installer GUI application appears
   You can select all options (default) to build and install all packages in the Delphi IDE
   Alternatively, if you just want to create the JCL include files...
   On the tab for your chosen compiler (RAD Studio 2009 in our example) 
   uncheck: Environment
            Make library units
            Packages
            Make demos

5) Click the "install" button
   You will see several confirmation dialogues - select "Yes" for all            
           
6) The produced JCL include files will be located in .\JCL\source\include
   In our example for D2009: .\JCL\source\include\jcld12.inc
   
           