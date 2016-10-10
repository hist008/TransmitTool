unit uFrmMain_Transmit;

interface

uses
  Windows, Messages, SysUtils,StrUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, RzPanel, StdCtrls, RzStatus,
  ActnList,uTFSystem, Buttons, PngBitBtn, ShellAPI,DateUtils,uDBLog,
  XPMan, ImgList, PngImageList, ComCtrls, RzTray,uSystemConfig,uFtpManager,uSharedManager;

const
  {自动启动时间}
  AUTO_START_TIME = 10;
type

//==============================================================================
// 线程     TUPDateThread
// 线程作者    author YaoXin chao
// 修改时间      date : 2015-11-13
//==============================================================================
  TUPDateThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy();override;
  public
    procedure Execute;override;
  public
    procedure Stop();
    procedure Continue();
  private
    m_hExit : THandle ;
    m_OnExecute : TNotifyEvent;
  public
    property OnExecute : TNotifyEvent read m_OnExecute write m_OnExecute;
  end;


  TFrmTransmit = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    E1: TMenuItem;
    N2: TMenuItem;
    RzPanel1: TRzPanel;
    ActionList1: TActionList;
    actStart: TAction;
    actStop: TAction;
    actClearLog: TAction;
    PopupMenu1: TPopupMenu;
    N3: TMenuItem;
    Panel1: TPanel;
    btnStart: TPngBitBtn;
    btnStop: TPngBitBtn;
    btnClearLogMemo: TPngBitBtn;
    Panel3: TPanel;
    btnStopAutoStart: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    MmoLogs: TMemo;
    PngImageList1: TPngImageList;
    XPManifest1: TXPManifest;
    TrayIcon: TRzTrayIcon;
    tmrAutoStart: TTimer;
    tmrShowCountdown: TTimer;
    Timer1: TTimer;
    tmrCaptureRange: TTimer;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    mniClearExpaLog: TMenuItem;
    mniManualUpload: TMenuItem;
    actClearExpaLog: TAction;
    XPManifest2: TXPManifest;
    tmrReStart: TTimer;
    RzStatusBar1: TRzStatusBar;
    RzStatusPane1: TRzStatusPane;
    btnManualUpload: TPngBitBtn;
    Bevel1: TBevel;
    N9: TMenuItem;
    N10: TMenuItem;
    stpVersion: TRzStatusPane;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure N2Click(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnClearLogMemoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure tmrAutoStartTimer(Sender: TObject);
    procedure tmrShowCountdownTimer(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure btnStopAutoStartClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure actClearExpaLogExecute(Sender: TObject);
    procedure tmrReStartTimer(Sender: TObject);
    procedure btnManualUploadClick(Sender: TObject);
    procedure btnManualStopClick(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    //插入一条日志
    procedure InsertUILog(Log:string;IsLogged:Boolean=True);
    //清空日志
    procedure ClearUILog();
    {功能:删除一个文件目录}
    procedure DeleteLogFile();
  private
    //自动上传
    procedure DoWorkAuto(Sender : TObject);
    //手工上传
    procedure DoWorkManual(Sender : TObject);
    //清理过期数据
    procedure DoClearLog(Sender : TObject);
  private
    //上传列表
    procedure UploadFiles(FileList:TStrings);
    //上传到FTP
    function  UploadToFtp(AFileName:string;IsForce:Boolean):Boolean;
    //上传到共享目录
    function  UploadToShared(AFileName:string;IsForce:Boolean):Boolean;
  private
    {功能:打开自动启动同步}
    procedure OpenAutoStart();
    {功能:关闭自动启动同步}
    procedure CloseAutoStart();
    {功能:开始数据同步}
    procedure StartUpdate();
    {功能:结束数据同步}
    procedure EndUpdate();
    {功能:拦截关机消息}
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION ;
  private
    //数据库记录 FTP
    m_FtpManager : TFtpManager ;
    //共享类
    m_SharedManager : TSharedManager ;
    //所有的文件列表
    m_FileListAuto : TStrings;
    //手工列表
    m_FileListManual : TStringList ;
    {是否关闭程序}
    m_bIsClose: Boolean;
    {数据更新线程}
    m_UPDateThread: TUPDateThread;
    {开始显示按钮时间}
    m_nShowButtonTime: int64;
    {当前是否处于自动更新状态}
    m_CriticalSection : TRTLCriticalSection;
    {退出线程事件}
    m_hExitEvent : THandle ;
  end;

var
  FrmTransmit: TFrmTransmit;

implementation

uses
  uGlobalDM,uFrmConfig,uFrmFileSel,uFrmLog;

{$R *.dfm}


var
  g_bStop : Boolean  ;   //if true 停止
  g_bIsUploadFtp,g_bIsUploadShared:Boolean ;

procedure TFrmTransmit.actClearExpaLogExecute(Sender: TObject);
var
  {数据更新线程}
  UPDateThread: TUPDateThread;
begin
  //清理过期日志
  mniClearExpaLog.Enabled := False ;
  UPDateThread := TUPDateThread.Create(True);
  UPDateThread.OnExecute := DoClearLog;
  UPDateThread.Continue;
end;

procedure TFrmTransmit.actClearLogExecute(Sender: TObject);
begin
  ClearUILog ;
end;

procedure TFrmTransmit.actStartExecute(Sender: TObject);
begin
  DoWorkAuto(Sender) ;
end;

procedure TFrmTransmit.btnClearLogMemoClick(Sender: TObject);
begin
  ClearUILog ;
end;

procedure TFrmTransmit.btnManualStopClick(Sender: TObject);
begin
  ;
end;

procedure TFrmTransmit.btnManualUploadClick(Sender: TObject);
var
  {数据更新线程}
  UPDateThread: TUPDateThread;
begin
  if btnStart.Enabled = False then
  begin
    Box('设置选项前,请先停止自动同步!');
    Exit;
  end;

  //获取文件列表
  m_FileListManual.Clear;
  g_bIsUploadFtp := False ;
  g_bIsUploadShared := False ;
  if not GetSelFiles(m_FileListManual,g_bIsUploadFtp,g_bIsUploadShared) then
    exit;

  btnManualUpload.Enabled := False ;
  mniManualUpload.Enabled := False ;
  //上传文件
  UPDateThread := TUPDateThread.Create(True);
  UPDateThread.OnExecute := DoWorkManual;
  UPDateThread.Continue;
end;

procedure TFrmTransmit.btnStartClick(Sender: TObject);
begin
  StartUpdate();
end;

procedure TFrmTransmit.btnStopAutoStartClick(Sender: TObject);
begin
  tmrAutoStart.Enabled := False;
  btnStopAutoStart.Visible := False;
end;

procedure TFrmTransmit.btnStopClick(Sender: TObject);
begin
  self.EndUpdate();


  btnStop.PngImage := nil;
  BtnStop.Enabled := False;
  BtnStart.Enabled := True;
  tmrCaptureRange.Enabled := False;
end;

procedure TFrmTransmit.ClearUILog;
begin
  EnterCriticalSection(m_CriticalSection);
  try
    MmoLogs.Lines.Clear;
  finally
    LeaveCriticalSection(m_CriticalSection);
  end;
end;

procedure TFrmTransmit.CloseAutoStart;
{功能:关闭自动启动同步}
begin
  btnStopAutoStart.Visible := False;
  tmrAutoStart.Enabled := False;
  tmrShowCountdown.Enabled := False;
end;



procedure TFrmTransmit.DeleteLogFile;
var
  List : TStringList ;
  i : Integer ;
  strText : string ;
begin
  List := TStringList.Create;
  try
    GlobalDM.GetLogList(g_strSysPath + 'logs\',List) ;
    for I := 0 to List.Count - 1 do
    begin
      strText := Format(' 正在清理第%d个 , 总共%d个', [i + 1, List.Count]);
      InsertUILog(strText, False);
      DeleteFile(List[i]);
    end;
  finally
   List.Free ;
  end;
end;

procedure TFrmTransmit.DoClearLog(Sender: TObject);
begin
  InsertUILog(' 正在清理过期日志...',False);
  DeleteLogFile ;
  InsertUILog(' 清理过期日志结束',False);
  mniClearExpaLog.Enabled := True ;
end;

procedure TFrmTransmit.DoWorkAuto(Sender : TObject);
var
  strText:string;
begin
  //获取文件列表
  m_FileListAuto.Clear;
  InsertUILog(' 正在检索需要上传的文件……',False);
  GlobalDM.GetFileList(GlobalDM.SystemConfig.Folder,m_FileListAuto);
  strText := Format(' 检索文件完毕,共有[%d]个文件需要上传',[m_FileListAuto.Count]);
  InsertUILog(strText,False);

  UploadFiles(m_FileListAuto)  ;
end;

procedure TFrmTransmit.DoWorkManual(Sender : TObject);
var
  i : Integer ;
  strFileName:string ;
  strText:string;
begin
  try
    strText := Format(' 检索文件完毕,共有[%d]个文件需要上传', [m_FileListManual.Count]);
    InsertUILog(strText, False);
    for i := 0 to m_FileListManual.Count - 1 do
    begin
      strFileName := m_FileListManual.Strings[i];
      //上传到FTP
      if g_bIsUploadFtp then
        UploadToFtp(strFileName,True);
      if g_bIsUploadShared then
        UploadToShared(strFileName,True);

      strText := Format(' 上传文件[%s] 结束', [strFileName]);
      InsertUILog(strText, False);
    end;
    InsertUILog('更新结束', False);

  finally
    mniManualUpload.Enabled := True ;
    btnManualUpload.Enabled := True ;
  end;
end;

procedure TFrmTransmit.E1Click(Sender: TObject);
begin
  m_bIsClose := True;
  Close;
end;

procedure TFrmTransmit.EndUpdate;
begin
  g_bStop := True ;

  SetEvent(m_hExitEvent);

  InsertUILog(' 正在停止数据更新线程……',False);
  try
    if Assigned(m_UPDateThread) then
    begin
      m_UPDateThread.Stop();
      m_UPDateThread.Free;
      m_UPDateThread := nil;
    end;
    InsertUILog(' 停止数据更新线程成功',False);
  except
  end;
end;

procedure TFrmTransmit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if m_bIsClose = False then
  begin
    Action := caNone;
    TrayIcon.MinimizeApp;
    Exit;
  end;
end;

procedure TFrmTransmit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if m_bIsClose = False then
  begin
    CanClose := False;
  end;
end;

procedure TFrmTransmit.FormCreate(Sender: TObject);
begin

  InitializeCriticalSection(m_CriticalSection);

  stpVersion.Caption := G_strSysVersion;

  m_hExitEvent := CreateEvent(nil,True,False,nil);

  m_FtpManager := TFtpManager.Create(GlobalDM.ADOConnection,InsertUILog);
  m_SharedManager := TSharedManager.Create(GlobalDM.ADOConnection,InsertUILog);

  m_FileListAuto := TStringList.Create ;
  m_FileListManual :=  TStringList.Create ;
  PageControl1.ActivePageIndex := 0;

end;

procedure TFrmTransmit.FormDestroy(Sender: TObject);
begin
  //停止同步
  EndUpdate();

  CloseHandle(m_hExitEvent);

  //释放列表
  m_FileListAuto.Free ;
  m_FileListManual.free ;

  //释放传输管理器
  m_FtpManager.Free ;
  m_SharedManager.Free ;

  GlobalDM.SetAutoRun();

  //此句应该放在最后调用，日志输出时还会调用
  DeleteCriticalSection(m_CriticalSection);
end;



procedure TFrmTransmit.FormShow(Sender: TObject);
begin
  OpenAutoStart();
end;



procedure TFrmTransmit.InsertUILog(Log: string;IsLogged:Boolean);
var
  strText : string ;
begin
  EnterCriticalSection(m_CriticalSection);
  try
    //写MEMO日志
    if MmoLogs.Lines.Count>1000 then
    begin
      MmoLogs.Lines.Clear;
    end;

    strText := FormatDateTime('[yyyy-MM-dd hh:mm:ss]',Now);
    strText := strText + Format('%s',[Log]);
    MmoLogs.Lines.Add(strText);

    //写文件日志
    if IsLogged then
    begin
      GlobalDM.InsertLog(strText);
    end;
  finally
    LeaveCriticalSection(m_CriticalSection);
  end;
end;


procedure TFrmTransmit.N2Click(Sender: TObject);
begin
  if btnStart.Enabled = False then
  begin
    Box('设置选项前,请先停止自动同步!');
    Exit;
  end;
  TFrmConfig.Config ;
end;

procedure TFrmTransmit.N5Click(Sender: TObject);
begin
  if not TBox('确认清空日志？') then
    Exit ;
  try
    TDBLog.ClearDB(GlobalDM.ADOConnection);
    Box('清空日志文件完毕');
  except
    on e:Exception do
    begin
      BoxErr(e.Message);
    end;
  end;
end;



procedure TFrmTransmit.N9Click(Sender: TObject);
begin
  TFrmLog.ShowLog ;
end;

procedure TFrmTransmit.OpenAutoStart;
begin
  m_nShowButtonTime := GetTickCount();
  tmrAutoStart.Enabled := True;
  tmrShowCountdown.Enabled := True;
  btnStopAutoStart.Caption :=
    format('"(%d)秒后自动启动数据同步,点击本按钮关闭"', [AUTO_START_TIME]);

  btnStopAutoStart.Visible := True;
end;



procedure TFrmTransmit.StartUpdate;
{功能:开始数据同步}
begin
  btnStop.PngImage := PngImageList1.PngImages.Items[0].PngImage;
  BtnStart.Enabled := False;
  BtnStop.Enabled := True;

  g_bStop := False ;

  //关闭自动启动
  CloseAutoStart();

  InsertUILog(' 正在启动数据更新线程……',False);

  //{
  m_UPDateThread := TUPDateThread.Create(True);
  m_UPDateThread.OnExecute := DoWorkAuto;
  m_UPDateThread.Continue;
  ResetEvent(m_hExitEvent) ;
  //}

end;



procedure TFrmTransmit.Timer1Timer(Sender: TObject);
begin
  if System.DebugHook = 0 then
  begin
    Timer1.Enabled := False;
    TrayIcon.MinimizeApp;
  end;
end;



procedure TFrmTransmit.tmrAutoStartTimer(Sender: TObject);
begin
  tmrShowCountdown.Enabled := False;
  tmrAutoStart.Enabled := False;
  btnStart.Click;
end;

procedure TFrmTransmit.tmrReStartTimer(Sender: TObject);
  procedure ReStart;
  begin
    //记录最近的关闭时间
    GlobalDM.SystemConfig.LastCloseDate := Now;
    //关闭任务栏图标
    TrayIcon.Destroy;
    //重启程序
    GlobalDM.ReStartApp;
  end;
var
  nDay,nHour,nMinute : Word ;
  dtNow : TDateTime ;
  RebootParams : RRebootParams ;
begin
  RebootParams := GlobalDM.SystemConfig.RebootParams ;
  dtNow := Now ;

  nDay := DayOf(dtNow);
  nHour := HourOf(dtNow) ;
  nMinute := MinuteOf(dtNow)  ;
  //对比时间
  if RebootParams.bEnable then
  begin
    //如果今天已经重启过就不在重启
    if RebootParams.dtLastCloseDate = 0 then
    begin
      if (nHour = HourOf(RebootParams.dtCloseDate)) and (nMinute >= MinuteOf(RebootParams.dtCloseDate)) then
      begin
        ReStart
      end;
    end
    else if ( nDay <= DayOf(RebootParams.dtLastCloseDate) ) then
      Exit
    else  if ( nHour >= HourOf(RebootParams.dtCloseDate) ) and ( nMinute >= MinuteOf(RebootParams.dtCloseDate) )  then
    begin
      ReStart
    end;
  end;
end;

procedure TFrmTransmit.tmrShowCountdownTimer(Sender: TObject);
begin
  btnStopAutoStart.Caption := format('"(%d)秒后自动启动数据同步,点击本按钮关闭"',
    [AUTO_START_TIME - ((GetTickCount() - m_nShowButtonTime) div 1000)]);
end;

procedure TFrmTransmit.UploadFiles(FileList:TStrings);
var
  i : Integer ;
  strFileName:string;
  strText : string ;
begin
  try
    m_FtpManager.FilterDate := GlobalDM.SystemConfig.UploadFilterDate  ;
    m_SharedManager.FilterDate := GlobalDM.SystemConfig.UploadFilterDate ;
    for i := 0 to FileList.Count - 1 do
    begin

      if WaitForSingleObject(m_hExitEvent, 0) = WAIT_OBJECT_0 then
        Break;

      if g_bStop then
        Break;

      strFileName := FileList.Strings[i];
      //上传到FTP
      if GlobalDM.SystemConfig.EnableFtp then
        UploadToFtp(strFileName,False);
      if GlobalDM.SystemConfig.EnableShared then
        UploadToShared(strFileName,False);

        {
        //上传完毕后是否删除源文件
        if GlobalDM.UpLoadFileDel then
        begin
          DeleteFile(strFullName)  ;
        end;
        }
      strText := Format(' 上传文件[%s] 结束', [strFileName]);
      InsertUILog(strText, False);
    end;
    InsertUILog('更新结束', False);

    //删除过期日志
    DeleteLogFile();
  finally
    ;
  end;
end;


function TFrmTransmit.UploadToFtp(AFileName: string;IsForce:Boolean): Boolean;
var
  i: Integer;
begin
  //添加到任务列表
  with GlobalDM.SystemConfig do
  begin
    for I := 0 to Length(FTPConfigArray) - 1 do
    begin
      if WaitForSingleObject(m_hExitEvent, 0) = WAIT_OBJECT_0 then
        Break;

      if g_bStop then
        Break;

      m_FtpManager.FTPConfig := FTPConfigArray[i];
      m_FtpManager.UpLoad(AFileName,IsForce) ;
    end;
  end;
  Result := True ;
end;



function TFrmTransmit.UploadToShared(AFileName: string;IsForce:Boolean): Boolean;
var
  i : Integer ;
begin
  //添加到任务列表
  with   GlobalDM.SystemConfig do
  begin
    for I := 0 to Length(SharedConfigArray) - 1 do
    begin

      if WaitForSingleObject(m_hExitEvent, 0) = WAIT_OBJECT_0 then
        Break;

      if g_bStop then
        Break;

      m_SharedManager.SharedConfig := SharedConfigArray[i];
      m_SharedManager.UpLoad(AFileName,IsForce);
    end;
  end;
  Result := True ;
end;



procedure TFrmTransmit.WMQueryEndSession(var Message: TMessage);
begin
  m_bIsClose := True; 
end;

{ TUPDateThread }

procedure TUPDateThread.Continue;
begin
  if self.Suspended then
  begin
    self.Resume();
  end;
end;

constructor TUPDateThread.Create(CreateSuspended: Boolean);
begin
  m_hExit := CreateEvent(nil,False,False,nil);
  inherited ;
end;

destructor TUPDateThread.Destroy;
begin
  CloseHandle(m_hExit);
  m_hExit :=  0 ;
end;

procedure TUPDateThread.Execute;
begin
  while True do
  begin
    if Assigned(m_OnExecute) then
      m_OnExecute(Self);
    if WAIT_OBJECT_0 = WaitForSingleObject(m_hExit,GlobalDM.SystemConfig.Interval*1000) then
    begin
      Break ;
    end;
  end;
end;

procedure TUPDateThread.Stop;
begin
  SetEvent(m_hExit);
  Self.Terminate;
end;

end.
