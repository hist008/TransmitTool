unit uTransManager;

interface

uses
  ADODB ,SysUtils,DateUtils;

type
  {��־�ص�����}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object ;
//==============================================================================
// ��������� TTransBaseManager
// ���������    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================
  TTransBaseManager = class
  public
    constructor Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
    destructor Destroy();override;
  public
    //�ϴ����� {�ڶ���������ʾ������ǿ�ƣ�����ǣ��Ͳ�����ļ�����Ч��}
    function UpLoad(FileName:string;IsForce:Boolean=False):Boolean;
  protected
    //�ϴ��ļ� �麯�� ��Ҫ���Ե�����ʵ���ϴ����� 
    function UploadFile(FileName:string):Boolean;virtual;abstract;
    //�Ƿ��ϴ���
    function  IsUploaded(FileName:string):Boolean;virtual;abstract;
    //����ɹ���־
    procedure InsertSuccessDBLog(FileName:string);virtual;abstract;
    //����ʧ����־
    procedure InsertErrorDBLog(FileName:string); virtual;abstract;
  private
    //����ļ��Ƿ���Ч
    function IsValidFile(FileName:string):Boolean;
    //����ļ��Ƿ��ǹ����ļ�
    function IsFileExpired(FileName:string;Day:Integer):Boolean;
  private
    //�ļ��Ĺ�������
    m_nFilterDate : Cardinal ;
    //�Ƿ�ֹͣ
    m_bStopFlag : Boolean ;
    //������־
    m_logUI :TLogEvent ;
  published
    property FilterDate : Cardinal read m_nFilterDate write m_nFilterDate ;
    property UILog:TLogEvent  read m_logUI write m_logUI;
    property Stop : Boolean read m_bStopFlag write m_bStopFlag ;
  end;

implementation

{ TTransBaseManager }

constructor TTransBaseManager.Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
const
  DEFAULT_FILTER_DATE = 30 ;
begin
  m_logUI := LogEvent ;
  m_nFilterDate := DEFAULT_FILTER_DATE ;
  m_bStopFlag := False ;
end;

destructor TTransBaseManager.Destroy;
begin

  inherited;
end;

function TTransBaseManager.IsFileExpired(FileName: string;
  Day: Integer): Boolean;
var
  DateTimeModify: TDateTime;
  nDayInterval:Integer ;
  text:string ;
begin

  if Day = 0 then
  begin
    Result := False ;
    Exit ;
  end;

  if FileName = '' then
    Exception.Create('�ļ���Ϊ��');

  FileAge(FileName, DateTimeModify) ;
  text := FormatDateTime('yyyy-MM-dd hh:mm:ss',DateTimeModify);
  nDayInterval := DaysBetween(Now,DateTimeModify);
  if  nDayInterval >= Day  then
    Result := True
  else
    Result := False ;
end;

function TTransBaseManager.IsValidFile(FileName: string): Boolean;
begin
  //����ļ����޸������Ƿ���ָ��������
  Result :=  not IsFileExpired(FileName,m_nFilterDate);
end;

function TTransBaseManager.UpLoad(FileName: string;IsForce:Boolean): Boolean;
var
  strText : string ;
begin
  Result := False ;
  try
    //����Ƿ��˳�
    if m_bStopFlag then
    begin
      if Assigned(m_logUI) then
      begin
        strText := '��⵽�˳���־';
        m_logUI(strText,False);
      end;
      Exit ;
    end;

    //����Ƿ���ǿ���ϴ�
    if not IsForce then
    begin
      //����ļ��Ƿ����
      if not IsValidFile(FileName) then
      begin
        if Assigned(m_logUI) then
        begin
          strText := Format(' �ļ�[%s] ����', [FileName]);
          m_logUI(strText,False);
        end;
        Exit;
      end;
    end;

    //����ļ��Ƿ��ϴ���
    if IsUploaded(FileName) then
    begin
      if Assigned(m_logUI) then
      begin
        strText := Format(' �ļ�:[%s] ���ϴ�', [FileName]);
        m_logUI(strText, False);
      end;
      Exit;
    end;

    //�ϴ��ļ�
    Result := UploadFile(FileName);
  except
    on e:Exception do
    begin
      ;
    end;
  end;
  
end;

end.
