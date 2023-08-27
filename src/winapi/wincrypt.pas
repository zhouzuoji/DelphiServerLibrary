unit wincrypt;

interface

uses
  Windows;

{ Crypto functions needed }
type
  HCRYPTPROV = ULONG_PTR;
  {$EXTERNALSYM HCRYPTPROV}

  _CRYPTOAPI_BLOB = record
    cbData: DWORD;
    pbData: LPBYTE;
  end;
  {$EXTERNALSYM _CRYPTOAPI_BLOB}
  CRYPT_INTEGER_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CRYPT_INTEGER_BLOB}
  PCRYPT_INTEGER_BLOB = ^_CRYPTOAPI_BLOB;
  {$EXTERNALSYM PCRYPT_INTEGER_BLOB}
  CRYPT_OBJID_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CRYPT_OBJID_BLOB}
  CERT_NAME_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CERT_NAME_BLOB}
  PCERT_NAME_BLOB = ^CERT_NAME_BLOB;
  {$EXTERNALSYM PCERT_NAME_BLOB}

  PCRYPT_BIT_BLOB = ^CRYPT_BIT_BLOB;
  {$EXTERNALSYM PCRYPT_BIT_BLOB}
  _CRYPT_BIT_BLOB = record
    cbData: DWORD;
    pbData: LPBYTE;
    cUnusedBits: DWORD;
  end;
  {$EXTERNALSYM _CRYPT_BIT_BLOB}
  CRYPT_BIT_BLOB = _CRYPT_BIT_BLOB;
  {$EXTERNALSYM CRYPT_BIT_BLOB}

  PCRYPT_ALGORITHM_IDENTIFIER = ^CRYPT_ALGORITHM_IDENTIFIER;
  {$EXTERNALSYM PCRYPT_ALGORITHM_IDENTIFIER}
  _CRYPT_ALGORITHM_IDENTIFIER = record
    pszObjId: LPSTR;
    Parameters: CRYPT_OBJID_BLOB;
  end;
  {$EXTERNALSYM _CRYPT_ALGORITHM_IDENTIFIER}
  CRYPT_ALGORITHM_IDENTIFIER = _CRYPT_ALGORITHM_IDENTIFIER;
  {$EXTERNALSYM CRYPT_ALGORITHM_IDENTIFIER}

  PCERT_PUBLIC_KEY_INFO = ^CERT_PUBLIC_KEY_INFO;
  {$EXTERNALSYM PCERT_PUBLIC_KEY_INFO}
  _CERT_PUBLIC_KEY_INFO = record
    Algorithm: CRYPT_ALGORITHM_IDENTIFIER;
    PublicKey: CRYPT_BIT_BLOB;
  end;
  {$EXTERNALSYM _CERT_PUBLIC_KEY_INFO}
  CERT_PUBLIC_KEY_INFO = _CERT_PUBLIC_KEY_INFO;
  {$EXTERNALSYM CERT_PUBLIC_KEY_INFO}

  PCERT_EXTENSION = ^CERT_EXTENSION;
  {$EXTERNALSYM PCERT_EXTENSION}
  _CERT_EXTENSION = record
    pszObjId: LPSTR;
    fCritical: BOOL;
    Value: CRYPT_OBJID_BLOB;
  end;
  {$EXTERNALSYM _CERT_EXTENSION}
  CERT_EXTENSION = _CERT_EXTENSION;
  {$EXTERNALSYM CERT_EXTENSION}


  PCERT_INFO = ^CERT_INFO;
  {$EXTERNALSYM PCERT_INFO}
  _CERT_INFO = record
    dwVersion: DWORD;
    SerialNumber: CRYPT_INTEGER_BLOB;
    SignatureAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    Issuer: CERT_NAME_BLOB;
    NotBefore: FILETIME;
    NotAfter: FILETIME;
    Subject: CERT_NAME_BLOB;
    SubjectPublicKeyInfo: CERT_PUBLIC_KEY_INFO;
    IssuerUniqueId: CRYPT_BIT_BLOB;
    SubjectUniqueId: CRYPT_BIT_BLOB;
    cExtension: DWORD;
    rgExtension: PCERT_EXTENSION;
  end;
  {$EXTERNALSYM _CERT_INFO}
  CERT_INFO = _CERT_INFO;
  {$EXTERNALSYM CERT_INFO}


  HCERTSTORE = Pointer;
  {$EXTERNALSYM HCERTSTORE}
  PCERT_CONTEXT = ^CERT_CONTEXT;

  {$EXTERNALSYM PCERT_CONTEXT}
  _CERT_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: LPBYTE;
    cbCertEncoded: DWORD;
    pCertInfo: PCERT_INFO;
    hCertStore: HCERTSTORE;
  end;
  {$EXTERNALSYM _CERT_CONTEXT}
  CERT_CONTEXT = _CERT_CONTEXT;
  {$EXTERNALSYM CERT_CONTEXT}
  PCCERT_CONTEXT = PCERT_CONTEXT;
  {$EXTERNALSYM PCCERT_CONTEXT}

  PPCERT_CONTEXT = ^PCERT_CONTEXT;

const
  Crypt32 = 'Crypt32.dll';

  CERT_CHAIN_FIND_BY_ISSUER_COMPARE_KEY_FLAG         = $0001;
  CERT_CHAIN_FIND_BY_ISSUER_COMPLEX_CHAIN_FLAG       = $0002;
  CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_URL_FLAG      = $0004;
  CERT_CHAIN_FIND_BY_ISSUER_LOCAL_MACHINE_FLAG       = $0008;
  CERT_CHAIN_FIND_BY_ISSUER_NO_KEY_FLAG              = $4000;
  CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_FLAG          = $8000;

  CERT_CHAIN_FIND_BY_ISSUER              = 1;

//+-------------------------------------------------------------------------
//  Certificate versions
//--------------------------------------------------------------------------

  CERT_V1 = 0;
  {$EXTERNALSYM CERT_V1}
  CERT_V2 = 1;
  {$EXTERNALSYM CERT_V2}
  CERT_V3 = 2;
  {$EXTERNALSYM CERT_V3}

//+-------------------------------------------------------------------------
//  Certificate Information Flags
//--------------------------------------------------------------------------

  CERT_INFO_VERSION_FLAG                 = 1;
  {$EXTERNALSYM CERT_INFO_VERSION_FLAG}
  CERT_INFO_SERIAL_NUMBER_FLAG           = 2;
  {$EXTERNALSYM CERT_INFO_SERIAL_NUMBER_FLAG}
  CERT_INFO_SIGNATURE_ALGORITHM_FLAG     = 3;
  {$EXTERNALSYM CERT_INFO_SIGNATURE_ALGORITHM_FLAG}
  CERT_INFO_ISSUER_FLAG                  = 4;
  {$EXTERNALSYM CERT_INFO_ISSUER_FLAG}
  CERT_INFO_NOT_BEFORE_FLAG              = 5;
  {$EXTERNALSYM CERT_INFO_NOT_BEFORE_FLAG}
  CERT_INFO_NOT_AFTER_FLAG               = 6;
  {$EXTERNALSYM CERT_INFO_NOT_AFTER_FLAG}
  CERT_INFO_SUBJECT_FLAG                 = 7;
  {$EXTERNALSYM CERT_INFO_SUBJECT_FLAG}
  CERT_INFO_SUBJECT_PUBLIC_KEY_INFO_FLAG = 8;
  {$EXTERNALSYM CERT_INFO_SUBJECT_PUBLIC_KEY_INFO_FLAG}
  CERT_INFO_ISSUER_UNIQUE_ID_FLAG        = 9;
  {$EXTERNALSYM CERT_INFO_ISSUER_UNIQUE_ID_FLAG}
  CERT_INFO_SUBJECT_UNIQUE_ID_FLAG       = 10;
  {$EXTERNALSYM CERT_INFO_SUBJECT_UNIQUE_ID_FLAG}
  CERT_INFO_EXTENSION_FLAG               = 11;

//+-------------------------------------------------------------------------
// Certificate comparison functions
//--------------------------------------------------------------------------

  {$EXTERNALSYM CERT_INFO_EXTENSION_FLAG}
  CERT_COMPARE_MASK           = $FFFF;
  {$EXTERNALSYM CERT_COMPARE_MASK}
  CERT_COMPARE_SHIFT          = 16;
  {$EXTERNALSYM CERT_COMPARE_SHIFT}
  CERT_COMPARE_ANY            = 0;
  {$EXTERNALSYM CERT_COMPARE_ANY}
  CERT_COMPARE_SHA1_HASH      = 1;
  {$EXTERNALSYM CERT_COMPARE_SHA1_HASH}
  CERT_COMPARE_NAME           = 2;
  {$EXTERNALSYM CERT_COMPARE_NAME}
  CERT_COMPARE_ATTR           = 3;
  {$EXTERNALSYM CERT_COMPARE_ATTR}
  CERT_COMPARE_MD5_HASH       = 4;
  {$EXTERNALSYM CERT_COMPARE_MD5_HASH}
  CERT_COMPARE_PROPERTY       = 5;
  {$EXTERNALSYM CERT_COMPARE_PROPERTY}
  CERT_COMPARE_PUBLIC_KEY     = 6;
  {$EXTERNALSYM CERT_COMPARE_PUBLIC_KEY}
  CERT_COMPARE_HASH           = CERT_COMPARE_SHA1_HASH;
  {$EXTERNALSYM CERT_COMPARE_HASH}
  CERT_COMPARE_NAME_STR_A     = 7;
  {$EXTERNALSYM CERT_COMPARE_NAME_STR_A}
  CERT_COMPARE_NAME_STR_W     = 8;
  {$EXTERNALSYM CERT_COMPARE_NAME_STR_W}
  CERT_COMPARE_KEY_SPEC       = 9;
  {$EXTERNALSYM CERT_COMPARE_KEY_SPEC}
  CERT_COMPARE_ENHKEY_USAGE   = 10;
  {$EXTERNALSYM CERT_COMPARE_ENHKEY_USAGE}
  CERT_COMPARE_CTL_USAGE      = CERT_COMPARE_ENHKEY_USAGE;
  {$EXTERNALSYM CERT_COMPARE_CTL_USAGE}
  CERT_COMPARE_SUBJECT_CERT   = 11;
  {$EXTERNALSYM CERT_COMPARE_SUBJECT_CERT}
  CERT_COMPARE_ISSUER_OF      = 12;
  {$EXTERNALSYM CERT_COMPARE_ISSUER_OF}
  CERT_COMPARE_EXISTING       = 13;
  {$EXTERNALSYM CERT_COMPARE_EXISTING}
  CERT_COMPARE_SIGNATURE_HASH = 14;
  {$EXTERNALSYM CERT_COMPARE_SIGNATURE_HASH}
  CERT_COMPARE_KEY_IDENTIFIER = 15;
  {$EXTERNALSYM CERT_COMPARE_KEY_IDENTIFIER}
  CERT_COMPARE_CERT_ID        = 16;
  {$EXTERNALSYM CERT_COMPARE_CERT_ID}

//+-------------------------------------------------------------------------
//  dwFindType
//
//  The dwFindType definition consists of two components:
//   - comparison function
//   - certificate information flag
//--------------------------------------------------------------------------

  CERT_FIND_ANY            = CERT_COMPARE_ANY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ANY}
  CERT_FIND_SHA1_HASH      = CERT_COMPARE_SHA1_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SHA1_HASH}
  CERT_FIND_MD5_HASH       = CERT_COMPARE_MD5_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_MD5_HASH}
  CERT_FIND_SIGNATURE_HASH = CERT_COMPARE_SIGNATURE_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SIGNATURE_HASH}
  CERT_FIND_KEY_IDENTIFIER = CERT_COMPARE_KEY_IDENTIFIER shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_KEY_IDENTIFIER}
  CERT_FIND_HASH           = CERT_FIND_SHA1_HASH;
  {$EXTERNALSYM CERT_FIND_HASH}
  CERT_FIND_PROPERTY       = CERT_COMPARE_PROPERTY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_PROPERTY}
  CERT_FIND_PUBLIC_KEY     = CERT_COMPARE_PUBLIC_KEY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_PUBLIC_KEY}
  CERT_FIND_SUBJECT_NAME   = CERT_COMPARE_NAME shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_NAME}
  CERT_FIND_SUBJECT_ATTR   = CERT_COMPARE_ATTR shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_ATTR}
  CERT_FIND_ISSUER_NAME    = CERT_COMPARE_NAME shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_NAME}
  CERT_FIND_ISSUER_ATTR    = CERT_COMPARE_ATTR shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_ATTR}
  CERT_FIND_SUBJECT_STR_A  = CERT_COMPARE_NAME_STR_A shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR_A}
  CERT_FIND_SUBJECT_STR_W  = CERT_COMPARE_NAME_STR_W shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR_W}
  CERT_FIND_SUBJECT_STR    = CERT_FIND_SUBJECT_STR_W;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR}
  CERT_FIND_ISSUER_STR_A   = CERT_COMPARE_NAME_STR_A shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR_A}
  CERT_FIND_ISSUER_STR_W   = CERT_COMPARE_NAME_STR_W shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR_W}
  CERT_FIND_ISSUER_STR     = CERT_FIND_ISSUER_STR_W;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR}
  CERT_FIND_KEY_SPEC       = CERT_COMPARE_KEY_SPEC shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_KEY_SPEC}
  CERT_FIND_ENHKEY_USAGE   = CERT_COMPARE_ENHKEY_USAGE shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ENHKEY_USAGE}
  CERT_FIND_CTL_USAGE      = CERT_FIND_ENHKEY_USAGE;
  {$EXTERNALSYM CERT_FIND_CTL_USAGE}

  CERT_FIND_SUBJECT_CERT = CERT_COMPARE_SUBJECT_CERT shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SUBJECT_CERT}
  CERT_FIND_ISSUER_OF    = CERT_COMPARE_ISSUER_OF shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ISSUER_OF}
  CERT_FIND_EXISTING     = CERT_COMPARE_EXISTING shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_EXISTING}
  CERT_FIND_CERT_ID      = CERT_COMPARE_CERT_ID shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_CERT_ID}

  CRYPT_ASN_ENCODING  = $00000001;
  {$EXTERNALSYM CRYPT_ASN_ENCODING}
  CRYPT_NDR_ENCODING  = $00000002;
  {$EXTERNALSYM CRYPT_NDR_ENCODING}
  X509_ASN_ENCODING   = $00000001;
  {$EXTERNALSYM X509_ASN_ENCODING}
  X509_NDR_ENCODING   = $00000002;
  {$EXTERNALSYM X509_NDR_ENCODING}
  PKCS_7_ASN_ENCODING = $00010000;
  {$EXTERNALSYM PKCS_7_ASN_ENCODING}
  PKCS_7_NDR_ENCODING = $00020000;
  {$EXTERNALSYM PKCS_7_NDR_ENCODING}

//+-------------------------------------------------------------------------
//  Certificate name string types
//--------------------------------------------------------------------------
  CERT_SIMPLE_NAME_STR = 1;
  {$EXTERNALSYM CERT_SIMPLE_NAME_STR}
  CERT_OID_NAME_STR    = 2;
  {$EXTERNALSYM CERT_OID_NAME_STR}
  CERT_X500_NAME_STR   = 3;
  {$EXTERNALSYM CERT_X500_NAME_STR}

  CERT_NAME_STR_CRLF_FLAG = $08000000;
  {$EXTERNALSYM CERT_NAME_STR_CRLF_FLAG}

//+-------------------------------------------------------------------------
//  Certificate name types
//--------------------------------------------------------------------------

const
  CERT_NAME_EMAIL_TYPE            = 1;
  {$EXTERNALSYM CERT_NAME_EMAIL_TYPE}
  CERT_NAME_RDN_TYPE              = 2;
  {$EXTERNALSYM CERT_NAME_RDN_TYPE}
  CERT_NAME_ATTR_TYPE             = 3;
  {$EXTERNALSYM CERT_NAME_ATTR_TYPE}
  CERT_NAME_SIMPLE_DISPLAY_TYPE   = 4;
  {$EXTERNALSYM CERT_NAME_SIMPLE_DISPLAY_TYPE}
  CERT_NAME_FRIENDLY_DISPLAY_TYPE = 5;
  {$EXTERNALSYM CERT_NAME_FRIENDLY_DISPLAY_TYPE}

//+-------------------------------------------------------------------------
//  Certificate name flags
//--------------------------------------------------------------------------

  CERT_NAME_ISSUER_FLAG           = $1;
  {$EXTERNALSYM CERT_NAME_ISSUER_FLAG}
  CERT_NAME_DISABLE_IE4_UTF8_FLAG = $00010000;
  {$EXTERNALSYM CERT_NAME_DISABLE_IE4_UTF8_FLAG}

type
  CRYPTOAPI_BLOB = record
    cbData: DWORD;
    pbData: Pointer;
  end;
  _SecPkgContext_IssuerListInfoEx = record
    aIssuers: PCERT_NAME_BLOB;
    cIssuers: DWORD;
  end;
  {$EXTERNALSYM _SecPkgContext_IssuerListInfoEx}
  SecPkgContext_IssuerListInfoEx = _SecPkgContext_IssuerListInfoEx;
  {$EXTERNALSYM SecPkgContext_IssuerListInfoEx}
  PSecPkgContext_IssuerListInfoEx = ^SecPkgContext_IssuerListInfoEx;
  {$EXTERNALSYM PSecPkgContext_IssuerListInfoEx}

  _CERT_TRUST_STATUS = record
    dwErrorStatus: DWORD;
    dwInfoStatus: DWORD;
  end;
  {$EXTERNALSYM _CERT_TRUST_STATUS}
  CERT_TRUST_STATUS = _CERT_TRUST_STATUS;
  {$EXTERNALSYM CERT_TRUST_STATUS}
  PCERT_TRUST_STATUS = ^_CERT_TRUST_STATUS;
  {$EXTERNALSYM PCERT_TRUST_STATUS}


  _CERT_CHAIN_ELEMENT = record
    cbSize: DWORD;
    pCertContext: PCCERT_CONTEXT;
    TrustStatus: CERT_TRUST_STATUS;
    pRevocationInfo: Pointer;//    pRevocationInfo: PCERT_REVOCATION_INFO;
    pIssuanceUsage: Pointer;//    pIssuanceUsage: PCERT_ENHKEY_USAGE;
    pApplicationUsage: Pointer;//    pApplicationUsage: PCERT_ENHKEY_USAGE;
    pwszExtendedErrorInfo: LPCWSTR;
  end;
  {$EXTERNALSYM _CERT_CHAIN_ELEMENT}
  CERT_CHAIN_ELEMENT = _CERT_CHAIN_ELEMENT;
  {$EXTERNALSYM CERT_CHAIN_ELEMENT}
  PCERT_CHAIN_ELEMENT = ^_CERT_CHAIN_ELEMENT;
  {$EXTERNALSYM PCERT_CHAIN_ELEMENT}
  PPCERT_CHAIN_ELEMENT = ^PCERT_CHAIN_ELEMENT;

  _CERT_SIMPLE_CHAIN = record
    cbSize: DWORD;
    TrustStatus: CERT_TRUST_STATUS;
    cElement: DWORD;
    rgpElement: PPCERT_CHAIN_ELEMENT;
    pTrustListInfo: Pointer;//pTrustListInfo: PCERT_TRUST_LIST_INFO;
    fHasRevocationFreshnessTime: BOOL;
    dwRevocationFreshnessTime: DWORD;
  end;
  {$EXTERNALSYM _CERT_SIMPLE_CHAIN}
  CERT_SIMPLE_CHAIN = _CERT_SIMPLE_CHAIN;
  {$EXTERNALSYM CERT_SIMPLE_CHAIN}
  PCERT_SIMPLE_CHAIN = ^_CERT_SIMPLE_CHAIN;
  {$EXTERNALSYM PCERT_SIMPLE_CHAIN}
  PPCERT_SIMPLE_CHAIN = ^PCERT_SIMPLE_CHAIN;


  PCCERT_CHAIN_CONTEXT = ^_CERT_CHAIN_CONTEXT;
  {$EXTERNALSYM PCCERT_CHAIN_CONTEXT}
  PPCCERT_CHAIN_CONTEXT = ^PCCERT_CHAIN_CONTEXT;
  _CERT_CHAIN_CONTEXT = record
    cbSize: DWORD;
    TrustStatus: CERT_TRUST_STATUS;
    cChain: DWORD;
    rgpChain: PPCERT_SIMPLE_CHAIN;
    cLowerQualityChainContext: DWORD;
    rgpLowerQualityChainContext: PPCCERT_CHAIN_CONTEXT;
    fHasRevocationFreshnessTime: BOOL;
    dwRevocationFreshnessTime: DWORD;
  end;
  {$EXTERNALSYM _CERT_CHAIN_CONTEXT}
  CERT_CHAIN_CONTEXT = _CERT_CHAIN_CONTEXT;
  {$EXTERNALSYM CERT_CHAIN_CONTEXT}

  PFN_CERT_CHAIN_FIND_BY_ISSUER_CALLBACK = procedure;

  _CERT_CHAIN_FIND_BY_ISSUER_PARA = record
    cbSize: DWORD;
    pszUsageIdentifier: LPCSTR;
    dwKeySpec: DWORD;
    dwAcquirePrivateKeyFlags: DWORD;
    cIssuer: DWORD;
    rgIssuer: PCERT_NAME_BLOB;
    pfnFindCallback: PFN_CERT_CHAIN_FIND_BY_ISSUER_CALLBACK;
    pvFindArg: Pointer;
    pdwIssuerChainIndex: PDWORD;
    pdwIssuerElementIndex: PDWORD;
  end;
  {$EXTERNALSYM _CERT_CHAIN_FIND_BY_ISSUER_PARA}
  CERT_CHAIN_FIND_BY_ISSUER_PARA = _CERT_CHAIN_FIND_BY_ISSUER_PARA;
  {$EXTERNALSYM CERT_CHAIN_FIND_BY_ISSUER_PARA}
  PCERT_CHAIN_FIND_BY_ISSUER_PARA = ^CERT_CHAIN_FIND_BY_ISSUER_PARA;
  {$EXTERNALSYM PCERT_CHAIN_FIND_BY_ISSUER_PARA}

const
  CERT_CLOSE_STORE_FORCE_FLAG = $00000001;
  {$EXTERNALSYM CERT_CLOSE_STORE_FORCE_FLAG}
  CERT_CLOSE_STORE_CHECK_FLAG = $00000002;
  {$EXTERNALSYM CERT_CLOSE_STORE_CHECK_FLAG}

const
  CERT_FIND_OPTIONAL_ENHKEY_USAGE_FLAG  = $1;
  {$EXTERNALSYM CERT_FIND_OPTIONAL_ENHKEY_USAGE_FLAG}
  CERT_FIND_EXT_ONLY_ENHKEY_USAGE_FLAG  = $2;
  {$EXTERNALSYM CERT_FIND_EXT_ONLY_ENHKEY_USAGE_FLAG}
  CERT_FIND_PROP_ONLY_ENHKEY_USAGE_FLAG = $4;
  {$EXTERNALSYM CERT_FIND_PROP_ONLY_ENHKEY_USAGE_FLAG}
  CERT_FIND_NO_ENHKEY_USAGE_FLAG        = $8;
  {$EXTERNALSYM CERT_FIND_NO_ENHKEY_USAGE_FLAG}
  CERT_FIND_OR_ENHKEY_USAGE_FLAG        = $10;
  {$EXTERNALSYM CERT_FIND_OR_ENHKEY_USAGE_FLAG}
  CERT_FIND_VALID_ENHKEY_USAGE_FLAG     = $20;
  {$EXTERNALSYM CERT_FIND_VALID_ENHKEY_USAGE_FLAG}

  CERT_FIND_OPTIONAL_CTL_USAGE_FLAG = CERT_FIND_OPTIONAL_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_OPTIONAL_CTL_USAGE_FLAG}

  CERT_FIND_EXT_ONLY_CTL_USAGE_FLAG = CERT_FIND_EXT_ONLY_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_EXT_ONLY_CTL_USAGE_FLAG}

  CERT_FIND_PROP_ONLY_CTL_USAGE_FLAG = CERT_FIND_PROP_ONLY_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_PROP_ONLY_CTL_USAGE_FLAG}

  CERT_FIND_NO_CTL_USAGE_FLAG    = CERT_FIND_NO_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_NO_CTL_USAGE_FLAG}
  CERT_FIND_OR_CTL_USAGE_FLAG    = CERT_FIND_OR_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_OR_CTL_USAGE_FLAG}
  CERT_FIND_VALID_CTL_USAGE_FLAG = CERT_FIND_VALID_ENHKEY_USAGE_FLAG;
  {$EXTERNALSYM CERT_FIND_VALID_CTL_USAGE_FLAG}

const
  // Crypt UI API DLL
  CryptUI = 'cryptui.dll';

  // flags for dwDontUseColumn
  CRYPTUI_SELECT_ISSUEDTO_COLUMN       = $000000001;
  CRYPTUI_SELECT_ISSUEDBY_COLUMN       = $000000002;
  CRYPTUI_SELECT_INTENDEDUSE_COLUMN    = $000000004;
  CRYPTUI_SELECT_FRIENDLYNAME_COLUMN   = $000000008;
  CRYPTUI_SELECT_LOCATION_COLUMN       = $000000010;
  CRYPTUI_SELECT_EXPIRATION_COLUMN     = $000000020;

// -----------------------------------------------------------------------------
// CryptUIDlgSelectCertificateFromStore
// http://msdn.microsoft.com/en-us/library/aa380288(VS.85).aspx
//
// The CryptUIDlgSelectCertificateFromStore function displays a dialog box
// that allows the selection of a certificate from a specified store
// -----------------------------------------------------------------------------
type
  CryptUIDlgSelectCertificateFromStoreProc =
                                  function (hCertStore: HCERTSTORE;
                                            hwnd: HWND;
                                            pwszTitle: LPCWSTR;
                                            pwszDisplayString: LPCWSTR;
                                            dwDontUseColumn: DWORD;
                                            dwFlags: DWORD;
                                            pvReserved: Pointer): PCCERT_CONTEXT; stdcall;
var
  pCryptUIDlgSelectCertificateFromStore: CryptUIDlgSelectCertificateFromStoreProc;

{$WARN SYMBOL_PLATFORM OFF}

const
  CERT_STORE_ADD_NEW                                  = 1;
  CERT_STORE_ADD_USE_EXISTING                         = 2;
  CERT_STORE_ADD_REPLACE_EXISTING                     = 3;
  CERT_STORE_ADD_ALWAYS                               = 4;
  CERT_STORE_ADD_REPLACE_EXISTING_INHERIT_PROPERTIES  = 5;
  CERT_STORE_ADD_NEWER                                = 6;
  CERT_STORE_ADD_NEWER_INHERIT_PROPERTIES             = 7;

function CertAddEncodedCertificateToStore(hCertStore: HCERTSTORE; dwCertEncodingType: DWORD;
  pbCertEncoded: Pointer; cbCertEncoded, dwAddDisposition: DWORD;
  ppCertContext: PPCERT_CONTEXT): BOOL; stdcall; external Crypt32 name 'CertAddEncodedCertificateToStore' delayed;
{$EXTERNALSYM CertAddEncodedCertificateToStore}

function CertAddCertificateContextToStore(hCertStore: HCERTSTORE; pCertContext: PCCERT_CONTEXT;
  dwAddDisposition: DWORD; ppStoreContext: PPCERT_CONTEXT): BOOL; stdcall; external Crypt32 name 'CertAddCertificateContextToStore' delayed;
{$EXTERNALSYM CertAddCertificateContextToStore}

function CertCreateCertificateContext(dwCertEncodingType: DWORD; pbCertEncoded: Pointer;
  cbCertEncoded: DWORD): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertCreateCertificateContext' delayed;
{$EXTERNALSYM CertCreateCertificateContext}

function CertEnumCertificatesInStore(hCertStore: HCERTSTORE;
  pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertEnumCertificatesInStore' delayed;
{$EXTERNALSYM CertEnumCertificatesInStore}

function CertFindCertificateInStore(hCertStore: HCERTSTORE;
  dwCertEncodingType, dwFindFlags, dwFindType: DWORD; pvFindPara: Pointer;
  pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertFindCertificateInStore' delayed;
{$EXTERNALSYM CertFindCertificateInStore}

function CertFindChainInStore(hCertStore: HCERTSTORE;
  dwCertEncodingType, dwFindFlags, dwFindType: DWORD; pvFindPara: Pointer;
  pPrevChainContext: PCCERT_CHAIN_CONTEXT): PCCERT_CHAIN_CONTEXT; stdcall; external Crypt32 name 'CertFindChainInStore' delayed;
{$EXTERNALSYM CertFindChainInStore}

function CertOpenStore(lpszStoreProvider: LPCSTR; dwEncodingType: DWORD;
  hCryptProv: HCRYPTPROV; dwFlags: DWORD; pvPara: Pointer): HCERTSTORE; stdcall; external Crypt32 name 'CertOpenStoreW' delayed;
{$EXTERNALSYM CertOpenStore}

function CertOpenSystemStore(hProv: HCRYPTPROV; szSubsystemProtocol: LPCTSTR): HCERTSTORE; stdcall; external Crypt32 name 'CertOpenSystemStoreW' delayed;
{$EXTERNALSYM CertOpenSystemStore}

function CertCloseStore(hCertStore: HCERTSTORE; dwFlags: DWORD): BOOL; stdcall; external Crypt32 name 'CertCloseStore' delayed;
{$EXTERNALSYM CertCloseStore}

procedure CertFreeCertificateChain(pChainContext: PCCERT_CHAIN_CONTEXT); stdcall; external Crypt32 name 'CertFreeCertificateChain' delayed;
{$EXTERNALSYM CertFreeCertificateChain}

function CertDuplicateCertificateContext(pCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertDuplicateCertificateContext' delayed;
{$EXTERNALSYM CertDuplicateCertificateContext}

function CertFreeCertificateContext(pCertContext: PCCERT_CONTEXT): BOOL; stdcall; external Crypt32 name 'CertFreeCertificateContext' delayed;
{$EXTERNALSYM CertFreeCertificateContext}

function CertNameToStr(dwCertEncodingType: DWORD; pName: PCERT_NAME_BLOB; dwStrType: DWORD; psz: LPTSTR;
  csz: DWORD): DWORD; stdcall; external Crypt32 name 'CertNameToStrW' delayed;
{$EXTERNALSYM CertNameToStr}

function CertGetNameString(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD;
  pvTypePara: Pointer; pszNameString: LPTSTR; cchNameString: DWORD): DWORD; stdcall; external Crypt32 name 'CertGetNameStringW' delayed;
{$EXTERNALSYM CertGetNameString}

function GetCertSerialNumber(Source: PCRYPT_INTEGER_BLOB): String; forward;
{$NODEFINE GetCertSerialNumber}

function FindCertWithSerialNumber(AStore: HCERTSTORE;
                                  ASerialNumber: string): PCERT_CONTEXT; forward;
{$NODEFINE FindCertWithSerialNumber}

function GetCertInfo(Context: PCERT_CONTEXT;
                     InfoFlag: Integer = 0;
                     InfoType: Integer = CERT_NAME_SIMPLE_DISPLAY_TYPE): string; forward;
{$NODEFINE GetCertInfo}

function BlobToStr(AEncoding: DWORD; Blob: PCERT_NAME_BLOB): PWideChar; forward;
{$NODEFINE GetCertInfo}

function ImportCert(_CertData: Pointer; _CertDataLen: Integer): Boolean;

implementation

uses
  SysUtils,
  Classes;

{ Crypt API helper functions }

function GetCertSerialNumber(Source: PCRYPT_INTEGER_BLOB): String;
{$IFDEF NEXTGEN}
var
  LBytes, LText: TBytes;
{$ENDIF}
begin
{$IFDEF NEXTGEN}
  LBytes := BytesOf(Source.pbData, Source.cbData);
  SetLength(LText, Length(LBytes) * 2);
  BinToHex(LBytes, 0, LText, 0, Length(LBytes));
  Result := TEncoding.ANSI.GetString(LText);
{$ELSE}
  SetLength(Result, Source.cbData * 2);
  BinToHex(Source.pbData, PChar(Result), Source.cbData);
{$ENDIF}
end;

function FindCertWithSerialNumber(AStore: HCERTSTORE;
                                  ASerialNumber: string): PCERT_CONTEXT;
var
  PrevContext, CurContext: PCERT_CONTEXT;
  CertInfo: String;
begin
  Result := nil;
  if AStore <> nil then
  begin
    PrevContext := nil;
    CurContext := CertEnumCertificatesInStore(AStore, PrevContext);
    while CurContext <> nil do
    begin
      CertInfo := GetCertSerialNumber(@CurContext^.pCertInfo^.SerialNumber);
      if SameText(CertInfo, ASerialNumber) then
      begin
        Result := CurContext;
        Exit;
      end;
      PrevContext := CurContext;
      CurContext := CertEnumCertificatesInStore(AStore, PrevContext);
    end;
  end;
end;

function GetCertInfo(Context: PCERT_CONTEXT;
                     InfoFlag: Integer = 0;
                     InfoType: Integer = CERT_NAME_SIMPLE_DISPLAY_TYPE): string;
var
  cbSize: DWORD;
begin
  Result := '';
  cbSize := CertGetNameString(Context, InfoType, InfoFlag, nil, nil, 0);
  if cbSize > 0 then
  begin
    SetLength(Result, cbSize-1);
    CertGetNameString(Context, InfoType, InfoFlag,
                      nil, PChar(Result), cbSize);
  end;
end;

function BlobToStr(AEncoding: DWORD; Blob: PCERT_NAME_BLOB): PWideChar;
var
  LSize: DWORD;
  LFormat: DWORD;
begin
  LFormat := CERT_SIMPLE_NAME_STR or CERT_NAME_STR_CRLF_FLAG;
  LSize := CertNameToStr(AEncoding, Blob, LFormat, nil, 0);
  GetMem(Result, LSize * SizeOf(Char));
  CertNameToStr(AEncoding, Blob, LFormat, Result, LSize);
end;

function ImportCert(_CertData: Pointer; _CertDataLen: Integer): Boolean;
var
  hStore: HCERTSTORE;
  LCertData: RawByteString;
  LCtx, LExistingCtx: PCCERT_CONTEXT;
begin
  hStore := CertOpenSystemStore(0, 'ROOT');
  if hStore = nil then
    Exit(False);
  LCtx := nil;
  LExistingCtx := nil;
  try
    LCtx := CertCreateCertificateContext(X509_ASN_ENCODING or PKCS_7_ASN_ENCODING, _CertData, _CertDataLen);
    if LCtx = nil then
      Exit(False);
    LExistingCtx := CertFindCertificateInStore(hStore, X509_ASN_ENCODING or PKCS_7_ASN_ENCODING, 0, CERT_FIND_EXISTING, LCtx, nil);
    if LExistingCtx = nil then
      Result := CertAddCertificateContextToStore(hStore, LCtx, CERT_STORE_ADD_REPLACE_EXISTING, nil)
    else
      Result := True;
  finally
    if LCtx <> nil then CertFreeCertificateContext(LCtx);
    if LExistingCtx <> nil then CertFreeCertificateContext(LExistingCtx);
    CertCloseStore(hStore, CERT_CLOSE_STORE_CHECK_FLAG);
  end;
end;

end.
