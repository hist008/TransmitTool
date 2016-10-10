unit uFtpOper;

interface
uses
  Windows,SysUtils,uTFSystem,uFtpConfig,uFTPTransportControl,StrUtils;

type
  {日志回调函数}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object;
  TDBLogEvent = procedure (LogText:string) of object;
//==============================================================================
// FTP操作类    author lyq
// 修改时间      date : 2015-11-12
//==============================================================================
  TFtpOper = class
  public
    constructor Create();
    destructor Destroy();override;
  public
      //上传
    function  UploadFile(FileName:string):Boolean;
  private
    //公司组件的回调函数
    procedure FTPTransportControlBeginTransportItem(nValue: Integer);
    procedure FTPTransportControlEndTransportItem(nValue: Integer);
    procedure FTPTransportControlTransportFailureNodify(ItemIndex: Integer;
      strErrorMessage: string; var ctType: TTransportFailureConfirmType);
  private
    //传输任务
    m_TransportFile: TTransportFile;
    //采用公司的组件
    FTPTransportControl : TFTPTransportControl ;
    //配置
    m_FTPConfig : RExFTPConfig;
    //重试次数
    m_nRetryCount : Integer ;
    //日志
    m_logEvent : TLogEvent ;
    //写数据成功日志
    m_logDBSuccessEvent : TDBLogEvent ;
    //写数据错误日志
    m_logDBErrorEvent : TDBLogEvent ;
  published
    property FTPConfig:RExFTPConfig read m_FTPConfig write m_FTPConfig ;
    property RetryCount : Integer read m_nRetryCount write m_nRetryCount ;
    property LogEvent : TLogEvent  read m_logEvent write m_logEvent ;
    property DBSuccessLogEvent : TDBLogEvent  read m_logDBSuccessEvent write m_logDBSuccessEvent ;
    property DBErrorLogEvent : TDBLogEvent  read m_logDBErrorEvent write m_logDBErrorEvent;
  end;

implementation

{ TFtpOper }

constructor TFtpOper.Create;
begin
  m_TransportFile := TTransportFile.Create ;
  FTPTransportControl := TFTPTransportControl.Create(nil);
  FTPTransportControl.OnTransportFailureNodify := FTPTransportControlTransportFailureNodify ;
  FTPTransportControl.OnBeginTransportItem := FTPTransportControlBeginTransportItem ;
  FTPTransportControl.OnEndTransportItem := FTPTransportControlEndTransportItem ;
end;

destructor TFtpOper.Destroy;
begin
  m_TransportFile.Free ;
  FTPTransportControl.Free ;
  inherited;
end;

procedure TFtpOper.FTPTransportControlBeginTransportItem(nValue: Integer);
var
  strText : string ;
begin
  m_nRetryCount := 0 ;
  strText := format('正在上传文件:{ FTP地址:%s , 文件名字:%s }',[
      FTPTransportControl.FTPConfig.strHost,
      FTPTransportControl.TransportFileList.Items[nValue].FileName]);
  if Assigned(m_logEvent) then
    m_logEvent(strText,False) ;
end;

procedure TFtpOper.FTPTransportControlEndTransportItem(nValue: Integer);
var
  strText : string ;
  strHost : string ;
  strFileName : string ;
begin
  strHost := FTPTransportControl.FTPConfig.strHost ;
  strFileName :=  FTPTransportControl.TransportFileList.Items[nValue].FileName ;
  if FTPTransportControl.TransportFileList.Items[nValue].TransportState = tsTransportSuccess then
  begin
    strText := format('上传文件成功:{ FTP地址:%s , 文件名字:%s }',[strHost,strFileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strText,False) ;
    //写数据库日志
    if Assigned(DBSuccessLogEvent) then
      DBSuccessLogEvent(strFileName) ;
  end
  else if FTPTransportControl.TransportFileList.Items[nValue].TransportState = tsTransportFailure then
  begin
    strText := format('上传文件失败:{ FTP地址:%s , 文件名字:%s ',[strHost,strFileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strText,True) ;
    //写数据库日志
    if Assigned(m_logDBErrorEvent) then
      m_logDBErrorEvent(strFileName) ;
  end;
end;

procedure TFtpOper.FTPTransportControlTransportFailureNodify(ItemIndex: Integer;
  strErrorMessage: string; var ctType: TTransportFailureConfirmType);
var
  strText : string ;
begin
  inc(m_nRetryCount)  ;
  if m_nRetryCount < 1 then
    ctType := ctRetry
  else
    ctType := ctSkip ;
  strText := Format('上传发生错误:{ FTP地址:%s , 文件名字:%s , 重试次数%d }',[
    FTPTransportControl.FTPConfig.strHost,
    strErrorMessage,m_nRetryCount]) ;
  strText := ReplaceStr(strText,#13#10,'');
  if Assigned(m_logEvent) then
    m_logEvent(strText,True);
end;

function TFtpOper.UploadFile(FileName: string): Boolean;
var
  strFullName: string;
  strFileName: string;
begin
  strFullName := FileName;
  strFileName := ExtractFileName(strFullName);
  with m_TransportFile do
  begin
    {文件名称}
    FileName := strFullName;
    {目标文件名称}
    DestFileName := strFileName;
    {服务器目录}
    FTPPath := '';
    {本地路径}
    LocalPath := '';
  end;

  FTPTransportControl.FTPConfig := FTPConfig.FTPConfig ;
  result := FTPTransportControl.Upload(strFullName, strFileName, '') ;
end;

end.
