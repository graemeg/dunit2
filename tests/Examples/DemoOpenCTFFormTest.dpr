program DemoOpenCTFFormTest;

{%TogetherDiagram 'E:\Dunit2\WC\Trunk\ModelSupport_DemoOpenCTFFormTest\default.txaPackage'}

uses
  {$IFDEF FASTMM}
    FastMM4,
  {$ENDIF}
  GUITestRunner            in '..\..\src\GUITestRunner.pas',
  TestFramework            in '..\..\src\TestFramework.pas',
  TextTestRunner           in '..\..\src\TextTestRunner.pas',
  ProjectsManager          in '..\..\src\ProjectsManager.pas',
  ProjectsManagerIFace     in '..\..\src\ProjectsManagerIFace.pas',
  TestFrameworkProxyIfaces in '..\..\src\TestFrameworkProxyIfaces.pas',
  TestFrameworkIfaces      in '..\..\src\TestFrameworkIfaces.pas',
  TestFrameworkProxy       in '..\..\src\TestFrameworkProxy.pas',
  TestListenerIface        in '..\..\src\TestListenerIface.pas',
  XMLListener              in '..\..\src\XMLListener.pas',
  Activex,
  CTFInterfaces            in '..\..\..\..\Externals\OpenCTF\CTFInterfaces.pas',
  OpenCTF                  in '..\..\..\..\Externals\OpenCTF\OpenCTF.pas',
  OpenCTFRunner            in '..\..\..\..\Externals\OpenCTF\OpenCTFRunner.pas',
  ctfUtils                 in '..\..\..\..\Externals\OpenCTF\ctfUtils.pas',
  ctfTestActnList          in '..\..\..\..\Externals\OpenCTF\tests\ctfTestActnList.pas',
  ctfTestTabOrder          in '..\..\..\..\Externals\OpenCTF\tests\ctfTestTabOrder.pas',
  ctfTestADO               in '..\..\..\..\Externals\OpenCTF\tests\ctfTestADO.pas',
  ctfTestControls          in '..\..\..\..\Externals\OpenCTF\tests\ctfTestControls.pas',
  ctfTestForm              in '..\..\..\..\Externals\OpenCTF\tests\ctfTestForm.pas',
  ctfTestFrame             in '..\..\..\..\Externals\OpenCTF\tests\ctfTestFrame.pas',
  ctfTestGlobalization     in '..\..\..\..\Externals\OpenCTF\tests\ctfTestGlobalization.pas',
  ctfTestMenus             in '..\..\..\..\Externals\OpenCTF\tests\ctfTestMenus.pas',
  ctfTestNames             in '..\..\..\..\Externals\OpenCTF\tests\ctfTestNames.pas'
  {,MyForm in Myform.pas'}
   ;

{$R *.res}

begin
  // Initialize the COM library
  CoInitialize(nil);
  // Register Form classes
  OpenCTF.RegisterFormClasses([{TMyForm}]);
  // run the tests
  OpenCTFRunner.Run;
end.

