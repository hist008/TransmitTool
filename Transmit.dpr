program Transmit;

{%TogetherDiagram 'ModelSupport_Transmit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uFrmConfig\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uGlobalDM\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uSharedCopy\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uFrmMain_Transmit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uSharedCopy\default.txvpck'}
{%TogetherDiagram 'ModelSupport_Transmit\uSharedConfig\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uGlobalDM\default.txvpck'}
{%TogetherDiagram 'ModelSupport_Transmit\uFrmConfig\default.txvpck'}
{%TogetherDiagram 'ModelSupport_Transmit\uFrmMain_Transmit\default.txvpck'}
{%TogetherDiagram 'ModelSupport_Transmit\uDBFtpTrans\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\uDBSharedTrans\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\Transmit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_Transmit\Transmit\default.txvpck'}

uses
  Windows,
  SysUtils,
  Forms,
  uFrmMain_Transmit in 'uFrmMain_Transmit.pas' {FrmTransmit},
  uGlobalDM in 'uGlobalDM.pas' {GlobalDM: TDataModule},
  uFtpConfig in '���ܵ�Ԫ\����\uFtpConfig.pas',
  uFrmConfig in '���ܴ���\����\uFrmConfig.pas' {FrmConfig},
  uFrmFtpTrans in '���ܴ���\����\FTPת��\uFrmFtpTrans.pas' {FrmFtpTrans},
  uSharedConfig in '���ܵ�Ԫ\����\uSharedConfig.pas',
  uDBSharedTrans in '���ܵ�Ԫ\���ݿ����\uDBSharedTrans.pas',
  uFrmSharedTrans in '���ܴ���\����\����ת��\uFrmSharedTrans.pas' {FrmSharedTrans},
  uDBFtpTrans in '���ܵ�Ԫ\���ݿ����\uDBFtpTrans.pas',
  uFrmFileSel in '���ܴ���\ѡ���ļ�����\uFrmFileSel.pas' {FrmFileSel},
  uSystemConfig in '���ܵ�Ԫ\����\uSystemConfig.pas',
  uTransManager in '���ܵ�Ԫ\uTransManager.pas',
  uFtpOper in '���ܵ�Ԫ\FTPת��\uFtpOper.pas',
  uFtpManager in '���ܵ�Ԫ\FTPת��\uFtpManager.pas',
  uSharedOper in '���ܵ�Ԫ\����ת��\uSharedOper.pas',
  uSharedManager in '���ܵ�Ԫ\����ת��\uSharedManager.pas',
  uFrmLog in '���ܴ���\��¼�鿴\uFrmLog.pas' {FrmLog},
  uDBLog in '���ܵ�Ԫ\������־\uDBLog.pas',
  uLogManage in '���ܵ�Ԫ\��־������\uLogManage.pas';

{$R *.res}

var
  HMutex: DWord;

begin

  HMutex := CreateMutex(nil, TRUE, 'Transmit_7CEBB85A-F948-4DEB-A9A9-2C209B30DB60'); //����Mutex���
  {-----���Mutex�����Ƿ���ڣ�������ڣ��˳�����------------}
  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    ReleaseMutex(hMutex); //�ͷ�Mutex����
    Exit;
  end;

  TimeSeparator := ':';
  DateSeparator := '-';
  ShortDateFormat := 'yyyy-mm-dd';
  ShortTimeFormat := 'hh:nn:ss';
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Title := 'ת������';
  Application.Initialize;
  try
    try
      Application.CreateForm(TGlobalDM, GlobalDM);

      //�������ݿ�
      if not GlobalDM.ConnectDB then
      begin
        Application.MessageBox('�������ݿ����', '��ʾ', MB_OK + MB_ICONINFORMATION);
        exit;
      end;

      //��������
      GlobalDM.LoadConfig();

      Application.CreateForm(TFrmTransmit, FrmTransmit);
      Application.Run;
    except
      on e: exception do
      begin
        ;
      end;
    end;
  finally

  end;
end.

