unit uSharedOper;

interface

uses
  Windows,SysUtils,uTFSystem,uSharedConfig;

type

  {日志回调函数}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object;
//==============================================================================
// 共享操作类    author lyq
// 修改时间      date : 2015-11-13
//==============================================================================

  TSharedOper = class
  public
    constructor Create();
    destructor Destroy();override;
  public
    //连接
    function  Connect():Boolean;
    //连接
    function  Connect1():Boolean;
    //上传
    function  UploadFile(FileName:string):Boolean;
    //断开练剑
    procedure DisConnect();
    //检测连接是否存活
    function  IsConnect():Boolean;
  private
    //共享配置
    m_SharedConfig : RSharedConfig ;
    //日志
    m_logEvent : TLogEvent ;
  public
    property  SharedConfig:RSharedConfig read m_SharedConfig write m_SharedConfig ;
    property  LogEvent : TLogEvent  read m_logEvent write m_logEvent ;
  end;


implementation

{ TSharedOper }



function TSharedOper.Connect(): Boolean;
var
  strLog : string ;
  strCommand: string;
  strDir: string;
begin
  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);
    {如果用户名不为空,那么则首先登陆}
  if (SharedConfig.strUserName <> '') then
  begin
    strCommand := 'net use %s /user:%s %s';
    if strDir[length(strDir)] = '\' then
      Delete(strDir, length(strDir), 1);

    strCommand := format(strCommand, [strDir, SharedConfig.strUserName, SharedConfig.strPassword]);

    if Assigned(m_logEvent) then
    begin
      strLog := '正在建立连接,请稍后...'  ;
      m_logEvent(strLog,False);
    end;
    winexec(PChar('cmd.exe /C ' + strCommand), SW_HIDE);
  end;

  Result := DirectoryExists(strDir);

  //写日志
  if not Result then
  begin
    strLog := format('连接失败:{ IP地址:%s}', [SharedConfig.strHost]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,True);
  end;
end;

function TSharedOper.Connect1: Boolean;
var
  lpStartupInfo: TStartupInfo;
  lpProcessInformation: TProcessInformation;

  strLog : string ;
  strCommand: string;
  strDir: string;
begin
  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);
    {如果用户名不为空,那么则首先登陆}
  if (SharedConfig.strUserName <> '') then
  begin
    strCommand := 'net use %s /user:%s %s';
    if strDir[length(strDir)] = '\' then
      Delete(strDir, length(strDir), 1);

    strCommand := format(strCommand, [strDir, SharedConfig.strUserName, SharedConfig.strPassword]);


    FillChar(lpStartupInfo, sizeof(lpStartupInfo), 0);
    FillChar(lpProcessInformation, sizeof(lpProcessInformation), 0);
    lpStartupInfo.cb := sizeof(lpStartupInfo);
    if CreateProcess(PChar('cmd.exe'),PChar(strCommand), nil, nil, false, 0, nil, nil, lpStartupInfo, lpProcessInformation) then
    begin
      CloseHandle(lpProcessInformation.hThread);
      CloseHandle(lpProcessInformation.hProcess);
    end;

    winexec(PChar('cmd.exe /C ' + strCommand), SW_HIDE);
  end;
  Result := DirectoryExists(strDir);

  //写日志
  if not Result then
  begin
    strLog := format('连接失败:{ IP地址:%s}', [SharedConfig.strHost]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,True);
  end;
end;

constructor TSharedOper.Create;
begin

end;

destructor TSharedOper.Destroy;
begin

  inherited;
end;

procedure TSharedOper.DisConnect();
var
  strShared:string;
  strDir: string;
begin
  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);

  strShared :=  Format('cmd.exe /C NET USE %s /DELETE /Y',[strDir]);
  //删除网络共享
  WinExec(PChar(strShared),SW_HIDE)  ;
end;

function TSharedOper.IsConnect(): Boolean;
var
  strDir: string;
begin
  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);
  Result := DirectoryExists(strDir);
end;

function TSharedOper.UploadFile(FileName: string): Boolean;
var
  strSrcFileName : string;
  strDstFileName : string;
  strDir : string;
  strLog : string ;
begin

  //上传文件开始
  strLog := format('正在上传文件:{ IP地址:%s , 文件名字:%s }', [SharedConfig.strHost, FileName]);
  if Assigned(m_logEvent) then
    m_logEvent(strLog,False);

  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);
  strSrcFileName :=  FileName ;

  strDstFileName := Format('%s\%s',[strDir,ExtractFileName(FileName)]) ;
  Result := copyfile(pchar(strSrcFileName),pchar(strDstFileName),false);

  //写日志
  if Result then
  begin
    strLog := format('上传文件成功:{ IP地址:%s , 文件名字:%s }', [SharedConfig.strHost, FileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,False);
  end
  else
  begin
    strLog := format('上传文件失败:{ IP地址:%s , 文件名字:%s }', [SharedConfig.strHost, FileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,True);
  end;
end;

end.
