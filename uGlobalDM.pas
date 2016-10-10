unit uGlobalDM;

interface

uses
  SysUtils,StrUtils, Classes,Forms,Windows,registry,IniFiles,uTFSystem,uMd5,
  uSystemConfig,uDBSharedTrans, DB, ADODB,uDBFtpTrans,Comobj,DateUtils;
type

//==============================================================================
// 全局功能单元  TGlobalDM
//==============================================================================

  TGlobalDM = class(TDataModule)
    ADOConnection: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  public
    //加载本地配置信息
    procedure LoadConfig;
    //连接本地数据库
    function ConnectDB(Database: WideString=''):Boolean;
    { 获取当前目录里面所有的文件}
    procedure GetFileList(Dir:string;List:TStrings;NeedDir:Boolean=False);
    { 获取当前目录里面所有的文件}
    procedure GetLogList(Dir:string;List:TStrings;NeedDir:Boolean=False);
    {程序自启动}
    procedure SetAutoRun();
    {功能:软件重启}
    procedure ReStartApp();
    {功能:Log}
    procedure InsertLog(LogText:String);
 private
     //压缩和修复数据库
    function CompactDB(AFileName,APassWord:string):boolean; deprecated;
        {功能:检测日志文件是否过期}
    function IsExpired(FileTime:TDateTime;ADay:Integer):Boolean;
    {功能:创建日志路径}
    procedure CreateLogsDir();
    {功能:将日志输出到文件}
    procedure LogOutPutFile(FileName,LogText:String);
  private
    //获取应用程序路径
    function GetAppPath: string;
    //获取FTP转发
    procedure GetSysConfig();
  public
    //配置文件
    SystemConfig : TSystemConfig ;
    //应用程序根路径
    property AppPath : string read GetAppPath;
  end;


var
  GlobalDM: TGlobalDM;
  G_strSysPath : String;//当前系统路径
  G_strSysVersion : String;//当前系统版本号


implementation

{$R *.dfm}

{ TGlobalDM }

function TGlobalDM.CompactDB(AFileName, APassWord: string): boolean;
//压缩与修复数据库,覆盖源文件
var
  STempFileName:string;
  vJE:OleVariant;
  strConnection:string;
begin
  Exit ;
  strConnection := 'Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+'FileTransmit.mdb'+';User Id=admin;Jet OLEDB:Database Password=thinkfreely;';
  try
    vJE:= CreateOleObject('JRO.JetEngine');
    vJE.CompactDatabase(format(strConnection,[AFileName,APassWord]),
    format(strConnection,[STempFileName,APassWord]));
    result:=CopyFile(PChar(STempFileName),PChar(AFileName),false);
    //DeleteFile(STempFileName);
  except
    result:=false;
  end;
end;

function TGlobalDM.ConnectDB(Database: WideString): Boolean;
var
  strConnection: string;
begin
  result := false;
  if ADOConnection.Connected then
    ADOConnection.Connected := false;

  if Database = '' then
    Database := ExtractFilePath(Application.ExeName) + 'FileTransmit.mdb';
  strConnection := 'Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source=' + Database + ';User Id=admin;Jet OLEDB:Database Password=thinkfreely;';
  try
    ADOConnection.Close;
    ADOConnection.ConnectionString := strConnection;
    ADOConnection.Open;
  except
  end;
  if ADOConnection.Connected then
    result := true;
end;

procedure TGlobalDM.CreateLogsDir;
{功能:创建日志路径}
var
  LogsPath : string ;
begin
  LogsPath := g_strSysPath + 'logs\' ;
  if DirectoryExists(LogsPath) = false then
    Mkdir( LogsPath );
end;

procedure TGlobalDM.DataModuleCreate(Sender: TObject);
begin
  G_strSysPath := ExtractFileDir(Application.ExeName) + '\';
  G_strSysVersion := GetFileVersion(Application.ExeName);
  SystemConfig := TSystemConfig.GetInstance(AppPath + 'Config.ini');

  //创建日志文件夹
  CreateLogsDir();

end;

procedure TGlobalDM.DataModuleDestroy(Sender: TObject);
begin
  SystemConfig.FreeInstnce;
end;


function TGlobalDM.GetAppPath: string;
begin
   Result := ExtractFilePath( Application.ExeName )
end;

procedure TGlobalDM.GetFileList(Dir: string; List: TStrings; NeedDir: Boolean);
var
  FSearchRec: TSearchRec;
  FindResult: Integer;
begin
  if Dir[length(Dir)] <> '\' then
    Dir := Dir + '\';
  FindResult := FindFirst(Dir + '*.*', faAnyFile, FSearchRec);
  while FindResult = 0 do
  begin
    if ((FSearchRec.Attr and faDirectory) = 0) then    //文件
    begin
      List.Add(LowerCase(Dir + FSearchRec.Name));
    end;
    if ((FSearchRec.Attr and faDirectory) <> 0) then
    begin
      if ((FSearchRec.Name <> '.') and (FSearchRec.Name <> '..')) then    //文件夹
      begin
        if NeedDir then
          GetFileList(dir + FSearchRec.Name, List);
      end;
    end;
    FindResult := FindNext(FSearchRec);
  end;
  FindClose(FSearchRec.FindHandle);
end;

procedure TGlobalDM.GetLogList(Dir: string; List: TStrings; NeedDir: Boolean);
var
  FSearchRec: TSearchRec;
  FindResult: Integer;
  nLogDate: Integer;
  wrFileTime: TDateTime;
  LSystemTime: TSystemTime;
  LocalFileTime: TFileTime;
begin
  nLogDate := SystemConfig.LogSaveDate;
  if Dir[length(Dir)] <> '\' then
    Dir := Dir + '\';
  FindResult := FindFirst(Dir + '*.log', faAnyFile, FSearchRec);
  while FindResult = 0 do
  begin
    if ((FSearchRec.Attr and faDirectory) = 0) then    //文件
    begin
      //文件时间转换到系统时间
      FileTimeToLocalFileTime(FSearchRec.FindData.ftLastWriteTime, LocalFileTime );
      FileTimeToSystemTime(LocalFileTime, LSystemTime);
      with LSystemTime do
        wrFileTime := EncodeDate(wYear, wMonth, wDay) +
          EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);

      if IsExpired(wrFileTime, nLogDate) then
        List.Add(LowerCase(Dir + FSearchRec.Name));
    end;
    if ((FSearchRec.Attr and faDirectory) <> 0) then
    begin
      if ((FSearchRec.Name <> '.') and (FSearchRec.Name <> '..')) then    //文件夹
      begin
        if NeedDir then
          GetLogList(dir + FSearchRec.Name, List);
      end;
    end;
    FindResult := FindNext(FSearchRec);
  end;
  FindClose(FSearchRec.FindHandle);
end;


procedure TGlobalDM.GetSysConfig;
begin
  with SystemConfig do
  begin

    SetLength(FTPConfigArray, 0);
    TDBFtpTrans.GetFtpList(ADOConnection, FTPConfigArray);

    SetLength(SharedConfigArray, 0);
    TDBSharedTrans.GetSharedList(ADOConnection, SharedConfigArray);
  end;
end;


procedure TGlobalDM.InsertLog(LogText: String);
var
  strFileName : string ;
begin
  strFileName := g_strSysPath + 'logs\' + formatDateTime('yyyymmdd', now) + '.log';
  LogOutPutFile(strFileName, LogText );
end;

function TGlobalDM.IsExpired(FileTime:TDateTime ; ADay: Integer): Boolean;
var
  nDayInterval:Integer ;
begin
  nDayInterval := DaysBetween(Now,FileTime);
  if  nDayInterval >= ADay then
    Result := True
  else
    Result := False ;
end;

procedure TGlobalDM.LoadConfig;
begin
  GetSysConfig;
end;

procedure TGlobalDM.LogOutPutFile(FileName, LogText: String);
{功能:将日志输出到文件}
var
  txFile : TextFile;
  FileHandle : Integer;
begin
  if FileExists(FileName) = False then
  begin
    FileHandle := FileCreate(FileName);
    FileClose(filehandle);
  end;
  AssignFile(txFile,FileName);
  Append(txFile);
  Writeln(txFile,LogText);
  CloseFile(txFile);
end;

procedure TGlobalDM.ReStartApp;
var
  lpStartupInfo: TStartupInfo;
  lpProcessInformation: TProcessInformation;
begin
  FillChar(lpStartupInfo, sizeof(lpStartupInfo), 0);
  FillChar(lpProcessInformation, sizeof(lpProcessInformation), 0);
  lpStartupInfo.cb := sizeof(lpStartupInfo);
  if CreateProcess(nil, PChar(Application.ExeName), nil, nil, false, 0, nil, nil, lpStartupInfo, lpProcessInformation) then
  begin
    CloseHandle(lpProcessInformation.hThread);
    CloseHandle(lpProcessInformation.hProcess);
  end;
  ExitProcess($dead);
end;


procedure TGlobalDM.SetAutoRun();
begin
  SetExeAutoRun('FTP转发工具',AppPath) ;
end;

end.
