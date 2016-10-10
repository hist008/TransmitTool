unit uFrmConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzTabs, ExtCtrls, RzPanel, StdCtrls, Mask, RzEdit, ComCtrls,uTFSystem,
  uDBFtpTrans,uFtpConfig,uSharedConfig,uDBSharedTrans,uSystemConfig, Buttons,
  PngSpeedButton;

type
  TFrmConfig = class(TForm)
    PageCtrlMain: TRzPageControl;
    tsConfig: TRzTabSheet;
    tbsFtpTrans: TRzTabSheet;
    TabSheet1: TRzTabSheet;
    GroupBox1: TGroupBox;
    lvShared: TListView;
    GroupBox2: TGroupBox;
    lvFtp: TListView;
    GroupBox3: TGroupBox;
    btnInsert: TPngSpeedButton;
    btnModify: TPngSpeedButton;
    btnDelete: TPngSpeedButton;
    btnRefresh: TPngSpeedButton;
    btnRefreshShared: TPngSpeedButton;
    btnDelShared: TPngSpeedButton;
    btnModifyShared: TPngSpeedButton;
    btnAddShared: TPngSpeedButton;
    btnSetUpOk: TPngSpeedButton;
    btnCancel: TPngSpeedButton;
    GroupBox6: TGroupBox;
    chkSharedTransmit: TCheckBox;
    chkFtpTransmit: TCheckBox;
    GroupBox7: TGroupBox;
    Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    Label6: TLabel;
    edtUploadDir: TEdit;
    edtUploadInterval: TRzNumericEdit;
    edtUploadFilterDate: TRzNumericEdit;
    Label5: TLabel;
    edtLogSaveDate: TRzNumericEdit;
    Label4: TLabel;
    Label9: TLabel;
    chkEnableReboot: TCheckBox;
    dtpRebootDate: TDateTimePicker;
    procedure btnSetUpOkClick(Sender: TObject);
    procedure btnSetUpCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure lvFtpDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddSharedClick(Sender: TObject);
    procedure btnModifySharedClick(Sender: TObject);
    procedure btnRefreshSharedClick(Sender: TObject);
    procedure btnDelSharedClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvSharedDblClick(Sender: TObject);
  private
    //FTPת���������ݿ�
    m_dbFtpTrans : TDBFtpTrans ;
    // ����������ݿ�
    m_dbSharedTrans : TDBSharedTrans ;
  private
    { Private declarations }
    //ˢ���б�
    //��ʼ����һҳ(ϵͳ����)
    procedure InitSysConfig();
    //��ʼ���ڶ�ҹ(FTP����)
    procedure InitFtpTransConfig();
    //��ʼ��������(����Ŀ¼)
    procedure InitSharedTransConfig();
  public
    { Public declarations }
    class procedure Config();
  end;

var
  FrmConfig: TFrmConfig;

implementation

uses
  uGlobalDM,uFrmFtpTrans,uFrmSharedTrans;

{$R *.dfm}

{ TFrmConfig }

procedure TFrmConfig.btnAddSharedClick(Sender: TObject);
var
  SharedConfig : RSharedConfig ;
begin
   if TFrmSharedTrans.GetConfig(SharedConfig,True) then
  begin
    m_dbSharedTrans.Insert(SharedConfig);
  end;
  InitSharedTransConfig ;
end;

procedure TFrmConfig.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel ;
end;

procedure TFrmConfig.btnDeleteClick(Sender: TObject);
var
  FTPConfig : RExFTPConfig ;
begin
  if lvFtp.Selected = nil then
  begin
    BoxErr('û��ѡ��Ҫ���ݣ�');
    exit;
  end;

  if not m_dbFtpTrans.QueryById(StrToInt(lvFtp.Selected.SubItems[lvFtp.Selected.SubItems.Count - 1]),FTPConfig) then
  begin
    BoxErr('û���ҵ�����Ϣ');
    Exit;
  end ;

  if not TBox('ȷ��ɾ����') then
    exit ;

  m_dbFtpTrans.Delete(FTPConfig)  ;
  InitFtpTransConfig;

end;



procedure TFrmConfig.btnDelSharedClick(Sender: TObject);
var
  SharedConfig :  RSharedConfig;
begin
  if lvShared.Selected = nil then
  begin
    BoxErr('û��ѡ��Ҫ���ݣ�');
    exit;
  end;

  if not m_dbSharedTrans.QueryById(StrToInt(lvShared.Selected.SubItems[lvShared.Selected.SubItems.Count - 1]),SharedConfig) then
  begin
    BoxErr('û���ҵ�����Ϣ');
    Exit;
  end ;

  if not TBox('ȷ��ɾ����') then
    exit ;

  m_dbSharedTrans.Delete(SharedConfig)  ;
  InitSharedTransConfig;
end;

procedure TFrmConfig.btnInsertClick(Sender: TObject);
var
  FTPConfig : RExFTPConfig ;
begin
   if TFrmFtpTrans.GetFtpConfig(FTPConfig,True) then
  begin
    m_dbFtpTrans.Insert(FTPConfig);
  end;
  InitFtpTransConfig ;
end;

procedure TFrmConfig.btnModifyClick(Sender: TObject);
var
  FTPConfig : RExFTPConfig ;
begin

  if lvFtp.Selected = nil then
  begin
    BoxErr('û��ѡ��Ҫ���ݣ�');
    exit;
  end;

  if not m_dbFtpTrans.QueryById(StrToInt(lvFtp.Selected.SubItems[lvFtp.Selected.SubItems.Count - 1]),FTPConfig) then
  begin
    BoxErr('û���ҵ�����Ϣ');
    Exit;
  end ;

  if TFrmFtpTrans.GetFtpConfig(FTPConfig,False) then
  begin
    m_dbFtpTrans.Modify(FTPConfig);
  end;
  InitFtpTransConfig ;
end;

procedure TFrmConfig.btnModifySharedClick(Sender: TObject);
var
  SharedConfig :  RSharedConfig;
begin

  if lvShared.Selected= nil then
  begin
    BoxErr('û��ѡ��Ҫ���ݣ�');
    exit;
  end;

  if not m_dbSharedTrans.QueryById(StrToInt(lvShared.Selected.SubItems[lvShared.Selected.SubItems.Count - 1]),SharedConfig) then
  begin
    BoxErr('û���ҵ�����Ϣ');
    Exit;
  end ;

  if TFrmSharedTrans.GetConfig(SharedConfig,False) then
  begin
    m_dbSharedTrans.Modify(SharedConfig);
  end;
  InitSharedTransConfig ;

end;

procedure TFrmConfig.btnRefreshClick(Sender: TObject);
begin
  InitFtpTransConfig;
end;

procedure TFrmConfig.btnRefreshSharedClick(Sender: TObject);
begin
  InitSharedTransConfig ;
end;

procedure TFrmConfig.btnSetUpCancelClick(Sender: TObject);
begin
  ;
end;

procedure TFrmConfig.btnSetUpOkClick(Sender: TObject);
var
  RebootParams:RRebootParams;
begin
  if edtUploadInterval.Text = '' then
  begin
    BoxErr('�ϴ��������Ϊ��');
    Exit;
  end;

  if edtUploadDir.Text = '' then
  begin
    BoxErr('�ϴ�Ŀ¼����Ϊ��');
    Exit;
  end;


  if not DirectoryExists( Trim(edtUploadDir.Text)) then
  begin
    BoxErr('�ϴ�Ŀ¼����������������');
    Exit;
  end;

  try
    with GlobalDM.SystemConfig do
    begin
      EnableFtp := chkFtpTransmit.Checked ;
      EnableShared := chkSharedTransmit.Checked ;
      Interval := StrToInt(edtUploadInterval.Text );
      Folder := Trim( edtUploadDir.Text ) ;
      EnableDelete := False ;//chkDelFile.Checked ;

      UploadFilterDate := StrToInt( edtUploadFilterDate.Text );
      LogSaveDate := StrToInt( edtLogSaveDate.Text );
    end;
    RebootParams.bEnable := chkEnableReboot.Checked ;
    RebootParams.dtCloseDate := dtpRebootDate.DateTime ;
    GlobalDM.SystemConfig.RebootParams := RebootParams ;

    Box('����ɹ�');
  except
    on e:Exception do
    begin
      BoxErr(e.Message);
    end;
  end;
end;

class procedure TFrmConfig.Config;
var
  frm : TFrmConfig ;
begin
  frm := TFrmConfig.Create(nil);
  try
    frm.InitSysConfig;
    frm.InitFtpTransConfig ;
    frm.InitSharedTransConfig;
    frm.ShowModal;
  finally
    frm.Free ;
  end;
end;

procedure TFrmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ;
end;

procedure TFrmConfig.FormCreate(Sender: TObject);
begin
  m_dbFtpTrans := TDBFtpTrans.Create(GlobalDM.ADOConnection);
  m_dbSharedTrans := TDBSharedTrans.Create(GlobalDM.ADOConnection);
end;

procedure TFrmConfig.FormDestroy(Sender: TObject);
begin
  m_dbFtpTrans.Free ;
  m_dbSharedTrans.Free ;
end;

procedure TFrmConfig.InitFtpTransConfig;
var
  i : Integer ;
  ListItem : TListItem ;
begin
  lvFtp.Items.Clear;
  with   GlobalDM do
  begin
    SetLength(SystemConfig.FTPConfigArray,0);
    m_dbFtpTrans.GetList(SystemConfig.FTPConfigArray);
    for I := 0 to Length(SystemConfig.FTPConfigArray) - 1 do
    begin
      ListItem := lvFtp.Items.Add;
      with ListItem do
      begin
        Caption := IntToStr(i+1);
        SubItems.Add(SystemConfig.FTPConfigArray[i].FTPConfig.strHost) ;
        SubItems.Add(SystemConfig.FTPConfigArray[i].FTPConfig.strUserName) ;
        //SubItems.Add(GlobalDM.FTPConfigArray[i].FTPConfig.strPassWord) ;
        SubItems.Add('*******') ;
        SubItems.Add(IntToStr(SystemConfig.FTPConfigArray[i].FTPConfig.nPort)) ;
        SubItems.Add(SystemConfig.FTPConfigArray[i].FTPConfig.strDir) ;
        SubItems.Add(IntToStr(SystemConfig.FTPConfigArray[i].nID));
      end;
    end;
  end;
end;

procedure TFrmConfig.InitSharedTransConfig;
var
  i : Integer ;
  ListItem : TListItem ;
begin
  lvShared.Items.Clear;
  with GlobalDM do
  begin
    SetLength(SystemConfig.SharedConfigArray, 0);
    m_dbSharedTrans.GetList(SystemConfig.SharedConfigArray);
    for I := 0 to Length(SystemConfig.SharedConfigArray) - 1 do
    begin
      ListItem := lvShared.Items.Add;
      with ListItem do
      begin
        Caption := IntToStr(i + 1);
        SubItems.Add(SystemConfig.SharedConfigArray[i].strHost);
        SubItems.Add(SystemConfig.SharedConfigArray[i].strUserName);
      //SubItems.Add(GlobalDM.SharedConfigArray[i].strPassWord) ;
        SubItems.Add('*******');
        SubItems.Add(SystemConfig.SharedConfigArray[i].strDir);
        SubItems.Add(IntToStr(SystemConfig.SharedConfigArray[i].nID));
      end;
    end;
  end;
end;

procedure TFrmConfig.InitSysConfig;
begin
  with GlobalDM do
  begin
    edtUploadInterval.Text := IntToStr(SystemConfig.Interval);
    edtUploadDir.Text := SystemConfig.Folder ;

    chkFtpTransmit.Checked := SystemConfig.EnableFtp;
    chkSharedTransmit.Checked := SystemConfig.EnableShared ;

    edtUploadFilterDate.Text  := IntToStr(SystemConfig.UploadFilterDate);
    edtLogSaveDate.Text :=    IntToStr(SystemConfig.LogSaveDate) ;


    chkEnableReboot.Checked := SystemConfig.RebootParams.bEnable ;
    dtpRebootDate.DateTime := SystemConfig.RebootParams.dtCloseDate
  end;
end;

procedure TFrmConfig.lvFtpDblClick(Sender: TObject);
begin
  btnModify.Click ;
end;

procedure TFrmConfig.lvSharedDblClick(Sender: TObject);
begin
  btnModifyShared.Click ;
end;

end.
