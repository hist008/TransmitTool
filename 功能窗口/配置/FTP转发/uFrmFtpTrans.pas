unit uFrmFtpTrans;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,idftp,uFTPTransportControl,uTFSystem,uFtpConfig;

type
  TFrmFtpTrans = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    edtHost: TEdit;
    edtPort: TEdit;
    edtUserName: TEdit;
    edtPassword: TEdit;
    edtPath: TEdit;
    btnTestConnection: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    //是否是增加
    m_bIsInsert : Boolean ;
    //FTP配置
    m_FTPConfig : RExFTPConfig ;
  private
    { Private declarations }
    //初始化
    procedure InitData(ExFTPConfig : RExFTPConfig;IsInsert:Boolean);
    //检查输入是否合法
    function CheckInput():Boolean;
  public
    { Public declarations }
    class function GetFtpConfig(var ExFTPConfig : RExFTPConfig;IsInsert:Boolean=True):Boolean;
  end;

var
  FrmFtpTrans: TFrmFtpTrans;

implementation

{$R *.dfm}

procedure TFrmFtpTrans.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel ;
end;

procedure TFrmFtpTrans.btnOKClick(Sender: TObject);
begin
  if not CheckInput then
    exit ;
  if not TBox('确认保存吗') then
    exit ;
  ModalResult := mrOk ;
end;

procedure TFrmFtpTrans.btnTestConnectionClick(Sender: TObject);
var
  Ftp: TIdFTP;
begin
  Ftp := TIdFTP.Create;
  try
    try

      Ftp.Host := Trim(edtHost.Text);
      Ftp.Port := StrToInt(Trim(edtPort.Text));
      Ftp.UserName := Trim(edtUserName.Text);
      Ftp.PassWord := Trim(edtPassword.Text);

      if not Ftp.Connected then
         Ftp.Connect;
      if not Ftp.Connected then
        ShowMessage('连接失败！')
      else
        ShowMessage('连接成功！');
    except
      on E: Exception do
        ShowMessage('连接失败！');
    end;
  finally
    if Ftp.Connected then
      Ftp.Disconnect;
    Ftp.Free;
  end;
end;

function TFrmFtpTrans.CheckInput: Boolean;
begin
  Result := False ;
  if edtHost.Text = '' then
  begin
    BoxErr('FTP地址不能为空');
    Exit;
  end;

  if edtPort.Text = '' then
  begin
    BoxErr('FTP端口号不能为空');
    Exit;
  end;

  m_FTPConfig.FTPConfig.strHost  := edtHost.Text ;
  m_FTPConfig.FTPConfig.strUserName := edtUserName.Text   ;
  m_FTPConfig.FTPConfig.strPassWord  := edtPassword.Text ;
  m_FTPConfig.FTPConfig.strDir :=  edtPath.Text  ;
  m_FTPConfig.FTPConfig.nPort :=  StrToInt(edtPort.Text) ;

  Result := True ;
end;

class function TFrmFtpTrans.GetFtpConfig(var ExFTPConfig: RExFTPConfig;
  IsInsert: Boolean): Boolean;
var
  frm : TFrmFtpTrans;
begin
  Result := False ;
  frm := TFrmFtpTrans.Create(nil);
  try
    frm.InitData(ExFTPConfig,IsInsert);
    if frm.ShowModal = mrOk then
    begin
      ExFTPConfig.FTPConfig.strHost := frm.m_FTPConfig.FTPConfig.strHost ;
      ExFTPConfig.FTPConfig.strUserName := frm.m_FTPConfig.FTPConfig.strUserName ;
      ExFTPConfig.FTPConfig.strPassWord := frm.m_FTPConfig.FTPConfig.strPassWord ;
      ExFTPConfig.FTPConfig.strDir := frm.m_FTPConfig.FTPConfig.strDir ;
      ExFTPConfig.FTPConfig.nPort := frm.m_FTPConfig.FTPConfig.nPort ;
      Result := True ;
    end;
  finally
    frm.Free ;
  end;
end;

procedure TFrmFtpTrans.InitData(ExFTPConfig : RExFTPConfig;IsInsert:Boolean);
begin
  m_bIsInsert := IsInsert ;
  if not IsInsert then
  begin
    edtHost.Text := ExFTPConfig.FTPConfig.strHost  ;
    edtUserName.Text :=  ExFTPConfig.FTPConfig.strUserName  ;
    edtPassword.Text :=  ExFTPConfig.FTPConfig.strPassWord  ;
    edtPath.Text :=  ExFTPConfig.FTPConfig.strDir  ;
    edtPort.Text :=   IntToStr(ExFTPConfig.FTPConfig.nPort)  ;
  end
  else
  begin
    edtPort.Text := IntToStr(21) ;
  end;
  
end;

end.
