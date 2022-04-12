object SimpleBrowserFrame: TSimpleBrowserFrame
  Left = 0
  Top = 0
  Width = 791
  Height = 666
  TabOrder = 0
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 41
    Width = 791
    Height = 301
    Align = alClient
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 791
    Height = 41
    Align = alTop
    TabOrder = 1
    DesignSize = (
      791
      41)
    object edtURL: TLabeledEdit
      Left = 41
      Top = 8
      Width = 610
      Height = 27
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 35
      EditLabel.Height = 19
      EditLabel.Caption = 'URL:'
      LabelPosition = lpLeft
      TabOrder = 0
    end
    object Button1: TButton
      Left = 657
      Top = 1
      Width = 36
      Height = 39
      Align = alRight
      Caption = 'GO'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 693
      Top = 1
      Width = 36
      Height = 39
      Align = alRight
      Caption = 'Exec'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button2: TButton
      Left = 729
      Top = 1
      Width = 61
      Height = 39
      Align = alRight
      Caption = 'DevTool'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object txtConsole: TMemo
    Left = 0
    Top = 342
    Width = 791
    Height = 162
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object txtScript: TMemo
    Left = 0
    Top = 504
    Width = 791
    Height = 162
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Chromium1: TChromium
    OnAddressChange = Chromium1AddressChange
    OnConsoleMessage = Chromium1ConsoleMessage
    Left = 384
    Top = 320
  end
end
