object FrmPDDLogin: TFrmPDDLogin
  Left = 0
  Top = 0
  Caption = 'FrmPDDLogin'
  ClientHeight = 1071
  ClientWidth = 1138
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 144
  TextHeight = 19
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 1138
    Height = 1071
    Align = alClient
    TabOrder = 0
  end
  object Chromium1: TChromium
    OnLoadEnd = Chromium1LoadEnd
    OnConsoleMessage = Chromium1ConsoleMessage
    OnBeforeBrowse = Chromium1BeforeBrowse
    Left = 624
    Top = 152
  end
end
