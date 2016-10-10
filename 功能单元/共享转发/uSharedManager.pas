unit uSharedManager;

interface

uses
  uTransManager,uSharedConfig,uSharedOper,uDBSharedTrans,ADODB,SysUtils,uMd5;

type
//==============================================================================
// ��������� TSharedManager
// ���������    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================
  TSharedManager = class(TTransBaseManager)
  public
    constructor Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
    destructor Destroy();override;
  protected
    //�ϴ��ļ�
    function UploadFile(FileName:string):Boolean;override;
    //�Ƿ��ϴ���
    function  IsUploaded(FileName:string):Boolean;override;
    //����Shared�ɹ���־
    procedure InsertSuccessDBLog(FileName:string);override;
    //����Sharedʧ����־
    procedure InsertErrorDBLog(FileName:string);override;
  private
    //���ݿ������¼
    m_dbSharedLog : TDBSharedLog ;
    //���������
    m_SharedOper : TSharedOper ;
    //��������
    m_SharedConfig : RSharedConfig ;
  public
    property  SharedConfig:RSharedConfig read m_SharedConfig write m_SharedConfig ;
  end;


implementation

{ TSharedManager }


constructor TSharedManager.Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
begin
  m_dbSharedLog := TDBSharedLog.Create(ADOConnection);
  m_SharedOper := TSharedOper.Create;
  m_SharedOper.LogEvent := LogEvent ;
  inherited Create(ADOConnection,LogEvent);
end;

destructor TSharedManager.Destroy;
begin
  m_dbSharedLog.Free ;
  m_SharedOper.Free ;
  inherited;
end;

procedure TSharedManager.InsertErrorDBLog(FileName: string);
var
  strMd5 : string ;
  strIp : string ;
begin
  strMd5 := RivestFile(FileName) ;
  strIp := m_SharedOper.SharedConfig.strHost ;
  m_dbSharedLog.AddFailerLog(strIp, FileName,strMd5,Now);
end;

procedure TSharedManager.InsertSuccessDBLog(FileName: string);
var
  strMd5 : string ;
  strIp : string ;
begin
  strIp := m_SharedOper.SharedConfig.strHost ;
  strMd5 := RivestFile(FileName) ;
  m_dbSharedLog.AddSuccessLog(strIp , FileName,strMd5,Now);
end;

function TSharedManager.IsUploaded(FileName: string): Boolean;
var
  strFileMd5 : string ;
  strIp : string ;
begin
  strFileMd5 := RivestFile(FileName)  ;
  if strFileMd5 = '' then
  begin
    raise Exception.Create('�ļ���MD5Ϊ��,����!');
    exit ;
  end;
  strIp := m_SharedConfig.strHost ;
  Result := m_dbSharedLog.IsExist(strIP,strFileMd5) ;
end;

function TSharedManager.UploadFile(FileName: string): Boolean;
begin
  Result := False ;
  m_SharedOper.SharedConfig := m_SharedConfig ;
  //����
  if not m_SharedOper.IsConnect() then
  begin
    if not m_SharedOper.Connect() then
    begin
      //�������ʧ����������ݿ���־
      //InsertErrorDBLog(FileName);
      Exit;
    end;
  end;

  //�ϴ��ļ�����¼���
  if m_SharedOper.UploadFile( FileName ) then
    InsertSuccessDBLog(FileName)
  else
    InsertErrorDBLog(FileName);
end;

end.
