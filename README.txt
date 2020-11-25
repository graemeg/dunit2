DUnit2 ReadMe
=============

DUnit2 is designed to improve upon Dunit V9.3 while maintaining a reasonable
degree of compatibility.

The project is still work-in-progress, so changes can occur regularly.


Brief outline of major changes
------------------------------
TestFrameworks.pas has largely been re-written.
Several key service routines have been retained.
TAbstractTest has been superceeded.
GUITextRunner and TextTestRunner have been retained with minimal modifications 
by introducing an intermediary TestFrameworkProxy class.
Initially it was intended to replace GUITestRunner to work directly with the new 
core code to improve execution speed. 
A ProjectsManager class has been introduced to handle multiple "Projects".

FastMM4Options.inc has been modified so FastMM4 should to be included in 
projects to pick up these changes. 


Effect of changes
-----------------
TTestCase constructors and destructors only execute once per TTestCase
registration, not once per published test method registration.
Speed of execution for repeat tests is considerably improved.
Simple unit tests (registered during initialization) should execute without code
change.

Complex unit tests i.e tests that reference internal DUnit functionality such as 
TTestResult and TTestFaulure now access these as interfaces.  
These usually only requires the addition of the interface definition unit name 
to a uses clause and to change types from TObject to TInterfaced Object. 
Calls to ".free" or "FreeOnNil" need to be changed to ":= nil".   
If TTestCase instances are created in more complex (i.e. not via RegisterTest) 
the constructor currently does not take a string parameter and the 
variable definition should be changed to "ITestCase" from TTestCase. 


Dunit self testing
------------------
For unit test registration Dunit2 employs a Singleton class "IProjectManager" 
which is itself extensively unit tested and released after many tests. 
Consequently unit self-tests need to be conducted on a duplicate subset of files.
Provision for this is included in the unit tests in the "Ref" folder.     

Up to (5) DLLs are loaded during unit testing of "TestModules" and 
"TestFrameworkProxy".
These have been pre-compiled and supplied. If significant changes are made to
TestFrameworks interfaced the DLLs need to be recompiled before executing unit 
tests in "UnitTestModules" and "UnitTestFrameworkProxy".

Testing under different computer loads may invoke an occasional test
timing error. These are insignificant in the overall scheme of things.


Files
-----
The accompanying files are spread through several folders.
"src" contains the usual suspects.
"tests" contains the new suite of unit tests.
"Ref" contains a duplicate of several src files that are compiled in while self
testing.
"Projects" contains a folder for each supported compiler, e.e. D5..D10, .NET
Each "Dx" folder contains the DPRs, DFM and a DCUs folder specific to each
compiler.

"Externals" contains third party tools, FastMM and JEDI_JCL.
The required JEDI JCL code has been mirrored into folders:-
JCL_Source, 
JCL_Common and 
JCL_Windows. 


Dunit2 Detailed Description
---------------------------
For an overview of Dunit2 design aims, new functionality and progress see:

   https://graemeg.github.io/dunit2/

You can also visit the original website of Peter McNab at:

   http://members.optusnet.com.au/mcnabp/index.html
