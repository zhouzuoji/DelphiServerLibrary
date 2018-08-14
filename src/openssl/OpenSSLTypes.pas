unit OpenSSLTypes;

interface

const
  SSL_ERROR_NONE = 0;  {$EXTERNALSYM SSL_ERROR_NONE}
  SSL_ERROR_SSL = 1;   {$EXTERNALSYM SSL_ERROR_SSL}
  SSL_ERROR_WANT_READ = 2; {$EXTERNALSYM SSL_ERROR_WANT_READ}
  SSL_ERROR_WANT_WRITE = 3; {$EXTERNALSYM SSL_ERROR_WANT_WRITE}
  SSL_ERROR_WANT_X509_LOOKUP = 4; {$EXTERNALSYM SSL_ERROR_WANT_X509_LOOKUP}
  SSL_ERROR_SYSCALL = 5;  {$EXTERNALSYM SSL_ERROR_SYSCALL}        // look at error stack/return value/errno
  SSL_ERROR_ZERO_RETURN = 6;  {$EXTERNALSYM SSL_ERROR_ZERO_RETURN}
  SSL_ERROR_WANT_CONNECT = 7;  {$EXTERNALSYM SSL_ERROR_WANT_CONNECT}
  SSL_ERROR_WANT_ACCEPT = 8; {$EXTERNALSYM SSL_ERROR_WANT_ACCEPT}

  NID_secp256k1 = 714; {$EXTERNALSYM NID_secp256k1}

  X509_FILETYPE_PEM = 1; {$EXTERNALSYM X509_FILETYPE_PEM}
  X509_FILETYPE_ASN1 = 2;  {$EXTERNALSYM X509_FILETYPE_ASN1}
  X509_FILETYPE_DEFAULT = 3; {$EXTERNALSYM X509_FILETYPE_DEFAULT}

  SSL_FILETYPE_PEM = X509_FILETYPE_PEM; {$EXTERNALSYM SSL_FILETYPE_PEM}
  SSL_FILETYPE_ASN1 = X509_FILETYPE_ASN1; {$EXTERNALSYM SSL_FILETYPE_ASN1}

  BIO_FLAGS_READ = $01;  {$EXTERNALSYM BIO_FLAGS_READ}
  BIO_FLAGS_WRITE = $02;  {$EXTERNALSYM BIO_FLAGS_WRITE}
  BIO_FLAGS_IO_SPECIAL = $04; {$EXTERNALSYM BIO_FLAGS_IO_SPECIAL}
  BIO_FLAGS_RWS = BIO_FLAGS_READ or BIO_FLAGS_WRITE or BIO_FLAGS_IO_SPECIAL; {$EXTERNALSYM BIO_FLAGS_RWS}
  BIO_FLAGS_SHOULD_RETRY = $08; {$EXTERNALSYM BIO_FLAGS_SHOULD_RETRY}

type
  TBN_CTX = record

  end;
  PBN_CTX = ^TBN_CTX;

  TBigNum = record

  end;
  PBigNum = ^TBigNum;

  TOpenSSL_BIO = record

  end;

  TECGroup = record

  end;
  PECGroup = ^TECGroup;

  TECPoint = record

  end;
  PECPoint = ^TECPoint;

  TECKey = record

  end;
  PECKey = ^TECKey;

  TECPointConversionForm = (
    pcfCompressed = 2,
    pcfUnCompressed = 4,
    pcfHybrid = 6);

  POpenSSL_BIO = ^TOpenSSL_BIO;

  TOpenSSL_bio_info_cb = procedure(bio: POpenSSL_BIO; p1: Int32; p2: PAnsiChar; p3: Int32; p4, p5: LongInt); cdecl;
  TBIOReadWriteFunc = function(bio: POpenSSL_BIO; buf: PAnsiChar; bufSize: Int32): Int32; cdecl;

  TOpenSSL_bio_method_st = packed record
    _type: Int32;
    name: PAnsiChar;
    bwrite: TBIOReadWriteFunc;
    bread: TBIOReadWriteFunc;
    bputs: function(bio: POpenSSL_BIO; buf: PAnsiChar): Int32; cdecl;
    bgets:  function(bio: POpenSSL_BIO; buf: PAnsiChar; bufLen: Int32): Int32; cdecl;
    ctrl: function(bio: POpenSSL_BIO; cmd: Int32; num: LongInt; ptr: Pointer): LongInt; cdecl;
    create: function(bio: POpenSSL_BIO): Int32; cdecl;
    destroy: function(bio: POpenSSL_BIO): Int32; cdecl;
    callback_ctrl: function(bio: POpenSSL_BIO; p1: Int32; p2: TOpenSSL_bio_info_cb): LongInt; cdecl;
  end;
  POpenSSL_bio_method_st = ^TOpenSSL_bio_method_st;
  TOpenSSL_BIO_METHOD = TOpenSSL_bio_method_st;
  POpenSSL_BIO_METHOD = POpenSSL_bio_method_st;

  TOpenSSL_SSL_CTX = record

  end;
  POpenSSL_SSL_CTX = ^TOpenSSL_SSL_CTX;

  TOpenSSL_SSL = record

  end;
  POpenSSL_SSL = ^TOpenSSL_SSL;

  TOpenSSL_SSL_METHOD = record

  end;
  POpenSSL_SSL_METHOD = ^TOpenSSL_SSL_METHOD;

  TOpenSSL_X509 = record

  end;
  POpenSSL_X509 = ^TOpenSSL_X509;

  TOpenSSL_X509_NAME = record

  end;
  POpenSSL_X509_NAME = ^TOpenSSL_X509_NAME;

  TSSLMethodProvider = function: POpenSSL_SSL_METHOD; cdecl;
implementation

end.
