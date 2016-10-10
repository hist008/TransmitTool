object FrmFtpTrans: TFrmFtpTrans
  Left = 0
  Top = 0
  Caption = 'FTP'#37197#32622
  ClientHeight = 255
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 19
  object Label1: TLabel
    Left = 41
    Top = 18
    Width = 89
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = 'FTP'#22320#22336#65306
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 32
    Top = 48
    Width = 98
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #31471#21475#21495#65306
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 32
    Top = 81
    Width = 98
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #29992#25143#21517#65306
    Layout = tlCenter
  end
  object Label5: TLabel
    Left = 32
    Top = 114
    Width = 89
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #23494#30721#65306
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 41
    Top = 155
    Width = 80
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #36335#24452#65306
    Layout = tlCenter
  end
  object btnOK: TButton
    Left = 229
    Top = 206
    Width = 76
    Height = 26
    Caption = #30830#23450
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 318
    Top = 206
    Width = 83
    Height = 26
    Caption = #21462#28040
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object edtHost: TEdit
    Left = 136
    Top = 14
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 2
  end
  object edtPort: TEdit
    Left = 136
    Top = 48
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 3
  end
  object edtUserName: TEdit
    Left = 136
    Top = 83
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 4
  end
  object edtPassword: TEdit
    Left = 136
    Top = 118
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    PasswordChar = '*'
    TabOrder = 5
  end
  object edtPath: TEdit
    Left = 136
    Top = 154
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 6
  end
  object btnTestConnection: TButton
    Left = 302
    Top = 154
    Width = 99
    Height = 26
    Caption = #27979#35797#36830#25509
    TabOrder = 7
    OnClick = btnTestConnectionClick
  end
end
