object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 346
  ClientWidth = 548
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    548
    346)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 532
    Height = 330
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      DesignSize = (
        524
        302)
      object Memo1: TMemo
        Left = 3
        Top = 3
        Width = 518
        Height = 118
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'Memo1&amp;&nbsp24t2w&quot;&nbsp;a&#29699;')
        TabOrder = 0
      end
      object Button1: TButton
        Left = 0
        Top = 274
        Width = 75
        Height = 25
        Caption = 'HtmlDecodeA'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Memo2: TMemo
        Left = 3
        Top = 127
        Width = 518
        Height = 118
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'Memo1')
        TabOrder = 2
      end
      object Button2: TButton
        Left = 88
        Top = 274
        Width = 75
        Height = 25
        Caption = 'HtmlDecodeW'
        TabOrder = 3
        OnClick = Button2Click
      end
    end
  end
end
