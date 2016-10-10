unit uFrmMain_Transmit;

interface

uses
  Windows, Messages, SysUtils,StrUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, RzPanel, StdCtrls, RzStatus,
  ActnList,uTFSystem, Buttons, PngBitBtn, ShellAPI,DateUtils,uDBLog,
  XPMan, ImgList, PngImageList, ComCtrls, RzTray,uSystemConfig,uFtpManager,uSharedManager;

const
  {�Զ�����ʱ��}
  AUTO_START_TIME = 10;
type

//==============================================================================
// �߳�     TUPDateThread
// �߳�����    author YaoXin chao
// �޸�ʱ��      date : 2015-11-13
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
    //����һ����־
    procedure InsertUILog(Log:string;IsLogged:Boolean=True);
    //�����־
    procedure ClearUILog();
    {����:ɾ��һ���ļ�Ŀ¼}
    procedure DeleteLogFile();
  private
    //�Զ��ϴ�
    procedure DoWorkAuto(Sender : TObject);
    //�ֹ��ϴ�
    procedure DoWorkManual(Sender : TObject);
    //�����������
    procedure DoClearLog(Sender : TObject);
  private
    //�ϴ��б�
    procedure UploadFiles(FileList:TStrings);
    //�ϴ���FTP
    function  UploadToFtp(AFileName:string;IsForce:Boolean):Boolean;
    //�ϴ�������Ŀ¼
    function  UploadToShared(AFileName:string;IsForce:Boolean):Boolean;
  private
    {����:���Զ�����ͬ��}
    procedure OpenAutoStart();
    {����:�ر��Զ�����ͬ��}
    procedure CloseAutoStart();
    {����:��ʼ����ͬ��}
    procedure StartUpdate();
    {����:��������ͬ��}
    procedure EndUpdate();
    {����:���عػ���Ϣ}
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION ;
  private
    //���ݿ��¼ FTP
    m_FtpManager : TFtpManager ;
    //������
    m_SharedManager : TSharedManager ;
    //���е��ļ��б�
    m_FileListAuto : TStrings;
    //�ֹ��б�
    m_FileListManual : TStringList ;
    {�Ƿ�رճ���}
    m_bIsClose: Boolean;
    {���ݸ����߳�}
    m_UPDateThread: TUPDateThread;
    {��ʼ��ʾ��ťʱ��}
    m_nShowButtonTime: int64;
    {��ǰ�Ƿ����Զ�����״̬}
    m_CriticalSection : TRTLCriticalSection;
    {�˳��߳��¼�}
    m_hExitEvent : THandle ;
  end;

var
  FrmTransmit: TFrmTransmit;

implementation

uses
  uGlobalDM,uFrmConfig,uFrmFileSel,uFrmLog;

{$R *.dfm}


var
  g_bStop : Boolean  ;   //if true ֹͣ
  g_bIsUploadFtp,g_bIsUploadShared:Boolean ;

procedure TFrmTransmit.actClearExpaLogExecute(Sender: TObject);
var
  {���ݸ����߳�}
  UPDateThread: TUPDateThread;
begin
  //���������־
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
  {���ݸ����߳�}
  UPDateThread: TUPDateThread;
begin
  if btnStart.Enabled = False then
  begin
    Box('����ѡ��ǰ,����ֹͣ�Զ�ͬ��!');
    Exit;
  end;

  //��ȡ�ļ��б�
  m_FileListManual.Clear;
  g_bIsUploadFtp := False ;
  g_bIsUploadShared := False ;
  if not GetSelFiles(m_FileListManual,g_bIsUploadFtp,g_bIsUploadShared) then
    exit;

  btnManualUpload.Enabled := False ;
  mniManualUpload.Enabled := False ;
  //�ϴ��ļ�
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
{����:�ر��Զ�����ͬ��}
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
      strText := Format(' ���������%d�� , �ܹ�%d��', [i + 1, List.Count]);
      InsertUILog(strText, False);
      DeleteFile(List[i]);
    end;
  finally
   List.Free ;
  end;
end;

procedure TFrmTransmit.DoClearLog(Sender: TObject);
begin
  InsertUILog(' �������������־...',False);
  DeleteLogFile ;
  InsertUILog(' ���������־����',False);
  mniClearExpaLog.Enabled := True ;
end;

procedure TFrmTransmit.DoWorkAuto(Sender : TObject);
var
  strText:string;
begin
  //��ȡ�ļ��б�
  m_FileListAuto.Clear;
  InsertUILog(' ���ڼ�����Ҫ�ϴ����ļ�����',False);
  GlobalDM.GetFileList(GlobalDM.SystemConfig.Folder,m_FileListAuto);
  strText := Format(' �����ļ����,����[%d]���ļ���Ҫ�ϴ�',[m_FileListAuto.Count]);
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
    strText := Format(' �����ļ����,����[%d]���ļ���Ҫ�ϴ�', [m_FileListManual.Count]);
    InsertUILog(strText, False);
    for i := 0 to m_FileListManual.Count - 1 do
    begin
      strFileName := m_FileListManual.Strings[i];
      //�ϴ���FTP
      if g_bIsUploadFtp then
        UploadToFtp(strFileName,True);
      if g_bIsUploadShared then
        UploadToShared(strFileName,True);

      strText := Format(' �ϴ��ļ�[%s] ����', [strFileName]);
      InsertUILog(strText, False);
    end;
    InsertUILog('���½���', False);

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

  InsertUILog(' ����ֹͣ���ݸ����̡߳���',False);
  try
    if Assigned(m_UPDateThread) then
    begin
      m_UPDateThread.Stop();
      m_UPDateThread.Free;
      m_UPDateThread := nil;
    end;
    InsertUILog(' ֹͣ���ݸ����̳߳ɹ�',False);
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
  //ֹͣͬ��
  EndUpdate();

  CloseHandle(m_hExitEvent);

  //�ͷ��б�
  m_FileListAuto.Free ;
  m_FileListManual.free ;

  //�ͷŴ��������
  m_FtpManager.Free ;
  m_SharedManager.Free ;

  GlobalDM.SetAutoRun();

  //�˾�Ӧ�÷��������ã���־���ʱ�������
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
    //дMEMO��־
    if MmoLogs.Lines.Count>1000 then
    begin
      MmoLogs.Lines.Clear;
    end;

    strText := FormatDateTime('[yyyy-MM-dd hh:mm:ss]',Now);
    strText := strText + Format('%s',[Log]);
    MmoLogs.Lines.Add(strText);

    //д�ļ���־
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
    Box('����ѡ��ǰ,����ֹͣ�Զ�ͬ��!');
    Exit;
  end;
  TFrmConfig.Config ;
end;

procedure TFrmTransmit.N5Click(Sender: TObject);
begin
  if not TBox('ȷ�������־��') then
    Exit ;
  try
    TDBLog.ClearDB(GlobalDM.ADOConnection);
    Box('�����־�ļ����');
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
    format('"(%d)����Զ���������ͬ��,�������ť�ر�"', [AUTO_START_TIME]);

  btnStopAutoStart.Visible := True;
end;



procedure TFrmTransmit.StartUpdate;
{����:��ʼ����ͬ��}
begin
  btnStop.PngImage := PngImageList1.PngImages.Items[0].PngImage;
  BtnStart.Enabled := False;
  BtnStop.Enabled := True;

  g_bStop := False ;

  //�ر��Զ�����
  CloseAutoStart();

  InsertUILog(' �����������ݸ����̡߳���',False);

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
    //��¼����Ĺر�ʱ��
    GlobalDM.SystemConfig.LastCloseDate := Now;
    //�ر�������ͼ��
    TrayIcon.Destroy;
    //��������
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
  //�Ա�ʱ��
  if RebootParams.bEnable then
  begin
    //��������Ѿ��������Ͳ�������
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
  btnStopAutoStart.Caption := format('"(%d)����Զ���������ͬ��,�������ť�ر�"',
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
      //�ϴ���FTP
      if GlobalDM.SystemConfig.EnableFtp then
        UploadToFtp(strFileName,False);
      if GlobalDM.SystemConfig.EnableShared then
        UploadToShared(strFileName,False);

        {
        //�ϴ���Ϻ��Ƿ�ɾ��Դ�ļ�
        if GlobalDM.UpLoadFileDel then
        begin
          DeleteFile(strFullName)  ;
        end;
        }
      strText := Format(' �ϴ��ļ�[%s] ����', [strFileName]);
      InsertUILog(strText, False);
    end;
    InsertUILog('���½���', False);

    //ɾ��������־
    DeleteLogFile();
  finally
    ;
  end;
end;


function TFrmTransmit.UploadToFtp(AFileName: string;IsForce:Boolean): Boolean;
var
  i: Integer;
begin
  //��ӵ������б�
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
  //��ӵ������б�
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
