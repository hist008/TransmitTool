unit uSharedOper;

interface

uses
  Windows,SysUtils,uTFSystem,uSharedConfig;

type

  {��־�ص�����}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object;
//==============================================================================
// ���������    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  TSharedOper = class
  public
    constructor Create();
    destructor Destroy();override;
  public
    //����
    function  Connect():Boolean;
    //����
    function  Connect1():Boolean;
    //�ϴ�
    function  UploadFile(FileName:string):Boolean;
    //�Ͽ�����
    procedure DisConnect();
    //��������Ƿ���
    function  IsConnect():Boolean;
  private
    //��������
    m_SharedConfig : RSharedConfig ;
    //��־
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
    {����û�����Ϊ��,��ô�����ȵ�½}
  if (SharedConfig.strUserName <> '') then
  begin
    strCommand := 'net use %s /user:%s %s';
    if strDir[length(strDir)] = '\' then
      Delete(strDir, length(strDir), 1);

    strCommand := format(strCommand, [strDir, SharedConfig.strUserName, SharedConfig.strPassword]);

    if Assigned(m_logEvent) then
    begin
      strLog := '���ڽ�������,���Ժ�...'  ;
      m_logEvent(strLog,False);
    end;
    winexec(PChar('cmd.exe /C ' + strCommand), SW_HIDE);
  end;

  Result := DirectoryExists(strDir);

  //д��־
  if not Result then
  begin
    strLog := format('����ʧ��:{ IP��ַ:%s}', [SharedConfig.strHost]);
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
    {����û�����Ϊ��,��ô�����ȵ�½}
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

  //д��־
  if not Result then
  begin
    strLog := format('����ʧ��:{ IP��ַ:%s}', [SharedConfig.strHost]);
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
  //ɾ�����繲��
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

  //�ϴ��ļ���ʼ
  strLog := format('�����ϴ��ļ�:{ IP��ַ:%s , �ļ�����:%s }', [SharedConfig.strHost, FileName]);
  if Assigned(m_logEvent) then
    m_logEvent(strLog,False);

  strDir := Format('\\%s\%s', [SharedConfig.strHost,SharedConfig.strDir]);
  strSrcFileName :=  FileName ;

  strDstFileName := Format('%s\%s',[strDir,ExtractFileName(FileName)]) ;
  Result := copyfile(pchar(strSrcFileName),pchar(strDstFileName),false);

  //д��־
  if Result then
  begin
    strLog := format('�ϴ��ļ��ɹ�:{ IP��ַ:%s , �ļ�����:%s }', [SharedConfig.strHost, FileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,False);
  end
  else
  begin
    strLog := format('�ϴ��ļ�ʧ��:{ IP��ַ:%s , �ļ�����:%s }', [SharedConfig.strHost, FileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strLog,True);
  end;
end;

end.
