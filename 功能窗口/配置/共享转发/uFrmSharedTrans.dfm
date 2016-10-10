object FrmSharedTrans: TFrmSharedTrans
  Left = 0
  Top = 0
  Caption = #20849#20139#30446#24405#37197#32622
  ClientHeight = 245
  ClientWidth = 429
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
    Left = 25
    Top = 34
    Width = 89
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = 'IP'#22320#22336#65306
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 16
    Top = 67
    Width = 98
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #29992#25143#21517#65306
    Layout = tlCenter
  end
  object Label5: TLabel
    Left = 16
    Top = 100
    Width = 89
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #23494#30721#65306
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 25
    Top = 141
    Width = 80
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #36335#24452#65306
    Layout = tlCenter
  end
  object btnOK: TButton
    Left = 213
    Top = 198
    Width = 76
    Height = 26
    Caption = #30830#23450
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 302
    Top = 198
    Width = 83
    Height = 26
    Caption = #21462#28040
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object edtHost: TEdit
    Left = 120
    Top = 30
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 2
  end
  object edtUserName: TEdit
    Left = 120
    Top = 69
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 3
  end
  object edtPassword: TEdit
    Left = 120
    Top = 104
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    PasswordChar = '*'
    TabOrder = 4
  end
  object edtPath: TEdit
    Left = 120
    Top = 140
    Width = 153
    Height = 27
    ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 5
  end
  object btnTestConnection: TButton
    Left = 279
    Top = 140
    Width = 99
    Height = 26
    Caption = #27979#35797#36830#25509
    TabOrder = 6
    OnClick = btnTestConnectionClick
  end
end
