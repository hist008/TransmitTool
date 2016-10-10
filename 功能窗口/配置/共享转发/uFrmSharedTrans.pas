unit uFrmSharedTrans;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,uSharedConfig,uTFSystem,uSharedOper;

type
  TFrmSharedTrans = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    edtHost: TEdit;
    edtUserName: TEdit;
    edtPassword: TEdit;
    edtPath: TEdit;
    btnTestConnection: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
  private
    //FTP配置
    m_SharedConfig : RSharedConfig ;
  private
      { Private declarations }
    //初始化
    procedure InitData(SharedConfig : RSharedConfig;IsInsert:Boolean);
    //检查输入是否合法
    function CheckInput():Boolean;
  public
    { Public declarations }
        { Public declarations }
    class function GetConfig(var SharedConfig : RSharedConfig;IsInsert:Boolean=True):Boolean;
  end;

var
  FrmSharedTrans: TFrmSharedTrans;

implementation



{$R *.dfm}

procedure TFrmSharedTrans.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel    ;
end;

procedure TFrmSharedTrans.btnOKClick(Sender: TObject);
begin
  if not CheckInput then
    exit ;
  if not TBox('确认保存吗') then
    exit ;
  ModalResult := mrOk ;
end;

procedure TFrmSharedTrans.btnTestConnectionClick(Sender: TObject);
var
  SharedOper : TSharedOper ;
  SharedConfig :   RSharedConfig ;
  strText : string ;
begin
  SharedOper := TSharedOper.Create;
  try
    btnTestConnection.Enabled := False ;

    SharedConfig.strHost := Trim(edtHost.Text);
    SharedConfig.strUserName := Trim(edtUserName.Text);
    SharedConfig.strPassWord := Trim(edtPassword.Text);
    SharedConfig.strDir := Trim(edtPath.Text);
    SharedOper.SharedConfig := SharedConfig ;
    if not SharedOper.Connect() then
    begin
      strText := format('连接失败: IP地址:%s ', [SharedConfig.strHost]);
      uTFSystem.BoxErr(strText);
    end
    else
      uTFSystem.Box('连接成功');
  finally
    SharedOper.free ;
    btnTestConnection.Enabled := True ;
  end;
end;

function TFrmSharedTrans.CheckInput: Boolean;
begin
  Result := False ;
  if Trim( edtHost.Text ) = '' then
  begin
    BoxErr('IP地址不能为空');
    Exit;
  end;


  m_SharedConfig.strHost  := Trim( edtHost.Text );
  m_SharedConfig.strUserName := Trim( edtUserName.Text  ) ;
  m_SharedConfig.strPassWord  := Trim( edtPassword.Text );
  m_SharedConfig.strDir := Trim( edtPath.Text ) ;
  Result := True ;
end;

class function TFrmSharedTrans.GetConfig(var SharedConfig: RSharedConfig;
  IsInsert: Boolean): Boolean;
var
  frm : TFrmSharedTrans;
begin
  Result := False ;
  frm := TFrmSharedTrans.Create(nil);
  try
    frm.InitData(SharedConfig,IsInsert);
    if frm.ShowModal = mrOk then
    begin
      SharedConfig.strHost := frm.m_SharedConfig.strHost ;
      SharedConfig.strUserName := frm.m_SharedConfig.strUserName ;
      SharedConfig.strPassWord := frm.m_SharedConfig.strPassWord ;
      SharedConfig.strDir := frm.m_SharedConfig.strDir ;
      Result := True ;
    end;
  finally
    frm.Free ;
  end;

end;

procedure TFrmSharedTrans.InitData(SharedConfig: RSharedConfig; IsInsert: Boolean);
begin
  if not IsInsert then
  begin
    edtHost.Text := SharedConfig.strHost  ;
    edtUserName.Text :=  SharedConfig.strUserName  ;
    edtPassword.Text :=  SharedConfig.strPassWord  ;
    edtPath.Text :=  SharedConfig.strDir  ;
  end ;
end;

end.
