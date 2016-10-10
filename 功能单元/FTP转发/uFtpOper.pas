unit uFtpOper;

interface
uses
  Windows,SysUtils,uTFSystem,uFtpConfig,uFTPTransportControl,StrUtils;

type
  {��־�ص�����}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object;
  TDBLogEvent = procedure (LogText:string) of object;
//==============================================================================
// FTP������    author lyq
// �޸�ʱ��      date : 2015-11-12
//==============================================================================
  TFtpOper = class
  public
    constructor Create();
    destructor Destroy();override;
  public
      //�ϴ�
    function  UploadFile(FileName:string):Boolean;
  private
    //��˾����Ļص�����
    procedure FTPTransportControlBeginTransportItem(nValue: Integer);
    procedure FTPTransportControlEndTransportItem(nValue: Integer);
    procedure FTPTransportControlTransportFailureNodify(ItemIndex: Integer;
      strErrorMessage: string; var ctType: TTransportFailureConfirmType);
  private
    //��������
    m_TransportFile: TTransportFile;
    //���ù�˾�����
    FTPTransportControl : TFTPTransportControl ;
    //����
    m_FTPConfig : RExFTPConfig;
    //���Դ���
    m_nRetryCount : Integer ;
    //��־
    m_logEvent : TLogEvent ;
    //д���ݳɹ���־
    m_logDBSuccessEvent : TDBLogEvent ;
    //д���ݴ�����־
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
  strText := format('�����ϴ��ļ�:{ FTP��ַ:%s , �ļ�����:%s }',[
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
    strText := format('�ϴ��ļ��ɹ�:{ FTP��ַ:%s , �ļ�����:%s }',[strHost,strFileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strText,False) ;
    //д���ݿ���־
    if Assigned(DBSuccessLogEvent) then
      DBSuccessLogEvent(strFileName) ;
  end
  else if FTPTransportControl.TransportFileList.Items[nValue].TransportState = tsTransportFailure then
  begin
    strText := format('�ϴ��ļ�ʧ��:{ FTP��ַ:%s , �ļ�����:%s ',[strHost,strFileName]);
    if Assigned(m_logEvent) then
      m_logEvent(strText,True) ;
    //д���ݿ���־
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
  strText := Format('�ϴ���������:{ FTP��ַ:%s , �ļ�����:%s , ���Դ���%d }',[
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
    {�ļ�����}
    FileName := strFullName;
    {Ŀ���ļ�����}
    DestFileName := strFileName;
    {������Ŀ¼}
    FTPPath := '';
    {����·��}
    LocalPath := '';
  end;

  FTPTransportControl.FTPConfig := FTPConfig.FTPConfig ;
  result := FTPTransportControl.Upload(strFullName, strFileName, '') ;
end;

end.
