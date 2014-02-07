  LeftClick('edtSource', 80, 7);
  EnterKeyInto('edtSource', VK_HOME, '[ssShift]');
  EnterTextInto('edtSource', 'Something Else');
  LeftClick('btnAdd', 50, 11);
  CheckControlTextEqual('lbDest', 'Something Else'#13#10);

  LeftClick('btnDisable', 48, 13);
  LeftClick('BitBtn1', 48, 8);
  LeftClick('SpeedButton1', 53, 11);

  LeftClick('btnModal', 44, 12);
  LeftClickAt(311, 71);
  CheckNotEnabled('btnDisable');

  CheckControlTextEqual('CheckBox1', 'False');
  LeftClick('CheckBox1', 9, 9);
  CheckControlTextEqual('CheckBox1', 'True');

  LeftClick('RadioButton1', 7, 6);
  CheckControlTextEqual('RadioButton1', 'True');

  LeftClick('ComboBox1', 107, 10);
  LeftClickAt(389, 582);
  CheckControlTextEqual('ComboBox1', 'two');

  LeftClick('ListBox1', 27, 33);
  LeftClick('Memo1', 59, 10);
  EnterKeyInto('Memo1', 13, '[]');
  EnterTextInto('Memo1', 'Script Demo');
  CheckControlTextEqual('Memo1', 'TMemo'#13#10'Script Demo');

  if ControlText('edtSource') <> 'Something Else' then
    Fail('(unexpected value)');