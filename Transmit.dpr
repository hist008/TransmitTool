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
  uFtpConfig in '功能单元\配置\uFtpConfig.pas',
  uFrmConfig in '功能窗口\配置\uFrmConfig.pas' {FrmConfig},
  uFrmFtpTrans in '功能窗口\配置\FTP转发\uFrmFtpTrans.pas' {FrmFtpTrans},
  uSharedConfig in '功能单元\配置\uSharedConfig.pas',
  uDBSharedTrans in '功能单元\数据库操作\uDBSharedTrans.pas',
  uFrmSharedTrans in '功能窗口\配置\共享转发\uFrmSharedTrans.pas' {FrmSharedTrans},
  uDBFtpTrans in '功能单元\数据库操作\uDBFtpTrans.pas',
  uFrmFileSel in '功能窗口\选择文件窗口\uFrmFileSel.pas' {FrmFileSel},
  uSystemConfig in '功能单元\配置\uSystemConfig.pas',
  uTransManager in '功能单元\uTransManager.pas',
  uFtpOper in '功能单元\FTP转发\uFtpOper.pas',
  uFtpManager in '功能单元\FTP转发\uFtpManager.pas',
  uSharedOper in '功能单元\共享转发\uSharedOper.pas',
  uSharedManager in '功能单元\共享转发\uSharedManager.pas',
  uFrmLog in '功能窗口\记录查看\uFrmLog.pas' {FrmLog},
  uDBLog in '功能单元\操作日志\uDBLog.pas',
  uLogManage in '功能单元\日志管理器\uLogManage.pas';

{$R *.res}

var
  HMutex: DWord;

begin

  HMutex := CreateMutex(nil, TRUE, 'Transmit_7CEBB85A-F948-4DEB-A9A9-2C209B30DB60'); //创建Mutex句柄
  {-----检测Mutex对象是否存在，如果存在，退出程序------------}
  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    ReleaseMutex(hMutex); //释放Mutex对象
    Exit;
  end;

  TimeSeparator := ':';
  DateSeparator := '-';
  ShortDateFormat := 'yyyy-mm-dd';
  ShortTimeFormat := 'hh:nn:ss';
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Title := '转发工具';
  Application.Initialize;
  try
    try
      Application.CreateForm(TGlobalDM, GlobalDM);

      //连接数据库
      if not GlobalDM.ConnectDB then
      begin
        Application.MessageBox('连接数据库错误', '提示', MB_OK + MB_ICONINFORMATION);
        exit;
      end;

      //加载配置
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

