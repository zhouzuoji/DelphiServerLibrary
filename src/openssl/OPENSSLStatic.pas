unit OpenSSLStatic;

interface

uses
  Windows, DSLWinsock2, msvcrt, OpenSSLTypes;

procedure SSL_load_error_strings; cdecl; external;
function SSL_library_init: Integer; cdecl; external;
function SSLv2_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv2_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv2_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv3_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv3_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv3_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv23_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv23_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function SSLv23_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_1_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_1_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_1_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_2_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_2_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function TLSv1_2_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLS_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLS_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLS_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_client_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_2_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_2_server_method: POpenSSL_SSL_METHOD; cdecl; external;
function DTLSv1_2_client_method: POpenSSL_SSL_METHOD; cdecl; external;

procedure CRYPTO_free(ptr: Pointer); cdecl; external;
function RIPEMD160(d: Pointer; n: Integer; md: Pointer): Pointer; cdecl; external;
function BN_new: PBigNum; cdecl; external;
procedure BN_free(n: PBigNum); cdecl; external;
function BN_bin2bn(s: Pointer; len: Integer; bn: PBigNum): PBigNum; cdecl; external;
function BN_bn2bin(a: PBigNum; buf: Pointer): Integer; cdecl; external;
function EC_GROUP_new_by_curve_name(nid: Integer): PECGroup; cdecl; external;
function EC_GROUP_get0_generator(group: PECGroup): PECPoint; cdecl; external;
procedure EC_GROUP_free(g: PECGroup); cdecl; external;
procedure EC_GROUP_clear_free(g: PECGroup); cdecl; external;
function EC_POINT_new(group: PECGroup): PECPoint; cdecl; external;
procedure EC_POINT_free(pt: PECPoint); cdecl; external;
function EC_POINT_mul(group: PECGroup; r: PECPoint; n: PBigNum;
  q: PECPoint; m: PBigNum; ctx: PBN_CTX): Integer; cdecl; external;
function EC_POINT_point2hex(group: PECGroup; pt: PECPoint;
  form: TECPointConversionForm; ctx: PBN_CTX): PAnsiChar; cdecl; external;
function EC_KEY_new: PECKey; cdecl; external;
procedure EC_KEY_free(key: PECKey); cdecl; external;
function EC_KEY_new_by_curve_name(nid: Integer): PECKey; cdecl; external;
function EC_KEY_get0_private_key(key: PECKey): PBigNum; cdecl; external;
function EC_KEY_get0_public_key(key: PECKey): PECPoint; cdecl; external;
function EC_KEY_generate_key(key: PECKey): Integer; cdecl; external;
function EC_KEY_check_key(key: PECKey): Integer; cdecl; external;
function SSL_CTX_new(meth: POpenSSL_SSL_METHOD): POpenSSL_SSL_CTX; cdecl; external;
procedure SSL_CTX_free(ctx: POpenSSL_SSL_CTX) cdecl; external;
function SSL_set_fd(s: POpenSSL_SSL; fd: Integer): Integer; cdecl; external;
function SSL_new(ctx: POpenSSL_SSL_CTX): POpenSSL_SSL; cdecl; external;
procedure SSL_free(ssl: POpenSSL_SSL); cdecl; external;
function SSL_connect(ssl: POpenSSL_SSL): Integer; cdecl; external;
function SSL_accept(ssl: POpenSSL_SSL): Integer; cdecl; external;
function SSL_read(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl; external;
function SSL_peek(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl; external;
function SSL_write(ssl: POpenSSL_SSL; buf: Pointer; num: Integer): Integer; cdecl; external;
function SSL_shutdown(s: POpenSSL_SSL): Integer; cdecl; external;
function SSL_get_error(s: POpenSSL_SSL; ret_code: Integer): Integer; cdecl; external;
procedure SSL_set_connect_state(s: POpenSSL_SSL); cdecl; external;
procedure SSL_set_accept_state(s: POpenSSL_SSL); cdecl; external;
function SSL_do_handshake(s: POpenSSL_SSL): Integer; cdecl; external;
function SSL_use_RSAPrivateKey_file(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_use_PrivateKey_file(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_use_certificate_file(s: POpenSSL_SSL; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_CTX_use_RSAPrivateKey_file(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_CTX_use_PrivateKey_file(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_CTX_use_certificate_file(ctx: POpenSSL_SSL_CTX; FileName: PAnsiChar; _type: Integer): Integer; cdecl; external;
function SSL_CTX_check_private_key(ctx: POpenSSL_SSL_CTX): Integer; cdecl; external;
function SSL_check_private_key(s: POpenSSL_SSL): Integer; cdecl; external;
function SSL_get_peer_certificate(s: POpenSSL_SSL): POpenSSL_X509; cdecl; external;
function X509_get_subject_name(a: POpenSSL_X509): POpenSSL_X509_NAME; cdecl; external;
function X509_get_issuer_name(a: POpenSSL_X509): POpenSSL_X509_NAME; cdecl; external;
function X509_NAME_oneline(a: POpenSSL_X509_NAME; buf: PAnsiChar; size: Integer): PAnsiChar; cdecl; external;

implementation

procedure CertCloseStore(); stdcall; external 'Crypt32.dll';
procedure CertDuplicateCertificateContext(); stdcall; external 'Crypt32.dll';
procedure CertEnumCertificatesInStore(); stdcall; external 'Crypt32.dll';
procedure CertFindCertificateInStore(); stdcall; external 'Crypt32.dll';
procedure CertFreeCertificateContext(); stdcall; external 'Crypt32.dll';
procedure CertGetCertificateContextProperty(); stdcall; external 'Crypt32.dll';
procedure CertOpenStore(); stdcall; external 'Crypt32.dll';
procedure CryptAcquireContextA(); stdcall; external 'Advapi32.dll';
procedure CryptCreateHash(); stdcall; external 'Advapi32.dll';
procedure CryptDecrypt(); stdcall; external 'Advapi32.dll';
procedure CryptDestroyHash(); stdcall; external 'Advapi32.dll';
procedure CryptDestroyKey(); stdcall; external 'Advapi32.dll';
procedure CryptEnumProvidersA(); stdcall; external 'Advapi32.dll';
procedure CryptExportKey(); stdcall; external 'Advapi32.dll';
procedure CryptGetProvParam(); stdcall; external 'Advapi32.dll';
procedure CryptGetUserKey(); stdcall; external 'Advapi32.dll';
procedure CryptReleaseContext(); stdcall; external 'Advapi32.dll';
procedure CryptSetHashParam(); stdcall; external 'Advapi32.dll';
procedure CryptSignHashA(); stdcall; external 'Advapi32.dll';


procedure _CONF_add_string(); cdecl; external;
procedure _CONF_free_data(); cdecl; external;
procedure _CONF_get_section(); cdecl; external;
procedure _CONF_get_section_values(); cdecl; external;
procedure _CONF_get_string(); cdecl; external;
procedure _CONF_new_data(); cdecl; external;
procedure _CONF_new_section(); cdecl; external;
procedure _des_crypt(); cdecl; external;
procedure _ossl_096_des_random_seed(); cdecl; external;
procedure _ossl_old_crypt(); cdecl; external;
procedure _ossl_old_des_cbc_cksum(); cdecl; external;
procedure _ossl_old_des_cbc_encrypt(); cdecl; external;
procedure _ossl_old_des_cfb_encrypt(); cdecl; external;
procedure _ossl_old_des_cfb64_encrypt(); cdecl; external;
procedure _ossl_old_des_crypt(); cdecl; external;
procedure _ossl_old_des_decrypt3(); cdecl; external;
procedure _ossl_old_des_ecb_encrypt(); cdecl; external;
procedure _ossl_old_des_ecb3_encrypt(); cdecl; external;
procedure _ossl_old_des_ede3_cbc_encrypt(); cdecl; external;
procedure _ossl_old_des_ede3_cfb64_encrypt(); cdecl; external;
procedure _ossl_old_des_ede3_ofb64_encrypt(); cdecl; external;
procedure _ossl_old_des_enc_read(); cdecl; external;
procedure _ossl_old_des_enc_write(); cdecl; external;
procedure _ossl_old_des_encrypt(); cdecl; external;
procedure _ossl_old_des_encrypt2(); cdecl; external;
procedure _ossl_old_des_encrypt3(); cdecl; external;
procedure _ossl_old_des_fcrypt(); cdecl; external;
procedure _ossl_old_des_is_weak_key(); cdecl; external;
procedure _ossl_old_des_key_sched(); cdecl; external;
procedure _ossl_old_des_ncbc_encrypt(); cdecl; external;
procedure _ossl_old_des_ofb_encrypt(); cdecl; external;
procedure _ossl_old_des_ofb64_encrypt(); cdecl; external;
procedure _ossl_old_des_options(); cdecl; external;
procedure _ossl_old_des_pcbc_encrypt(); cdecl; external;
procedure _ossl_old_des_quad_cksum(); cdecl; external;
procedure _ossl_old_des_random_key(); cdecl; external;
procedure _ossl_old_des_random_seed(); cdecl; external;
procedure _ossl_old_des_read_2passwords(); cdecl; external;
procedure _ossl_old_des_read_password(); cdecl; external;
procedure _ossl_old_des_read_pw(); cdecl; external;
procedure _ossl_old_des_read_pw_string(); cdecl; external;
procedure _ossl_old_des_set_key(); cdecl; external;
procedure _ossl_old_des_set_odd_parity(); cdecl; external;
procedure _ossl_old_des_string_to_2keys(); cdecl; external;
procedure _ossl_old_des_string_to_key(); cdecl; external;
procedure _ossl_old_des_xcbc_encrypt(); cdecl; external;
procedure _shadow_DES_check_key(); cdecl; external;
procedure _shadow_DES_rw_mode(); cdecl; external;
procedure a2d_ASN1_OBJECT(); cdecl; external;
procedure a2i_ASN1_ENUMERATED(); cdecl; external;
procedure a2i_ASN1_INTEGER(); cdecl; external;
procedure a2i_ASN1_STRING(); cdecl; external;
procedure a2i_GENERAL_NAME(); cdecl; external;
procedure a2i_ipadd(); cdecl; external;
procedure a2i_IPADDRESS(); cdecl; external;
procedure a2i_IPADDRESS_NC(); cdecl; external;
procedure ACCESS_DESCRIPTION_free(); cdecl; external;
procedure ACCESS_DESCRIPTION_it(); cdecl; external;
procedure ACCESS_DESCRIPTION_new(); cdecl; external;
procedure AES_bi_ige_encrypt(); cdecl; external;
procedure AES_cbc_encrypt(); cdecl; external;
procedure AES_cfb1_encrypt(); cdecl; external;
procedure AES_cfb128_encrypt(); cdecl; external;
procedure AES_cfb8_encrypt(); cdecl; external;
procedure AES_ctr128_encrypt(); cdecl; external;
procedure AES_decrypt(); cdecl; external;
procedure AES_ecb_encrypt(); cdecl; external;
procedure AES_encrypt(); cdecl; external;
procedure AES_ige_encrypt(); cdecl; external;
procedure AES_ofb128_encrypt(); cdecl; external;
procedure AES_options(); cdecl; external;
procedure AES_set_decrypt_key(); cdecl; external;
procedure AES_set_encrypt_key(); cdecl; external;
procedure AES_unwrap_key(); cdecl; external;
procedure AES_version(); cdecl; external;
procedure AES_wrap_key(); cdecl; external;
procedure app_pkey_methods(); cdecl; external;
procedure asn1_item_combine_free(); cdecl; external;
procedure asn1_add_error(); cdecl; external;
procedure ASN1_add_oid_module(); cdecl; external;
procedure ASN1_ANY_it(); cdecl; external;
procedure ASN1_BIT_STRING_check(); cdecl; external;
procedure ASN1_BIT_STRING_free(); cdecl; external;
procedure ASN1_BIT_STRING_get_bit(); cdecl; external;
procedure ASN1_BIT_STRING_it(); cdecl; external;
procedure ASN1_BIT_STRING_name_print(); cdecl; external;
procedure ASN1_BIT_STRING_new(); cdecl; external;
procedure ASN1_BIT_STRING_num_asc(); cdecl; external;
procedure ASN1_BIT_STRING_set(); cdecl; external;
procedure ASN1_BIT_STRING_set_asc(); cdecl; external;
procedure ASN1_BIT_STRING_set_bit(); cdecl; external;
procedure ASN1_BMPSTRING_free(); cdecl; external;
procedure ASN1_BMPSTRING_it(); cdecl; external;
procedure ASN1_BMPSTRING_new(); cdecl; external;
procedure ASN1_bn_print(); cdecl; external;
procedure ASN1_BOOLEAN_it(); cdecl; external;
procedure ASN1_check_infinite_end(); cdecl; external;
procedure ASN1_const_check_infinite_end(); cdecl; external;
procedure asn1_const_Finish(); cdecl; external;
procedure ASN1_d2i_bio(); cdecl; external;
procedure ASN1_d2i_fp(); cdecl; external;
procedure ASN1_digest(); cdecl; external;
procedure asn1_do_adb(); cdecl; external;
procedure asn1_do_lock(); cdecl; external;
procedure ASN1_dup(); cdecl; external;
procedure asn1_enc_free(); cdecl; external;
procedure asn1_enc_init(); cdecl; external;
procedure asn1_enc_restore(); cdecl; external;
procedure asn1_enc_save(); cdecl; external;
procedure ASN1_ENUMERATED_free(); cdecl; external;
procedure ASN1_ENUMERATED_get(); cdecl; external;
procedure ASN1_ENUMERATED_it(); cdecl; external;
procedure ASN1_ENUMERATED_new(); cdecl; external;
procedure ASN1_ENUMERATED_set(); cdecl; external;
procedure ASN1_ENUMERATED_to_BN(); cdecl; external;
procedure asn1_ex_c2i(); cdecl; external;
procedure asn1_ex_i2c(); cdecl; external;
procedure ASN1_FBOOLEAN_it(); cdecl; external;
procedure asn1_Finish(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_adj(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_check(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_free(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_it(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_new(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_print(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_set(); cdecl; external;
procedure ASN1_GENERALIZEDTIME_set_string(); cdecl; external;
procedure asn1_generalizedtime_to_tm(); cdecl; external;
procedure ASN1_GENERALSTRING_free(); cdecl; external;
procedure ASN1_GENERALSTRING_it(); cdecl; external;
procedure ASN1_GENERALSTRING_new(); cdecl; external;
procedure ASN1_generate_nconf(); cdecl; external;
procedure ASN1_generate_v3(); cdecl; external;
procedure asn1_get_choice_selector(); cdecl; external;
procedure asn1_get_field_ptr(); cdecl; external;
procedure ASN1_get_object(); cdecl; external;
procedure asn1_GetSequence(); cdecl; external;
procedure ASN1_i2d_bio(); cdecl; external;
procedure ASN1_i2d_fp(); cdecl; external;
procedure ASN1_IA5STRING_free(); cdecl; external;
procedure ASN1_IA5STRING_it(); cdecl; external;
procedure ASN1_IA5STRING_new(); cdecl; external;
procedure ASN1_INTEGER_cmp(); cdecl; external;
procedure ASN1_INTEGER_dup(); cdecl; external;
procedure ASN1_INTEGER_free(); cdecl; external;
procedure ASN1_INTEGER_get(); cdecl; external;
procedure ASN1_INTEGER_it(); cdecl; external;
procedure ASN1_INTEGER_new(); cdecl; external;
procedure ASN1_INTEGER_set(); cdecl; external;
procedure ASN1_INTEGER_to_BN(); cdecl; external;
procedure ASN1_item_d2i(); cdecl; external;
procedure ASN1_item_d2i_bio(); cdecl; external;
procedure ASN1_item_d2i_fp(); cdecl; external;
procedure ASN1_item_digest(); cdecl; external;
procedure ASN1_item_dup(); cdecl; external;
procedure ASN1_item_ex_d2i(); cdecl; external;
procedure ASN1_item_ex_free(); cdecl; external;
procedure ASN1_item_ex_i2d(); cdecl; external;
procedure ASN1_item_ex_new(); cdecl; external;
procedure ASN1_item_free(); cdecl; external;
procedure ASN1_item_i2d(); cdecl; external;
procedure ASN1_item_i2d_bio(); cdecl; external;
procedure ASN1_item_i2d_fp(); cdecl; external;
procedure ASN1_item_ndef_i2d(); cdecl; external;
procedure ASN1_item_new(); cdecl; external;
procedure ASN1_item_pack(); cdecl; external;
procedure ASN1_item_print(); cdecl; external;
procedure ASN1_item_sign(); cdecl; external;
procedure ASN1_item_sign_ctx(); cdecl; external;
procedure ASN1_item_unpack(); cdecl; external;
procedure ASN1_item_verify(); cdecl; external;
procedure ASN1_mbstring_copy(); cdecl; external;
procedure ASN1_mbstring_ncopy(); cdecl; external;
procedure ASN1_NULL_free(); cdecl; external;
procedure ASN1_NULL_it(); cdecl; external;
procedure ASN1_NULL_new(); cdecl; external;
procedure ASN1_OBJECT_create(); cdecl; external;
procedure ASN1_OBJECT_free(); cdecl; external;
procedure ASN1_OBJECT_it(); cdecl; external;
procedure ASN1_OBJECT_new(); cdecl; external;
procedure ASN1_object_size(); cdecl; external;
procedure ASN1_OCTET_STRING_cmp(); cdecl; external;
procedure ASN1_OCTET_STRING_dup(); cdecl; external;
procedure ASN1_OCTET_STRING_free(); cdecl; external;
procedure ASN1_OCTET_STRING_it(); cdecl; external;
procedure ASN1_OCTET_STRING_NDEF_it(); cdecl; external;
procedure ASN1_OCTET_STRING_new(); cdecl; external;
procedure ASN1_OCTET_STRING_set(); cdecl; external;
procedure ASN1_pack_string(); cdecl; external;
procedure ASN1_parse(); cdecl; external;
procedure ASN1_parse_dump(); cdecl; external;
procedure ASN1_PCTX_free(); cdecl; external;
procedure ASN1_PCTX_get_cert_flags(); cdecl; external;
procedure ASN1_PCTX_get_flags(); cdecl; external;
procedure ASN1_PCTX_get_nm_flags(); cdecl; external;
procedure ASN1_PCTX_get_oid_flags(); cdecl; external;
procedure ASN1_PCTX_get_str_flags(); cdecl; external;
procedure ASN1_PCTX_new(); cdecl; external;
procedure ASN1_PCTX_set_cert_flags(); cdecl; external;
procedure ASN1_PCTX_set_flags(); cdecl; external;
procedure ASN1_PCTX_set_nm_flags(); cdecl; external;
procedure ASN1_PCTX_set_oid_flags(); cdecl; external;
procedure ASN1_PCTX_set_str_flags(); cdecl; external;
procedure ASN1_primitive_free(); cdecl; external;
procedure ASN1_primitive_new(); cdecl; external;
procedure ASN1_PRINTABLE_free(); cdecl; external;
procedure ASN1_PRINTABLE_it(); cdecl; external;
procedure ASN1_PRINTABLE_new(); cdecl; external;
procedure ASN1_PRINTABLE_type(); cdecl; external;
procedure ASN1_PRINTABLESTRING_free(); cdecl; external;
procedure ASN1_PRINTABLESTRING_it(); cdecl; external;
procedure ASN1_PRINTABLESTRING_new(); cdecl; external;
procedure ASN1_put_eoc(); cdecl; external;
procedure ASN1_put_object(); cdecl; external;
procedure ASN1_seq_pack(); cdecl; external;
procedure ASN1_seq_unpack(); cdecl; external;
procedure ASN1_SEQUENCE_ANY_it(); cdecl; external;
procedure ASN1_SEQUENCE_it(); cdecl; external;
procedure ASN1_SET_ANY_it(); cdecl; external;
procedure asn1_set_choice_selector(); cdecl; external;
procedure ASN1_sign(); cdecl; external;
procedure ASN1_STRING_clear_free(); cdecl; external;
procedure ASN1_STRING_cmp(); cdecl; external;
procedure ASN1_STRING_copy(); cdecl; external;
procedure ASN1_STRING_data(); cdecl; external;
procedure ASN1_STRING_dup(); cdecl; external;
procedure ASN1_STRING_free(); cdecl; external;
procedure ASN1_STRING_get_default_mask(); cdecl; external;
procedure ASN1_STRING_length(); cdecl; external;
procedure ASN1_STRING_length_set(); cdecl; external;
procedure ASN1_STRING_new(); cdecl; external;
procedure ASN1_STRING_print(); cdecl; external;
procedure ASN1_STRING_print_ex(); cdecl; external;
procedure ASN1_STRING_print_ex_fp(); cdecl; external;
procedure ASN1_STRING_set(); cdecl; external;
procedure ASN1_STRING_set_by_NID(); cdecl; external;
procedure ASN1_STRING_set_default_mask(); cdecl; external;
procedure ASN1_STRING_set_default_mask_asc(); cdecl; external;
procedure ASN1_STRING_set0(); cdecl; external;
procedure ASN1_STRING_TABLE_add(); cdecl; external;
procedure ASN1_STRING_TABLE_cleanup(); cdecl; external;
procedure ASN1_STRING_TABLE_get(); cdecl; external;
procedure ASN1_STRING_to_UTF8(); cdecl; external;
procedure ASN1_STRING_type(); cdecl; external;
procedure ASN1_STRING_type_new(); cdecl; external;
procedure ASN1_T61STRING_free(); cdecl; external;
procedure ASN1_T61STRING_it(); cdecl; external;
procedure ASN1_T61STRING_new(); cdecl; external;
procedure ASN1_tag2bit(); cdecl; external;
procedure ASN1_tag2str(); cdecl; external;
procedure ASN1_TBOOLEAN_it(); cdecl; external;
procedure ASN1_template_d2i(); cdecl; external;
procedure ASN1_template_free(); cdecl; external;
procedure ASN1_template_i2d(); cdecl; external;
procedure ASN1_template_new(); cdecl; external;
procedure asn1_template_print_ctx(); cdecl; external;
procedure ASN1_TIME_adj(); cdecl; external;
procedure ASN1_TIME_check(); cdecl; external;
procedure ASN1_TIME_diff(); cdecl; external;
procedure ASN1_TIME_free(); cdecl; external;
procedure ASN1_TIME_it(); cdecl; external;
procedure ASN1_TIME_new(); cdecl; external;
procedure ASN1_TIME_print(); cdecl; external;
procedure ASN1_TIME_set(); cdecl; external;
procedure ASN1_TIME_set_string(); cdecl; external;
procedure ASN1_TIME_to_generalizedtime(); cdecl; external;
procedure ASN1_TYPE_cmp(); cdecl; external;
procedure ASN1_TYPE_free(); cdecl; external;
procedure ASN1_TYPE_get(); cdecl; external;
procedure ASN1_TYPE_get_int_octetstring(); cdecl; external;
procedure ASN1_TYPE_get_octetstring(); cdecl; external;
procedure ASN1_TYPE_new(); cdecl; external;
procedure ASN1_TYPE_set(); cdecl; external;
procedure ASN1_TYPE_set_int_octetstring(); cdecl; external;
procedure ASN1_TYPE_set_octetstring(); cdecl; external;
procedure ASN1_TYPE_set1(); cdecl; external;
procedure ASN1_UNIVERSALSTRING_free(); cdecl; external;
procedure ASN1_UNIVERSALSTRING_it(); cdecl; external;
procedure ASN1_UNIVERSALSTRING_new(); cdecl; external;
procedure ASN1_UNIVERSALSTRING_to_string(); cdecl; external;
procedure ASN1_unpack_string(); cdecl; external;
procedure ASN1_UTCTIME_adj(); cdecl; external;
procedure ASN1_UTCTIME_check(); cdecl; external;
procedure ASN1_UTCTIME_cmp_time_t(); cdecl; external;
procedure ASN1_UTCTIME_free(); cdecl; external;
procedure ASN1_UTCTIME_it(); cdecl; external;
procedure ASN1_UTCTIME_new(); cdecl; external;
procedure ASN1_UTCTIME_print(); cdecl; external;
procedure ASN1_UTCTIME_set(); cdecl; external;
procedure ASN1_UTCTIME_set_string(); cdecl; external;
procedure asn1_utctime_to_tm(); cdecl; external;
procedure ASN1_UTF8STRING_free(); cdecl; external;
procedure ASN1_UTF8STRING_it(); cdecl; external;
procedure ASN1_UTF8STRING_new(); cdecl; external;
procedure ASN1_verify(); cdecl; external;
procedure ASN1_version(); cdecl; external;
procedure ASN1_VISIBLESTRING_free(); cdecl; external;
procedure ASN1_VISIBLESTRING_it(); cdecl; external;
procedure ASN1_VISIBLESTRING_new(); cdecl; external;
procedure AUTHORITY_INFO_ACCESS_free(); cdecl; external;
procedure AUTHORITY_INFO_ACCESS_it(); cdecl; external;
procedure AUTHORITY_INFO_ACCESS_new(); cdecl; external;
procedure AUTHORITY_KEYID_free(); cdecl; external;
procedure AUTHORITY_KEYID_it(); cdecl; external;
procedure AUTHORITY_KEYID_new(); cdecl; external;
procedure b2i_PrivateKey(); cdecl; external;
procedure b2i_PrivateKey_bio(); cdecl; external;
procedure b2i_PublicKey(); cdecl; external;
procedure b2i_PublicKey_bio(); cdecl; external;
procedure b2i_PVK_bio(); cdecl; external;
procedure BASIC_CONSTRAINTS_free(); cdecl; external;
procedure BASIC_CONSTRAINTS_it(); cdecl; external;
procedure BASIC_CONSTRAINTS_new(); cdecl; external;
procedure BF_cbc_encrypt(); cdecl; external;
procedure BF_cfb64_encrypt(); cdecl; external;
procedure BF_decrypt(); cdecl; external;
procedure BF_ecb_encrypt(); cdecl; external;
procedure BF_encrypt(); cdecl; external;
procedure BF_ofb64_encrypt(); cdecl; external;
procedure BF_options(); cdecl; external;
procedure BF_set_key(); cdecl; external;
procedure BF_version(); cdecl; external;
procedure BIGNUM_it(); cdecl; external;
procedure BIO_accept(); cdecl; external;
procedure BIO_asn1_get_prefix(); cdecl; external;
procedure BIO_asn1_get_suffix(); cdecl; external;
procedure BIO_asn1_set_prefix(); cdecl; external;
procedure BIO_asn1_set_suffix(); cdecl; external;
procedure BIO_callback_ctrl(); cdecl; external;
procedure BIO_clear_flags(); cdecl; external;
procedure BIO_CONNECT_free(); cdecl; external;
procedure BIO_CONNECT_new(); cdecl; external;
procedure BIO_copy_next_retry(); cdecl; external;
procedure BIO_ctrl(); cdecl; external;
procedure BIO_ctrl_get_read_request(); cdecl; external;
procedure BIO_ctrl_get_write_guarantee(); cdecl; external;
procedure BIO_ctrl_pending(); cdecl; external;
procedure BIO_ctrl_reset_read_request(); cdecl; external;
procedure BIO_ctrl_wpending(); cdecl; external;
procedure BIO_debug_callback(); cdecl; external;
procedure BIO_dgram_non_fatal_error(); cdecl; external;
procedure BIO_dump(); cdecl; external;
procedure BIO_dump_cb(); cdecl; external;
procedure BIO_dump_fp(); cdecl; external;
procedure BIO_dump_indent(); cdecl; external;
procedure BIO_dump_indent_cb(); cdecl; external;
procedure BIO_dump_indent_fp(); cdecl; external;
procedure BIO_dup_chain(); cdecl; external;
procedure BIO_f_asn1(); cdecl; external;
procedure BIO_f_base64(); cdecl; external;
procedure BIO_f_buffer(); cdecl; external;
procedure BIO_f_cipher(); cdecl; external;
procedure BIO_f_md(); cdecl; external;
procedure BIO_f_nbio_test(); cdecl; external;
procedure BIO_f_null(); cdecl; external;
procedure BIO_f_reliable(); cdecl; external;
procedure BIO_f_ssl(); cdecl; external;
procedure BIO_fd_non_fatal_error(); cdecl; external;
procedure BIO_fd_should_retry(); cdecl; external;
procedure BIO_find_type(); cdecl; external;
procedure BIO_free(); cdecl; external;
procedure BIO_free_all(); cdecl; external;
procedure BIO_get_accept_socket(); cdecl; external;
procedure BIO_get_callback(); cdecl; external;
procedure BIO_get_callback_arg(); cdecl; external;
procedure BIO_get_ex_data(); cdecl; external;
procedure BIO_get_ex_new_index(); cdecl; external;
procedure BIO_get_host_ip(); cdecl; external;
procedure BIO_get_port(); cdecl; external;
procedure BIO_get_retry_BIO(); cdecl; external;
procedure BIO_get_retry_reason(); cdecl; external;
procedure BIO_gethostbyname(); cdecl; external;
procedure BIO_gets(); cdecl; external;
procedure BIO_hex_string(); cdecl; external;
procedure BIO_indent(); cdecl; external;
procedure BIO_int_ctrl(); cdecl; external;
procedure BIO_method_name(); cdecl; external;
procedure BIO_method_type(); cdecl; external;
procedure BIO_new(); cdecl; external;
procedure BIO_new_accept(); cdecl; external;
procedure BIO_new_bio_pair(); cdecl; external;
procedure BIO_new_buffer_ssl_connect(); cdecl; external;
procedure BIO_new_CMS(); cdecl; external;
procedure BIO_new_connect(); cdecl; external;
procedure BIO_new_dgram(); cdecl; external;
procedure BIO_new_fd(); cdecl; external;
procedure BIO_new_file(); cdecl; external;
procedure BIO_new_fp(); cdecl; external;
procedure BIO_new_mem_buf(); cdecl; external;
procedure BIO_new_NDEF(); cdecl; external;
procedure BIO_new_PKCS7(); cdecl; external;
procedure BIO_new_socket(); cdecl; external;
procedure BIO_new_ssl(); cdecl; external;
procedure BIO_new_ssl_connect(); cdecl; external;
procedure BIO_next(); cdecl; external;
procedure BIO_nread(); cdecl; external;
procedure BIO_nread0(); cdecl; external;
procedure BIO_number_read(); cdecl; external;
procedure BIO_number_written(); cdecl; external;
procedure BIO_nwrite(); cdecl; external;
procedure BIO_nwrite0(); cdecl; external;
procedure BIO_pop(); cdecl; external;
procedure BIO_printf(); cdecl; external;
procedure BIO_ptr_ctrl(); cdecl; external;
procedure BIO_push(); cdecl; external;
procedure BIO_puts(); cdecl; external;
procedure BIO_read(); cdecl; external;
procedure BIO_s_accept(); cdecl; external;
procedure BIO_s_bio(); cdecl; external;
procedure BIO_s_connect(); cdecl; external;
procedure BIO_s_datagram(); cdecl; external;
procedure BIO_s_fd(); cdecl; external;
procedure BIO_s_file(); cdecl; external;
procedure BIO_s_mem(); cdecl; external;
procedure BIO_s_null(); cdecl; external;
procedure BIO_s_socket(); cdecl; external;
procedure BIO_set(); cdecl; external;
procedure BIO_set_callback(); cdecl; external;
procedure BIO_set_callback_arg(); cdecl; external;
procedure BIO_set_cipher(); cdecl; external;
procedure BIO_set_ex_data(); cdecl; external;
procedure BIO_set_flags(); cdecl; external;
procedure BIO_set_tcp_ndelay(); cdecl; external;
procedure BIO_snprintf(); cdecl; external;
procedure BIO_sock_cleanup(); cdecl; external;
procedure BIO_sock_error(); cdecl; external;
procedure BIO_sock_init(); cdecl; external;
procedure BIO_sock_non_fatal_error(); cdecl; external;
procedure BIO_sock_should_retry(); cdecl; external;
procedure BIO_socket_ioctl(); cdecl; external;
procedure BIO_socket_nbio(); cdecl; external;
procedure BIO_ssl_copy_session_id(); cdecl; external;
procedure BIO_ssl_shutdown(); cdecl; external;
procedure BIO_test_flags(); cdecl; external;
procedure BIO_vfree(); cdecl; external;
procedure BIO_vprintf(); cdecl; external;
procedure BIO_vsnprintf(); cdecl; external;
procedure BIO_write(); cdecl; external;
procedure BN_add(); cdecl; external;
procedure bn_add_part_words(); cdecl; external;
procedure BN_add_word(); cdecl; external;
procedure bn_add_words(); cdecl; external;
procedure BN_asc2bn(); cdecl; external;
procedure BN_BLINDING_convert(); cdecl; external;
procedure BN_BLINDING_convert_ex(); cdecl; external;
procedure BN_BLINDING_create_param(); cdecl; external;
procedure BN_BLINDING_free(); cdecl; external;
procedure BN_BLINDING_get_flags(); cdecl; external;
procedure BN_BLINDING_get_thread_id(); cdecl; external;
procedure BN_BLINDING_invert(); cdecl; external;
procedure BN_BLINDING_invert_ex(); cdecl; external;
procedure BN_BLINDING_new(); cdecl; external;
procedure BN_BLINDING_set_flags(); cdecl; external;
procedure BN_BLINDING_set_thread_id(); cdecl; external;
procedure BN_BLINDING_thread_id(); cdecl; external;
procedure BN_BLINDING_update(); cdecl; external;
procedure BN_bn2dec(); cdecl; external;
procedure BN_bn2hex(); cdecl; external;
procedure BN_bn2mpi(); cdecl; external;
procedure BN_bntest_rand(); cdecl; external;
procedure BN_clear(); cdecl; external;
procedure BN_clear_bit(); cdecl; external;
procedure BN_clear_free(); cdecl; external;
procedure BN_cmp(); cdecl; external;
procedure bn_cmp_part_words(); cdecl; external;
procedure bn_cmp_words(); cdecl; external;
procedure BN_consttime_swap(); cdecl; external;
procedure BN_copy(); cdecl; external;
procedure BN_CTX_end(); cdecl; external;
procedure BN_CTX_free(); cdecl; external;
procedure BN_CTX_get(); cdecl; external;
procedure BN_CTX_init(); cdecl; external;
procedure BN_CTX_new(); cdecl; external;
procedure BN_CTX_start(); cdecl; external;
procedure BN_dec2bn(); cdecl; external;
procedure BN_div(); cdecl; external;
procedure BN_div_recp(); cdecl; external;
procedure BN_div_word(); cdecl; external;
procedure bn_div_words(); cdecl; external;
procedure BN_dup(); cdecl; external;
procedure bn_dup_expand(); cdecl; external;
procedure BN_exp(); cdecl; external;
procedure bn_expand2(); cdecl; external;
procedure BN_from_montgomery(); cdecl; external;
procedure BN_gcd(); cdecl; external;
procedure BN_GENCB_call(); cdecl; external;
procedure BN_generate_prime(); cdecl; external;
procedure BN_generate_prime_ex(); cdecl; external;
procedure BN_get_params(); cdecl; external;
procedure BN_get_word(); cdecl; external;
procedure BN_get0_nist_prime_192(); cdecl; external;
procedure BN_get0_nist_prime_224(); cdecl; external;
procedure BN_get0_nist_prime_256(); cdecl; external;
procedure BN_get0_nist_prime_384(); cdecl; external;
procedure BN_get0_nist_prime_521(); cdecl; external;
procedure BN_GF2m_add(); cdecl; external;
procedure BN_GF2m_arr2poly(); cdecl; external;
procedure BN_GF2m_mod(); cdecl; external;
procedure BN_GF2m_mod_arr(); cdecl; external;
procedure BN_GF2m_mod_div(); cdecl; external;
procedure BN_GF2m_mod_div_arr(); cdecl; external;
procedure BN_GF2m_mod_exp(); cdecl; external;
procedure BN_GF2m_mod_exp_arr(); cdecl; external;
procedure BN_GF2m_mod_inv(); cdecl; external;
procedure BN_GF2m_mod_inv_arr(); cdecl; external;
procedure BN_GF2m_mod_mul(); cdecl; external;
procedure BN_GF2m_mod_mul_arr(); cdecl; external;
procedure BN_GF2m_mod_solve_quad(); cdecl; external;
procedure BN_GF2m_mod_solve_quad_arr(); cdecl; external;
procedure BN_GF2m_mod_sqr(); cdecl; external;
procedure BN_GF2m_mod_sqr_arr(); cdecl; external;
procedure BN_GF2m_mod_sqrt(); cdecl; external;
procedure BN_GF2m_mod_sqrt_arr(); cdecl; external;
procedure BN_GF2m_poly2arr(); cdecl; external;
procedure BN_hex2bn(); cdecl; external;
procedure BN_init(); cdecl; external;
procedure BN_is_bit_set(); cdecl; external;
procedure BN_is_prime(); cdecl; external;
procedure BN_is_prime_ex(); cdecl; external;
procedure BN_is_prime_fasttest(); cdecl; external;
procedure BN_is_prime_fasttest_ex(); cdecl; external;
procedure BN_kronecker(); cdecl; external;
procedure BN_lshift(); cdecl; external;
procedure BN_lshift1(); cdecl; external;
procedure BN_mask_bits(); cdecl; external;
procedure BN_mod_add(); cdecl; external;
procedure BN_mod_add_quick(); cdecl; external;
procedure BN_mod_exp(); cdecl; external;
procedure BN_mod_exp_mont(); cdecl; external;
procedure BN_mod_exp_mont_consttime(); cdecl; external;
procedure BN_mod_exp_mont_word(); cdecl; external;
procedure BN_mod_exp_recp(); cdecl; external;
procedure BN_mod_exp_simple(); cdecl; external;
procedure BN_mod_exp2_mont(); cdecl; external;
procedure BN_mod_inverse(); cdecl; external;
procedure BN_mod_lshift(); cdecl; external;
procedure BN_mod_lshift_quick(); cdecl; external;
procedure BN_mod_lshift1(); cdecl; external;
procedure BN_mod_lshift1_quick(); cdecl; external;
procedure BN_mod_mul(); cdecl; external;
procedure BN_mod_mul_montgomery(); cdecl; external;
procedure BN_mod_mul_reciprocal(); cdecl; external;
procedure BN_mod_sqr(); cdecl; external;
procedure BN_mod_sqrt(); cdecl; external;
procedure BN_mod_sub(); cdecl; external;
procedure BN_mod_sub_quick(); cdecl; external;
procedure BN_mod_word(); cdecl; external;
procedure BN_MONT_CTX_copy(); cdecl; external;
procedure BN_MONT_CTX_free(); cdecl; external;
procedure BN_MONT_CTX_init(); cdecl; external;
procedure BN_MONT_CTX_new(); cdecl; external;
procedure BN_MONT_CTX_set(); cdecl; external;
procedure BN_MONT_CTX_set_locked(); cdecl; external;
procedure BN_mpi2bn(); cdecl; external;
procedure BN_mul(); cdecl; external;
procedure bn_mul_add_words(); cdecl; external;
procedure bn_mul_comba4(); cdecl; external;
procedure bn_mul_comba8(); cdecl; external;
procedure bn_mul_high(); cdecl; external;
procedure bn_mul_low_normal(); cdecl; external;
procedure bn_mul_low_recursive(); cdecl; external;
procedure bn_mul_normal(); cdecl; external;
procedure bn_mul_part_recursive(); cdecl; external;
procedure bn_mul_recursive(); cdecl; external;
procedure BN_mul_word(); cdecl; external;
procedure bn_mul_words(); cdecl; external;
procedure BN_nist_mod_192(); cdecl; external;
procedure BN_nist_mod_224(); cdecl; external;
procedure BN_nist_mod_256(); cdecl; external;
procedure BN_nist_mod_384(); cdecl; external;
procedure BN_nist_mod_521(); cdecl; external;
procedure BN_nnmod(); cdecl; external;
procedure BN_num_bits(); cdecl; external;
procedure BN_num_bits_word(); cdecl; external;
procedure BN_options(); cdecl; external;
procedure BN_print(); cdecl; external;
procedure BN_print_fp(); cdecl; external;
procedure BN_pseudo_rand(); cdecl; external;
procedure BN_pseudo_rand_range(); cdecl; external;
procedure BN_rand(); cdecl; external;
procedure BN_rand_range(); cdecl; external;
procedure BN_reciprocal(); cdecl; external;
procedure BN_RECP_CTX_free(); cdecl; external;
procedure BN_RECP_CTX_init(); cdecl; external;
procedure BN_RECP_CTX_new(); cdecl; external;
procedure BN_RECP_CTX_set(); cdecl; external;
procedure BN_rshift(); cdecl; external;
procedure BN_rshift1(); cdecl; external;
procedure BN_set_bit(); cdecl; external;
procedure BN_set_negative(); cdecl; external;
procedure BN_set_params(); cdecl; external;
procedure BN_set_word(); cdecl; external;
procedure BN_sqr(); cdecl; external;
procedure bn_sqr_comba4(); cdecl; external;
procedure bn_sqr_comba8(); cdecl; external;
procedure bn_sqr_normal(); cdecl; external;
procedure bn_sqr_recursive(); cdecl; external;
procedure bn_sqr_words(); cdecl; external;
procedure BN_sub(); cdecl; external;
procedure bn_sub_part_words(); cdecl; external;
procedure BN_sub_word(); cdecl; external;
procedure bn_sub_words(); cdecl; external;
procedure BN_swap(); cdecl; external;
procedure BN_to_ASN1_ENUMERATED(); cdecl; external;
procedure BN_to_ASN1_INTEGER(); cdecl; external;
procedure BN_uadd(); cdecl; external;
procedure BN_ucmp(); cdecl; external;
procedure BN_usub(); cdecl; external;
procedure BN_value_one(); cdecl; external;
procedure BN_version(); cdecl; external;
procedure BN_X931_derive_prime_ex(); cdecl; external;
procedure BN_X931_generate_prime_ex(); cdecl; external;
procedure BN_X931_generate_Xpq(); cdecl; external;
procedure BUF_MEM_free(); cdecl; external;
procedure BUF_MEM_grow(); cdecl; external;
procedure BUF_MEM_grow_clean(); cdecl; external;
procedure BUF_MEM_new(); cdecl; external;
procedure BUF_memdup(); cdecl; external;
procedure BUF_reverse(); cdecl; external;
procedure BUF_strdup(); cdecl; external;
procedure BUF_strlcat(); cdecl; external;
procedure BUF_strlcpy(); cdecl; external;
procedure BUF_strndup(); cdecl; external;
procedure BUF_strnlen(); cdecl; external;
procedure c2i_ASN1_BIT_STRING(); cdecl; external;
procedure c2i_ASN1_INTEGER(); cdecl; external;
procedure c2i_ASN1_OBJECT(); cdecl; external;
procedure Camellia_cbc_encrypt(); cdecl; external;
procedure Camellia_cfb1_encrypt(); cdecl; external;
procedure Camellia_cfb128_encrypt(); cdecl; external;
procedure Camellia_cfb8_encrypt(); cdecl; external;
procedure Camellia_ctr128_encrypt(); cdecl; external;
procedure Camellia_decrypt(); cdecl; external;
procedure Camellia_DecryptBlock(); cdecl; external;
procedure Camellia_DecryptBlock_Rounds(); cdecl; external;
procedure Camellia_ecb_encrypt(); cdecl; external;
procedure Camellia_Ekeygen(); cdecl; external;
procedure Camellia_encrypt(); cdecl; external;
procedure Camellia_EncryptBlock(); cdecl; external;
procedure Camellia_EncryptBlock_Rounds(); cdecl; external;
procedure Camellia_ofb128_encrypt(); cdecl; external;
procedure Camellia_set_key(); cdecl; external;
procedure CAMELLIA_version(); cdecl; external;
procedure capi_cert_get_fname(); cdecl; external;
procedure capi_dump_cert(); cdecl; external;
procedure capi_find_key(); cdecl; external;
procedure capi_free_key(); cdecl; external;
procedure capi_get_prov_info(); cdecl; external;
procedure capi_list_certs(); cdecl; external;
procedure capi_open_store(); cdecl; external;
procedure CAST_cbc_encrypt(); cdecl; external;
procedure CAST_cfb64_encrypt(); cdecl; external;
procedure CAST_decrypt(); cdecl; external;
procedure CAST_ecb_encrypt(); cdecl; external;
procedure CAST_encrypt(); cdecl; external;
procedure CAST_ofb64_encrypt(); cdecl; external;
procedure CAST_S_table0(); cdecl; external;
procedure CAST_S_table1(); cdecl; external;
procedure CAST_S_table2(); cdecl; external;
procedure CAST_S_table3(); cdecl; external;
procedure CAST_S_table4(); cdecl; external;
procedure CAST_S_table5(); cdecl; external;
procedure CAST_S_table6(); cdecl; external;
procedure CAST_S_table7(); cdecl; external;
procedure CAST_set_key(); cdecl; external;
procedure CAST_version(); cdecl; external;
procedure CBIGNUM_it(); cdecl; external;
procedure CERTIFICATEPOLICIES_free(); cdecl; external;
procedure CERTIFICATEPOLICIES_it(); cdecl; external;
procedure CERTIFICATEPOLICIES_new(); cdecl; external;
procedure check_defer(); cdecl; external;
procedure cipher_gost(); cdecl; external;
procedure cipher_gost_cpacnt(); cdecl; external;
procedure cmac_asn1_meth(); cdecl; external;
procedure CMAC_CTX_cleanup(); cdecl; external;
procedure CMAC_CTX_copy(); cdecl; external;
procedure CMAC_CTX_free(); cdecl; external;
procedure CMAC_CTX_get0_cipher_ctx(); cdecl; external;
procedure CMAC_CTX_new(); cdecl; external;
procedure CMAC_Final(); cdecl; external;
procedure CMAC_Init(); cdecl; external;
procedure cmac_pkey_meth(); cdecl; external;
procedure CMAC_resume(); cdecl; external;
procedure CMAC_Update(); cdecl; external;
procedure CMS_add_simple_smimecap(); cdecl; external;
procedure CMS_add_smimecap(); cdecl; external;
procedure CMS_add_standard_smimecap(); cdecl; external;
procedure CMS_add0_cert(); cdecl; external;
procedure CMS_add0_CertificateChoices(); cdecl; external;
procedure CMS_add0_crl(); cdecl; external;
procedure CMS_add0_recipient_key(); cdecl; external;
procedure CMS_add0_recipient_password(); cdecl; external;
procedure CMS_add0_RevocationInfoChoice(); cdecl; external;
procedure CMS_add1_cert(); cdecl; external;
procedure CMS_add1_crl(); cdecl; external;
procedure CMS_add1_ReceiptRequest(); cdecl; external;
procedure CMS_add1_recipient_cert(); cdecl; external;
procedure CMS_add1_signer(); cdecl; external;
procedure CMS_Attributes_Sign_it(); cdecl; external;
procedure CMS_Attributes_Verify_it(); cdecl; external;
procedure CMS_AuthenticatedData_it(); cdecl; external;
procedure CMS_CertificateChoices_it(); cdecl; external;
procedure CMS_compress(); cdecl; external;
procedure CMS_CompressedData_it(); cdecl; external;
procedure cms_content_bio(); cdecl; external;
procedure CMS_ContentInfo_free(); cdecl; external;
procedure CMS_ContentInfo_it(); cdecl; external;
procedure CMS_ContentInfo_new(); cdecl; external;
procedure CMS_ContentInfo_print_ctx(); cdecl; external;
procedure CMS_data(); cdecl; external;
procedure cms_Data_create(); cdecl; external;
procedure CMS_dataFinal(); cdecl; external;
procedure CMS_dataInit(); cdecl; external;
procedure CMS_decrypt(); cdecl; external;
procedure CMS_decrypt_set1_key(); cdecl; external;
procedure CMS_decrypt_set1_password(); cdecl; external;
procedure CMS_decrypt_set1_pkey(); cdecl; external;
procedure CMS_digest_create(); cdecl; external;
procedure CMS_digest_verify(); cdecl; external;
procedure cms_DigestAlgorithm_find_ctx(); cdecl; external;
procedure cms_DigestAlgorithm_init_bio(); cdecl; external;
procedure cms_DigestAlgorithm_set(); cdecl; external;
procedure cms_DigestedData_create(); cdecl; external;
procedure cms_DigestedData_do_final(); cdecl; external;
procedure cms_DigestedData_init_bio(); cdecl; external;
procedure CMS_DigestedData_it(); cdecl; external;
procedure CMS_EncapsulatedContentInfo_it(); cdecl; external;
procedure cms_encode_Receipt(); cdecl; external;
procedure CMS_encrypt(); cdecl; external;
procedure cms_EncryptedContent_init(); cdecl; external;
procedure cms_EncryptedContent_init_bio(); cdecl; external;
procedure CMS_EncryptedContentInfo_it(); cdecl; external;
procedure CMS_EncryptedData_decrypt(); cdecl; external;
procedure CMS_EncryptedData_encrypt(); cdecl; external;
procedure cms_EncryptedData_init_bio(); cdecl; external;
procedure CMS_EncryptedData_it(); cdecl; external;
procedure CMS_EncryptedData_set1_key(); cdecl; external;
procedure cms_env_asn1_ctrl(); cdecl; external;
procedure CMS_EnvelopedData_create(); cdecl; external;
procedure cms_EnvelopedData_init_bio(); cdecl; external;
procedure CMS_EnvelopedData_it(); cdecl; external;
procedure CMS_final(); cdecl; external;
procedure CMS_get0_content(); cdecl; external;
procedure CMS_get0_eContentType(); cdecl; external;
procedure cms_get0_enveloped(); cdecl; external;
procedure CMS_get0_RecipientInfos(); cdecl; external;
procedure CMS_get0_SignerInfos(); cdecl; external;
procedure CMS_get0_signers(); cdecl; external;
procedure CMS_get0_type(); cdecl; external;
procedure CMS_get1_certs(); cdecl; external;
procedure CMS_get1_crls(); cdecl; external;
procedure CMS_get1_ReceiptRequest(); cdecl; external;
procedure cms_ias_cert_cmp(); cdecl; external;
procedure CMS_is_detached(); cdecl; external;
procedure CMS_IssuerAndSerialNumber_it(); cdecl; external;
procedure CMS_KEKIdentifier_it(); cdecl; external;
procedure CMS_KEKRecipientInfo_it(); cdecl; external;
procedure CMS_KeyAgreeRecipientIdentifier_it(); cdecl; external;
procedure CMS_KeyAgreeRecipientInfo_it(); cdecl; external;
procedure cms_keyid_cert_cmp(); cdecl; external;
procedure CMS_KeyTransRecipientInfo_it(); cdecl; external;
procedure cms_msgSigDigest_add1(); cdecl; external;
procedure CMS_OriginatorIdentifierOrKey_it(); cdecl; external;
procedure CMS_OriginatorInfo_it(); cdecl; external;
procedure CMS_OriginatorPublicKey_it(); cdecl; external;
procedure CMS_OtherCertificateFormat_it(); cdecl; external;
procedure CMS_OtherKeyAttribute_it(); cdecl; external;
procedure CMS_OtherRecipientInfo_it(); cdecl; external;
procedure CMS_OtherRevocationInfoFormat_it(); cdecl; external;
procedure CMS_PasswordRecipientInfo_it(); cdecl; external;
procedure cms_pkey_get_ri_type(); cdecl; external;
procedure CMS_Receipt_it(); cdecl; external;
procedure cms_Receipt_verify(); cdecl; external;
procedure CMS_ReceiptRequest_create0(); cdecl; external;
procedure CMS_ReceiptRequest_free(); cdecl; external;
procedure CMS_ReceiptRequest_get0_values(); cdecl; external;
procedure CMS_ReceiptRequest_it(); cdecl; external;
procedure CMS_ReceiptRequest_new(); cdecl; external;
procedure CMS_ReceiptsFrom_it(); cdecl; external;
procedure CMS_RecipientEncryptedKey_cert_cmp(); cdecl; external;
procedure CMS_RecipientEncryptedKey_get0_id(); cdecl; external;
procedure CMS_RecipientEncryptedKey_it(); cdecl; external;
procedure CMS_RecipientInfo_decrypt(); cdecl; external;
procedure CMS_RecipientInfo_encrypt(); cdecl; external;
procedure CMS_RecipientInfo_get0_pkey_ctx(); cdecl; external;
procedure CMS_RecipientInfo_it(); cdecl; external;
procedure CMS_RecipientInfo_kari_decrypt(); cdecl; external;
procedure cms_RecipientInfo_kari_encrypt(); cdecl; external;
procedure CMS_RecipientInfo_kari_get0_alg(); cdecl; external;
procedure CMS_RecipientInfo_kari_get0_ctx(); cdecl; external;
procedure CMS_RecipientInfo_kari_get0_orig_id(); cdecl; external;
procedure CMS_RecipientInfo_kari_get0_reks(); cdecl; external;
procedure cms_RecipientInfo_kari_init(); cdecl; external;
procedure CMS_RecipientInfo_kari_orig_id_cmp(); cdecl; external;
procedure CMS_RecipientInfo_kari_set0_pkey(); cdecl; external;
procedure CMS_RecipientInfo_kekri_get0_id(); cdecl; external;
procedure CMS_RecipientInfo_kekri_id_cmp(); cdecl; external;
procedure CMS_RecipientInfo_ktri_cert_cmp(); cdecl; external;
procedure CMS_RecipientInfo_ktri_get0_algs(); cdecl; external;
procedure CMS_RecipientInfo_ktri_get0_signer_id(); cdecl; external;
procedure cms_RecipientInfo_pwri_crypt(); cdecl; external;
procedure CMS_RecipientInfo_set0_key(); cdecl; external;
procedure CMS_RecipientInfo_set0_password(); cdecl; external;
procedure CMS_RecipientInfo_set0_pkey(); cdecl; external;
procedure CMS_RecipientInfo_type(); cdecl; external;
procedure CMS_RecipientKeyIdentifier_it(); cdecl; external;
procedure CMS_RevocationInfoChoice_it(); cdecl; external;
procedure CMS_set_detached(); cdecl; external;
procedure CMS_set1_eContentType(); cdecl; external;
procedure cms_set1_ias(); cdecl; external;
procedure cms_set1_keyid(); cdecl; external;
procedure cms_set1_SignerIdentifier(); cdecl; external;
procedure CMS_set1_signers_certs(); cdecl; external;
procedure CMS_SharedInfo_encode(); cdecl; external;
procedure CMS_SharedInfo_it(); cdecl; external;
procedure CMS_sign(); cdecl; external;
procedure CMS_sign_receipt(); cdecl; external;
procedure CMS_signed_add1_attr(); cdecl; external;
procedure CMS_signed_add1_attr_by_NID(); cdecl; external;
procedure CMS_signed_add1_attr_by_OBJ(); cdecl; external;
procedure CMS_signed_add1_attr_by_txt(); cdecl; external;
procedure CMS_signed_delete_attr(); cdecl; external;
procedure CMS_signed_get_attr(); cdecl; external;
procedure CMS_signed_get_attr_by_NID(); cdecl; external;
procedure CMS_signed_get_attr_by_OBJ(); cdecl; external;
procedure CMS_signed_get_attr_count(); cdecl; external;
procedure CMS_signed_get0_data_by_OBJ(); cdecl; external;
procedure cms_SignedData_final(); cdecl; external;
procedure CMS_SignedData_init(); cdecl; external;
procedure cms_SignedData_init_bio(); cdecl; external;
procedure CMS_SignedData_it(); cdecl; external;
procedure cms_SignerIdentifier_cert_cmp(); cdecl; external;
procedure cms_SignerIdentifier_get0_signer_id(); cdecl; external;
procedure CMS_SignerIdentifier_it(); cdecl; external;
procedure CMS_SignerInfo_cert_cmp(); cdecl; external;
procedure CMS_SignerInfo_get0_algs(); cdecl; external;
procedure CMS_SignerInfo_get0_md_ctx(); cdecl; external;
procedure CMS_SignerInfo_get0_pkey_ctx(); cdecl; external;
procedure CMS_SignerInfo_get0_signature(); cdecl; external;
procedure CMS_SignerInfo_get0_signer_id(); cdecl; external;
procedure CMS_SignerInfo_it(); cdecl; external;
procedure CMS_SignerInfo_set1_signer_cert(); cdecl; external;
procedure CMS_SignerInfo_sign(); cdecl; external;
procedure CMS_SignerInfo_verify(); cdecl; external;
procedure CMS_SignerInfo_verify_content(); cdecl; external;
procedure CMS_stream(); cdecl; external;
procedure CMS_uncompress(); cdecl; external;
procedure CMS_unsigned_add1_attr(); cdecl; external;
procedure CMS_unsigned_add1_attr_by_NID(); cdecl; external;
procedure CMS_unsigned_add1_attr_by_OBJ(); cdecl; external;
procedure CMS_unsigned_add1_attr_by_txt(); cdecl; external;
procedure CMS_unsigned_delete_attr(); cdecl; external;
procedure CMS_unsigned_get_attr(); cdecl; external;
procedure CMS_unsigned_get_attr_by_NID(); cdecl; external;
procedure CMS_unsigned_get_attr_by_OBJ(); cdecl; external;
procedure CMS_unsigned_get_attr_count(); cdecl; external;
procedure CMS_unsigned_get0_data_by_OBJ(); cdecl; external;
procedure CMS_verify(); cdecl; external;
procedure CMS_verify_receipt(); cdecl; external;
procedure COMP_compress_block(); cdecl; external;
procedure COMP_CTX_free(); cdecl; external;
procedure COMP_CTX_new(); cdecl; external;
procedure COMP_expand_block(); cdecl; external;
procedure COMP_rle(); cdecl; external;
procedure COMP_zlib(); cdecl; external;
procedure COMP_zlib_cleanup(); cdecl; external;
procedure CONF_def_version(); cdecl; external;
procedure CONF_dump_bio(); cdecl; external;
procedure CONF_dump_fp(); cdecl; external;
procedure CONF_free(); cdecl; external;
procedure CONF_get_number(); cdecl; external;
procedure CONF_get_section(); cdecl; external;
procedure CONF_get_string(); cdecl; external;
procedure CONF_get1_default_config_file(); cdecl; external;
procedure CONF_imodule_get_flags(); cdecl; external;
procedure CONF_imodule_get_module(); cdecl; external;
procedure CONF_imodule_get_name(); cdecl; external;
procedure CONF_imodule_get_usr_data(); cdecl; external;
procedure CONF_imodule_get_value(); cdecl; external;
procedure CONF_imodule_set_flags(); cdecl; external;
procedure CONF_imodule_set_usr_data(); cdecl; external;
procedure CONF_load(); cdecl; external;
procedure CONF_load_bio(); cdecl; external;
procedure CONF_load_fp(); cdecl; external;
procedure CONF_module_add(); cdecl; external;
procedure CONF_module_get_usr_data(); cdecl; external;
procedure CONF_module_set_usr_data(); cdecl; external;
procedure CONF_modules_finish(); cdecl; external;
procedure CONF_modules_free(); cdecl; external;
procedure CONF_modules_load(); cdecl; external;
procedure CONF_modules_load_file(); cdecl; external;
procedure CONF_modules_unload(); cdecl; external;
procedure CONF_parse_list(); cdecl; external;
procedure CONF_set_default_method(); cdecl; external;
procedure CONF_set_nconf(); cdecl; external;
procedure CONF_version(); cdecl; external;
procedure CRL_DIST_POINTS_free(); cdecl; external;
procedure CRL_DIST_POINTS_it(); cdecl; external;
procedure CRL_DIST_POINTS_new(); cdecl; external;
procedure CRYPTO_128_unwrap(); cdecl; external;
procedure CRYPTO_128_wrap(); cdecl; external;
procedure CRYPTO_add_lock(); cdecl; external;
procedure CRYPTO_cbc128_decrypt(); cdecl; external;
procedure CRYPTO_cbc128_encrypt(); cdecl; external;
procedure CRYPTO_ccm128_aad(); cdecl; external;
procedure CRYPTO_ccm128_decrypt(); cdecl; external;
procedure CRYPTO_ccm128_decrypt_ccm64(); cdecl; external;
procedure CRYPTO_ccm128_encrypt(); cdecl; external;
procedure CRYPTO_ccm128_encrypt_ccm64(); cdecl; external;
procedure CRYPTO_ccm128_init(); cdecl; external;
procedure CRYPTO_ccm128_setiv(); cdecl; external;
procedure CRYPTO_ccm128_tag(); cdecl; external;
procedure CRYPTO_cfb128_1_encrypt(); cdecl; external;
procedure CRYPTO_cfb128_8_encrypt(); cdecl; external;
procedure CRYPTO_cfb128_encrypt(); cdecl; external;
procedure CRYPTO_cleanup_all_ex_data(); cdecl; external;
procedure CRYPTO_ctr128_encrypt(); cdecl; external;
procedure CRYPTO_ctr128_encrypt_ctr32(); cdecl; external;
procedure CRYPTO_cts128_decrypt(); cdecl; external;
procedure CRYPTO_cts128_decrypt_block(); cdecl; external;
procedure CRYPTO_cts128_encrypt(); cdecl; external;
procedure CRYPTO_cts128_encrypt_block(); cdecl; external;
procedure CRYPTO_dbg_free(); cdecl; external;
procedure CRYPTO_dbg_get_options(); cdecl; external;
procedure CRYPTO_dbg_malloc(); cdecl; external;
procedure CRYPTO_dbg_realloc(); cdecl; external;
procedure CRYPTO_dbg_set_options(); cdecl; external;
procedure CRYPTO_destroy_dynlockid(); cdecl; external;
procedure CRYPTO_dup_ex_data(); cdecl; external;
procedure CRYPTO_ex_data_new_class(); cdecl; external;
procedure CRYPTO_free_ex_data(); cdecl; external;
procedure CRYPTO_free_locked(); cdecl; external;
procedure CRYPTO_gcm128_aad(); cdecl; external;
procedure CRYPTO_gcm128_decrypt(); cdecl; external;
procedure CRYPTO_gcm128_decrypt_ctr32(); cdecl; external;
procedure CRYPTO_gcm128_encrypt(); cdecl; external;
procedure CRYPTO_gcm128_encrypt_ctr32(); cdecl; external;
procedure CRYPTO_gcm128_finish(); cdecl; external;
procedure CRYPTO_gcm128_init(); cdecl; external;
procedure CRYPTO_gcm128_new(); cdecl; external;
procedure CRYPTO_gcm128_release(); cdecl; external;
procedure CRYPTO_gcm128_setiv(); cdecl; external;
procedure CRYPTO_gcm128_tag(); cdecl; external;
procedure CRYPTO_get_add_lock_callback(); cdecl; external;
procedure CRYPTO_get_dynlock_create_callback(); cdecl; external;
procedure CRYPTO_get_dynlock_destroy_callback(); cdecl; external;
procedure CRYPTO_get_dynlock_lock_callback(); cdecl; external;
procedure CRYPTO_get_dynlock_value(); cdecl; external;
procedure CRYPTO_get_ex_data(); cdecl; external;
procedure CRYPTO_get_ex_data_implementation(); cdecl; external;
procedure CRYPTO_get_ex_new_index(); cdecl; external;
procedure CRYPTO_get_id_callback(); cdecl; external;
procedure CRYPTO_get_lock_name(); cdecl; external;
procedure CRYPTO_get_locked_mem_ex_functions(); cdecl; external;
procedure CRYPTO_get_locked_mem_functions(); cdecl; external;
procedure CRYPTO_get_locking_callback(); cdecl; external;
procedure CRYPTO_get_mem_debug_functions(); cdecl; external;
procedure CRYPTO_get_mem_debug_options(); cdecl; external;
procedure CRYPTO_get_mem_ex_functions(); cdecl; external;
procedure CRYPTO_get_mem_functions(); cdecl; external;
procedure CRYPTO_get_new_dynlockid(); cdecl; external;
procedure CRYPTO_get_new_lockid(); cdecl; external;
procedure CRYPTO_is_mem_check_on(); cdecl; external;
procedure CRYPTO_lock(); cdecl; external;
procedure CRYPTO_malloc(); cdecl; external;
procedure CRYPTO_malloc_locked(); cdecl; external;
procedure CRYPTO_mem_ctrl(); cdecl; external;
procedure CRYPTO_mem_leaks(); cdecl; external;
procedure CRYPTO_mem_leaks_cb(); cdecl; external;
procedure CRYPTO_mem_leaks_fp(); cdecl; external;
procedure CRYPTO_memcmp(); cdecl; external;
procedure CRYPTO_new_ex_data(); cdecl; external;
procedure CRYPTO_nistcts128_decrypt(); cdecl; external;
procedure CRYPTO_nistcts128_decrypt_block(); cdecl; external;
procedure CRYPTO_nistcts128_encrypt(); cdecl; external;
procedure CRYPTO_nistcts128_encrypt_block(); cdecl; external;
procedure CRYPTO_num_locks(); cdecl; external;
procedure CRYPTO_ofb128_encrypt(); cdecl; external;
procedure CRYPTO_pop_info(); cdecl; external;
procedure CRYPTO_push_info_(); cdecl; external;
procedure CRYPTO_realloc(); cdecl; external;
procedure CRYPTO_realloc_clean(); cdecl; external;
procedure CRYPTO_remalloc(); cdecl; external;
procedure CRYPTO_remove_all_info(); cdecl; external;
procedure CRYPTO_set_add_lock_callback(); cdecl; external;
procedure CRYPTO_set_dynlock_create_callback(); cdecl; external;
procedure CRYPTO_set_dynlock_destroy_callback(); cdecl; external;
procedure CRYPTO_set_dynlock_lock_callback(); cdecl; external;
procedure CRYPTO_set_ex_data(); cdecl; external;
procedure CRYPTO_set_ex_data_implementation(); cdecl; external;
procedure CRYPTO_set_id_callback(); cdecl; external;
procedure CRYPTO_set_locked_mem_ex_functions(); cdecl; external;
procedure CRYPTO_set_locked_mem_functions(); cdecl; external;
procedure CRYPTO_set_locking_callback(); cdecl; external;
procedure CRYPTO_set_mem_debug_functions(); cdecl; external;
procedure CRYPTO_set_mem_debug_options(); cdecl; external;
procedure CRYPTO_set_mem_ex_functions(); cdecl; external;
procedure CRYPTO_set_mem_functions(); cdecl; external;
procedure CRYPTO_strdup(); cdecl; external;
procedure CRYPTO_thread_id(); cdecl; external;
procedure CRYPTO_THREADID_cmp(); cdecl; external;
procedure CRYPTO_THREADID_cpy(); cdecl; external;
procedure CRYPTO_THREADID_current(); cdecl; external;
procedure CRYPTO_THREADID_get_callback(); cdecl; external;
procedure CRYPTO_THREADID_hash(); cdecl; external;
procedure CRYPTO_THREADID_set_callback(); cdecl; external;
procedure CRYPTO_THREADID_set_numeric(); cdecl; external;
procedure CRYPTO_THREADID_set_pointer(); cdecl; external;
procedure CRYPTO_xts128_encrypt(); cdecl; external;
procedure cryptopro_key_meshing(); cdecl; external;
procedure CryptoProKeyMeshingKey(); cdecl; external;
procedure custom_ext_add(); cdecl; external;
procedure custom_ext_init(); cdecl; external;
procedure custom_ext_parse(); cdecl; external;
procedure custom_exts_copy(); cdecl; external;
procedure custom_exts_copy_flags(); cdecl; external;
procedure custom_exts_free(); cdecl; external;
procedure d2i_ACCESS_DESCRIPTION(); cdecl; external;
procedure d2i_ASN1_BIT_STRING(); cdecl; external;
procedure d2i_ASN1_BMPSTRING(); cdecl; external;
procedure d2i_ASN1_BOOLEAN(); cdecl; external;
procedure d2i_ASN1_bytes(); cdecl; external;
procedure d2i_ASN1_ENUMERATED(); cdecl; external;
procedure d2i_ASN1_GENERALIZEDTIME(); cdecl; external;
procedure d2i_ASN1_GENERALSTRING(); cdecl; external;
procedure d2i_ASN1_IA5STRING(); cdecl; external;
procedure d2i_ASN1_INTEGER(); cdecl; external;
procedure d2i_ASN1_NULL(); cdecl; external;
procedure d2i_ASN1_OBJECT(); cdecl; external;
procedure d2i_ASN1_OCTET_STRING(); cdecl; external;
procedure d2i_ASN1_PRINTABLE(); cdecl; external;
procedure d2i_ASN1_PRINTABLESTRING(); cdecl; external;
procedure d2i_ASN1_SEQUENCE_ANY(); cdecl; external;
procedure d2i_ASN1_SET(); cdecl; external;
procedure d2i_ASN1_SET_ANY(); cdecl; external;
procedure d2i_ASN1_T61STRING(); cdecl; external;
procedure d2i_ASN1_TIME(); cdecl; external;
procedure d2i_ASN1_TYPE(); cdecl; external;
procedure d2i_ASN1_type_bytes(); cdecl; external;
procedure d2i_ASN1_UINTEGER(); cdecl; external;
procedure d2i_ASN1_UNIVERSALSTRING(); cdecl; external;
procedure d2i_ASN1_UTCTIME(); cdecl; external;
procedure d2i_ASN1_UTF8STRING(); cdecl; external;
procedure d2i_ASN1_VISIBLESTRING(); cdecl; external;
procedure d2i_AUTHORITY_INFO_ACCESS(); cdecl; external;
procedure d2i_AUTHORITY_KEYID(); cdecl; external;
procedure d2i_AutoPrivateKey(); cdecl; external;
procedure d2i_BASIC_CONSTRAINTS(); cdecl; external;
procedure d2i_CERTIFICATEPOLICIES(); cdecl; external;
procedure d2i_CMS_bio(); cdecl; external;
procedure d2i_CMS_ContentInfo(); cdecl; external;
procedure d2i_CMS_ReceiptRequest(); cdecl; external;
procedure d2i_CRL_DIST_POINTS(); cdecl; external;
procedure d2i_DHparams(); cdecl; external;
procedure d2i_DHxparams(); cdecl; external;
procedure d2i_DIRECTORYSTRING(); cdecl; external;
procedure d2i_DISPLAYTEXT(); cdecl; external;
procedure d2i_DIST_POINT(); cdecl; external;
procedure d2i_DIST_POINT_NAME(); cdecl; external;
procedure d2i_DSA_PUBKEY(); cdecl; external;
procedure d2i_DSA_PUBKEY_bio(); cdecl; external;
procedure d2i_DSA_PUBKEY_fp(); cdecl; external;
procedure d2i_DSA_SIG(); cdecl; external;
procedure d2i_DSAparams(); cdecl; external;
procedure d2i_DSAPrivateKey(); cdecl; external;
procedure d2i_DSAPrivateKey_bio(); cdecl; external;
procedure d2i_DSAPrivateKey_fp(); cdecl; external;
procedure d2i_DSAPublicKey(); cdecl; external;
procedure d2i_EC_PRIVATEKEY(); cdecl; external;
procedure d2i_EC_PUBKEY(); cdecl; external;
procedure d2i_EC_PUBKEY_bio(); cdecl; external;
procedure d2i_EC_PUBKEY_fp(); cdecl; external;
procedure d2i_ECDSA_SIG(); cdecl; external;
procedure d2i_ECParameters(); cdecl; external;
procedure d2i_ECPKPARAMETERS(); cdecl; external;
procedure d2i_ECPrivateKey(); cdecl; external;
procedure d2i_ECPrivateKey_bio(); cdecl; external;
procedure d2i_ECPrivateKey_fp(); cdecl; external;
procedure d2i_EDIPARTYNAME(); cdecl; external;
procedure d2i_ESS_CERT_ID(); cdecl; external;
procedure d2i_ESS_ISSUER_SERIAL(); cdecl; external;
procedure d2i_ESS_SIGNING_CERT(); cdecl; external;
procedure d2i_EXTENDED_KEY_USAGE(); cdecl; external;
procedure d2i_GENERAL_NAME(); cdecl; external;
procedure d2i_GENERAL_NAMES(); cdecl; external;
procedure d2i_GOST_CIPHER_PARAMS(); cdecl; external;
procedure d2i_GOST_CLIENT_KEY_EXCHANGE_PARAMS(); cdecl; external;
procedure d2i_GOST_KEY_AGREEMENT_INFO(); cdecl; external;
procedure d2i_GOST_KEY_INFO(); cdecl; external;
procedure d2i_GOST_KEY_PARAMS(); cdecl; external;
procedure d2i_GOST_KEY_TRANSPORT(); cdecl; external;
procedure d2i_int_dhx(); cdecl; external;
procedure d2i_ISSUING_DIST_POINT(); cdecl; external;
procedure d2i_KRB5_APREQ(); cdecl; external;
procedure d2i_KRB5_APREQBODY(); cdecl; external;
procedure d2i_KRB5_AUTHDATA(); cdecl; external;
procedure d2i_KRB5_AUTHENT(); cdecl; external;
procedure d2i_KRB5_AUTHENTBODY(); cdecl; external;
procedure d2i_KRB5_CHECKSUM(); cdecl; external;
procedure d2i_KRB5_ENCDATA(); cdecl; external;
procedure d2i_KRB5_ENCKEY(); cdecl; external;
procedure d2i_KRB5_PRINCNAME(); cdecl; external;
procedure d2i_KRB5_TICKET(); cdecl; external;
procedure d2i_KRB5_TKTBODY(); cdecl; external;
procedure d2i_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure d2i_NETSCAPE_ENCRYPTED_PKEY(); cdecl; external;
procedure d2i_NETSCAPE_PKEY(); cdecl; external;
procedure d2i_Netscape_RSA(); cdecl; external;
procedure d2i_NETSCAPE_SPKAC(); cdecl; external;
procedure d2i_NETSCAPE_SPKI(); cdecl; external;
procedure d2i_NETSCAPE_X509(); cdecl; external;
procedure d2i_NOTICEREF(); cdecl; external;
procedure d2i_OCSP_BASICRESP(); cdecl; external;
procedure d2i_OCSP_CERTID(); cdecl; external;
procedure d2i_OCSP_CERTSTATUS(); cdecl; external;
procedure d2i_OCSP_CRLID(); cdecl; external;
procedure d2i_OCSP_ONEREQ(); cdecl; external;
procedure d2i_OCSP_REQINFO(); cdecl; external;
procedure d2i_OCSP_REQUEST(); cdecl; external;
procedure d2i_OCSP_RESPBYTES(); cdecl; external;
procedure d2i_OCSP_RESPDATA(); cdecl; external;
procedure d2i_OCSP_RESPID(); cdecl; external;
procedure d2i_OCSP_RESPONSE(); cdecl; external;
procedure d2i_OCSP_REVOKEDINFO(); cdecl; external;
procedure d2i_OCSP_SERVICELOC(); cdecl; external;
procedure d2i_OCSP_SIGNATURE(); cdecl; external;
procedure d2i_OCSP_SINGLERESP(); cdecl; external;
procedure d2i_OTHERNAME(); cdecl; external;
procedure d2i_PBE2PARAM(); cdecl; external;
procedure d2i_PBEPARAM(); cdecl; external;
procedure d2i_PBKDF2PARAM(); cdecl; external;
procedure d2i_PKCS12(); cdecl; external;
procedure d2i_PKCS12_BAGS(); cdecl; external;
procedure d2i_PKCS12_bio(); cdecl; external;
procedure d2i_PKCS12_fp(); cdecl; external;
procedure d2i_PKCS12_MAC_DATA(); cdecl; external;
procedure d2i_PKCS12_SAFEBAG(); cdecl; external;
procedure d2i_PKCS7(); cdecl; external;
procedure d2i_PKCS7_bio(); cdecl; external;
procedure d2i_PKCS7_DIGEST(); cdecl; external;
procedure d2i_PKCS7_ENC_CONTENT(); cdecl; external;
procedure d2i_PKCS7_ENCRYPT(); cdecl; external;
procedure d2i_PKCS7_ENVELOPE(); cdecl; external;
procedure d2i_PKCS7_fp(); cdecl; external;
procedure d2i_PKCS7_ISSUER_AND_SERIAL(); cdecl; external;
procedure d2i_PKCS7_RECIP_INFO(); cdecl; external;
procedure d2i_PKCS7_SIGN_ENVELOPE(); cdecl; external;
procedure d2i_PKCS7_SIGNED(); cdecl; external;
procedure d2i_PKCS7_SIGNER_INFO(); cdecl; external;
procedure d2i_PKCS8_bio(); cdecl; external;
procedure d2i_PKCS8_fp(); cdecl; external;
procedure d2i_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure d2i_PKCS8_PRIV_KEY_INFO_bio(); cdecl; external;
procedure d2i_PKCS8_PRIV_KEY_INFO_fp(); cdecl; external;
procedure d2i_PKCS8PrivateKey_bio(); cdecl; external;
procedure d2i_PKCS8PrivateKey_fp(); cdecl; external;
procedure d2i_PKEY_USAGE_PERIOD(); cdecl; external;
procedure d2i_POLICYINFO(); cdecl; external;
procedure d2i_POLICYQUALINFO(); cdecl; external;
procedure d2i_PrivateKey(); cdecl; external;
procedure d2i_PrivateKey_bio(); cdecl; external;
procedure d2i_PrivateKey_fp(); cdecl; external;
procedure d2i_PROXY_CERT_INFO_EXTENSION(); cdecl; external;
procedure d2i_PROXY_POLICY(); cdecl; external;
procedure d2i_PUBKEY(); cdecl; external;
procedure d2i_PUBKEY_bio(); cdecl; external;
procedure d2i_PUBKEY_fp(); cdecl; external;
procedure d2i_PublicKey(); cdecl; external;
procedure d2i_RSA_NET(); cdecl; external;
procedure d2i_RSA_OAEP_PARAMS(); cdecl; external;
procedure d2i_RSA_PSS_PARAMS(); cdecl; external;
procedure d2i_RSA_PUBKEY(); cdecl; external;
procedure d2i_RSA_PUBKEY_bio(); cdecl; external;
procedure d2i_RSA_PUBKEY_fp(); cdecl; external;
procedure d2i_RSAPrivateKey(); cdecl; external;
procedure d2i_RSAPrivateKey_bio(); cdecl; external;
procedure d2i_RSAPrivateKey_fp(); cdecl; external;
procedure d2i_RSAPublicKey(); cdecl; external;
procedure d2i_RSAPublicKey_bio(); cdecl; external;
procedure d2i_RSAPublicKey_fp(); cdecl; external;
procedure d2i_SSL_SESSION(); cdecl; external;
procedure d2i_SXNET(); cdecl; external;
procedure d2i_SXNETID(); cdecl; external;
procedure d2i_TS_ACCURACY(); cdecl; external;
procedure d2i_TS_MSG_IMPRINT(); cdecl; external;
procedure d2i_TS_MSG_IMPRINT_bio(); cdecl; external;
procedure d2i_TS_MSG_IMPRINT_fp(); cdecl; external;
procedure d2i_TS_REQ(); cdecl; external;
procedure d2i_TS_REQ_bio(); cdecl; external;
procedure d2i_TS_REQ_fp(); cdecl; external;
procedure d2i_TS_RESP(); cdecl; external;
procedure d2i_TS_RESP_bio(); cdecl; external;
procedure d2i_TS_RESP_fp(); cdecl; external;
procedure d2i_TS_STATUS_INFO(); cdecl; external;
procedure d2i_TS_TST_INFO(); cdecl; external;
procedure d2i_TS_TST_INFO_bio(); cdecl; external;
procedure d2i_TS_TST_INFO_fp(); cdecl; external;
procedure d2i_USERNOTICE(); cdecl; external;
procedure d2i_X509(); cdecl; external;
procedure d2i_X509_ALGOR(); cdecl; external;
procedure d2i_X509_ALGORS(); cdecl; external;
procedure d2i_X509_ATTRIBUTE(); cdecl; external;
procedure d2i_X509_AUX(); cdecl; external;
procedure d2i_X509_bio(); cdecl; external;
procedure d2i_X509_CERT_AUX(); cdecl; external;
procedure d2i_X509_CERT_PAIR(); cdecl; external;
procedure d2i_X509_CINF(); cdecl; external;
procedure d2i_X509_CRL(); cdecl; external;
procedure d2i_X509_CRL_bio(); cdecl; external;
procedure d2i_X509_CRL_fp(); cdecl; external;
procedure d2i_X509_CRL_INFO(); cdecl; external;
procedure d2i_X509_EXTENSION(); cdecl; external;
procedure d2i_X509_EXTENSIONS(); cdecl; external;
procedure d2i_X509_fp(); cdecl; external;
procedure d2i_X509_NAME(); cdecl; external;
procedure d2i_X509_NAME_ENTRY(); cdecl; external;
procedure d2i_X509_PKEY(); cdecl; external;
procedure d2i_X509_PUBKEY(); cdecl; external;
procedure d2i_X509_REQ(); cdecl; external;
procedure d2i_X509_REQ_bio(); cdecl; external;
procedure d2i_X509_REQ_fp(); cdecl; external;
procedure d2i_X509_REQ_INFO(); cdecl; external;
procedure d2i_X509_REVOKED(); cdecl; external;
procedure d2i_X509_SIG(); cdecl; external;
procedure d2i_X509_VAL(); cdecl; external;
procedure default_pctx(); cdecl; external;
procedure DES_cbc_cksum(); cdecl; external;
procedure DES_cbc_encrypt(); cdecl; external;
procedure DES_cfb_encrypt(); cdecl; external;
procedure DES_cfb64_encrypt(); cdecl; external;
procedure DES_check_key_parity(); cdecl; external;
procedure DES_crypt(); cdecl; external;
procedure DES_decrypt3(); cdecl; external;
procedure DES_ecb_encrypt(); cdecl; external;
procedure DES_ecb3_encrypt(); cdecl; external;
procedure DES_ede3_cbc_encrypt(); cdecl; external;
procedure DES_ede3_cbcm_encrypt(); cdecl; external;
procedure DES_ede3_cfb_encrypt(); cdecl; external;
procedure DES_ede3_cfb64_encrypt(); cdecl; external;
procedure DES_ede3_ofb64_encrypt(); cdecl; external;
procedure DES_enc_read(); cdecl; external;
procedure DES_enc_write(); cdecl; external;
procedure DES_encrypt1(); cdecl; external;
procedure DES_encrypt2(); cdecl; external;
procedure DES_encrypt3(); cdecl; external;
procedure DES_fcrypt(); cdecl; external;
procedure DES_is_weak_key(); cdecl; external;
procedure DES_key_sched(); cdecl; external;
procedure DES_ncbc_encrypt(); cdecl; external;
procedure DES_ofb_encrypt(); cdecl; external;
procedure DES_ofb64_encrypt(); cdecl; external;
procedure DES_options(); cdecl; external;
procedure DES_pcbc_encrypt(); cdecl; external;
procedure DES_quad_cksum(); cdecl; external;
procedure DES_random_key(); cdecl; external;
procedure DES_read_2passwords(); cdecl; external;
procedure DES_read_password(); cdecl; external;
procedure DES_set_key(); cdecl; external;
procedure DES_set_key_checked(); cdecl; external;
procedure DES_set_key_unchecked(); cdecl; external;
procedure DES_set_odd_parity(); cdecl; external;
procedure DES_SPtrans(); cdecl; external;
procedure DES_string_to_2keys(); cdecl; external;
procedure DES_string_to_key(); cdecl; external;
procedure DES_xcbc_encrypt(); cdecl; external;
procedure dh_asn1_meth(); cdecl; external;
procedure DH_check(); cdecl; external;
procedure DH_check_pub_key(); cdecl; external;
procedure DH_compute_key(); cdecl; external;
procedure DH_compute_key_padded(); cdecl; external;
procedure DH_free(); cdecl; external;
procedure DH_generate_key(); cdecl; external;
procedure DH_generate_parameters(); cdecl; external;
procedure DH_generate_parameters_ex(); cdecl; external;
procedure DH_get_1024_160(); cdecl; external;
procedure DH_get_2048_224(); cdecl; external;
procedure DH_get_2048_256(); cdecl; external;
procedure DH_get_default_method(); cdecl; external;
procedure DH_get_ex_data(); cdecl; external;
procedure DH_get_ex_new_index(); cdecl; external;
procedure DH_KDF_X9_42(); cdecl; external;
procedure DH_new(); cdecl; external;
procedure DH_new_method(); cdecl; external;
procedure DH_OpenSSL(); cdecl; external;
procedure dh_pkey_meth(); cdecl; external;
procedure DH_set_default_method(); cdecl; external;
procedure DH_set_ex_data(); cdecl; external;
procedure DH_set_method(); cdecl; external;
procedure DH_size(); cdecl; external;
procedure DH_up_ref(); cdecl; external;
procedure DH_version(); cdecl; external;
procedure DHparams_dup(); cdecl; external;
procedure DHparams_it(); cdecl; external;
procedure DHparams_print(); cdecl; external;
procedure DHparams_print_fp(); cdecl; external;
procedure DHvparams_it(); cdecl; external;
procedure dhx_asn1_meth(); cdecl; external;
procedure dhx_pkey_meth(); cdecl; external;
procedure DHxparams_it(); cdecl; external;
procedure digest_gost(); cdecl; external;
procedure DIRECTORYSTRING_free(); cdecl; external;
procedure DIRECTORYSTRING_it(); cdecl; external;
procedure DIRECTORYSTRING_new(); cdecl; external;
procedure DISPLAYTEXT_free(); cdecl; external;
procedure DISPLAYTEXT_it(); cdecl; external;
procedure DISPLAYTEXT_new(); cdecl; external;
procedure DIST_POINT_free(); cdecl; external;
procedure DIST_POINT_it(); cdecl; external;
procedure DIST_POINT_NAME_free(); cdecl; external;
procedure DIST_POINT_NAME_it(); cdecl; external;
procedure DIST_POINT_NAME_new(); cdecl; external;
procedure DIST_POINT_new(); cdecl; external;
procedure DIST_POINT_set_dpname(); cdecl; external;
procedure do_dtls1_write(); cdecl; external;
procedure done_gost_hash_ctx(); cdecl; external;
procedure dsa_asn1_meths(); cdecl; external;
procedure dsa_builtin_paramgen(); cdecl; external;
procedure dsa_builtin_paramgen2(); cdecl; external;
procedure DSA_do_sign(); cdecl; external;
procedure DSA_do_verify(); cdecl; external;
procedure DSA_dup_DH(); cdecl; external;
procedure DSA_free(); cdecl; external;
procedure DSA_generate_key(); cdecl; external;
procedure DSA_generate_parameters(); cdecl; external;
procedure DSA_generate_parameters_ex(); cdecl; external;
procedure DSA_get_default_method(); cdecl; external;
procedure DSA_get_ex_data(); cdecl; external;
procedure DSA_get_ex_new_index(); cdecl; external;
procedure DSA_new(); cdecl; external;
procedure DSA_new_method(); cdecl; external;
procedure DSA_OpenSSL(); cdecl; external;
procedure dsa_paramgen_check_g(); cdecl; external;
procedure dsa_pkey_meth(); cdecl; external;
procedure DSA_print(); cdecl; external;
procedure DSA_print_fp(); cdecl; external;
procedure dsa_pub_internal_it(); cdecl; external;
procedure DSA_set_default_method(); cdecl; external;
procedure DSA_set_ex_data(); cdecl; external;
procedure DSA_set_method(); cdecl; external;
procedure DSA_SIG_free(); cdecl; external;
procedure DSA_SIG_it(); cdecl; external;
procedure DSA_SIG_new(); cdecl; external;
procedure DSA_sign(); cdecl; external;
procedure DSA_sign_setup(); cdecl; external;
procedure DSA_size(); cdecl; external;
procedure DSA_up_ref(); cdecl; external;
procedure DSA_verify(); cdecl; external;
procedure DSA_version(); cdecl; external;
procedure DSAparams_dup(); cdecl; external;
procedure DSAparams_it(); cdecl; external;
procedure DSAparams_print(); cdecl; external;
procedure DSAparams_print_fp(); cdecl; external;
procedure DSAPrivateKey_it(); cdecl; external;
procedure DSAPublicKey_it(); cdecl; external;
procedure DSO_bind_func(); cdecl; external;
procedure DSO_bind_var(); cdecl; external;
procedure DSO_convert_filename(); cdecl; external;
procedure DSO_ctrl(); cdecl; external;
procedure DSO_flags(); cdecl; external;
procedure DSO_free(); cdecl; external;
procedure DSO_get_default_method(); cdecl; external;
procedure DSO_get_filename(); cdecl; external;
procedure DSO_get_loaded_filename(); cdecl; external;
procedure DSO_get_method(); cdecl; external;
procedure DSO_global_lookup(); cdecl; external;
procedure DSO_load(); cdecl; external;
procedure DSO_merge(); cdecl; external;
procedure DSO_METHOD_beos(); cdecl; external;
procedure DSO_METHOD_dl(); cdecl; external;
procedure DSO_METHOD_dlfcn(); cdecl; external;
procedure DSO_METHOD_null(); cdecl; external;
procedure DSO_METHOD_openssl(); cdecl; external;
procedure DSO_METHOD_vms(); cdecl; external;
procedure DSO_METHOD_win32(); cdecl; external;
procedure DSO_new(); cdecl; external;
procedure DSO_new_method(); cdecl; external;
procedure DSO_pathbyaddr(); cdecl; external;
procedure DSO_set_default_method(); cdecl; external;
procedure DSO_set_filename(); cdecl; external;
procedure DSO_set_method(); cdecl; external;
procedure DSO_set_name_converter(); cdecl; external;
procedure DSO_up_ref(); cdecl; external;
procedure dtls1_accept(); cdecl; external;
procedure dtls1_buffer_message(); cdecl; external;
procedure dtls1_check_timeout_num(); cdecl; external;
procedure dtls1_clear(); cdecl; external;
procedure dtls1_clear_received_buffer(); cdecl; external;
procedure dtls1_clear_sent_buffer(); cdecl; external;
procedure dtls1_connect(); cdecl; external;
procedure dtls1_ctrl(); cdecl; external;
procedure dtls1_default_timeout(); cdecl; external;
procedure dtls1_dispatch_alert(); cdecl; external;
procedure dtls1_do_write(); cdecl; external;
procedure dtls1_double_timeout(); cdecl; external;
procedure dtls1_free(); cdecl; external;
procedure dtls1_get_ccs_header(); cdecl; external;
procedure dtls1_get_cipher(); cdecl; external;
procedure dtls1_get_message(); cdecl; external;
procedure dtls1_get_message_header(); cdecl; external;
procedure dtls1_get_queue_priority(); cdecl; external;
procedure dtls1_get_record(); cdecl; external;
procedure dtls1_get_timeout(); cdecl; external;
procedure dtls1_handle_timeout(); cdecl; external;
procedure dtls1_heartbeat(); cdecl; external;
procedure dtls1_hm_fragment_free(); cdecl; external;
procedure dtls1_is_timer_expired(); cdecl; external;
procedure dtls1_link_min_mtu(); cdecl; external;
procedure dtls1_listen(); cdecl; external;
procedure dtls1_min_mtu(); cdecl; external;
procedure dtls1_new(); cdecl; external;
procedure dtls1_process_heartbeat(); cdecl; external;
procedure dtls1_read_bytes(); cdecl; external;
procedure dtls1_read_failed(); cdecl; external;
procedure dtls1_reset_seq_numbers(); cdecl; external;
procedure dtls1_retransmit_buffered_messages(); cdecl; external;
procedure dtls1_retransmit_message(); cdecl; external;
procedure dtls1_send_change_cipher_spec(); cdecl; external;
procedure dtls1_set_message_header(); cdecl; external;
procedure dtls1_shutdown(); cdecl; external;
procedure dtls1_start_timer(); cdecl; external;
procedure dtls1_stop_timer(); cdecl; external;
procedure dtls1_version_str(); cdecl; external;
procedure dtls1_write_app_data_bytes(); cdecl; external;
procedure dtls1_write_bytes(); cdecl; external;
procedure DTLSv1_2_enc_data(); cdecl; external;
procedure DTLSv1_enc_data(); cdecl; external;
procedure EC_curve_nid2nist(); cdecl; external;
procedure EC_curve_nist2nid(); cdecl; external;
procedure EC_EX_DATA_clear_free_all_data(); cdecl; external;
procedure EC_EX_DATA_clear_free_data(); cdecl; external;
procedure EC_EX_DATA_free_all_data(); cdecl; external;
procedure EC_EX_DATA_free_data(); cdecl; external;
procedure EC_EX_DATA_get_data(); cdecl; external;
procedure EC_EX_DATA_set_data(); cdecl; external;
procedure EC_get_builtin_curves(); cdecl; external;
procedure ec_GF2m_have_precompute_mult(); cdecl; external;
procedure ec_GF2m_precompute_mult(); cdecl; external;
procedure ec_GF2m_simple_add(); cdecl; external;
procedure ec_GF2m_simple_cmp(); cdecl; external;
procedure ec_GF2m_simple_dbl(); cdecl; external;
procedure ec_GF2m_simple_field_div(); cdecl; external;
procedure ec_GF2m_simple_field_mul(); cdecl; external;
procedure ec_GF2m_simple_field_sqr(); cdecl; external;
procedure ec_GF2m_simple_group_check_discriminant(); cdecl; external;
procedure ec_GF2m_simple_group_clear_finish(); cdecl; external;
procedure ec_GF2m_simple_group_copy(); cdecl; external;
procedure ec_GF2m_simple_group_finish(); cdecl; external;
procedure ec_GF2m_simple_group_get_curve(); cdecl; external;
procedure ec_GF2m_simple_group_get_degree(); cdecl; external;
procedure ec_GF2m_simple_group_init(); cdecl; external;
procedure ec_GF2m_simple_group_set_curve(); cdecl; external;
procedure ec_GF2m_simple_invert(); cdecl; external;
procedure ec_GF2m_simple_is_at_infinity(); cdecl; external;
procedure ec_GF2m_simple_is_on_curve(); cdecl; external;
procedure ec_GF2m_simple_make_affine(); cdecl; external;
procedure EC_GF2m_simple_method(); cdecl; external;
procedure ec_GF2m_simple_mul(); cdecl; external;
procedure ec_GF2m_simple_oct2point(); cdecl; external;
procedure ec_GF2m_simple_point_clear_finish(); cdecl; external;
procedure ec_GF2m_simple_point_copy(); cdecl; external;
procedure ec_GF2m_simple_point_finish(); cdecl; external;
procedure ec_GF2m_simple_point_get_affine_coordinates(); cdecl; external;
procedure ec_GF2m_simple_point_init(); cdecl; external;
procedure ec_GF2m_simple_point_set_affine_coordinates(); cdecl; external;
procedure ec_GF2m_simple_point_set_to_infinity(); cdecl; external;
procedure ec_GF2m_simple_point2oct(); cdecl; external;
procedure ec_GF2m_simple_points_make_affine(); cdecl; external;
procedure ec_GF2m_simple_set_compressed_coordinates(); cdecl; external;
procedure ec_GFp_mont_field_decode(); cdecl; external;
procedure ec_GFp_mont_field_encode(); cdecl; external;
procedure ec_GFp_mont_field_mul(); cdecl; external;
procedure ec_GFp_mont_field_set_to_one(); cdecl; external;
procedure ec_GFp_mont_field_sqr(); cdecl; external;
procedure ec_GFp_mont_group_clear_finish(); cdecl; external;
procedure ec_GFp_mont_group_copy(); cdecl; external;
procedure ec_GFp_mont_group_finish(); cdecl; external;
procedure ec_GFp_mont_group_init(); cdecl; external;
procedure ec_GFp_mont_group_set_curve(); cdecl; external;
procedure EC_GFp_mont_method(); cdecl; external;
procedure ec_GFp_nist_field_mul(); cdecl; external;
procedure ec_GFp_nist_field_sqr(); cdecl; external;
procedure ec_GFp_nist_group_copy(); cdecl; external;
procedure ec_GFp_nist_group_set_curve(); cdecl; external;
procedure EC_GFp_nist_method(); cdecl; external;
procedure ec_GFp_simple_add(); cdecl; external;
procedure ec_GFp_simple_cmp(); cdecl; external;
procedure ec_GFp_simple_dbl(); cdecl; external;
procedure ec_GFp_simple_field_mul(); cdecl; external;
procedure ec_GFp_simple_field_sqr(); cdecl; external;
procedure ec_GFp_simple_get_Jprojective_coordinates_GFp(); cdecl; external;
procedure ec_GFp_simple_group_check_discriminant(); cdecl; external;
procedure ec_GFp_simple_group_clear_finish(); cdecl; external;
procedure ec_GFp_simple_group_copy(); cdecl; external;
procedure ec_GFp_simple_group_finish(); cdecl; external;
procedure ec_GFp_simple_group_get_curve(); cdecl; external;
procedure ec_GFp_simple_group_get_degree(); cdecl; external;
procedure ec_GFp_simple_group_init(); cdecl; external;
procedure ec_GFp_simple_group_set_curve(); cdecl; external;
procedure ec_GFp_simple_invert(); cdecl; external;
procedure ec_GFp_simple_is_at_infinity(); cdecl; external;
procedure ec_GFp_simple_is_on_curve(); cdecl; external;
procedure ec_GFp_simple_make_affine(); cdecl; external;
procedure EC_GFp_simple_method(); cdecl; external;
procedure ec_GFp_simple_oct2point(); cdecl; external;
procedure ec_GFp_simple_point_clear_finish(); cdecl; external;
procedure ec_GFp_simple_point_copy(); cdecl; external;
procedure ec_GFp_simple_point_finish(); cdecl; external;
procedure ec_GFp_simple_point_get_affine_coordinates(); cdecl; external;
procedure ec_GFp_simple_point_init(); cdecl; external;
procedure ec_GFp_simple_point_set_affine_coordinates(); cdecl; external;
procedure ec_GFp_simple_point_set_to_infinity(); cdecl; external;
procedure ec_GFp_simple_point2oct(); cdecl; external;
procedure ec_GFp_simple_points_make_affine(); cdecl; external;
procedure ec_GFp_simple_set_compressed_coordinates(); cdecl; external;
procedure ec_GFp_simple_set_Jprojective_coordinates_GFp(); cdecl; external;
procedure EC_GROUP_check(); cdecl; external;
procedure EC_GROUP_check_discriminant(); cdecl; external;
procedure EC_GROUP_cmp(); cdecl; external;
procedure EC_GROUP_copy(); cdecl; external;
procedure EC_GROUP_dup(); cdecl; external;
procedure EC_GROUP_get_asn1_flag(); cdecl; external;
procedure EC_GROUP_get_basis_type(); cdecl; external;
procedure EC_GROUP_get_cofactor(); cdecl; external;
procedure EC_GROUP_get_curve_GF2m(); cdecl; external;
procedure EC_GROUP_get_curve_GFp(); cdecl; external;
procedure EC_GROUP_get_curve_name(); cdecl; external;
procedure EC_GROUP_get_degree(); cdecl; external;
procedure EC_GROUP_get_mont_data(); cdecl; external;
procedure EC_GROUP_get_order(); cdecl; external;
procedure EC_GROUP_get_pentanomial_basis(); cdecl; external;
procedure EC_GROUP_get_point_conversion_form(); cdecl; external;
procedure EC_GROUP_get_seed_len(); cdecl; external;
procedure EC_GROUP_get_trinomial_basis(); cdecl; external;
procedure EC_GROUP_get0_seed(); cdecl; external;
procedure EC_GROUP_have_precompute_mult(); cdecl; external;
procedure EC_GROUP_method_of(); cdecl; external;
procedure EC_GROUP_new(); cdecl; external;
procedure EC_GROUP_new_curve_GF2m(); cdecl; external;
procedure EC_GROUP_new_curve_GFp(); cdecl; external;
procedure EC_GROUP_precompute_mult(); cdecl; external;
procedure EC_GROUP_set_asn1_flag(); cdecl; external;
procedure EC_GROUP_set_curve_GF2m(); cdecl; external;
procedure EC_GROUP_set_curve_GFp(); cdecl; external;
procedure EC_GROUP_set_curve_name(); cdecl; external;
procedure EC_GROUP_set_generator(); cdecl; external;
procedure EC_GROUP_set_point_conversion_form(); cdecl; external;
procedure EC_GROUP_set_seed(); cdecl; external;
procedure EC_KEY_clear_flags(); cdecl; external;
procedure EC_KEY_copy(); cdecl; external;
procedure EC_KEY_dup(); cdecl; external;
procedure EC_KEY_get_conv_form(); cdecl; external;
procedure EC_KEY_get_enc_flags(); cdecl; external;
procedure EC_KEY_get_flags(); cdecl; external;
procedure EC_KEY_get_key_method_data(); cdecl; external;
procedure EC_KEY_get0_group(); cdecl; external;
procedure EC_KEY_insert_key_method_data(); cdecl; external;
procedure EC_KEY_precompute_mult(); cdecl; external;
procedure EC_KEY_print(); cdecl; external;
procedure EC_KEY_print_fp(); cdecl; external;
procedure EC_KEY_set_asn1_flag(); cdecl; external;
procedure EC_KEY_set_conv_form(); cdecl; external;
procedure EC_KEY_set_enc_flags(); cdecl; external;
procedure EC_KEY_set_flags(); cdecl; external;
procedure EC_KEY_set_group(); cdecl; external;
procedure EC_KEY_set_private_key(); cdecl; external;
procedure EC_KEY_set_public_key(); cdecl; external;
procedure EC_KEY_set_public_key_affine_coordinates(); cdecl; external;
procedure EC_KEY_up_ref(); cdecl; external;
procedure EC_METHOD_get_field_type(); cdecl; external;
procedure ec_pkey_meth(); cdecl; external;
procedure EC_POINT_add(); cdecl; external;
procedure EC_POINT_bn2point(); cdecl; external;
procedure EC_POINT_clear_free(); cdecl; external;
procedure EC_POINT_cmp(); cdecl; external;
procedure EC_POINT_copy(); cdecl; external;
procedure EC_POINT_dbl(); cdecl; external;
procedure EC_POINT_dup(); cdecl; external;
procedure EC_POINT_get_affine_coordinates_GF2m(); cdecl; external;
procedure EC_POINT_get_affine_coordinates_GFp(); cdecl; external;
procedure EC_POINT_get_Jprojective_coordinates_GFp(); cdecl; external;
procedure EC_POINT_hex2point(); cdecl; external;
procedure EC_POINT_invert(); cdecl; external;
procedure EC_POINT_is_at_infinity(); cdecl; external;
procedure EC_POINT_is_on_curve(); cdecl; external;
procedure EC_POINT_make_affine(); cdecl; external;
procedure EC_POINT_method_of(); cdecl; external;
procedure EC_POINT_oct2point(); cdecl; external;
procedure EC_POINT_point2bn(); cdecl; external;
procedure EC_POINT_point2oct(); cdecl; external;
procedure EC_POINT_set_affine_coordinates_GF2m(); cdecl; external;
procedure EC_POINT_set_affine_coordinates_GFp(); cdecl; external;
procedure EC_POINT_set_compressed_coordinates_GF2m(); cdecl; external;
procedure EC_POINT_set_compressed_coordinates_GFp(); cdecl; external;
procedure EC_POINT_set_Jprojective_coordinates_GFp(); cdecl; external;
procedure EC_POINT_set_to_infinity(); cdecl; external;
procedure EC_POINTs_make_affine(); cdecl; external;
procedure EC_POINTs_mul(); cdecl; external;
procedure ec_precompute_mont_data(); cdecl; external;
procedure EC_PRIVATEKEY_free(); cdecl; external;
procedure EC_PRIVATEKEY_it(); cdecl; external;
procedure EC_PRIVATEKEY_new(); cdecl; external;
procedure EC_version(); cdecl; external;
procedure ec_wNAF_have_precompute_mult(); cdecl; external;
procedure ec_wNAF_mul(); cdecl; external;
procedure ec_wNAF_precompute_mult(); cdecl; external;
procedure ecdh_check(); cdecl; external;
procedure ECDH_compute_key(); cdecl; external;
procedure ECDH_get_default_method(); cdecl; external;
procedure ECDH_get_ex_data(); cdecl; external;
procedure ECDH_get_ex_new_index(); cdecl; external;
procedure ECDH_KDF_X9_62(); cdecl; external;
procedure ECDH_OpenSSL(); cdecl; external;
procedure ECDH_set_default_method(); cdecl; external;
procedure ECDH_set_ex_data(); cdecl; external;
procedure ECDH_set_method(); cdecl; external;
procedure ECDH_version(); cdecl; external;
procedure ecdsa_check(); cdecl; external;
procedure ECDSA_do_sign(); cdecl; external;
procedure ECDSA_do_sign_ex(); cdecl; external;
procedure ECDSA_do_verify(); cdecl; external;
procedure ECDSA_get_default_method(); cdecl; external;
procedure ECDSA_get_ex_data(); cdecl; external;
procedure ECDSA_get_ex_new_index(); cdecl; external;
procedure ECDSA_METHOD_free(); cdecl; external;
procedure ECDSA_METHOD_get_app_data(); cdecl; external;
procedure ECDSA_METHOD_new(); cdecl; external;
procedure ECDSA_METHOD_set_app_data(); cdecl; external;
procedure ECDSA_METHOD_set_flags(); cdecl; external;
procedure ECDSA_METHOD_set_name(); cdecl; external;
procedure ECDSA_METHOD_set_sign(); cdecl; external;
procedure ECDSA_METHOD_set_sign_setup(); cdecl; external;
procedure ECDSA_METHOD_set_verify(); cdecl; external;
procedure ECDSA_OpenSSL(); cdecl; external;
procedure ECDSA_set_default_method(); cdecl; external;
procedure ECDSA_set_ex_data(); cdecl; external;
procedure ECDSA_set_method(); cdecl; external;
procedure ECDSA_SIG_free(); cdecl; external;
procedure ECDSA_SIG_it(); cdecl; external;
procedure ECDSA_SIG_new(); cdecl; external;
procedure ECDSA_sign(); cdecl; external;
procedure ECDSA_sign_ex(); cdecl; external;
procedure ECDSA_sign_setup(); cdecl; external;
procedure ECDSA_size(); cdecl; external;
procedure ECDSA_verify(); cdecl; external;
procedure ECDSA_version(); cdecl; external;
procedure eckey_asn1_meth(); cdecl; external;
procedure ECPARAMETERS_free(); cdecl; external;
procedure ECPARAMETERS_it(); cdecl; external;
procedure ECPARAMETERS_new(); cdecl; external;
procedure ECParameters_print(); cdecl; external;
procedure ECParameters_print_fp(); cdecl; external;
procedure ECPKPARAMETERS_free(); cdecl; external;
procedure ECPKPARAMETERS_it(); cdecl; external;
procedure ECPKPARAMETERS_new(); cdecl; external;
procedure ECPKParameters_print(); cdecl; external;
procedure ECPKParameters_print_fp(); cdecl; external;
procedure EDIPARTYNAME_free(); cdecl; external;
procedure EDIPARTYNAME_it(); cdecl; external;
procedure EDIPARTYNAME_new(); cdecl; external;
procedure ENGINE_add(); cdecl; external;
procedure ENGINE_add_conf_module(); cdecl; external;
procedure ENGINE_by_id(); cdecl; external;
procedure ENGINE_cleanup(); cdecl; external;
procedure engine_cleanup_add_first(); cdecl; external;
procedure engine_cleanup_add_last(); cdecl; external;
procedure ENGINE_cmd_is_executable(); cdecl; external;
procedure ENGINE_ctrl(); cdecl; external;
procedure ENGINE_ctrl_cmd(); cdecl; external;
procedure ENGINE_ctrl_cmd_string(); cdecl; external;
procedure ENGINE_finish(); cdecl; external;
procedure ENGINE_free(); cdecl; external;
procedure engine_free_util(); cdecl; external;
procedure ENGINE_get_cipher(); cdecl; external;
procedure ENGINE_get_cipher_engine(); cdecl; external;
procedure ENGINE_get_ciphers(); cdecl; external;
procedure ENGINE_get_cmd_defns(); cdecl; external;
procedure ENGINE_get_ctrl_function(); cdecl; external;
procedure ENGINE_get_default_DH(); cdecl; external;
procedure ENGINE_get_default_DSA(); cdecl; external;
procedure ENGINE_get_default_ECDH(); cdecl; external;
procedure ENGINE_get_default_ECDSA(); cdecl; external;
procedure ENGINE_get_default_RAND(); cdecl; external;
procedure ENGINE_get_default_RSA(); cdecl; external;
procedure ENGINE_get_destroy_function(); cdecl; external;
procedure ENGINE_get_DH(); cdecl; external;
procedure ENGINE_get_digest(); cdecl; external;
procedure ENGINE_get_digest_engine(); cdecl; external;
procedure ENGINE_get_digests(); cdecl; external;
procedure ENGINE_get_DSA(); cdecl; external;
procedure ENGINE_get_ECDH(); cdecl; external;
procedure ENGINE_get_ECDSA(); cdecl; external;
procedure ENGINE_get_ex_data(); cdecl; external;
procedure ENGINE_get_ex_new_index(); cdecl; external;
procedure ENGINE_get_finish_function(); cdecl; external;
procedure ENGINE_get_first(); cdecl; external;
procedure ENGINE_get_flags(); cdecl; external;
procedure ENGINE_get_id(); cdecl; external;
procedure ENGINE_get_init_function(); cdecl; external;
procedure ENGINE_get_last(); cdecl; external;
procedure ENGINE_get_load_privkey_function(); cdecl; external;
procedure ENGINE_get_load_pubkey_function(); cdecl; external;
procedure ENGINE_get_name(); cdecl; external;
procedure ENGINE_get_next(); cdecl; external;
procedure ENGINE_get_pkey_asn1_meth(); cdecl; external;
procedure ENGINE_get_pkey_asn1_meth_engine(); cdecl; external;
procedure ENGINE_get_pkey_asn1_meth_str(); cdecl; external;
procedure ENGINE_get_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_get_pkey_meth(); cdecl; external;
procedure ENGINE_get_pkey_meth_engine(); cdecl; external;
procedure ENGINE_get_pkey_meths(); cdecl; external;
procedure ENGINE_get_prev(); cdecl; external;
procedure ENGINE_get_RAND(); cdecl; external;
procedure ENGINE_get_RSA(); cdecl; external;
procedure ENGINE_get_ssl_client_cert_function(); cdecl; external;
procedure ENGINE_get_static_state(); cdecl; external;
procedure ENGINE_get_STORE(); cdecl; external;
procedure ENGINE_get_table_flags(); cdecl; external;
procedure ENGINE_init(); cdecl; external;
procedure ENGINE_load_4758cca(); cdecl; external;
procedure ENGINE_load_aep(); cdecl; external;
procedure ENGINE_load_atalla(); cdecl; external;
procedure ENGINE_load_builtin_engines(); cdecl; external;
procedure ENGINE_load_capi(); cdecl; external;
procedure ENGINE_load_chil(); cdecl; external;
procedure ENGINE_load_cryptodev(); cdecl; external;
procedure ENGINE_load_cswift(); cdecl; external;
procedure ENGINE_load_dynamic(); cdecl; external;
procedure ENGINE_load_gost(); cdecl; external;
procedure ENGINE_load_nuron(); cdecl; external;
procedure ENGINE_load_openssl(); cdecl; external;
procedure ENGINE_load_padlock(); cdecl; external;
procedure ENGINE_load_private_key(); cdecl; external;
procedure ENGINE_load_public_key(); cdecl; external;
procedure ENGINE_load_rdrand(); cdecl; external;
procedure ENGINE_load_ssl_client_cert(); cdecl; external;
procedure ENGINE_load_sureware(); cdecl; external;
procedure ENGINE_load_ubsec(); cdecl; external;
procedure ENGINE_new(); cdecl; external;
procedure ENGINE_pkey_asn1_find_str(); cdecl; external;
procedure engine_pkey_asn1_meths_free(); cdecl; external;
procedure engine_pkey_meths_free(); cdecl; external;
procedure ENGINE_register_all_ciphers(); cdecl; external;
procedure ENGINE_register_all_complete(); cdecl; external;
procedure ENGINE_register_all_DH(); cdecl; external;
procedure ENGINE_register_all_digests(); cdecl; external;
procedure ENGINE_register_all_DSA(); cdecl; external;
procedure ENGINE_register_all_ECDH(); cdecl; external;
procedure ENGINE_register_all_ECDSA(); cdecl; external;
procedure ENGINE_register_all_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_register_all_pkey_meths(); cdecl; external;
procedure ENGINE_register_all_RAND(); cdecl; external;
procedure ENGINE_register_all_RSA(); cdecl; external;
procedure ENGINE_register_all_STORE(); cdecl; external;
procedure ENGINE_register_ciphers(); cdecl; external;
procedure ENGINE_register_complete(); cdecl; external;
procedure ENGINE_register_DH(); cdecl; external;
procedure ENGINE_register_digests(); cdecl; external;
procedure ENGINE_register_DSA(); cdecl; external;
procedure ENGINE_register_ECDH(); cdecl; external;
procedure ENGINE_register_ECDSA(); cdecl; external;
procedure ENGINE_register_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_register_pkey_meths(); cdecl; external;
procedure ENGINE_register_RAND(); cdecl; external;
procedure ENGINE_register_RSA(); cdecl; external;
procedure ENGINE_register_STORE(); cdecl; external;
procedure ENGINE_remove(); cdecl; external;
procedure engine_set_all_null(); cdecl; external;
procedure ENGINE_set_ciphers(); cdecl; external;
procedure ENGINE_set_cmd_defns(); cdecl; external;
procedure ENGINE_set_ctrl_function(); cdecl; external;
procedure ENGINE_set_default(); cdecl; external;
procedure ENGINE_set_default_ciphers(); cdecl; external;
procedure ENGINE_set_default_DH(); cdecl; external;
procedure ENGINE_set_default_digests(); cdecl; external;
procedure ENGINE_set_default_DSA(); cdecl; external;
procedure ENGINE_set_default_ECDH(); cdecl; external;
procedure ENGINE_set_default_ECDSA(); cdecl; external;
procedure ENGINE_set_default_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_set_default_pkey_meths(); cdecl; external;
procedure ENGINE_set_default_RAND(); cdecl; external;
procedure ENGINE_set_default_RSA(); cdecl; external;
procedure ENGINE_set_default_string(); cdecl; external;
procedure ENGINE_set_destroy_function(); cdecl; external;
procedure ENGINE_set_DH(); cdecl; external;
procedure ENGINE_set_digests(); cdecl; external;
procedure ENGINE_set_DSA(); cdecl; external;
procedure ENGINE_set_ECDH(); cdecl; external;
procedure ENGINE_set_ECDSA(); cdecl; external;
procedure ENGINE_set_ex_data(); cdecl; external;
procedure ENGINE_set_finish_function(); cdecl; external;
procedure ENGINE_set_flags(); cdecl; external;
procedure ENGINE_set_id(); cdecl; external;
procedure ENGINE_set_init_function(); cdecl; external;
procedure ENGINE_set_load_privkey_function(); cdecl; external;
procedure ENGINE_set_load_pubkey_function(); cdecl; external;
procedure ENGINE_set_load_ssl_client_cert_function(); cdecl; external;
procedure ENGINE_set_name(); cdecl; external;
procedure ENGINE_set_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_set_pkey_meths(); cdecl; external;
procedure ENGINE_set_RAND(); cdecl; external;
procedure ENGINE_set_RSA(); cdecl; external;
procedure ENGINE_set_STORE(); cdecl; external;
procedure ENGINE_set_table_flags(); cdecl; external;
procedure engine_table_cleanup(); cdecl; external;
procedure engine_table_doall(); cdecl; external;
procedure engine_table_register(); cdecl; external;
procedure engine_table_select(); cdecl; external;
procedure engine_table_unregister(); cdecl; external;
procedure engine_unlocked_finish(); cdecl; external;
procedure engine_unlocked_init(); cdecl; external;
procedure ENGINE_unregister_ciphers(); cdecl; external;
procedure ENGINE_unregister_DH(); cdecl; external;
procedure ENGINE_unregister_digests(); cdecl; external;
procedure ENGINE_unregister_DSA(); cdecl; external;
procedure ENGINE_unregister_ECDH(); cdecl; external;
procedure ENGINE_unregister_ECDSA(); cdecl; external;
procedure ENGINE_unregister_pkey_asn1_meths(); cdecl; external;
procedure ENGINE_unregister_pkey_meths(); cdecl; external;
procedure ENGINE_unregister_RAND(); cdecl; external;
procedure ENGINE_unregister_RSA(); cdecl; external;
procedure ENGINE_unregister_STORE(); cdecl; external;
procedure ENGINE_up_ref(); cdecl; external;
procedure ERR_add_error_data(); cdecl; external;
procedure ERR_add_error_vdata(); cdecl; external;
procedure ERR_clear_error(); cdecl; external;
procedure ERR_error_string(); cdecl; external;
procedure ERR_error_string_n(); cdecl; external;
procedure ERR_free_strings(); cdecl; external;
procedure ERR_func_error_string(); cdecl; external;
procedure ERR_get_err_state_table(); cdecl; external;
procedure ERR_get_error(); cdecl; external;
procedure ERR_get_error_line(); cdecl; external;
procedure ERR_get_error_line_data(); cdecl; external;
procedure ERR_get_implementation(); cdecl; external;
procedure ERR_get_next_error_library(); cdecl; external;
procedure ERR_get_state(); cdecl; external;
procedure ERR_get_string_table(); cdecl; external;
procedure ERR_GOST_error(); cdecl; external;
procedure ERR_lib_error_string(); cdecl; external;
procedure ERR_load_ASN1_strings(); cdecl; external;
procedure ERR_load_BIO_strings(); cdecl; external;
procedure ERR_load_BN_strings(); cdecl; external;
procedure ERR_load_BUF_strings(); cdecl; external;
procedure ERR_load_CMS_strings(); cdecl; external;
procedure ERR_load_COMP_strings(); cdecl; external;
procedure ERR_load_CONF_strings(); cdecl; external;
procedure ERR_load_CRYPTO_strings(); cdecl; external;
procedure ERR_load_DH_strings(); cdecl; external;
procedure ERR_load_DSA_strings(); cdecl; external;
procedure ERR_load_DSO_strings(); cdecl; external;
procedure ERR_load_EC_strings(); cdecl; external;
procedure ERR_load_ECDH_strings(); cdecl; external;
procedure ERR_load_ECDSA_strings(); cdecl; external;
procedure ERR_load_ENGINE_strings(); cdecl; external;
procedure ERR_load_ERR_strings(); cdecl; external;
procedure ERR_load_EVP_strings(); cdecl; external;
procedure ERR_load_GOST_strings(); cdecl; external;
procedure ERR_load_OBJ_strings(); cdecl; external;
procedure ERR_load_OCSP_strings(); cdecl; external;
procedure ERR_load_PEM_strings(); cdecl; external;
procedure ERR_load_PKCS12_strings(); cdecl; external;
procedure ERR_load_PKCS7_strings(); cdecl; external;
procedure ERR_load_RAND_strings(); cdecl; external;
procedure ERR_load_RSA_strings(); cdecl; external;
procedure ERR_load_SSL_strings(); cdecl; external;
procedure ERR_load_strings(); cdecl; external;
procedure ERR_load_TS_strings(); cdecl; external;
procedure ERR_load_UI_strings(); cdecl; external;
procedure ERR_load_X509_strings(); cdecl; external;
procedure ERR_load_X509V3_strings(); cdecl; external;
procedure ERR_peek_error(); cdecl; external;
procedure ERR_peek_error_line(); cdecl; external;
procedure ERR_peek_error_line_data(); cdecl; external;
procedure ERR_peek_last_error(); cdecl; external;
procedure ERR_peek_last_error_line(); cdecl; external;
procedure ERR_peek_last_error_line_data(); cdecl; external;
procedure ERR_pop_to_mark(); cdecl; external;
procedure ERR_print_errors(); cdecl; external;
procedure ERR_print_errors_cb(); cdecl; external;
procedure ERR_print_errors_fp(); cdecl; external;
procedure ERR_put_error(); cdecl; external;
procedure ERR_reason_error_string(); cdecl; external;
procedure ERR_release_err_state_table(); cdecl; external;
procedure ERR_remove_state(); cdecl; external;
procedure ERR_remove_thread_state(); cdecl; external;
procedure ERR_set_error_data(); cdecl; external;
procedure ERR_set_implementation(); cdecl; external;
procedure ERR_set_mark(); cdecl; external;
procedure ERR_unload_GOST_strings(); cdecl; external;
procedure ERR_unload_strings(); cdecl; external;
procedure ESS_CERT_ID_dup(); cdecl; external;
procedure ESS_CERT_ID_free(); cdecl; external;
procedure ESS_CERT_ID_it(); cdecl; external;
procedure ESS_CERT_ID_new(); cdecl; external;
procedure ESS_ISSUER_SERIAL_dup(); cdecl; external;
procedure ESS_ISSUER_SERIAL_free(); cdecl; external;
procedure ESS_ISSUER_SERIAL_it(); cdecl; external;
procedure ESS_ISSUER_SERIAL_new(); cdecl; external;
procedure ESS_SIGNING_CERT_dup(); cdecl; external;
procedure ESS_SIGNING_CERT_free(); cdecl; external;
procedure ESS_SIGNING_CERT_it(); cdecl; external;
procedure ESS_SIGNING_CERT_new(); cdecl; external;
procedure EVP_add_alg_module(); cdecl; external;
procedure EVP_add_cipher(); cdecl; external;
procedure EVP_add_digest(); cdecl; external;
procedure EVP_aes_128_cbc(); cdecl; external;
procedure EVP_aes_128_cbc_hmac_sha1(); cdecl; external;
procedure EVP_aes_128_cbc_hmac_sha256(); cdecl; external;
procedure EVP_aes_128_ccm(); cdecl; external;
procedure EVP_aes_128_cfb(); cdecl; external;
procedure EVP_aes_128_cfb1(); cdecl; external;
procedure EVP_aes_128_cfb128(); cdecl; external;
procedure EVP_aes_128_cfb8(); cdecl; external;
procedure EVP_aes_128_ctr(); cdecl; external;
procedure EVP_aes_128_ecb(); cdecl; external;
procedure EVP_aes_128_gcm(); cdecl; external;
procedure EVP_aes_128_ofb(); cdecl; external;
procedure EVP_aes_128_wrap(); cdecl; external;
procedure EVP_aes_128_xts(); cdecl; external;
procedure EVP_aes_192_cbc(); cdecl; external;
procedure EVP_aes_192_ccm(); cdecl; external;
procedure EVP_aes_192_cfb(); cdecl; external;
procedure EVP_aes_192_cfb1(); cdecl; external;
procedure EVP_aes_192_cfb128(); cdecl; external;
procedure EVP_aes_192_cfb8(); cdecl; external;
procedure EVP_aes_192_ctr(); cdecl; external;
procedure EVP_aes_192_ecb(); cdecl; external;
procedure EVP_aes_192_gcm(); cdecl; external;
procedure EVP_aes_192_ofb(); cdecl; external;
procedure EVP_aes_192_wrap(); cdecl; external;
procedure EVP_aes_256_cbc(); cdecl; external;
procedure EVP_aes_256_cbc_hmac_sha1(); cdecl; external;
procedure EVP_aes_256_cbc_hmac_sha256(); cdecl; external;
procedure EVP_aes_256_ccm(); cdecl; external;
procedure EVP_aes_256_cfb(); cdecl; external;
procedure EVP_aes_256_cfb1(); cdecl; external;
procedure EVP_aes_256_cfb128(); cdecl; external;
procedure EVP_aes_256_cfb8(); cdecl; external;
procedure EVP_aes_256_ctr(); cdecl; external;
procedure EVP_aes_256_ecb(); cdecl; external;
procedure EVP_aes_256_gcm(); cdecl; external;
procedure EVP_aes_256_ofb(); cdecl; external;
procedure EVP_aes_256_wrap(); cdecl; external;
procedure EVP_aes_256_xts(); cdecl; external;
procedure EVP_bf_cbc(); cdecl; external;
procedure EVP_bf_cfb(); cdecl; external;
procedure EVP_bf_cfb64(); cdecl; external;
procedure EVP_bf_ecb(); cdecl; external;
procedure EVP_bf_ofb(); cdecl; external;
procedure EVP_BytesToKey(); cdecl; external;
procedure EVP_camellia_128_cbc(); cdecl; external;
procedure EVP_camellia_128_cfb1(); cdecl; external;
procedure EVP_camellia_128_cfb128(); cdecl; external;
procedure EVP_camellia_128_cfb8(); cdecl; external;
procedure EVP_camellia_128_ecb(); cdecl; external;
procedure EVP_camellia_128_ofb(); cdecl; external;
procedure EVP_camellia_192_cbc(); cdecl; external;
procedure EVP_camellia_192_cfb1(); cdecl; external;
procedure EVP_camellia_192_cfb128(); cdecl; external;
procedure EVP_camellia_192_cfb8(); cdecl; external;
procedure EVP_camellia_192_ecb(); cdecl; external;
procedure EVP_camellia_192_ofb(); cdecl; external;
procedure EVP_camellia_256_cbc(); cdecl; external;
procedure EVP_camellia_256_cfb1(); cdecl; external;
procedure EVP_camellia_256_cfb128(); cdecl; external;
procedure EVP_camellia_256_cfb8(); cdecl; external;
procedure EVP_camellia_256_ecb(); cdecl; external;
procedure EVP_camellia_256_ofb(); cdecl; external;
procedure EVP_cast5_cbc(); cdecl; external;
procedure EVP_cast5_cfb(); cdecl; external;
procedure EVP_cast5_cfb64(); cdecl; external;
procedure EVP_cast5_ecb(); cdecl; external;
procedure EVP_cast5_ofb(); cdecl; external;
procedure EVP_Cipher(); cdecl; external;
procedure EVP_CIPHER_asn1_to_param(); cdecl; external;
procedure EVP_CIPHER_block_size(); cdecl; external;
procedure EVP_CIPHER_CTX_block_size(); cdecl; external;
procedure EVP_CIPHER_CTX_cipher(); cdecl; external;
procedure EVP_CIPHER_CTX_cleanup(); cdecl; external;
procedure EVP_CIPHER_CTX_clear_flags(); cdecl; external;
procedure EVP_CIPHER_CTX_copy(); cdecl; external;
procedure EVP_CIPHER_CTX_ctrl(); cdecl; external;
procedure EVP_CIPHER_CTX_flags(); cdecl; external;
procedure EVP_CIPHER_CTX_free(); cdecl; external;
procedure EVP_CIPHER_CTX_get_app_data(); cdecl; external;
procedure EVP_CIPHER_CTX_init(); cdecl; external;
procedure EVP_CIPHER_CTX_iv_length(); cdecl; external;
procedure EVP_CIPHER_CTX_key_length(); cdecl; external;
procedure EVP_CIPHER_CTX_new(); cdecl; external;
procedure EVP_CIPHER_CTX_nid(); cdecl; external;
procedure EVP_CIPHER_CTX_rand_key(); cdecl; external;
procedure EVP_CIPHER_CTX_set_app_data(); cdecl; external;
procedure EVP_CIPHER_CTX_set_flags(); cdecl; external;
procedure EVP_CIPHER_CTX_set_key_length(); cdecl; external;
procedure EVP_CIPHER_CTX_set_padding(); cdecl; external;
procedure EVP_CIPHER_CTX_test_flags(); cdecl; external;
procedure EVP_CIPHER_do_all(); cdecl; external;
procedure EVP_CIPHER_do_all_sorted(); cdecl; external;
procedure EVP_CIPHER_flags(); cdecl; external;
procedure EVP_CIPHER_get_asn1_iv(); cdecl; external;
procedure EVP_CIPHER_iv_length(); cdecl; external;
procedure EVP_CIPHER_key_length(); cdecl; external;
procedure EVP_CIPHER_nid(); cdecl; external;
procedure EVP_CIPHER_param_to_asn1(); cdecl; external;
procedure EVP_CIPHER_set_asn1_iv(); cdecl; external;
procedure EVP_CIPHER_type(); cdecl; external;
procedure EVP_CipherFinal(); cdecl; external;
procedure EVP_CipherFinal_ex(); cdecl; external;
procedure EVP_CipherInit(); cdecl; external;
procedure EVP_CipherInit_ex(); cdecl; external;
procedure EVP_CipherUpdate(); cdecl; external;
procedure EVP_cleanup(); cdecl; external;
procedure EVP_DecodeBlock(); cdecl; external;
procedure EVP_DecodeFinal(); cdecl; external;
procedure EVP_DecodeInit(); cdecl; external;
procedure EVP_DecodeUpdate(); cdecl; external;
procedure EVP_DecryptFinal(); cdecl; external;
procedure EVP_DecryptFinal_ex(); cdecl; external;
procedure EVP_DecryptInit(); cdecl; external;
procedure EVP_DecryptInit_ex(); cdecl; external;
procedure EVP_DecryptUpdate(); cdecl; external;
procedure EVP_des_cbc(); cdecl; external;
procedure EVP_des_cfb(); cdecl; external;
procedure EVP_des_cfb1(); cdecl; external;
procedure EVP_des_cfb64(); cdecl; external;
procedure EVP_des_cfb8(); cdecl; external;
procedure EVP_des_ecb(); cdecl; external;
procedure EVP_des_ede(); cdecl; external;
procedure EVP_des_ede_cbc(); cdecl; external;
procedure EVP_des_ede_cfb(); cdecl; external;
procedure EVP_des_ede_cfb64(); cdecl; external;
procedure EVP_des_ede_ecb(); cdecl; external;
procedure EVP_des_ede_ofb(); cdecl; external;
procedure EVP_des_ede3(); cdecl; external;
procedure EVP_des_ede3_cbc(); cdecl; external;
procedure EVP_des_ede3_cfb(); cdecl; external;
procedure EVP_des_ede3_cfb1(); cdecl; external;
procedure EVP_des_ede3_cfb64(); cdecl; external;
procedure EVP_des_ede3_cfb8(); cdecl; external;
procedure EVP_des_ede3_ecb(); cdecl; external;
procedure EVP_des_ede3_ofb(); cdecl; external;
procedure EVP_des_ede3_wrap(); cdecl; external;
procedure EVP_des_ofb(); cdecl; external;
procedure EVP_desx_cbc(); cdecl; external;
procedure EVP_Digest(); cdecl; external;
procedure EVP_DigestFinal(); cdecl; external;
procedure EVP_DigestFinal_ex(); cdecl; external;
procedure EVP_DigestInit(); cdecl; external;
procedure EVP_DigestInit_ex(); cdecl; external;
procedure EVP_DigestSignFinal(); cdecl; external;
procedure EVP_DigestSignInit(); cdecl; external;
procedure EVP_DigestUpdate(); cdecl; external;
procedure EVP_DigestVerifyFinal(); cdecl; external;
procedure EVP_DigestVerifyInit(); cdecl; external;
procedure EVP_dss(); cdecl; external;
procedure EVP_dss1(); cdecl; external;
procedure EVP_ecdsa(); cdecl; external;
procedure EVP_enc_null(); cdecl; external;
procedure EVP_EncodeBlock(); cdecl; external;
procedure EVP_EncodeFinal(); cdecl; external;
procedure EVP_EncodeInit(); cdecl; external;
procedure EVP_EncodeUpdate(); cdecl; external;
procedure EVP_EncryptFinal(); cdecl; external;
procedure EVP_EncryptFinal_ex(); cdecl; external;
procedure EVP_EncryptInit(); cdecl; external;
procedure EVP_EncryptInit_ex(); cdecl; external;
procedure EVP_EncryptUpdate(); cdecl; external;
procedure EVP_get_cipherbyname(); cdecl; external;
procedure EVP_get_digestbyname(); cdecl; external;
procedure EVP_get_pw_prompt(); cdecl; external;
procedure EVP_idea_cbc(); cdecl; external;
procedure EVP_idea_cfb(); cdecl; external;
procedure EVP_idea_cfb64(); cdecl; external;
procedure EVP_idea_ecb(); cdecl; external;
procedure EVP_idea_ofb(); cdecl; external;
procedure EVP_MD_block_size(); cdecl; external;
procedure EVP_MD_CTX_cleanup(); cdecl; external;
procedure EVP_MD_CTX_clear_flags(); cdecl; external;
procedure EVP_MD_CTX_copy(); cdecl; external;
procedure EVP_MD_CTX_copy_ex(); cdecl; external;
procedure EVP_MD_CTX_create(); cdecl; external;
procedure EVP_MD_CTX_destroy(); cdecl; external;
procedure EVP_MD_CTX_init(); cdecl; external;
procedure EVP_MD_CTX_md(); cdecl; external;
procedure EVP_MD_CTX_set_flags(); cdecl; external;
procedure EVP_MD_CTX_test_flags(); cdecl; external;
procedure EVP_MD_do_all(); cdecl; external;
procedure EVP_MD_do_all_sorted(); cdecl; external;
procedure EVP_MD_flags(); cdecl; external;
procedure EVP_md_null(); cdecl; external;
procedure EVP_MD_pkey_type(); cdecl; external;
procedure EVP_MD_size(); cdecl; external;
procedure EVP_MD_type(); cdecl; external;
procedure EVP_md4(); cdecl; external;
procedure EVP_md5(); cdecl; external;
procedure EVP_mdc2(); cdecl; external;
procedure EVP_OpenFinal(); cdecl; external;
procedure EVP_OpenInit(); cdecl; external;
procedure EVP_PBE_alg_add(); cdecl; external;
procedure EVP_PBE_alg_add_type(); cdecl; external;
procedure EVP_PBE_CipherInit(); cdecl; external;
procedure EVP_PBE_cleanup(); cdecl; external;
procedure EVP_PBE_find(); cdecl; external;
procedure EVP_PKCS82PKEY(); cdecl; external;
procedure EVP_PKEY_add1_attr(); cdecl; external;
procedure EVP_PKEY_add1_attr_by_NID(); cdecl; external;
procedure EVP_PKEY_add1_attr_by_OBJ(); cdecl; external;
procedure EVP_PKEY_add1_attr_by_txt(); cdecl; external;
procedure EVP_PKEY_asn1_add_alias(); cdecl; external;
procedure EVP_PKEY_asn1_add0(); cdecl; external;
procedure EVP_PKEY_asn1_copy(); cdecl; external;
procedure EVP_PKEY_asn1_find(); cdecl; external;
procedure EVP_PKEY_asn1_find_str(); cdecl; external;
procedure EVP_PKEY_asn1_free(); cdecl; external;
procedure EVP_PKEY_asn1_get_count(); cdecl; external;
procedure EVP_PKEY_asn1_get0(); cdecl; external;
procedure EVP_PKEY_asn1_get0_info(); cdecl; external;
procedure EVP_PKEY_asn1_new(); cdecl; external;
procedure EVP_PKEY_asn1_set_ctrl(); cdecl; external;
procedure EVP_PKEY_asn1_set_free(); cdecl; external;
procedure EVP_PKEY_asn1_set_item(); cdecl; external;
procedure EVP_PKEY_asn1_set_param(); cdecl; external;
procedure EVP_PKEY_asn1_set_private(); cdecl; external;
procedure EVP_PKEY_asn1_set_public(); cdecl; external;
procedure EVP_PKEY_assign(); cdecl; external;
procedure EVP_PKEY_base_id(); cdecl; external;
procedure EVP_PKEY_bits(); cdecl; external;
procedure EVP_PKEY_cmp(); cdecl; external;
procedure EVP_PKEY_cmp_parameters(); cdecl; external;
procedure EVP_PKEY_copy_parameters(); cdecl; external;
procedure EVP_PKEY_CTX_ctrl(); cdecl; external;
procedure EVP_PKEY_CTX_ctrl_str(); cdecl; external;
procedure EVP_PKEY_CTX_dup(); cdecl; external;
procedure EVP_PKEY_CTX_free(); cdecl; external;
procedure EVP_PKEY_CTX_get_app_data(); cdecl; external;
procedure EVP_PKEY_CTX_get_cb(); cdecl; external;
procedure EVP_PKEY_CTX_get_data(); cdecl; external;
procedure EVP_PKEY_CTX_get_keygen_info(); cdecl; external;
procedure EVP_PKEY_CTX_get_operation(); cdecl; external;
procedure EVP_PKEY_CTX_get0_peerkey(); cdecl; external;
procedure EVP_PKEY_CTX_get0_pkey(); cdecl; external;
procedure EVP_PKEY_CTX_new(); cdecl; external;
procedure EVP_PKEY_CTX_new_id(); cdecl; external;
procedure EVP_PKEY_CTX_set_app_data(); cdecl; external;
procedure EVP_PKEY_CTX_set_cb(); cdecl; external;
procedure EVP_PKEY_CTX_set_data(); cdecl; external;
procedure EVP_PKEY_CTX_set0_keygen_info(); cdecl; external;
procedure EVP_PKEY_decrypt(); cdecl; external;
procedure EVP_PKEY_decrypt_init(); cdecl; external;
procedure EVP_PKEY_decrypt_old(); cdecl; external;
procedure EVP_PKEY_delete_attr(); cdecl; external;
procedure EVP_PKEY_derive(); cdecl; external;
procedure EVP_PKEY_derive_init(); cdecl; external;
procedure EVP_PKEY_derive_set_peer(); cdecl; external;
procedure EVP_PKEY_encrypt(); cdecl; external;
procedure EVP_PKEY_encrypt_init(); cdecl; external;
procedure EVP_PKEY_encrypt_old(); cdecl; external;
procedure EVP_PKEY_free(); cdecl; external;
procedure EVP_PKEY_get_attr(); cdecl; external;
procedure EVP_PKEY_get_attr_by_NID(); cdecl; external;
procedure EVP_PKEY_get_attr_by_OBJ(); cdecl; external;
procedure EVP_PKEY_get_attr_count(); cdecl; external;
procedure EVP_PKEY_get_default_digest_nid(); cdecl; external;
procedure EVP_PKEY_get0(); cdecl; external;
procedure EVP_PKEY_get0_asn1(); cdecl; external;
procedure EVP_PKEY_get1_DH(); cdecl; external;
procedure EVP_PKEY_get1_DSA(); cdecl; external;
procedure EVP_PKEY_get1_EC_KEY(); cdecl; external;
procedure EVP_PKEY_get1_RSA(); cdecl; external;
procedure EVP_PKEY_id(); cdecl; external;
procedure EVP_PKEY_keygen(); cdecl; external;
procedure EVP_PKEY_keygen_init(); cdecl; external;
procedure EVP_PKEY_meth_add0(); cdecl; external;
procedure EVP_PKEY_meth_copy(); cdecl; external;
procedure EVP_PKEY_meth_find(); cdecl; external;
procedure EVP_PKEY_meth_free(); cdecl; external;
procedure EVP_PKEY_meth_get0_info(); cdecl; external;
procedure EVP_PKEY_meth_new(); cdecl; external;
procedure EVP_PKEY_meth_set_cleanup(); cdecl; external;
procedure EVP_PKEY_meth_set_copy(); cdecl; external;
procedure EVP_PKEY_meth_set_ctrl(); cdecl; external;
procedure EVP_PKEY_meth_set_decrypt(); cdecl; external;
procedure EVP_PKEY_meth_set_derive(); cdecl; external;
procedure EVP_PKEY_meth_set_encrypt(); cdecl; external;
procedure EVP_PKEY_meth_set_init(); cdecl; external;
procedure EVP_PKEY_meth_set_keygen(); cdecl; external;
procedure EVP_PKEY_meth_set_paramgen(); cdecl; external;
procedure EVP_PKEY_meth_set_sign(); cdecl; external;
procedure EVP_PKEY_meth_set_signctx(); cdecl; external;
procedure EVP_PKEY_meth_set_verify(); cdecl; external;
procedure EVP_PKEY_meth_set_verify_recover(); cdecl; external;
procedure EVP_PKEY_meth_set_verifyctx(); cdecl; external;
procedure EVP_PKEY_missing_parameters(); cdecl; external;
procedure EVP_PKEY_new(); cdecl; external;
procedure EVP_PKEY_new_mac_key(); cdecl; external;
procedure EVP_PKEY_paramgen(); cdecl; external;
procedure EVP_PKEY_paramgen_init(); cdecl; external;
procedure EVP_PKEY_print_params(); cdecl; external;
procedure EVP_PKEY_print_private(); cdecl; external;
procedure EVP_PKEY_print_public(); cdecl; external;
procedure EVP_PKEY_save_parameters(); cdecl; external;
procedure evp_pkey_set_cb_translate(); cdecl; external;
procedure EVP_PKEY_set_type(); cdecl; external;
procedure EVP_PKEY_set_type_str(); cdecl; external;
procedure EVP_PKEY_set1_DH(); cdecl; external;
procedure EVP_PKEY_set1_DSA(); cdecl; external;
procedure EVP_PKEY_set1_EC_KEY(); cdecl; external;
procedure EVP_PKEY_set1_RSA(); cdecl; external;
procedure EVP_PKEY_sign(); cdecl; external;
procedure EVP_PKEY_sign_init(); cdecl; external;
procedure EVP_PKEY_size(); cdecl; external;
procedure EVP_PKEY_type(); cdecl; external;
procedure EVP_PKEY_verify(); cdecl; external;
procedure EVP_PKEY_verify_init(); cdecl; external;
procedure EVP_PKEY_verify_recover(); cdecl; external;
procedure EVP_PKEY_verify_recover_init(); cdecl; external;
procedure EVP_PKEY2PKCS8(); cdecl; external;
procedure EVP_PKEY2PKCS8_broken(); cdecl; external;
procedure EVP_rc2_40_cbc(); cdecl; external;
procedure EVP_rc2_64_cbc(); cdecl; external;
procedure EVP_rc2_cbc(); cdecl; external;
procedure EVP_rc2_cfb(); cdecl; external;
procedure EVP_rc2_cfb64(); cdecl; external;
procedure EVP_rc2_ecb(); cdecl; external;
procedure EVP_rc2_ofb(); cdecl; external;
procedure EVP_rc4(); cdecl; external;
procedure EVP_rc4_40(); cdecl; external;
procedure EVP_rc4_hmac_md5(); cdecl; external;
procedure EVP_read_pw_string(); cdecl; external;
procedure EVP_read_pw_string_min(); cdecl; external;
procedure EVP_ripemd160(); cdecl; external;
procedure EVP_SealFinal(); cdecl; external;
procedure EVP_SealInit(); cdecl; external;
procedure EVP_seed_cbc(); cdecl; external;
procedure EVP_seed_cfb128(); cdecl; external;
procedure EVP_seed_ecb(); cdecl; external;
procedure EVP_seed_ofb(); cdecl; external;
procedure EVP_set_pw_prompt(); cdecl; external;
procedure EVP_sha(); cdecl; external;
procedure EVP_sha1(); cdecl; external;
procedure EVP_sha224(); cdecl; external;
procedure EVP_sha256(); cdecl; external;
procedure EVP_sha384(); cdecl; external;
procedure EVP_sha512(); cdecl; external;
procedure EVP_SignFinal(); cdecl; external;
procedure EVP_VerifyFinal(); cdecl; external;
procedure EVP_version(); cdecl; external;
procedure EVP_whirlpool(); cdecl; external;
procedure EXTENDED_KEY_USAGE_free(); cdecl; external;
procedure EXTENDED_KEY_USAGE_it(); cdecl; external;
procedure EXTENDED_KEY_USAGE_new(); cdecl; external;
procedure fcrypt_body(); cdecl; external;
procedure fill_GOST2001_params(); cdecl; external;
procedure fill_GOST94_params(); cdecl; external;
procedure finish_hash(); cdecl; external;
procedure FIPS_mode(); cdecl; external;
procedure FIPS_mode_set(); cdecl; external;
procedure gai_strerrorA(); cdecl; external;
procedure gai_strerrorW(); cdecl; external;
procedure GENERAL_NAME_cmp(); cdecl; external;
procedure GENERAL_NAME_dup(); cdecl; external;
procedure GENERAL_NAME_free(); cdecl; external;
procedure GENERAL_NAME_get0_otherName(); cdecl; external;
procedure GENERAL_NAME_get0_value(); cdecl; external;
procedure GENERAL_NAME_it(); cdecl; external;
procedure GENERAL_NAME_new(); cdecl; external;
procedure GENERAL_NAME_print(); cdecl; external;
procedure GENERAL_NAME_set0_othername(); cdecl; external;
procedure GENERAL_NAME_set0_value(); cdecl; external;
procedure GENERAL_NAMES_free(); cdecl; external;
procedure GENERAL_NAMES_it(); cdecl; external;
procedure GENERAL_NAMES_new(); cdecl; external;
procedure GENERAL_SUBTREE_free(); cdecl; external;
procedure GENERAL_SUBTREE_it(); cdecl; external;
procedure GENERAL_SUBTREE_new(); cdecl; external;
procedure get_encryption_params(); cdecl; external;
procedure get_gost_engine_param(); cdecl; external;
procedure get_mac(); cdecl; external;
procedure get_rfc2409_prime_1024(); cdecl; external;
procedure get_rfc2409_prime_768(); cdecl; external;
procedure get_rfc3526_prime_1536(); cdecl; external;
procedure get_rfc3526_prime_2048(); cdecl; external;
procedure get_rfc3526_prime_3072(); cdecl; external;
procedure get_rfc3526_prime_4096(); cdecl; external;
procedure get_rfc3526_prime_6144(); cdecl; external;
procedure get_rfc3526_prime_8192(); cdecl; external;
procedure getbnfrombuf(); cdecl; external;
procedure getipv4sourcefilter(); cdecl; external;
procedure getsourcefilter(); cdecl; external;
procedure gost_cipher_list(); cdecl; external;
procedure GOST_CIPHER_PARAMS_free(); cdecl; external;
procedure GOST_CIPHER_PARAMS_it(); cdecl; external;
procedure GOST_CIPHER_PARAMS_new(); cdecl; external;
procedure GOST_CLIENT_KEY_EXCHANGE_PARAMS_free(); cdecl; external;
procedure GOST_CLIENT_KEY_EXCHANGE_PARAMS_it(); cdecl; external;
procedure GOST_CLIENT_KEY_EXCHANGE_PARAMS_new(); cdecl; external;
procedure gost_cmds(); cdecl; external;
procedure gost_control_func(); cdecl; external;
procedure gost_dec(); cdecl; external;
procedure gost_dec_cfb(); cdecl; external;
procedure gost_destroy(); cdecl; external;
procedure gost_do_sign(); cdecl; external;
procedure gost_do_verify(); cdecl; external;
procedure gost_enc(); cdecl; external;
procedure gost_enc_cfb(); cdecl; external;
procedure gost_enc_with_key(); cdecl; external;
procedure gost_get_key(); cdecl; external;
procedure gost_get0_priv_key(); cdecl; external;
procedure gost_init(); cdecl; external;
procedure gost_key(); cdecl; external;
procedure GOST_KEY_AGREEMENT_INFO_free(); cdecl; external;
procedure GOST_KEY_AGREEMENT_INFO_it(); cdecl; external;
procedure GOST_KEY_AGREEMENT_INFO_new(); cdecl; external;
procedure GOST_KEY_INFO_free(); cdecl; external;
procedure GOST_KEY_INFO_it(); cdecl; external;
procedure GOST_KEY_INFO_new(); cdecl; external;
procedure GOST_KEY_PARAMS_free(); cdecl; external;
procedure GOST_KEY_PARAMS_it(); cdecl; external;
procedure GOST_KEY_PARAMS_new(); cdecl; external;
procedure GOST_KEY_TRANSPORT_free(); cdecl; external;
procedure GOST_KEY_TRANSPORT_it(); cdecl; external;
procedure GOST_KEY_TRANSPORT_new(); cdecl; external;
procedure gost_mac(); cdecl; external;
procedure gost_mac_iv(); cdecl; external;
procedure gost_param_free(); cdecl; external;
procedure gost_set_default_param(); cdecl; external;
procedure gost_sign_keygen(); cdecl; external;
procedure gost2001_compute_public(); cdecl; external;
procedure gost2001_do_sign(); cdecl; external;
procedure gost2001_do_verify(); cdecl; external;
procedure gost2001_keygen(); cdecl; external;
procedure Gost28147_CryptoProParamSetA(); cdecl; external;
procedure Gost28147_CryptoProParamSetB(); cdecl; external;
procedure Gost28147_CryptoProParamSetC(); cdecl; external;
procedure Gost28147_CryptoProParamSetD(); cdecl; external;
procedure Gost28147_TestParamSet(); cdecl; external;
procedure gost94_compute_public(); cdecl; external;
procedure gost94_nid_by_params(); cdecl; external;
procedure gostcrypt(); cdecl; external;
procedure gostdecrypt(); cdecl; external;
procedure GostR3411_94_CryptoProParamSet(); cdecl; external;
procedure GostR3411_94_TestParamSet(); cdecl; external;
procedure hash_block(); cdecl; external;
procedure hashsum2bn(); cdecl; external;
procedure hex_to_string(); cdecl; external;
procedure HMAC(); cdecl; external;
procedure hmac_asn1_meth(); cdecl; external;
procedure HMAC_CTX_cleanup(); cdecl; external;
procedure HMAC_CTX_copy(); cdecl; external;
procedure HMAC_CTX_init(); cdecl; external;
procedure HMAC_CTX_set_flags(); cdecl; external;
procedure HMAC_Final(); cdecl; external;
procedure HMAC_Init(); cdecl; external;
procedure HMAC_Init_ex(); cdecl; external;
procedure hmac_pkey_meth(); cdecl; external;
procedure HMAC_Update(); cdecl; external;
procedure i2a_ACCESS_DESCRIPTION(); cdecl; external;
procedure i2a_ASN1_ENUMERATED(); cdecl; external;
procedure i2a_ASN1_INTEGER(); cdecl; external;
procedure i2a_ASN1_OBJECT(); cdecl; external;
procedure i2a_ASN1_STRING(); cdecl; external;
procedure i2b_PrivateKey_bio(); cdecl; external;
procedure i2b_PublicKey_bio(); cdecl; external;
procedure i2b_PVK_bio(); cdecl; external;
procedure i2c_ASN1_BIT_STRING(); cdecl; external;
procedure i2c_ASN1_INTEGER(); cdecl; external;
procedure i2d_ACCESS_DESCRIPTION(); cdecl; external;
procedure i2d_ASN1_bio_stream(); cdecl; external;
procedure i2d_ASN1_BIT_STRING(); cdecl; external;
procedure i2d_ASN1_BMPSTRING(); cdecl; external;
procedure i2d_ASN1_BOOLEAN(); cdecl; external;
procedure i2d_ASN1_bytes(); cdecl; external;
procedure i2d_ASN1_ENUMERATED(); cdecl; external;
procedure i2d_ASN1_GENERALIZEDTIME(); cdecl; external;
procedure i2d_ASN1_GENERALSTRING(); cdecl; external;
procedure i2d_ASN1_IA5STRING(); cdecl; external;
procedure i2d_ASN1_INTEGER(); cdecl; external;
procedure i2d_ASN1_NULL(); cdecl; external;
procedure i2d_ASN1_OBJECT(); cdecl; external;
procedure i2d_ASN1_OCTET_STRING(); cdecl; external;
procedure i2d_ASN1_PRINTABLE(); cdecl; external;
procedure i2d_ASN1_PRINTABLESTRING(); cdecl; external;
procedure i2d_ASN1_SEQUENCE_ANY(); cdecl; external;
procedure i2d_ASN1_SET(); cdecl; external;
procedure i2d_ASN1_SET_ANY(); cdecl; external;
procedure i2d_ASN1_T61STRING(); cdecl; external;
procedure i2d_ASN1_TIME(); cdecl; external;
procedure i2d_ASN1_TYPE(); cdecl; external;
procedure i2d_ASN1_UNIVERSALSTRING(); cdecl; external;
procedure i2d_ASN1_UTCTIME(); cdecl; external;
procedure i2d_ASN1_UTF8STRING(); cdecl; external;
procedure i2d_ASN1_VISIBLESTRING(); cdecl; external;
procedure i2d_AUTHORITY_INFO_ACCESS(); cdecl; external;
procedure i2d_AUTHORITY_KEYID(); cdecl; external;
procedure i2d_BASIC_CONSTRAINTS(); cdecl; external;
procedure i2d_CERTIFICATEPOLICIES(); cdecl; external;
procedure i2d_CMS_bio(); cdecl; external;
procedure i2d_CMS_bio_stream(); cdecl; external;
procedure i2d_CMS_ContentInfo(); cdecl; external;
procedure i2d_CMS_ReceiptRequest(); cdecl; external;
procedure i2d_CRL_DIST_POINTS(); cdecl; external;
procedure i2d_DHparams(); cdecl; external;
procedure i2d_DHxparams(); cdecl; external;
procedure i2d_DIRECTORYSTRING(); cdecl; external;
procedure i2d_DISPLAYTEXT(); cdecl; external;
procedure i2d_DIST_POINT(); cdecl; external;
procedure i2d_DIST_POINT_NAME(); cdecl; external;
procedure i2d_DSA_PUBKEY(); cdecl; external;
procedure i2d_DSA_PUBKEY_bio(); cdecl; external;
procedure i2d_DSA_PUBKEY_fp(); cdecl; external;
procedure i2d_DSA_SIG(); cdecl; external;
procedure i2d_DSAparams(); cdecl; external;
procedure i2d_DSAPrivateKey(); cdecl; external;
procedure i2d_DSAPrivateKey_bio(); cdecl; external;
procedure i2d_DSAPrivateKey_fp(); cdecl; external;
procedure i2d_DSAPublicKey(); cdecl; external;
procedure i2d_EC_PRIVATEKEY(); cdecl; external;
procedure i2d_EC_PUBKEY(); cdecl; external;
procedure i2d_EC_PUBKEY_bio(); cdecl; external;
procedure i2d_EC_PUBKEY_fp(); cdecl; external;
procedure i2d_ECDSA_SIG(); cdecl; external;
procedure i2d_ECParameters(); cdecl; external;
procedure i2d_ECPKPARAMETERS(); cdecl; external;
procedure i2d_ECPrivateKey(); cdecl; external;
procedure i2d_ECPrivateKey_bio(); cdecl; external;
procedure i2d_ECPrivateKey_fp(); cdecl; external;
procedure i2d_EDIPARTYNAME(); cdecl; external;
procedure i2d_ESS_CERT_ID(); cdecl; external;
procedure i2d_ESS_ISSUER_SERIAL(); cdecl; external;
procedure i2d_ESS_SIGNING_CERT(); cdecl; external;
procedure i2d_EXTENDED_KEY_USAGE(); cdecl; external;
procedure i2d_GENERAL_NAME(); cdecl; external;
procedure i2d_GENERAL_NAMES(); cdecl; external;
procedure i2d_GOST_CIPHER_PARAMS(); cdecl; external;
procedure i2d_GOST_CLIENT_KEY_EXCHANGE_PARAMS(); cdecl; external;
procedure i2d_GOST_KEY_AGREEMENT_INFO(); cdecl; external;
procedure i2d_GOST_KEY_INFO(); cdecl; external;
procedure i2d_GOST_KEY_PARAMS(); cdecl; external;
procedure i2d_GOST_KEY_TRANSPORT(); cdecl; external;
procedure i2d_int_dhx(); cdecl; external;
procedure i2d_ISSUING_DIST_POINT(); cdecl; external;
procedure i2d_KRB5_APREQ(); cdecl; external;
procedure i2d_KRB5_APREQBODY(); cdecl; external;
procedure i2d_KRB5_AUTHDATA(); cdecl; external;
procedure i2d_KRB5_AUTHENT(); cdecl; external;
procedure i2d_KRB5_AUTHENTBODY(); cdecl; external;
procedure i2d_KRB5_CHECKSUM(); cdecl; external;
procedure i2d_KRB5_ENCDATA(); cdecl; external;
procedure i2d_KRB5_ENCKEY(); cdecl; external;
procedure i2d_KRB5_PRINCNAME(); cdecl; external;
procedure i2d_KRB5_TICKET(); cdecl; external;
procedure i2d_KRB5_TKTBODY(); cdecl; external;
procedure i2d_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure i2d_NETSCAPE_ENCRYPTED_PKEY(); cdecl; external;
procedure i2d_NETSCAPE_PKEY(); cdecl; external;
procedure i2d_Netscape_RSA(); cdecl; external;
procedure i2d_NETSCAPE_SPKAC(); cdecl; external;
procedure i2d_NETSCAPE_SPKI(); cdecl; external;
procedure i2d_NETSCAPE_X509(); cdecl; external;
procedure i2d_NOTICEREF(); cdecl; external;
procedure i2d_OCSP_BASICRESP(); cdecl; external;
procedure i2d_OCSP_CERTID(); cdecl; external;
procedure i2d_OCSP_CERTSTATUS(); cdecl; external;
procedure i2d_OCSP_CRLID(); cdecl; external;
procedure i2d_OCSP_ONEREQ(); cdecl; external;
procedure i2d_OCSP_REQINFO(); cdecl; external;
procedure i2d_OCSP_REQUEST(); cdecl; external;
procedure i2d_OCSP_RESPBYTES(); cdecl; external;
procedure i2d_OCSP_RESPDATA(); cdecl; external;
procedure i2d_OCSP_RESPID(); cdecl; external;
procedure i2d_OCSP_RESPONSE(); cdecl; external;
procedure i2d_OCSP_REVOKEDINFO(); cdecl; external;
procedure i2d_OCSP_SERVICELOC(); cdecl; external;
procedure i2d_OCSP_SIGNATURE(); cdecl; external;
procedure i2d_OCSP_SINGLERESP(); cdecl; external;
procedure i2d_OTHERNAME(); cdecl; external;
procedure i2d_PBE2PARAM(); cdecl; external;
procedure i2d_PBEPARAM(); cdecl; external;
procedure i2d_PBKDF2PARAM(); cdecl; external;
procedure i2d_PKCS12(); cdecl; external;
procedure i2d_PKCS12_BAGS(); cdecl; external;
procedure i2d_PKCS12_bio(); cdecl; external;
procedure i2d_PKCS12_fp(); cdecl; external;
procedure i2d_PKCS12_MAC_DATA(); cdecl; external;
procedure i2d_PKCS12_SAFEBAG(); cdecl; external;
procedure i2d_PKCS7(); cdecl; external;
procedure i2d_PKCS7_bio(); cdecl; external;
procedure i2d_PKCS7_bio_stream(); cdecl; external;
procedure i2d_PKCS7_DIGEST(); cdecl; external;
procedure i2d_PKCS7_ENC_CONTENT(); cdecl; external;
procedure i2d_PKCS7_ENCRYPT(); cdecl; external;
procedure i2d_PKCS7_ENVELOPE(); cdecl; external;
procedure i2d_PKCS7_fp(); cdecl; external;
procedure i2d_PKCS7_ISSUER_AND_SERIAL(); cdecl; external;
procedure i2d_PKCS7_NDEF(); cdecl; external;
procedure i2d_PKCS7_RECIP_INFO(); cdecl; external;
procedure i2d_PKCS7_SIGN_ENVELOPE(); cdecl; external;
procedure i2d_PKCS7_SIGNED(); cdecl; external;
procedure i2d_PKCS7_SIGNER_INFO(); cdecl; external;
procedure i2d_PKCS8_bio(); cdecl; external;
procedure i2d_PKCS8_fp(); cdecl; external;
procedure i2d_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure i2d_PKCS8_PRIV_KEY_INFO_bio(); cdecl; external;
procedure i2d_PKCS8_PRIV_KEY_INFO_fp(); cdecl; external;
procedure i2d_PKCS8PrivateKey_bio(); cdecl; external;
procedure i2d_PKCS8PrivateKey_fp(); cdecl; external;
procedure i2d_PKCS8PrivateKey_nid_bio(); cdecl; external;
procedure i2d_PKCS8PrivateKey_nid_fp(); cdecl; external;
procedure i2d_PKCS8PrivateKeyInfo_bio(); cdecl; external;
procedure i2d_PKCS8PrivateKeyInfo_fp(); cdecl; external;
procedure i2d_PKEY_USAGE_PERIOD(); cdecl; external;
procedure i2d_POLICYINFO(); cdecl; external;
procedure i2d_POLICYQUALINFO(); cdecl; external;
procedure i2d_PrivateKey(); cdecl; external;
procedure i2d_PrivateKey_bio(); cdecl; external;
procedure i2d_PrivateKey_fp(); cdecl; external;
procedure i2d_PROXY_CERT_INFO_EXTENSION(); cdecl; external;
procedure i2d_PROXY_POLICY(); cdecl; external;
procedure i2d_PUBKEY(); cdecl; external;
procedure i2d_PUBKEY_bio(); cdecl; external;
procedure i2d_PUBKEY_fp(); cdecl; external;
procedure i2d_PublicKey(); cdecl; external;
procedure i2d_re_X509_tbs(); cdecl; external;
procedure i2d_RSA_NET(); cdecl; external;
procedure i2d_RSA_OAEP_PARAMS(); cdecl; external;
procedure i2d_RSA_PSS_PARAMS(); cdecl; external;
procedure i2d_RSA_PUBKEY(); cdecl; external;
procedure i2d_RSA_PUBKEY_bio(); cdecl; external;
procedure i2d_RSA_PUBKEY_fp(); cdecl; external;
procedure i2d_RSAPrivateKey(); cdecl; external;
procedure i2d_RSAPrivateKey_bio(); cdecl; external;
procedure i2d_RSAPrivateKey_fp(); cdecl; external;
procedure i2d_RSAPublicKey(); cdecl; external;
procedure i2d_RSAPublicKey_bio(); cdecl; external;
procedure i2d_RSAPublicKey_fp(); cdecl; external;
procedure i2d_SSL_SESSION(); cdecl; external;
procedure i2d_SXNET(); cdecl; external;
procedure i2d_SXNETID(); cdecl; external;
procedure i2d_TS_ACCURACY(); cdecl; external;
procedure i2d_TS_MSG_IMPRINT(); cdecl; external;
procedure i2d_TS_MSG_IMPRINT_bio(); cdecl; external;
procedure i2d_TS_MSG_IMPRINT_fp(); cdecl; external;
procedure i2d_TS_REQ(); cdecl; external;
procedure i2d_TS_REQ_bio(); cdecl; external;
procedure i2d_TS_REQ_fp(); cdecl; external;
procedure i2d_TS_RESP(); cdecl; external;
procedure i2d_TS_RESP_bio(); cdecl; external;
procedure i2d_TS_RESP_fp(); cdecl; external;
procedure i2d_TS_STATUS_INFO(); cdecl; external;
procedure i2d_TS_TST_INFO(); cdecl; external;
procedure i2d_TS_TST_INFO_bio(); cdecl; external;
procedure i2d_TS_TST_INFO_fp(); cdecl; external;
procedure i2d_USERNOTICE(); cdecl; external;
procedure i2d_X509(); cdecl; external;
procedure i2d_X509_ALGOR(); cdecl; external;
procedure i2d_X509_ALGORS(); cdecl; external;
procedure i2d_X509_ATTRIBUTE(); cdecl; external;
procedure i2d_X509_AUX(); cdecl; external;
procedure i2d_X509_bio(); cdecl; external;
procedure i2d_X509_CERT_AUX(); cdecl; external;
procedure i2d_X509_CERT_PAIR(); cdecl; external;
procedure i2d_X509_CINF(); cdecl; external;
procedure i2d_X509_CRL(); cdecl; external;
procedure i2d_X509_CRL_bio(); cdecl; external;
procedure i2d_X509_CRL_fp(); cdecl; external;
procedure i2d_X509_CRL_INFO(); cdecl; external;
procedure i2d_X509_EXTENSION(); cdecl; external;
procedure i2d_X509_EXTENSIONS(); cdecl; external;
procedure i2d_X509_fp(); cdecl; external;
procedure i2d_X509_NAME(); cdecl; external;
procedure i2d_X509_NAME_ENTRY(); cdecl; external;
procedure i2d_X509_PKEY(); cdecl; external;
procedure i2d_X509_PUBKEY(); cdecl; external;
procedure i2d_X509_REQ(); cdecl; external;
procedure i2d_X509_REQ_bio(); cdecl; external;
procedure i2d_X509_REQ_fp(); cdecl; external;
procedure i2d_X509_REQ_INFO(); cdecl; external;
procedure i2d_X509_REVOKED(); cdecl; external;
procedure i2d_X509_SIG(); cdecl; external;
procedure i2d_X509_VAL(); cdecl; external;
procedure i2o_ECPublicKey(); cdecl; external;
procedure i2s_ASN1_ENUMERATED(); cdecl; external;
procedure i2s_ASN1_ENUMERATED_TABLE(); cdecl; external;
procedure i2s_ASN1_INTEGER(); cdecl; external;
procedure i2s_ASN1_OCTET_STRING(); cdecl; external;
procedure i2t_ASN1_OBJECT(); cdecl; external;
procedure i2v_ASN1_BIT_STRING(); cdecl; external;
procedure i2v_GENERAL_NAME(); cdecl; external;
procedure i2v_GENERAL_NAMES(); cdecl; external;
procedure idea_cbc_encrypt(); cdecl; external;
procedure idea_cfb64_encrypt(); cdecl; external;
procedure idea_ecb_encrypt(); cdecl; external;
procedure idea_encrypt(); cdecl; external;
procedure idea_ofb64_encrypt(); cdecl; external;
procedure idea_options(); cdecl; external;
procedure idea_set_decrypt_key(); cdecl; external;
procedure idea_set_encrypt_key(); cdecl; external;
procedure IDEA_version(); cdecl; external;
procedure idealsendbacklognotify(); cdecl; external;
procedure idealsendbacklogquery(); cdecl; external;
procedure imit_gost_cpa(); cdecl; external;
procedure IN6_ADDR_EQUAL(); cdecl; external;
procedure IN6_IS_ADDR_ANYCAST(); cdecl; external;
procedure IN6_IS_ADDR_EUI64(); cdecl; external;
procedure IN6_IS_ADDR_GLOBAL(); cdecl; external;
procedure IN6_IS_ADDR_LINKLOCAL(); cdecl; external;
procedure IN6_IS_ADDR_LOOPBACK(); cdecl; external;
procedure IN6_IS_ADDR_MC_GLOBAL(); cdecl; external;
procedure IN6_IS_ADDR_MC_LINKLOCAL(); cdecl; external;
procedure IN6_IS_ADDR_MC_NODELOCAL(); cdecl; external;
procedure IN6_IS_ADDR_MC_ORGLOCAL(); cdecl; external;
procedure IN6_IS_ADDR_MC_SITELOCAL(); cdecl; external;
procedure IN6_IS_ADDR_MULTICAST(); cdecl; external;
procedure IN6_IS_ADDR_SITELOCAL(); cdecl; external;
procedure IN6_IS_ADDR_SUBNET_RESERVED_ANYCAST(); cdecl; external;
procedure IN6_IS_ADDR_SUBNET_ROUTER_ANYCAST(); cdecl; external;
procedure IN6_IS_ADDR_UNSPECIFIED(); cdecl; external;
procedure IN6_IS_ADDR_V4COMPAT(); cdecl; external;
procedure IN6_IS_ADDR_V4MAPPED(); cdecl; external;
procedure IN6_IS_ADDR_V4TRANSLATED(); cdecl; external;
procedure IN6_SET_ADDR_LOOPBACK(); cdecl; external;
procedure IN6_SET_ADDR_UNSPECIFIED(); cdecl; external;
procedure IN6ADDR_ISANY(); cdecl; external;
procedure IN6ADDR_ISEQUAL(); cdecl; external;
procedure IN6ADDR_ISLOOPBACK(); cdecl; external;
procedure IN6ADDR_ISUNSPECIFIED(); cdecl; external;
procedure IN6ADDR_SETANY(); cdecl; external;
procedure IN6ADDR_SETLOOPBACK(); cdecl; external;
procedure init_gost_hash_ctx(); cdecl; external;
procedure int_rsa_verify(); cdecl; external;
procedure ISSUING_DIST_POINT_free(); cdecl; external;
procedure ISSUING_DIST_POINT_it(); cdecl; external;
procedure ISSUING_DIST_POINT_new(); cdecl; external;
procedure keyDiversifyCryptoPro(); cdecl; external;
procedure keyUnwrapCryptoPro(); cdecl; external;
procedure keyWrapCryptoPro(); cdecl; external;
procedure KRB5_APREQ_free(); cdecl; external;
procedure KRB5_APREQ_it(); cdecl; external;
procedure KRB5_APREQ_new(); cdecl; external;
procedure KRB5_APREQBODY_free(); cdecl; external;
procedure KRB5_APREQBODY_it(); cdecl; external;
procedure KRB5_APREQBODY_new(); cdecl; external;
procedure KRB5_AUTHDATA_free(); cdecl; external;
procedure KRB5_AUTHDATA_it(); cdecl; external;
procedure KRB5_AUTHDATA_new(); cdecl; external;
procedure KRB5_AUTHENT_free(); cdecl; external;
procedure KRB5_AUTHENT_it(); cdecl; external;
procedure KRB5_AUTHENT_new(); cdecl; external;
procedure KRB5_AUTHENTBODY_free(); cdecl; external;
procedure KRB5_AUTHENTBODY_it(); cdecl; external;
procedure KRB5_AUTHENTBODY_new(); cdecl; external;
procedure KRB5_CHECKSUM_free(); cdecl; external;
procedure KRB5_CHECKSUM_it(); cdecl; external;
procedure KRB5_CHECKSUM_new(); cdecl; external;
procedure KRB5_ENCDATA_free(); cdecl; external;
procedure KRB5_ENCDATA_it(); cdecl; external;
procedure KRB5_ENCDATA_new(); cdecl; external;
procedure KRB5_ENCKEY_free(); cdecl; external;
procedure KRB5_ENCKEY_it(); cdecl; external;
procedure KRB5_ENCKEY_new(); cdecl; external;
procedure KRB5_PRINCNAME_free(); cdecl; external;
procedure KRB5_PRINCNAME_it(); cdecl; external;
procedure KRB5_PRINCNAME_new(); cdecl; external;
procedure KRB5_TICKET_free(); cdecl; external;
procedure KRB5_TICKET_it(); cdecl; external;
procedure KRB5_TICKET_new(); cdecl; external;
procedure KRB5_TKTBODY_free(); cdecl; external;
procedure KRB5_TKTBODY_it(); cdecl; external;
procedure KRB5_TKTBODY_new(); cdecl; external;
procedure level_add_node(); cdecl; external;
procedure level_find_node(); cdecl; external;
procedure lh_delete(); cdecl; external;
procedure lh_doall(); cdecl; external;
procedure lh_doall_arg(); cdecl; external;
procedure lh_free(); cdecl; external;
procedure lh_insert(); cdecl; external;
procedure lh_new(); cdecl; external;
procedure lh_node_stats(); cdecl; external;
procedure lh_node_stats_bio(); cdecl; external;
procedure lh_node_usage_stats(); cdecl; external;
procedure lh_node_usage_stats_bio(); cdecl; external;
procedure lh_num_items(); cdecl; external;
procedure lh_retrieve(); cdecl; external;
procedure lh_stats(); cdecl; external;
procedure lh_stats_bio(); cdecl; external;
procedure lh_strhash(); cdecl; external;
procedure lh_version(); cdecl; external;
procedure LONG_it(); cdecl; external;
procedure mac_block(); cdecl; external;
procedure MD4(); cdecl; external;
procedure md4_block_data_order(); cdecl; external;
procedure MD4_Final(); cdecl; external;
procedure MD4_Init(); cdecl; external;
procedure MD4_Transform(); cdecl; external;
procedure MD4_Update(); cdecl; external;
procedure MD4_version(); cdecl; external;
procedure MD5(); cdecl; external;
procedure md5_block_data_order(); cdecl; external;
procedure MD5_Final(); cdecl; external;
procedure MD5_Init(); cdecl; external;
procedure MD5_Transform(); cdecl; external;
procedure MD5_Update(); cdecl; external;
procedure MD5_version(); cdecl; external;
procedure MDC2(); cdecl; external;
procedure MDC2_Final(); cdecl; external;
procedure MDC2_Init(); cdecl; external;
procedure MDC2_Update(); cdecl; external;
procedure n_ssl3_mac(); cdecl; external;
procedure name_cmp(); cdecl; external;
procedure NAME_CONSTRAINTS_check(); cdecl; external;
procedure NAME_CONSTRAINTS_free(); cdecl; external;
procedure NAME_CONSTRAINTS_it(); cdecl; external;
procedure NAME_CONSTRAINTS_new(); cdecl; external;
procedure NCONF_default(); cdecl; external;
procedure NCONF_dump_bio(); cdecl; external;
procedure NCONF_dump_fp(); cdecl; external;
procedure NCONF_free(); cdecl; external;
procedure NCONF_free_data(); cdecl; external;
procedure NCONF_get_number_e(); cdecl; external;
procedure NCONF_get_section(); cdecl; external;
procedure NCONF_get_string(); cdecl; external;
procedure NCONF_load(); cdecl; external;
procedure NCONF_load_bio(); cdecl; external;
procedure NCONF_load_fp(); cdecl; external;
procedure NCONF_new(); cdecl; external;
procedure NCONF_WIN32(); cdecl; external;
procedure NETSCAPE_CERT_SEQUENCE_free(); cdecl; external;
procedure NETSCAPE_CERT_SEQUENCE_it(); cdecl; external;
procedure NETSCAPE_CERT_SEQUENCE_new(); cdecl; external;
procedure NETSCAPE_ENCRYPTED_PKEY_free(); cdecl; external;
procedure NETSCAPE_ENCRYPTED_PKEY_it(); cdecl; external;
procedure NETSCAPE_ENCRYPTED_PKEY_new(); cdecl; external;
procedure NETSCAPE_PKEY_free(); cdecl; external;
procedure NETSCAPE_PKEY_it(); cdecl; external;
procedure NETSCAPE_PKEY_new(); cdecl; external;
procedure NETSCAPE_SPKAC_free(); cdecl; external;
procedure NETSCAPE_SPKAC_it(); cdecl; external;
procedure NETSCAPE_SPKAC_new(); cdecl; external;
procedure NETSCAPE_SPKI_b64_decode(); cdecl; external;
procedure NETSCAPE_SPKI_b64_encode(); cdecl; external;
procedure NETSCAPE_SPKI_free(); cdecl; external;
procedure NETSCAPE_SPKI_get_pubkey(); cdecl; external;
procedure NETSCAPE_SPKI_it(); cdecl; external;
procedure NETSCAPE_SPKI_new(); cdecl; external;
procedure NETSCAPE_SPKI_print(); cdecl; external;
procedure NETSCAPE_SPKI_set_pubkey(); cdecl; external;
procedure NETSCAPE_SPKI_sign(); cdecl; external;
procedure NETSCAPE_SPKI_verify(); cdecl; external;
procedure NETSCAPE_X509_free(); cdecl; external;
procedure NETSCAPE_X509_it(); cdecl; external;
procedure NETSCAPE_X509_new(); cdecl; external;
procedure NOTICEREF_free(); cdecl; external;
procedure NOTICEREF_it(); cdecl; external;
procedure NOTICEREF_new(); cdecl; external;
procedure o2i_ECPublicKey(); cdecl; external;
procedure OBJ_add_object(); cdecl; external;
procedure OBJ_add_sigid(); cdecl; external;
procedure OBJ_bsearch_(); cdecl; external;
procedure OBJ_bsearch_ex_(); cdecl; external;
procedure OBJ_bsearch_ssl_cipher_id(); cdecl; external;
procedure OBJ_cleanup(); cdecl; external;
procedure obj_cleanup_defer(); cdecl; external;
procedure OBJ_cmp(); cdecl; external;
procedure OBJ_create(); cdecl; external;
procedure OBJ_create_objects(); cdecl; external;
procedure OBJ_dup(); cdecl; external;
procedure OBJ_find_sigid_algs(); cdecl; external;
procedure OBJ_find_sigid_by_algs(); cdecl; external;
procedure OBJ_ln2nid(); cdecl; external;
procedure OBJ_NAME_add(); cdecl; external;
procedure OBJ_NAME_cleanup(); cdecl; external;
procedure OBJ_NAME_do_all(); cdecl; external;
procedure OBJ_NAME_do_all_sorted(); cdecl; external;
procedure OBJ_NAME_get(); cdecl; external;
procedure OBJ_NAME_init(); cdecl; external;
procedure OBJ_NAME_new_index(); cdecl; external;
procedure OBJ_NAME_remove(); cdecl; external;
procedure OBJ_new_nid(); cdecl; external;
procedure OBJ_nid2ln(); cdecl; external;
procedure OBJ_nid2obj(); cdecl; external;
procedure OBJ_nid2sn(); cdecl; external;
procedure OBJ_obj2nid(); cdecl; external;
procedure OBJ_obj2txt(); cdecl; external;
procedure OBJ_sigid_free(); cdecl; external;
procedure OBJ_sn2nid(); cdecl; external;
procedure OBJ_txt2nid(); cdecl; external;
procedure OBJ_txt2obj(); cdecl; external;
procedure OCSP_accept_responses_new(); cdecl; external;
procedure OCSP_archive_cutoff_new(); cdecl; external;
procedure OCSP_basic_add1_cert(); cdecl; external;
procedure OCSP_basic_add1_nonce(); cdecl; external;
procedure OCSP_basic_add1_status(); cdecl; external;
procedure OCSP_basic_sign(); cdecl; external;
procedure OCSP_basic_verify(); cdecl; external;
procedure OCSP_BASICRESP_add_ext(); cdecl; external;
procedure OCSP_BASICRESP_add1_ext_i2d(); cdecl; external;
procedure OCSP_BASICRESP_delete_ext(); cdecl; external;
procedure OCSP_BASICRESP_free(); cdecl; external;
procedure OCSP_BASICRESP_get_ext(); cdecl; external;
procedure OCSP_BASICRESP_get_ext_by_critical(); cdecl; external;
procedure OCSP_BASICRESP_get_ext_by_NID(); cdecl; external;
procedure OCSP_BASICRESP_get_ext_by_OBJ(); cdecl; external;
procedure OCSP_BASICRESP_get_ext_count(); cdecl; external;
procedure OCSP_BASICRESP_get1_ext_d2i(); cdecl; external;
procedure OCSP_BASICRESP_it(); cdecl; external;
procedure OCSP_BASICRESP_new(); cdecl; external;
procedure OCSP_cert_id_new(); cdecl; external;
procedure OCSP_cert_status_str(); cdecl; external;
procedure OCSP_cert_to_id(); cdecl; external;
procedure OCSP_CERTID_dup(); cdecl; external;
procedure OCSP_CERTID_free(); cdecl; external;
procedure OCSP_CERTID_it(); cdecl; external;
procedure OCSP_CERTID_new(); cdecl; external;
procedure OCSP_CERTSTATUS_free(); cdecl; external;
procedure OCSP_CERTSTATUS_it(); cdecl; external;
procedure OCSP_CERTSTATUS_new(); cdecl; external;
procedure OCSP_check_nonce(); cdecl; external;
procedure OCSP_check_validity(); cdecl; external;
procedure OCSP_copy_nonce(); cdecl; external;
procedure OCSP_crl_reason_str(); cdecl; external;
procedure OCSP_CRLID_free(); cdecl; external;
procedure OCSP_CRLID_it(); cdecl; external;
procedure OCSP_CRLID_new(); cdecl; external;
procedure OCSP_id_cmp(); cdecl; external;
procedure OCSP_id_get0_info(); cdecl; external;
procedure OCSP_id_issuer_cmp(); cdecl; external;
procedure OCSP_ONEREQ_add_ext(); cdecl; external;
procedure OCSP_ONEREQ_add1_ext_i2d(); cdecl; external;
procedure OCSP_ONEREQ_delete_ext(); cdecl; external;
procedure OCSP_ONEREQ_free(); cdecl; external;
procedure OCSP_ONEREQ_get_ext(); cdecl; external;
procedure OCSP_ONEREQ_get_ext_by_critical(); cdecl; external;
procedure OCSP_ONEREQ_get_ext_by_NID(); cdecl; external;
procedure OCSP_ONEREQ_get_ext_by_OBJ(); cdecl; external;
procedure OCSP_ONEREQ_get_ext_count(); cdecl; external;
procedure OCSP_onereq_get0_id(); cdecl; external;
procedure OCSP_ONEREQ_get1_ext_d2i(); cdecl; external;
procedure OCSP_ONEREQ_it(); cdecl; external;
procedure OCSP_ONEREQ_new(); cdecl; external;
procedure OCSP_parse_url(); cdecl; external;
procedure OCSP_REQ_CTX_add1_header(); cdecl; external;
procedure OCSP_REQ_CTX_free(); cdecl; external;
procedure OCSP_REQ_CTX_get0_mem_bio(); cdecl; external;
procedure OCSP_REQ_CTX_http(); cdecl; external;
procedure OCSP_REQ_CTX_i2d(); cdecl; external;
procedure OCSP_REQ_CTX_nbio(); cdecl; external;
procedure OCSP_REQ_CTX_nbio_d2i(); cdecl; external;
procedure OCSP_REQ_CTX_new(); cdecl; external;
procedure OCSP_REQ_CTX_set1_req(); cdecl; external;
procedure OCSP_REQINFO_free(); cdecl; external;
procedure OCSP_REQINFO_it(); cdecl; external;
procedure OCSP_REQINFO_new(); cdecl; external;
procedure OCSP_REQUEST_add_ext(); cdecl; external;
procedure OCSP_request_add0_id(); cdecl; external;
procedure OCSP_request_add1_cert(); cdecl; external;
procedure OCSP_REQUEST_add1_ext_i2d(); cdecl; external;
procedure OCSP_request_add1_nonce(); cdecl; external;
procedure OCSP_REQUEST_delete_ext(); cdecl; external;
procedure OCSP_REQUEST_free(); cdecl; external;
procedure OCSP_REQUEST_get_ext(); cdecl; external;
procedure OCSP_REQUEST_get_ext_by_critical(); cdecl; external;
procedure OCSP_REQUEST_get_ext_by_NID(); cdecl; external;
procedure OCSP_REQUEST_get_ext_by_OBJ(); cdecl; external;
procedure OCSP_REQUEST_get_ext_count(); cdecl; external;
procedure OCSP_REQUEST_get1_ext_d2i(); cdecl; external;
procedure OCSP_request_is_signed(); cdecl; external;
procedure OCSP_REQUEST_it(); cdecl; external;
procedure OCSP_REQUEST_new(); cdecl; external;
procedure OCSP_request_onereq_count(); cdecl; external;
procedure OCSP_request_onereq_get0(); cdecl; external;
procedure OCSP_REQUEST_print(); cdecl; external;
procedure OCSP_request_set1_name(); cdecl; external;
procedure OCSP_request_sign(); cdecl; external;
procedure OCSP_request_verify(); cdecl; external;
procedure OCSP_resp_count(); cdecl; external;
procedure OCSP_resp_find(); cdecl; external;
procedure OCSP_resp_find_status(); cdecl; external;
procedure OCSP_resp_get0(); cdecl; external;
procedure OCSP_RESPBYTES_free(); cdecl; external;
procedure OCSP_RESPBYTES_it(); cdecl; external;
procedure OCSP_RESPBYTES_new(); cdecl; external;
procedure OCSP_RESPDATA_free(); cdecl; external;
procedure OCSP_RESPDATA_it(); cdecl; external;
procedure OCSP_RESPDATA_new(); cdecl; external;
procedure OCSP_RESPID_free(); cdecl; external;
procedure OCSP_RESPID_it(); cdecl; external;
procedure OCSP_RESPID_new(); cdecl; external;
procedure OCSP_response_create(); cdecl; external;
procedure OCSP_RESPONSE_free(); cdecl; external;
procedure OCSP_response_get1_basic(); cdecl; external;
procedure OCSP_RESPONSE_it(); cdecl; external;
procedure OCSP_RESPONSE_new(); cdecl; external;
procedure OCSP_RESPONSE_print(); cdecl; external;
procedure OCSP_response_status(); cdecl; external;
procedure OCSP_response_status_str(); cdecl; external;
procedure OCSP_REVOKEDINFO_free(); cdecl; external;
procedure OCSP_REVOKEDINFO_it(); cdecl; external;
procedure OCSP_REVOKEDINFO_new(); cdecl; external;
procedure OCSP_sendreq_bio(); cdecl; external;
procedure OCSP_sendreq_nbio(); cdecl; external;
procedure OCSP_sendreq_new(); cdecl; external;
procedure OCSP_SERVICELOC_free(); cdecl; external;
procedure OCSP_SERVICELOC_it(); cdecl; external;
procedure OCSP_SERVICELOC_new(); cdecl; external;
procedure OCSP_set_max_response_length(); cdecl; external;
procedure OCSP_SIGNATURE_free(); cdecl; external;
procedure OCSP_SIGNATURE_it(); cdecl; external;
procedure OCSP_SIGNATURE_new(); cdecl; external;
procedure OCSP_single_get0_status(); cdecl; external;
procedure OCSP_SINGLERESP_add_ext(); cdecl; external;
procedure OCSP_SINGLERESP_add1_ext_i2d(); cdecl; external;
procedure OCSP_SINGLERESP_delete_ext(); cdecl; external;
procedure OCSP_SINGLERESP_free(); cdecl; external;
procedure OCSP_SINGLERESP_get_ext(); cdecl; external;
procedure OCSP_SINGLERESP_get_ext_by_critical(); cdecl; external;
procedure OCSP_SINGLERESP_get_ext_by_NID(); cdecl; external;
procedure OCSP_SINGLERESP_get_ext_by_OBJ(); cdecl; external;
procedure OCSP_SINGLERESP_get_ext_count(); cdecl; external;
procedure OCSP_SINGLERESP_get1_ext_d2i(); cdecl; external;
procedure OCSP_SINGLERESP_it(); cdecl; external;
procedure OCSP_SINGLERESP_new(); cdecl; external;
procedure OCSP_url_svcloc_new(); cdecl; external;
procedure OPENSSL_add_all_algorithms_conf(); cdecl; external;
procedure OPENSSL_add_all_algorithms_noconf(); cdecl; external;
procedure OpenSSL_add_all_ciphers(); cdecl; external;
procedure OpenSSL_add_all_digests(); cdecl; external;
procedure OPENSSL_asc2uni(); cdecl; external;
procedure OPENSSL_cleanse(); cdecl; external;
procedure OPENSSL_config(); cdecl; external;
procedure OPENSSL_cpuid_setup(); cdecl; external;
procedure OPENSSL_DIR_end(); cdecl; external;
procedure OPENSSL_DIR_read(); cdecl; external;
procedure OPENSSL_gmtime(); cdecl; external;
procedure OPENSSL_gmtime_adj(); cdecl; external;
procedure OPENSSL_gmtime_diff(); cdecl; external;
procedure OPENSSL_ia32cap_loc(); cdecl; external;
procedure OPENSSL_ia32cap_P(); cdecl; external;
procedure OPENSSL_init(); cdecl; external;
procedure OPENSSL_isservice(); cdecl; external;
procedure OPENSSL_issetugid(); cdecl; external;
procedure OPENSSL_load_builtin_modules(); cdecl; external;
procedure OPENSSL_memcmp(); cdecl; external;
procedure OPENSSL_no_config(); cdecl; external;
procedure OPENSSL_NONPIC_relocated(); cdecl; external;
procedure OPENSSL_showfatal(); cdecl; external;
procedure OPENSSL_stderr(); cdecl; external;
procedure OPENSSL_strcasecmp(); cdecl; external;
procedure OPENSSL_strncasecmp(); cdecl; external;
procedure OPENSSL_uni2asc(); cdecl; external;
procedure OpenSSLDie(); cdecl; external;
procedure OSSL_DES_version(); cdecl; external;
procedure OSSL_libdes_version(); cdecl; external;
procedure OTHERNAME_cmp(); cdecl; external;
procedure OTHERNAME_free(); cdecl; external;
procedure OTHERNAME_it(); cdecl; external;
procedure OTHERNAME_new(); cdecl; external;
procedure p_CSwift_AcquireAccContext(); cdecl; external;
procedure p_CSwift_AttachKeyParam(); cdecl; external;
procedure p_CSwift_ReleaseAccContext(); cdecl; external;
procedure p_CSwift_SimpleRequest(); cdecl; external;
procedure pack_sign_cp(); cdecl; external;
procedure PBE2PARAM_free(); cdecl; external;
procedure PBE2PARAM_it(); cdecl; external;
procedure PBE2PARAM_new(); cdecl; external;
procedure PBEPARAM_free(); cdecl; external;
procedure PBEPARAM_it(); cdecl; external;
procedure PBEPARAM_new(); cdecl; external;
procedure PBKDF2PARAM_free(); cdecl; external;
procedure PBKDF2PARAM_it(); cdecl; external;
procedure PBKDF2PARAM_new(); cdecl; external;
procedure PEM_ASN1_read(); cdecl; external;
procedure PEM_ASN1_read_bio(); cdecl; external;
procedure PEM_ASN1_write(); cdecl; external;
procedure PEM_ASN1_write_bio(); cdecl; external;
procedure PEM_bytes_read_bio(); cdecl; external;
procedure pem_check_suffix(); cdecl; external;
procedure PEM_def_callback(); cdecl; external;
procedure PEM_dek_info(); cdecl; external;
procedure PEM_do_header(); cdecl; external;
procedure PEM_get_EVP_CIPHER_INFO(); cdecl; external;
procedure PEM_proc_type(); cdecl; external;
procedure PEM_read(); cdecl; external;
procedure PEM_read_bio(); cdecl; external;
procedure PEM_read_bio_CMS(); cdecl; external;
procedure PEM_read_bio_DHparams(); cdecl; external;
procedure PEM_read_bio_DSA_PUBKEY(); cdecl; external;
procedure PEM_read_bio_DSAparams(); cdecl; external;
procedure PEM_read_bio_DSAPrivateKey(); cdecl; external;
procedure PEM_read_bio_EC_PUBKEY(); cdecl; external;
procedure PEM_read_bio_ECPKParameters(); cdecl; external;
procedure PEM_read_bio_ECPrivateKey(); cdecl; external;
procedure PEM_read_bio_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure PEM_read_bio_Parameters(); cdecl; external;
procedure PEM_read_bio_PKCS7(); cdecl; external;
procedure PEM_read_bio_PKCS8(); cdecl; external;
procedure PEM_read_bio_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure PEM_read_bio_PrivateKey(); cdecl; external;
procedure PEM_read_bio_PUBKEY(); cdecl; external;
procedure PEM_read_bio_RSA_PUBKEY(); cdecl; external;
procedure PEM_read_bio_RSAPrivateKey(); cdecl; external;
procedure PEM_read_bio_RSAPublicKey(); cdecl; external;
procedure PEM_read_bio_SSL_SESSION(); cdecl; external;
procedure PEM_read_bio_X509(); cdecl; external;
procedure PEM_read_bio_X509_AUX(); cdecl; external;
procedure PEM_read_bio_X509_CERT_PAIR(); cdecl; external;
procedure PEM_read_bio_X509_CRL(); cdecl; external;
procedure PEM_read_bio_X509_REQ(); cdecl; external;
procedure PEM_read_CMS(); cdecl; external;
procedure PEM_read_DHparams(); cdecl; external;
procedure PEM_read_DSA_PUBKEY(); cdecl; external;
procedure PEM_read_DSAparams(); cdecl; external;
procedure PEM_read_DSAPrivateKey(); cdecl; external;
procedure PEM_read_EC_PUBKEY(); cdecl; external;
procedure PEM_read_ECPKParameters(); cdecl; external;
procedure PEM_read_ECPrivateKey(); cdecl; external;
procedure PEM_read_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure PEM_read_PKCS7(); cdecl; external;
procedure PEM_read_PKCS8(); cdecl; external;
procedure PEM_read_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure PEM_read_PrivateKey(); cdecl; external;
procedure PEM_read_PUBKEY(); cdecl; external;
procedure PEM_read_RSA_PUBKEY(); cdecl; external;
procedure PEM_read_RSAPrivateKey(); cdecl; external;
procedure PEM_read_RSAPublicKey(); cdecl; external;
procedure PEM_read_SSL_SESSION(); cdecl; external;
procedure PEM_read_X509(); cdecl; external;
procedure PEM_read_X509_AUX(); cdecl; external;
procedure PEM_read_X509_CERT_PAIR(); cdecl; external;
procedure PEM_read_X509_CRL(); cdecl; external;
procedure PEM_read_X509_REQ(); cdecl; external;
procedure PEM_SealFinal(); cdecl; external;
procedure PEM_SealInit(); cdecl; external;
procedure PEM_SealUpdate(); cdecl; external;
procedure PEM_SignFinal(); cdecl; external;
procedure PEM_SignInit(); cdecl; external;
procedure PEM_SignUpdate(); cdecl; external;
procedure PEM_version(); cdecl; external;
procedure PEM_write(); cdecl; external;
procedure PEM_write_bio(); cdecl; external;
procedure PEM_write_bio_ASN1_stream(); cdecl; external;
procedure PEM_write_bio_CMS(); cdecl; external;
procedure PEM_write_bio_CMS_stream(); cdecl; external;
procedure PEM_write_bio_DHparams(); cdecl; external;
procedure PEM_write_bio_DHxparams(); cdecl; external;
procedure PEM_write_bio_DSA_PUBKEY(); cdecl; external;
procedure PEM_write_bio_DSAparams(); cdecl; external;
procedure PEM_write_bio_DSAPrivateKey(); cdecl; external;
procedure PEM_write_bio_EC_PUBKEY(); cdecl; external;
procedure PEM_write_bio_ECPKParameters(); cdecl; external;
procedure PEM_write_bio_ECPrivateKey(); cdecl; external;
procedure PEM_write_bio_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure PEM_write_bio_Parameters(); cdecl; external;
procedure PEM_write_bio_PKCS7(); cdecl; external;
procedure PEM_write_bio_PKCS7_stream(); cdecl; external;
procedure PEM_write_bio_PKCS8(); cdecl; external;
procedure PEM_write_bio_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure PEM_write_bio_PKCS8PrivateKey(); cdecl; external;
procedure PEM_write_bio_PKCS8PrivateKey_nid(); cdecl; external;
procedure PEM_write_bio_PrivateKey(); cdecl; external;
procedure PEM_write_bio_PUBKEY(); cdecl; external;
procedure PEM_write_bio_RSA_PUBKEY(); cdecl; external;
procedure PEM_write_bio_RSAPrivateKey(); cdecl; external;
procedure PEM_write_bio_RSAPublicKey(); cdecl; external;
procedure PEM_write_bio_SSL_SESSION(); cdecl; external;
procedure PEM_write_bio_X509(); cdecl; external;
procedure PEM_write_bio_X509_AUX(); cdecl; external;
procedure PEM_write_bio_X509_CERT_PAIR(); cdecl; external;
procedure PEM_write_bio_X509_CRL(); cdecl; external;
procedure PEM_write_bio_X509_REQ(); cdecl; external;
procedure PEM_write_bio_X509_REQ_NEW(); cdecl; external;
procedure PEM_write_CMS(); cdecl; external;
procedure PEM_write_DHparams(); cdecl; external;
procedure PEM_write_DHxparams(); cdecl; external;
procedure PEM_write_DSA_PUBKEY(); cdecl; external;
procedure PEM_write_DSAparams(); cdecl; external;
procedure PEM_write_DSAPrivateKey(); cdecl; external;
procedure PEM_write_EC_PUBKEY(); cdecl; external;
procedure PEM_write_ECPKParameters(); cdecl; external;
procedure PEM_write_ECPrivateKey(); cdecl; external;
procedure PEM_write_NETSCAPE_CERT_SEQUENCE(); cdecl; external;
procedure PEM_write_PKCS7(); cdecl; external;
procedure PEM_write_PKCS8(); cdecl; external;
procedure PEM_write_PKCS8_PRIV_KEY_INFO(); cdecl; external;
procedure PEM_write_PKCS8PrivateKey(); cdecl; external;
procedure PEM_write_PKCS8PrivateKey_nid(); cdecl; external;
procedure PEM_write_PrivateKey(); cdecl; external;
procedure PEM_write_PUBKEY(); cdecl; external;
procedure PEM_write_RSA_PUBKEY(); cdecl; external;
procedure PEM_write_RSAPrivateKey(); cdecl; external;
procedure PEM_write_RSAPublicKey(); cdecl; external;
procedure PEM_write_SSL_SESSION(); cdecl; external;
procedure PEM_write_X509(); cdecl; external;
procedure PEM_write_X509_AUX(); cdecl; external;
procedure PEM_write_X509_CERT_PAIR(); cdecl; external;
procedure PEM_write_X509_CRL(); cdecl; external;
procedure PEM_write_X509_REQ(); cdecl; external;
procedure PEM_write_X509_REQ_NEW(); cdecl; external;
procedure PEM_X509_INFO_read(); cdecl; external;
procedure PEM_X509_INFO_read_bio(); cdecl; external;
procedure PEM_X509_INFO_write_bio(); cdecl; external;
procedure pitem_free(); cdecl; external;
procedure pitem_new(); cdecl; external;
procedure PKCS1_MGF1(); cdecl; external;
procedure PKCS12_add_cert(); cdecl; external;
procedure PKCS12_add_CSPName_asc(); cdecl; external;
procedure PKCS12_add_friendlyname_asc(); cdecl; external;
procedure PKCS12_add_friendlyname_uni(); cdecl; external;
procedure PKCS12_add_key(); cdecl; external;
procedure PKCS12_add_localkeyid(); cdecl; external;
procedure PKCS12_add_safe(); cdecl; external;
procedure PKCS12_add_safes(); cdecl; external;
procedure PKCS12_AUTHSAFES_it(); cdecl; external;
procedure PKCS12_BAGS_free(); cdecl; external;
procedure PKCS12_BAGS_it(); cdecl; external;
procedure PKCS12_BAGS_new(); cdecl; external;
procedure PKCS12_certbag2x509(); cdecl; external;
procedure PKCS12_certbag2x509crl(); cdecl; external;
procedure PKCS12_create(); cdecl; external;
procedure PKCS12_decrypt_skey(); cdecl; external;
procedure PKCS12_free(); cdecl; external;
procedure PKCS12_gen_mac(); cdecl; external;
procedure PKCS12_get_attr_gen(); cdecl; external;
procedure PKCS12_get_friendlyname(); cdecl; external;
procedure PKCS12_init(); cdecl; external;
procedure PKCS12_it(); cdecl; external;
procedure PKCS12_item_decrypt_d2i(); cdecl; external;
procedure PKCS12_item_i2d_encrypt(); cdecl; external;
procedure PKCS12_item_pack_safebag(); cdecl; external;
procedure PKCS12_key_gen_asc(); cdecl; external;
procedure PKCS12_key_gen_uni(); cdecl; external;
procedure PKCS12_MAC_DATA_free(); cdecl; external;
procedure PKCS12_MAC_DATA_it(); cdecl; external;
procedure PKCS12_MAC_DATA_new(); cdecl; external;
procedure PKCS12_MAKE_KEYBAG(); cdecl; external;
procedure PKCS12_MAKE_SHKEYBAG(); cdecl; external;
procedure PKCS12_new(); cdecl; external;
procedure PKCS12_newpass(); cdecl; external;
procedure PKCS12_pack_authsafes(); cdecl; external;
procedure PKCS12_pack_p7data(); cdecl; external;
procedure PKCS12_pack_p7encdata(); cdecl; external;
procedure PKCS12_parse(); cdecl; external;
procedure PKCS12_PBE_add(); cdecl; external;
procedure PKCS12_pbe_crypt(); cdecl; external;
procedure PKCS12_PBE_keyivgen(); cdecl; external;
procedure PKCS12_SAFEBAG_free(); cdecl; external;
procedure PKCS12_SAFEBAG_it(); cdecl; external;
procedure PKCS12_SAFEBAG_new(); cdecl; external;
procedure PKCS12_SAFEBAGS_it(); cdecl; external;
procedure PKCS12_set_mac(); cdecl; external;
procedure PKCS12_setup_mac(); cdecl; external;
procedure PKCS12_unpack_authsafes(); cdecl; external;
procedure PKCS12_unpack_p7data(); cdecl; external;
procedure PKCS12_unpack_p7encdata(); cdecl; external;
procedure PKCS12_verify_mac(); cdecl; external;
procedure PKCS12_x5092certbag(); cdecl; external;
procedure PKCS12_x509crl2certbag(); cdecl; external;
procedure PKCS5_PBE_add(); cdecl; external;
procedure PKCS5_PBE_keyivgen(); cdecl; external;
procedure PKCS5_pbe_set(); cdecl; external;
procedure PKCS5_pbe_set0_algor(); cdecl; external;
procedure PKCS5_pbe2_set(); cdecl; external;
procedure PKCS5_pbe2_set_iv(); cdecl; external;
procedure PKCS5_PBKDF2_HMAC(); cdecl; external;
procedure PKCS5_PBKDF2_HMAC_SHA1(); cdecl; external;
procedure PKCS5_pbkdf2_set(); cdecl; external;
procedure PKCS5_v2_PBE_keyivgen(); cdecl; external;
procedure PKCS5_v2_PBKDF2_keyivgen(); cdecl; external;
procedure PKCS7_add_attrib_content_type(); cdecl; external;
procedure PKCS7_add_attrib_smimecap(); cdecl; external;
procedure PKCS7_add_attribute(); cdecl; external;
procedure PKCS7_add_certificate(); cdecl; external;
procedure PKCS7_add_crl(); cdecl; external;
procedure PKCS7_add_recipient(); cdecl; external;
procedure PKCS7_add_recipient_info(); cdecl; external;
procedure PKCS7_add_signature(); cdecl; external;
procedure PKCS7_add_signed_attribute(); cdecl; external;
procedure PKCS7_add_signer(); cdecl; external;
procedure PKCS7_add0_attrib_signing_time(); cdecl; external;
procedure PKCS7_add1_attrib_digest(); cdecl; external;
procedure PKCS7_ATTR_SIGN_it(); cdecl; external;
procedure PKCS7_ATTR_VERIFY_it(); cdecl; external;
procedure PKCS7_cert_from_signer_info(); cdecl; external;
procedure PKCS7_content_new(); cdecl; external;
procedure PKCS7_ctrl(); cdecl; external;
procedure PKCS7_dataDecode(); cdecl; external;
procedure PKCS7_dataFinal(); cdecl; external;
procedure PKCS7_dataInit(); cdecl; external;
procedure PKCS7_dataVerify(); cdecl; external;
procedure PKCS7_decrypt(); cdecl; external;
procedure PKCS7_DIGEST_free(); cdecl; external;
procedure PKCS7_digest_from_attributes(); cdecl; external;
procedure PKCS7_DIGEST_it(); cdecl; external;
procedure PKCS7_DIGEST_new(); cdecl; external;
procedure PKCS7_dup(); cdecl; external;
procedure PKCS7_ENC_CONTENT_free(); cdecl; external;
procedure PKCS7_ENC_CONTENT_it(); cdecl; external;
procedure PKCS7_ENC_CONTENT_new(); cdecl; external;
procedure PKCS7_encrypt(); cdecl; external;
procedure PKCS7_ENCRYPT_free(); cdecl; external;
procedure PKCS7_ENCRYPT_it(); cdecl; external;
procedure PKCS7_ENCRYPT_new(); cdecl; external;
procedure PKCS7_ENVELOPE_free(); cdecl; external;
procedure PKCS7_ENVELOPE_it(); cdecl; external;
procedure PKCS7_ENVELOPE_new(); cdecl; external;
procedure PKCS7_final(); cdecl; external;
procedure PKCS7_free(); cdecl; external;
procedure PKCS7_get_attribute(); cdecl; external;
procedure PKCS7_get_issuer_and_serial(); cdecl; external;
procedure PKCS7_get_signed_attribute(); cdecl; external;
procedure PKCS7_get_signer_info(); cdecl; external;
procedure PKCS7_get_smimecap(); cdecl; external;
procedure PKCS7_get0_signers(); cdecl; external;
procedure PKCS7_ISSUER_AND_SERIAL_digest(); cdecl; external;
procedure PKCS7_ISSUER_AND_SERIAL_free(); cdecl; external;
procedure PKCS7_ISSUER_AND_SERIAL_it(); cdecl; external;
procedure PKCS7_ISSUER_AND_SERIAL_new(); cdecl; external;
procedure PKCS7_it(); cdecl; external;
procedure PKCS7_new(); cdecl; external;
procedure PKCS7_print_ctx(); cdecl; external;
procedure PKCS7_RECIP_INFO_free(); cdecl; external;
procedure PKCS7_RECIP_INFO_get0_alg(); cdecl; external;
procedure PKCS7_RECIP_INFO_it(); cdecl; external;
procedure PKCS7_RECIP_INFO_new(); cdecl; external;
procedure PKCS7_RECIP_INFO_set(); cdecl; external;
procedure PKCS7_set_attributes(); cdecl; external;
procedure PKCS7_set_cipher(); cdecl; external;
procedure PKCS7_set_content(); cdecl; external;
procedure PKCS7_set_digest(); cdecl; external;
procedure PKCS7_set_signed_attributes(); cdecl; external;
procedure PKCS7_set_type(); cdecl; external;
procedure PKCS7_set0_type_other(); cdecl; external;
procedure PKCS7_sign(); cdecl; external;
procedure PKCS7_sign_add_signer(); cdecl; external;
procedure PKCS7_SIGN_ENVELOPE_free(); cdecl; external;
procedure PKCS7_SIGN_ENVELOPE_it(); cdecl; external;
procedure PKCS7_SIGN_ENVELOPE_new(); cdecl; external;
procedure PKCS7_signatureVerify(); cdecl; external;
procedure PKCS7_SIGNED_free(); cdecl; external;
procedure PKCS7_SIGNED_it(); cdecl; external;
procedure PKCS7_SIGNED_new(); cdecl; external;
procedure PKCS7_SIGNER_INFO_free(); cdecl; external;
procedure PKCS7_SIGNER_INFO_get0_algs(); cdecl; external;
procedure PKCS7_SIGNER_INFO_it(); cdecl; external;
procedure PKCS7_SIGNER_INFO_new(); cdecl; external;
procedure PKCS7_SIGNER_INFO_set(); cdecl; external;
procedure PKCS7_SIGNER_INFO_sign(); cdecl; external;
procedure PKCS7_simple_smimecap(); cdecl; external;
procedure PKCS7_stream(); cdecl; external;
procedure PKCS7_to_TS_TST_INFO(); cdecl; external;
procedure PKCS7_verify(); cdecl; external;
procedure PKCS8_add_keyusage(); cdecl; external;
procedure PKCS8_decrypt(); cdecl; external;
procedure PKCS8_encrypt(); cdecl; external;
procedure PKCS8_pkey_get0(); cdecl; external;
procedure PKCS8_pkey_set0(); cdecl; external;
procedure PKCS8_PRIV_KEY_INFO_free(); cdecl; external;
procedure PKCS8_PRIV_KEY_INFO_it(); cdecl; external;
procedure PKCS8_PRIV_KEY_INFO_new(); cdecl; external;
procedure PKCS8_set_broken(); cdecl; external;
procedure pkey_GOST01cp_decrypt(); cdecl; external;
procedure pkey_GOST01cp_encrypt(); cdecl; external;
procedure pkey_gost2001_derive(); cdecl; external;
procedure pkey_gost94_derive(); cdecl; external;
procedure pkey_GOST94cp_decrypt(); cdecl; external;
procedure pkey_GOST94cp_encrypt(); cdecl; external;
procedure PKEY_USAGE_PERIOD_free(); cdecl; external;
procedure PKEY_USAGE_PERIOD_it(); cdecl; external;
procedure PKEY_USAGE_PERIOD_new(); cdecl; external;
procedure policy_cache_find_data(); cdecl; external;
procedure policy_cache_free(); cdecl; external;
procedure policy_cache_set(); cdecl; external;
procedure policy_cache_set_mapping(); cdecl; external;
procedure POLICY_CONSTRAINTS_free(); cdecl; external;
procedure POLICY_CONSTRAINTS_it(); cdecl; external;
procedure POLICY_CONSTRAINTS_new(); cdecl; external;
procedure policy_data_free(); cdecl; external;
procedure policy_data_new(); cdecl; external;
procedure POLICY_MAPPING_free(); cdecl; external;
procedure POLICY_MAPPING_it(); cdecl; external;
procedure POLICY_MAPPING_new(); cdecl; external;
procedure POLICY_MAPPINGS_it(); cdecl; external;
procedure policy_node_cmp_new(); cdecl; external;
procedure policy_node_free(); cdecl; external;
procedure policy_node_match(); cdecl; external;
procedure POLICYINFO_free(); cdecl; external;
procedure POLICYINFO_it(); cdecl; external;
procedure POLICYINFO_new(); cdecl; external;
procedure POLICYQUALINFO_free(); cdecl; external;
procedure POLICYQUALINFO_it(); cdecl; external;
procedure POLICYQUALINFO_new(); cdecl; external;
procedure pqueue_find(); cdecl; external;
procedure pqueue_free(); cdecl; external;
procedure pqueue_insert(); cdecl; external;
procedure pqueue_iterator(); cdecl; external;
procedure pqueue_new(); cdecl; external;
procedure pqueue_next(); cdecl; external;
procedure pqueue_peek(); cdecl; external;
procedure pqueue_pop(); cdecl; external;
procedure pqueue_print(); cdecl; external;
procedure pqueue_size(); cdecl; external;
procedure private_AES_set_decrypt_key(); cdecl; external;
procedure private_AES_set_encrypt_key(); cdecl; external;
procedure private_Camellia_set_key(); cdecl; external;
procedure private_RC4_set_key(); cdecl; external;
procedure PROXY_CERT_INFO_EXTENSION_free(); cdecl; external;
procedure PROXY_CERT_INFO_EXTENSION_it(); cdecl; external;
procedure PROXY_CERT_INFO_EXTENSION_new(); cdecl; external;
procedure PROXY_POLICY_free(); cdecl; external;
procedure PROXY_POLICY_it(); cdecl; external;
procedure PROXY_POLICY_new(); cdecl; external;
procedure R3410_2001_paramset(); cdecl; external;
procedure R3410_paramset(); cdecl; external;
procedure RAND_add(); cdecl; external;
procedure RAND_bytes(); cdecl; external;
procedure RAND_cleanup(); cdecl; external;
procedure RAND_egd(); cdecl; external;
procedure RAND_egd_bytes(); cdecl; external;
procedure RAND_event(); cdecl; external;
procedure RAND_file_name(); cdecl; external;
procedure RAND_get_rand_method(); cdecl; external;
procedure RAND_load_file(); cdecl; external;
procedure RAND_poll(); cdecl; external;
procedure RAND_pseudo_bytes(); cdecl; external;
procedure RAND_query_egd_bytes(); cdecl; external;
procedure RAND_screen(); cdecl; external;
procedure RAND_seed(); cdecl; external;
procedure RAND_set_rand_engine(); cdecl; external;
procedure RAND_set_rand_method(); cdecl; external;
procedure RAND_SSLeay(); cdecl; external;
procedure rand_ssleay_meth(); cdecl; external;
procedure RAND_status(); cdecl; external;
procedure RAND_version(); cdecl; external;
procedure RAND_write_file(); cdecl; external;
procedure RC2_cbc_encrypt(); cdecl; external;
procedure RC2_cfb64_encrypt(); cdecl; external;
procedure RC2_decrypt(); cdecl; external;
procedure RC2_ecb_encrypt(); cdecl; external;
procedure RC2_encrypt(); cdecl; external;
procedure RC2_ofb64_encrypt(); cdecl; external;
procedure RC2_set_key(); cdecl; external;
procedure RC2_version(); cdecl; external;
procedure RC4(); cdecl; external;
procedure RC4_options(); cdecl; external;
procedure RC4_set_key(); cdecl; external;
procedure RC4_version(); cdecl; external;
procedure register_ameth_gost(); cdecl; external;
procedure register_pmeth_gost(); cdecl; external;
procedure ripemd160_block_data_order; cdecl; external;
procedure RIPEMD160_Final(); cdecl; external;
procedure RIPEMD160_Init(); cdecl; external;
procedure RIPEMD160_Transform(); cdecl; external;
procedure RIPEMD160_Update(); cdecl; external;
procedure RMD160_version(); cdecl; external;
procedure rsa_asn1_meths(); cdecl; external;
procedure RSA_blinding_off(); cdecl; external;
procedure RSA_blinding_on(); cdecl; external;
procedure RSA_check_key(); cdecl; external;
procedure RSA_flags(); cdecl; external;
procedure RSA_free(); cdecl; external;
procedure RSA_generate_key(); cdecl; external;
procedure RSA_generate_key_ex(); cdecl; external;
procedure RSA_get_default_method(); cdecl; external;
procedure RSA_get_ex_data(); cdecl; external;
procedure RSA_get_ex_new_index(); cdecl; external;
procedure RSA_get_method(); cdecl; external;
procedure RSA_memory_lock(); cdecl; external;
procedure RSA_new(); cdecl; external;
procedure RSA_new_method(); cdecl; external;
procedure RSA_null_method(); cdecl; external;
procedure RSA_OAEP_PARAMS_free(); cdecl; external;
procedure RSA_OAEP_PARAMS_it(); cdecl; external;
procedure RSA_OAEP_PARAMS_new(); cdecl; external;
procedure RSA_padding_add_none(); cdecl; external;
procedure RSA_padding_add_PKCS1_OAEP(); cdecl; external;
procedure RSA_padding_add_PKCS1_OAEP_mgf1(); cdecl; external;
procedure RSA_padding_add_PKCS1_PSS(); cdecl; external;
procedure RSA_padding_add_PKCS1_PSS_mgf1(); cdecl; external;
procedure RSA_padding_add_PKCS1_type_1(); cdecl; external;
procedure RSA_padding_add_PKCS1_type_2(); cdecl; external;
procedure RSA_padding_add_SSLv23(); cdecl; external;
procedure RSA_padding_add_X931(); cdecl; external;
procedure RSA_padding_check_none(); cdecl; external;
procedure RSA_padding_check_PKCS1_OAEP(); cdecl; external;
procedure RSA_padding_check_PKCS1_OAEP_mgf1(); cdecl; external;
procedure RSA_padding_check_PKCS1_type_1(); cdecl; external;
procedure RSA_padding_check_PKCS1_type_2(); cdecl; external;
procedure RSA_padding_check_SSLv23(); cdecl; external;
procedure RSA_padding_check_X931(); cdecl; external;
procedure RSA_PKCS1_SSLeay(); cdecl; external;
procedure rsa_pkey_meth(); cdecl; external;
procedure RSA_print(); cdecl; external;
procedure RSA_print_fp(); cdecl; external;
procedure RSA_private_decrypt(); cdecl; external;
procedure RSA_private_encrypt(); cdecl; external;
procedure RSA_PSS_PARAMS_free(); cdecl; external;
procedure RSA_PSS_PARAMS_it(); cdecl; external;
procedure RSA_PSS_PARAMS_new(); cdecl; external;
procedure RSA_public_decrypt(); cdecl; external;
procedure RSA_public_encrypt(); cdecl; external;
procedure RSA_set_default_method(); cdecl; external;
procedure RSA_set_ex_data(); cdecl; external;
procedure RSA_set_method(); cdecl; external;
procedure RSA_setup_blinding(); cdecl; external;
procedure RSA_sign(); cdecl; external;
procedure RSA_sign_ASN1_OCTET_STRING(); cdecl; external;
procedure RSA_size(); cdecl; external;
procedure RSA_up_ref(); cdecl; external;
procedure RSA_verify(); cdecl; external;
procedure RSA_verify_ASN1_OCTET_STRING(); cdecl; external;
procedure RSA_verify_PKCS1_PSS(); cdecl; external;
procedure RSA_verify_PKCS1_PSS_mgf1(); cdecl; external;
procedure RSA_version(); cdecl; external;
procedure RSA_X931_hash_id(); cdecl; external;
procedure RSAPrivateKey_dup(); cdecl; external;
procedure RSAPrivateKey_it(); cdecl; external;
procedure RSAPublicKey_dup(); cdecl; external;
procedure RSAPublicKey_it(); cdecl; external;
procedure s2i_ASN1_INTEGER(); cdecl; external;
procedure s2i_ASN1_OCTET_STRING(); cdecl; external;
procedure SEED_cbc_encrypt(); cdecl; external;
procedure SEED_cfb128_encrypt(); cdecl; external;
procedure SEED_decrypt(); cdecl; external;
procedure SEED_ecb_encrypt(); cdecl; external;
procedure SEED_encrypt(); cdecl; external;
procedure SEED_ofb128_encrypt(); cdecl; external;
procedure SEED_set_key(); cdecl; external;
procedure setipv4sourcefilter(); cdecl; external;
procedure setsourcefilter(); cdecl; external;
procedure SHA(); cdecl; external;
procedure SHA_Final(); cdecl; external;
procedure SHA_Init(); cdecl; external;
procedure SHA_Transform(); cdecl; external;
procedure SHA_Update(); cdecl; external;
procedure SHA_version(); cdecl; external;
procedure SHA1(); cdecl; external;
procedure SHA1_Final(); cdecl; external;
procedure SHA1_Init(); cdecl; external;
procedure SHA1_Transform(); cdecl; external;
procedure SHA1_Update(); cdecl; external;
procedure SHA1_version(); cdecl; external;
procedure SHA224(); cdecl; external;
procedure SHA224_Final(); cdecl; external;
procedure SHA224_Init(); cdecl; external;
procedure SHA224_Update(); cdecl; external;
procedure SHA256(); cdecl; external;
procedure SHA256_Final(); cdecl; external;
procedure SHA256_Init(); cdecl; external;
procedure SHA256_Transform(); cdecl; external;
procedure SHA256_Update(); cdecl; external;
procedure SHA256_version(); cdecl; external;
procedure SHA384(); cdecl; external;
procedure SHA384_Final(); cdecl; external;
procedure SHA384_Init(); cdecl; external;
procedure SHA384_Update(); cdecl; external;
procedure SHA512(); cdecl; external;
procedure SHA512_Final(); cdecl; external;
procedure SHA512_Init(); cdecl; external;
procedure SHA512_Transform(); cdecl; external;
procedure SHA512_Update(); cdecl; external;
procedure SHA512_version(); cdecl; external;
procedure sig_app(); cdecl; external;
procedure sigx_app(); cdecl; external;
procedure sk_deep_copy(); cdecl; external;
procedure sk_delete(); cdecl; external;
procedure sk_delete_ptr(); cdecl; external;
procedure sk_dup(); cdecl; external;
procedure sk_find(); cdecl; external;
procedure sk_find_ex(); cdecl; external;
procedure sk_free(); cdecl; external;
procedure sk_insert(); cdecl; external;
procedure sk_is_sorted(); cdecl; external;
procedure sk_new(); cdecl; external;
procedure sk_new_null(); cdecl; external;
procedure sk_num(); cdecl; external;
procedure sk_pop(); cdecl; external;
procedure sk_pop_free(); cdecl; external;
procedure sk_push(); cdecl; external;
procedure sk_set(); cdecl; external;
procedure sk_set_cmp_func(); cdecl; external;
procedure sk_shift(); cdecl; external;
procedure sk_sort(); cdecl; external;
procedure sk_unshift(); cdecl; external;
procedure sk_value(); cdecl; external;
procedure sk_zero(); cdecl; external;
procedure SMIME_crlf_copy(); cdecl; external;
procedure SMIME_read_ASN1(); cdecl; external;
procedure SMIME_read_CMS(); cdecl; external;
procedure SMIME_read_PKCS7(); cdecl; external;
procedure SMIME_text(); cdecl; external;
procedure SMIME_write_ASN1(); cdecl; external;
procedure SMIME_write_CMS(); cdecl; external;
procedure SMIME_write_PKCS7(); cdecl; external;
procedure SRP_Calc_A(); cdecl; external;
procedure SRP_Calc_A_param(); cdecl; external;
procedure SRP_Calc_B(); cdecl; external;
procedure SRP_Calc_client_key(); cdecl; external;
procedure SRP_Calc_server_key(); cdecl; external;
procedure SRP_Calc_u(); cdecl; external;
procedure SRP_Calc_x(); cdecl; external;
procedure SRP_check_known_gN_param(); cdecl; external;
procedure SRP_create_verifier(); cdecl; external;
procedure SRP_create_verifier_BN(); cdecl; external;
procedure SRP_generate_client_master_secret(); cdecl; external;
procedure SRP_generate_server_master_secret(); cdecl; external;
procedure SRP_get_default_gN(); cdecl; external;
procedure SRP_user_pwd_free(); cdecl; external;
procedure SRP_VBASE_free(); cdecl; external;
procedure SRP_VBASE_get_by_user(); cdecl; external;
procedure SRP_VBASE_get1_by_user(); cdecl; external;
procedure SRP_VBASE_init(); cdecl; external;
procedure SRP_VBASE_new(); cdecl; external;
procedure SRP_Verify_A_mod_N(); cdecl; external;
procedure SRP_Verify_B_mod_N(); cdecl; external;
procedure srp_verify_server_param(); cdecl; external;
procedure ssl_add_cert_chain(); cdecl; external;
procedure SSL_add_client_CA(); cdecl; external;
procedure ssl_add_clienthello_renegotiate_ext(); cdecl; external;
procedure ssl_add_clienthello_tlsext(); cdecl; external;
procedure ssl_add_clienthello_use_srtp_ext(); cdecl; external;
procedure SSL_add_dir_cert_subjects_to_stack(); cdecl; external;
procedure SSL_add_file_cert_subjects_to_stack(); cdecl; external;
procedure ssl_add_serverhello_renegotiate_ext(); cdecl; external;
procedure ssl_add_serverhello_tlsext(); cdecl; external;
procedure ssl_add_serverhello_use_srtp_ext(); cdecl; external;
procedure SSL_alert_desc_string(); cdecl; external;
procedure SSL_alert_desc_string_long(); cdecl; external;
procedure SSL_alert_type_string(); cdecl; external;
procedure SSL_alert_type_string_long(); cdecl; external;
procedure ssl_bad_method(); cdecl; external;
procedure ssl_build_cert_chain(); cdecl; external;
procedure ssl_bytes_to_cipher_list(); cdecl; external;
procedure SSL_cache_hit(); cdecl; external;
procedure SSL_callback_ctrl(); cdecl; external;
procedure ssl_cert_add0_chain_cert(); cdecl; external;
procedure ssl_cert_add1_chain_cert(); cdecl; external;
procedure ssl_cert_clear_certs(); cdecl; external;
procedure ssl_cert_dup(); cdecl; external;
procedure ssl_cert_free(); cdecl; external;
procedure ssl_cert_inst(); cdecl; external;
procedure ssl_cert_new(); cdecl; external;
procedure ssl_cert_select_current(); cdecl; external;
procedure ssl_cert_set_cert_cb(); cdecl; external;
procedure ssl_cert_set_cert_store(); cdecl; external;
procedure ssl_cert_set_current(); cdecl; external;
procedure ssl_cert_set_default_md(); cdecl; external;
procedure ssl_cert_set0_chain(); cdecl; external;
procedure ssl_cert_set1_chain(); cdecl; external;
procedure ssl_cert_type(); cdecl; external;
procedure SSL_certs_clear(); cdecl; external;
procedure SSL_check_chain(); cdecl; external;
procedure ssl_check_clienthello_tlsext_late(); cdecl; external;
procedure ssl_check_serverhello_tlsext(); cdecl; external;
procedure ssl_check_srvr_ecc_cert_and_alg(); cdecl; external;
procedure SSL_CIPHER_description(); cdecl; external;
procedure SSL_CIPHER_find(); cdecl; external;
procedure SSL_CIPHER_get_bits(); cdecl; external;
procedure ssl_cipher_get_cert_index(); cdecl; external;
procedure ssl_cipher_get_evp(); cdecl; external;
procedure SSL_CIPHER_get_id(); cdecl; external;
procedure SSL_CIPHER_get_name(); cdecl; external;
procedure SSL_CIPHER_get_version(); cdecl; external;
procedure ssl_cipher_id_cmp(); cdecl; external;
procedure ssl_cipher_list_to_bytes(); cdecl; external;
procedure ssl_cipher_ptr_id_cmp(); cdecl; external;
procedure SSL_clear(); cdecl; external;
procedure ssl_clear_bad_session(); cdecl; external;
procedure ssl_clear_cipher_ctx(); cdecl; external;
procedure ssl_clear_hash_ctx(); cdecl; external;
procedure SSL_COMP_add_compression_method(); cdecl; external;
procedure SSL_COMP_free_compression_methods(); cdecl; external;
procedure SSL_COMP_get_compression_methods(); cdecl; external;
procedure SSL_COMP_get_name(); cdecl; external;
procedure SSL_COMP_set0_compression_methods(); cdecl; external;
procedure SSL_CONF_cmd(); cdecl; external;
procedure SSL_CONF_cmd_argv(); cdecl; external;
procedure SSL_CONF_cmd_value_type(); cdecl; external;
procedure SSL_CONF_CTX_clear_flags(); cdecl; external;
procedure SSL_CONF_CTX_finish(); cdecl; external;
procedure SSL_CONF_CTX_free(); cdecl; external;
procedure SSL_CONF_CTX_new(); cdecl; external;
procedure SSL_CONF_CTX_set_flags(); cdecl; external;
procedure SSL_CONF_CTX_set_ssl(); cdecl; external;
procedure SSL_CONF_CTX_set_ssl_ctx(); cdecl; external;
procedure SSL_CONF_CTX_set1_prefix(); cdecl; external;
procedure SSL_copy_session_id(); cdecl; external;
procedure ssl_create_cipher_list(); cdecl; external;
procedure SSL_ctrl(); cdecl; external;
procedure SSL_CTX_add_client_CA(); cdecl; external;
procedure SSL_CTX_add_client_custom_ext(); cdecl; external;
procedure SSL_CTX_add_server_custom_ext(); cdecl; external;
procedure SSL_CTX_add_session(); cdecl; external;
procedure SSL_CTX_callback_ctrl(); cdecl; external;
procedure SSL_CTX_ctrl(); cdecl; external;
procedure SSL_CTX_flush_sessions(); cdecl; external;
procedure SSL_CTX_get_cert_store(); cdecl; external;
procedure SSL_CTX_get_client_CA_list(); cdecl; external;
procedure SSL_CTX_get_client_cert_cb(); cdecl; external;
procedure SSL_CTX_get_ex_data(); cdecl; external;
procedure SSL_CTX_get_ex_new_index(); cdecl; external;
procedure SSL_CTX_get_info_callback(); cdecl; external;
procedure SSL_CTX_get_quiet_shutdown(); cdecl; external;
procedure SSL_CTX_get_ssl_method(); cdecl; external;
procedure SSL_CTX_get_timeout(); cdecl; external;
procedure SSL_CTX_get_verify_callback(); cdecl; external;
procedure SSL_CTX_get_verify_depth(); cdecl; external;
procedure SSL_CTX_get_verify_mode(); cdecl; external;
procedure SSL_CTX_get0_certificate(); cdecl; external;
procedure SSL_CTX_get0_param(); cdecl; external;
procedure SSL_CTX_get0_privatekey(); cdecl; external;
procedure SSL_CTX_load_verify_locations(); cdecl; external;
procedure SSL_CTX_remove_session(); cdecl; external;
procedure SSL_CTX_sess_get_get_cb(); cdecl; external;
procedure SSL_CTX_sess_get_new_cb(); cdecl; external;
procedure SSL_CTX_sess_get_remove_cb(); cdecl; external;
procedure SSL_CTX_sess_set_get_cb(); cdecl; external;
procedure SSL_CTX_sess_set_new_cb(); cdecl; external;
procedure SSL_CTX_sess_set_remove_cb(); cdecl; external;
procedure SSL_CTX_sessions(); cdecl; external;
procedure SSL_CTX_set_alpn_protos(); cdecl; external;
procedure SSL_CTX_set_alpn_select_cb(); cdecl; external;
procedure SSL_CTX_set_cert_cb(); cdecl; external;
procedure SSL_CTX_set_cert_store(); cdecl; external;
procedure SSL_CTX_set_cert_verify_callback(); cdecl; external;
procedure SSL_CTX_set_cipher_list(); cdecl; external;
procedure SSL_CTX_set_client_CA_list(); cdecl; external;
procedure SSL_CTX_set_client_cert_cb(); cdecl; external;
procedure SSL_CTX_set_client_cert_engine(); cdecl; external;
procedure SSL_CTX_set_cookie_generate_cb(); cdecl; external;
procedure SSL_CTX_set_cookie_verify_cb(); cdecl; external;
procedure SSL_CTX_set_default_passwd_cb(); cdecl; external;
procedure SSL_CTX_set_default_passwd_cb_userdata(); cdecl; external;
procedure SSL_CTX_set_default_verify_paths(); cdecl; external;
procedure SSL_CTX_set_ex_data(); cdecl; external;
procedure SSL_CTX_set_generate_session_id(); cdecl; external;
procedure SSL_CTX_set_info_callback(); cdecl; external;
procedure SSL_CTX_set_msg_callback(); cdecl; external;
procedure SSL_CTX_set_next_proto_select_cb(); cdecl; external;
procedure SSL_CTX_set_next_protos_advertised_cb(); cdecl; external;
procedure SSL_CTX_set_psk_client_callback(); cdecl; external;
procedure SSL_CTX_set_psk_server_callback(); cdecl; external;
procedure SSL_CTX_set_purpose(); cdecl; external;
procedure SSL_CTX_set_quiet_shutdown(); cdecl; external;
procedure SSL_CTX_set_session_id_context(); cdecl; external;
procedure SSL_CTX_set_srp_cb_arg(); cdecl; external;
procedure SSL_CTX_set_srp_client_pwd_callback(); cdecl; external;
procedure SSL_CTX_set_srp_password(); cdecl; external;
procedure SSL_CTX_set_srp_strength(); cdecl; external;
procedure SSL_CTX_set_srp_username(); cdecl; external;
procedure SSL_CTX_set_srp_username_callback(); cdecl; external;
procedure SSL_CTX_set_srp_verify_param_callback(); cdecl; external;
procedure SSL_CTX_set_ssl_version(); cdecl; external;
procedure SSL_CTX_set_timeout(); cdecl; external;
procedure SSL_CTX_set_tlsext_use_srtp(); cdecl; external;
procedure SSL_CTX_set_tmp_dh_callback(); cdecl; external;
procedure SSL_CTX_set_tmp_ecdh_callback(); cdecl; external;
procedure SSL_CTX_set_tmp_rsa_callback(); cdecl; external;
procedure SSL_CTX_set_trust(); cdecl; external;
procedure SSL_CTX_set_verify(); cdecl; external;
procedure SSL_CTX_set_verify_depth(); cdecl; external;
procedure SSL_CTX_set1_param(); cdecl; external;
procedure SSL_CTX_SRP_CTX_free(); cdecl; external;
procedure SSL_CTX_SRP_CTX_init(); cdecl; external;
procedure SSL_CTX_use_certificate(); cdecl; external;
procedure SSL_CTX_use_certificate_ASN1(); cdecl; external;
procedure SSL_CTX_use_certificate_chain_file(); cdecl; external;
procedure SSL_CTX_use_PrivateKey(); cdecl; external;
procedure SSL_CTX_use_PrivateKey_ASN1(); cdecl; external;
procedure SSL_CTX_use_psk_identity_hint(); cdecl; external;
procedure SSL_CTX_use_RSAPrivateKey(); cdecl; external;
procedure SSL_CTX_use_RSAPrivateKey_ASN1(); cdecl; external;
procedure SSL_CTX_use_serverinfo(); cdecl; external;
procedure SSL_CTX_use_serverinfo_file(); cdecl; external;
procedure ssl_do_client_cert_cb(); cdecl; external;
procedure SSL_dup(); cdecl; external;
procedure SSL_dup_CA_list(); cdecl; external;
procedure SSL_export_keying_material(); cdecl; external;
procedure SSL_extension_supported(); cdecl; external;
procedure ssl_fill_hello_random(); cdecl; external;
procedure ssl_free_wbio_buffer(); cdecl; external;
procedure ssl_get_algorithm2(); cdecl; external;
procedure SSL_get_certificate(); cdecl; external;
procedure ssl_get_cipher_by_char(); cdecl; external;
procedure SSL_get_cipher_list(); cdecl; external;
procedure SSL_get_ciphers(); cdecl; external;
procedure ssl_get_ciphers_by_id(); cdecl; external;
procedure SSL_get_client_CA_list(); cdecl; external;
procedure SSL_get_current_cipher(); cdecl; external;
procedure SSL_get_current_compression(); cdecl; external;
procedure SSL_get_current_expansion(); cdecl; external;
procedure SSL_get_default_timeout(); cdecl; external;
procedure SSL_get_ex_data(); cdecl; external;
procedure SSL_get_ex_data_X509_STORE_CTX_idx(); cdecl; external;
procedure SSL_get_ex_new_index(); cdecl; external;
procedure SSL_get_fd(); cdecl; external;
procedure SSL_get_finished(); cdecl; external;
procedure ssl_get_handshake_digest(); cdecl; external;
procedure SSL_get_info_callback(); cdecl; external;
procedure ssl_get_new_session(); cdecl; external;
procedure SSL_get_peer_cert_chain(); cdecl; external;
procedure SSL_get_peer_finished(); cdecl; external;
procedure ssl_get_prev_session(); cdecl; external;
procedure SSL_get_privatekey(); cdecl; external;
procedure SSL_get_psk_identity(); cdecl; external;
procedure SSL_get_psk_identity_hint(); cdecl; external;
procedure SSL_get_quiet_shutdown(); cdecl; external;
procedure SSL_get_rbio(); cdecl; external;
procedure SSL_get_read_ahead(); cdecl; external;
procedure SSL_get_rfd(); cdecl; external;
procedure SSL_get_selected_srtp_profile(); cdecl; external;
procedure ssl_get_server_cert_serverinfo(); cdecl; external;
procedure ssl_get_server_send_pkey(); cdecl; external;
procedure SSL_get_servername(); cdecl; external;
procedure SSL_get_servername_type(); cdecl; external;
procedure SSL_get_session(); cdecl; external;
procedure SSL_get_shared_ciphers(); cdecl; external;
procedure SSL_get_shared_sigalgs(); cdecl; external;
procedure SSL_get_shutdown(); cdecl; external;
procedure SSL_get_sigalgs(); cdecl; external;
procedure ssl_get_sign_pkey(); cdecl; external;
procedure SSL_get_srp_g(); cdecl; external;
procedure SSL_get_srp_N(); cdecl; external;
procedure SSL_get_srp_userinfo(); cdecl; external;
procedure SSL_get_srp_username(); cdecl; external;
procedure SSL_get_srtp_profiles(); cdecl; external;
procedure SSL_get_SSL_CTX(); cdecl; external;
procedure SSL_get_ssl_method(); cdecl; external;
procedure SSL_get_verify_callback(); cdecl; external;
procedure SSL_get_verify_depth(); cdecl; external;
procedure SSL_get_verify_mode(); cdecl; external;
procedure SSL_get_verify_result(); cdecl; external;
procedure SSL_get_version(); cdecl; external;
procedure SSL_get_wbio(); cdecl; external;
procedure SSL_get_wfd(); cdecl; external;
procedure SSL_get0_alpn_selected(); cdecl; external;
procedure SSL_get0_next_proto_negotiated(); cdecl; external;
procedure SSL_get0_param(); cdecl; external;
procedure SSL_get1_session(); cdecl; external;
procedure SSL_has_matching_session_id(); cdecl; external;
procedure ssl_init_wbio_buffer(); cdecl; external;
procedure SSL_is_server(); cdecl; external;
procedure ssl_load_ciphers(); cdecl; external;
procedure SSL_load_client_CA_file(); cdecl; external;
procedure ssl_ok(); cdecl; external;
procedure ssl_parse_clienthello_renegotiate_ext(); cdecl; external;
procedure ssl_parse_clienthello_tlsext(); cdecl; external;
procedure ssl_parse_clienthello_use_srtp_ext(); cdecl; external;
procedure ssl_parse_serverhello_renegotiate_ext(); cdecl; external;
procedure ssl_parse_serverhello_tlsext(); cdecl; external;
procedure ssl_parse_serverhello_use_srtp_ext(); cdecl; external;
procedure SSL_pending(); cdecl; external;
procedure ssl_prepare_clienthello_tlsext(); cdecl; external;
procedure ssl_prepare_serverhello_tlsext(); cdecl; external;
procedure SSL_renegotiate(); cdecl; external;
procedure SSL_renegotiate_abbreviated(); cdecl; external;
procedure SSL_renegotiate_pending(); cdecl; external;
procedure ssl_replace_hash(); cdecl; external;
procedure SSL_rstate_string(); cdecl; external;
procedure SSL_rstate_string_long(); cdecl; external;
procedure SSL_select_next_proto(); cdecl; external;
procedure ssl_sess_cert_free(); cdecl; external;
procedure ssl_sess_cert_new(); cdecl; external;
procedure ssl_session_dup(); cdecl; external;
procedure SSL_SESSION_free(); cdecl; external;
procedure SSL_SESSION_get_compress_id(); cdecl; external;
procedure SSL_SESSION_get_ex_data(); cdecl; external;
procedure SSL_SESSION_get_ex_new_index(); cdecl; external;
procedure SSL_SESSION_get_id(); cdecl; external;
procedure SSL_SESSION_get_time(); cdecl; external;
procedure SSL_SESSION_get_timeout(); cdecl; external;
procedure SSL_SESSION_get0_peer(); cdecl; external;
procedure SSL_SESSION_new(); cdecl; external;
procedure SSL_SESSION_print(); cdecl; external;
procedure SSL_SESSION_print_fp(); cdecl; external;
procedure SSL_SESSION_set_ex_data(); cdecl; external;
procedure SSL_SESSION_set_time(); cdecl; external;
procedure SSL_SESSION_set_timeout(); cdecl; external;
procedure SSL_SESSION_set1_id_context(); cdecl; external;
procedure SSL_set_alpn_protos(); cdecl; external;
procedure SSL_set_bio(); cdecl; external;
procedure SSL_set_cert_cb(); cdecl; external;
procedure ssl_set_cert_masks(); cdecl; external;
procedure SSL_set_cipher_list(); cdecl; external;
procedure SSL_set_client_CA_list(); cdecl; external;
procedure ssl_set_client_disabled(); cdecl; external;
procedure SSL_set_debug(); cdecl; external;
procedure SSL_set_ex_data(); cdecl; external;
procedure SSL_set_generate_session_id(); cdecl; external;
procedure SSL_set_info_callback(); cdecl; external;
procedure SSL_set_msg_callback(); cdecl; external;
procedure ssl_set_peer_cert_type(); cdecl; external;
procedure SSL_set_psk_client_callback(); cdecl; external;
procedure SSL_set_psk_server_callback(); cdecl; external;
procedure SSL_set_purpose(); cdecl; external;
procedure SSL_set_quiet_shutdown(); cdecl; external;
procedure SSL_set_read_ahead(); cdecl; external;
procedure SSL_set_rfd(); cdecl; external;
procedure SSL_set_session(); cdecl; external;
procedure SSL_set_session_id_context(); cdecl; external;
procedure SSL_set_session_secret_cb(); cdecl; external;
procedure SSL_set_session_ticket_ext(); cdecl; external;
procedure SSL_set_session_ticket_ext_cb(); cdecl; external;
procedure SSL_set_shutdown(); cdecl; external;
procedure SSL_set_srp_server_param(); cdecl; external;
procedure SSL_set_srp_server_param_pw(); cdecl; external;
procedure SSL_set_SSL_CTX(); cdecl; external;
procedure SSL_set_ssl_method(); cdecl; external;
procedure SSL_set_state(); cdecl; external;
procedure SSL_set_tlsext_use_srtp(); cdecl; external;
procedure SSL_set_tmp_dh_callback(); cdecl; external;
procedure SSL_set_tmp_ecdh_callback(); cdecl; external;
procedure SSL_set_tmp_rsa_callback(); cdecl; external;
procedure SSL_set_trust(); cdecl; external;
procedure SSL_set_verify(); cdecl; external;
procedure SSL_set_verify_depth(); cdecl; external;
procedure SSL_set_verify_result(); cdecl; external;
procedure SSL_set_wfd(); cdecl; external;
procedure SSL_set1_param(); cdecl; external;
procedure SSL_SRP_CTX_free(); cdecl; external;
procedure SSL_SRP_CTX_init(); cdecl; external;
procedure SSL_srp_server_param_with_username(); cdecl; external;
procedure SSL_state(); cdecl; external;
procedure SSL_state_string(); cdecl; external;
procedure SSL_state_string_long(); cdecl; external;
procedure ssl_undefined_const_function(); cdecl; external;
procedure ssl_undefined_function(); cdecl; external;
procedure ssl_undefined_void_function(); cdecl; external;
procedure ssl_update_cache(); cdecl; external;
procedure SSL_use_certificate(); cdecl; external;
procedure SSL_use_certificate_ASN1(); cdecl; external;
procedure SSL_use_PrivateKey(); cdecl; external;
procedure SSL_use_PrivateKey_ASN1(); cdecl; external;
procedure SSL_use_psk_identity_hint(); cdecl; external;
procedure SSL_use_RSAPrivateKey(); cdecl; external;
procedure SSL_use_RSAPrivateKey_ASN1(); cdecl; external;
procedure ssl_verify_alarm_type(); cdecl; external;
procedure ssl_verify_cert_chain(); cdecl; external;
procedure SSL_version(); cdecl; external;
procedure SSL_version_str(); cdecl; external;
procedure SSL_want(); cdecl; external;
procedure ssl23_accept(); cdecl; external;
procedure ssl23_connect(); cdecl; external;
procedure ssl23_default_timeout(); cdecl; external;
procedure ssl23_get_cipher(); cdecl; external;
procedure ssl23_get_cipher_by_char(); cdecl; external;
procedure ssl23_get_client_hello(); cdecl; external;
procedure ssl23_num_ciphers(); cdecl; external;
procedure ssl23_peek(); cdecl; external;
procedure ssl23_put_cipher_by_char(); cdecl; external;
procedure ssl23_read(); cdecl; external;
procedure ssl23_read_bytes(); cdecl; external;
procedure ssl23_write(); cdecl; external;
procedure ssl23_write_bytes(); cdecl; external;
procedure ssl3_accept(); cdecl; external;
procedure ssl3_alert_code(); cdecl; external;
procedure ssl3_callback_ctrl(); cdecl; external;
procedure ssl3_cbc_copy_mac(); cdecl; external;
procedure ssl3_cbc_digest_record(); cdecl; external;
procedure ssl3_cbc_record_digest_supported(); cdecl; external;
procedure ssl3_cbc_remove_padding(); cdecl; external;
procedure ssl3_cert_verify_mac(); cdecl; external;
procedure ssl3_change_cipher_state(); cdecl; external;
procedure ssl3_check_cert_and_algorithm(); cdecl; external;
procedure ssl3_choose_cipher(); cdecl; external;
procedure ssl3_ciphers(); cdecl; external;
procedure ssl3_cleanup_key_block(); cdecl; external;
procedure ssl3_clear(); cdecl; external;
procedure ssl3_client_hello(); cdecl; external;
procedure ssl3_comp_find(); cdecl; external;
procedure ssl3_connect(); cdecl; external;
procedure ssl3_ctrl(); cdecl; external;
procedure ssl3_ctx_callback_ctrl(); cdecl; external;
procedure ssl3_ctx_ctrl(); cdecl; external;
procedure ssl3_default_timeout(); cdecl; external;
procedure ssl3_digest_cached_records(); cdecl; external;
procedure ssl3_dispatch_alert(); cdecl; external;
procedure ssl3_do_change_cipher_spec(); cdecl; external;
procedure ssl3_do_compress(); cdecl; external;
procedure ssl3_do_uncompress(); cdecl; external;
procedure ssl3_do_write(); cdecl; external;
procedure ssl3_enc(); cdecl; external;
procedure ssl3_final_finish_mac(); cdecl; external;
procedure ssl3_finish_mac(); cdecl; external;
procedure ssl3_free(); cdecl; external;
procedure ssl3_free_digest_list(); cdecl; external;
procedure ssl3_generate_master_secret(); cdecl; external;
procedure ssl3_get_cert_status(); cdecl; external;
procedure ssl3_get_cert_verify(); cdecl; external;
procedure ssl3_get_certificate_request(); cdecl; external;
procedure ssl3_get_cipher(); cdecl; external;
procedure ssl3_get_cipher_by_char(); cdecl; external;
procedure ssl3_get_client_certificate(); cdecl; external;
procedure ssl3_get_client_hello(); cdecl; external;
procedure ssl3_get_client_key_exchange(); cdecl; external;
procedure ssl3_get_finished(); cdecl; external;
procedure ssl3_get_key_exchange(); cdecl; external;
procedure ssl3_get_message(); cdecl; external;
procedure ssl3_get_new_session_ticket(); cdecl; external;
procedure ssl3_get_next_proto(); cdecl; external;
procedure ssl3_get_req_cert_type(); cdecl; external;
procedure ssl3_get_server_certificate(); cdecl; external;
procedure ssl3_get_server_done(); cdecl; external;
procedure ssl3_get_server_hello(); cdecl; external;
procedure ssl3_handshake_write(); cdecl; external;
procedure ssl3_init_finished_mac(); cdecl; external;
procedure ssl3_new(); cdecl; external;
procedure ssl3_num_ciphers(); cdecl; external;
procedure ssl3_output_cert_chain(); cdecl; external;
procedure ssl3_peek(); cdecl; external;
procedure ssl3_pending(); cdecl; external;
procedure ssl3_put_cipher_by_char(); cdecl; external;
procedure ssl3_read(); cdecl; external;
procedure ssl3_read_bytes(); cdecl; external;
procedure ssl3_read_n(); cdecl; external;
procedure ssl3_record_sequence_update(); cdecl; external;
procedure ssl3_release_read_buffer(); cdecl; external;
procedure ssl3_release_write_buffer(); cdecl; external;
procedure ssl3_renegotiate(); cdecl; external;
procedure ssl3_renegotiate_check(); cdecl; external;
procedure ssl3_send_alert(); cdecl; external;
procedure ssl3_send_cert_status(); cdecl; external;
procedure ssl3_send_certificate_request(); cdecl; external;
procedure ssl3_send_change_cipher_spec(); cdecl; external;
procedure ssl3_send_client_certificate(); cdecl; external;
procedure ssl3_send_client_key_exchange(); cdecl; external;
procedure ssl3_send_client_verify(); cdecl; external;
procedure ssl3_send_finished(); cdecl; external;
procedure ssl3_send_hello_request(); cdecl; external;
procedure ssl3_send_newsession_ticket(); cdecl; external;
procedure ssl3_send_next_proto(); cdecl; external;
procedure ssl3_send_server_certificate(); cdecl; external;
procedure ssl3_send_server_done(); cdecl; external;
procedure ssl3_send_server_hello(); cdecl; external;
procedure ssl3_send_server_key_exchange(); cdecl; external;
procedure ssl3_set_handshake_header(); cdecl; external;
procedure ssl3_setup_buffers(); cdecl; external;
procedure ssl3_setup_key_block(); cdecl; external;
procedure ssl3_setup_read_buffer(); cdecl; external;
procedure ssl3_setup_write_buffer(); cdecl; external;
procedure ssl3_shutdown(); cdecl; external;
procedure ssl3_undef_enc_method(); cdecl; external;
procedure ssl3_version_str(); cdecl; external;
procedure ssl3_write(); cdecl; external;
procedure ssl3_write_bytes(); cdecl; external;
procedure ssl3_write_pending(); cdecl; external;
procedure SSLeay(); cdecl; external;
procedure ssleay_rand_bytes(); cdecl; external;
procedure SSLeay_version(); cdecl; external;
procedure SSLv3_enc_data(); cdecl; external;
procedure STACK_version(); cdecl; external;
procedure start_hash(); cdecl; external;
procedure store_bignum(); cdecl; external;
procedure string_to_hex(); cdecl; external;
procedure SXNET_add_id_asc(); cdecl; external;
procedure SXNET_add_id_INTEGER(); cdecl; external;
procedure SXNET_add_id_ulong(); cdecl; external;
procedure SXNET_free(); cdecl; external;
procedure SXNET_get_id_asc(); cdecl; external;
procedure SXNET_get_id_INTEGER(); cdecl; external;
procedure SXNET_get_id_ulong(); cdecl; external;
procedure SXNET_it(); cdecl; external;
procedure SXNET_new(); cdecl; external;
procedure SXNETID_free(); cdecl; external;
procedure SXNETID_it(); cdecl; external;
procedure SXNETID_new(); cdecl; external;
procedure tls1_alert_code(); cdecl; external;
procedure tls1_cbc_remove_padding(); cdecl; external;
procedure tls1_cert_verify_mac(); cdecl; external;
procedure tls1_change_cipher_state(); cdecl; external;
procedure tls1_check_chain(); cdecl; external;
procedure tls1_check_curve(); cdecl; external;
procedure tls1_check_ec_tmp_key(); cdecl; external;
procedure tls1_clear(); cdecl; external;
procedure tls1_default_timeout(); cdecl; external;
procedure tls1_ec_curve_id2nid(); cdecl; external;
procedure tls1_ec_nid2curve_id(); cdecl; external;
procedure tls1_enc(); cdecl; external;
procedure tls1_export_keying_material(); cdecl; external;
procedure tls1_final_finish_mac(); cdecl; external;
procedure tls1_free(); cdecl; external;
procedure tls1_generate_master_secret(); cdecl; external;
procedure tls1_heartbeat(); cdecl; external;
procedure tls1_mac(); cdecl; external;
procedure tls1_new(); cdecl; external;
procedure tls1_process_heartbeat(); cdecl; external;
procedure tls1_process_sigalgs(); cdecl; external;
procedure tls1_process_ticket(); cdecl; external;
procedure tls1_save_sigalgs(); cdecl; external;
procedure tls1_set_cert_validity(); cdecl; external;
procedure tls1_set_curves(); cdecl; external;
procedure tls1_set_curves_list(); cdecl; external;
procedure tls1_set_server_sigalgs(); cdecl; external;
procedure tls1_set_sigalgs(); cdecl; external;
procedure tls1_set_sigalgs_list(); cdecl; external;
procedure tls1_setup_key_block(); cdecl; external;
procedure tls1_shared_curve(); cdecl; external;
procedure tls1_version_str(); cdecl; external;
procedure tls12_check_peer_sigalg(); cdecl; external;
procedure tls12_get_hash(); cdecl; external;
procedure tls12_get_psigalgs(); cdecl; external;
procedure tls12_get_sigandhash(); cdecl; external;
procedure tls12_get_sigid(); cdecl; external;
procedure TLSv1_1_enc_data(); cdecl; external;
procedure TLSv1_2_enc_data(); cdecl; external;
procedure TLSv1_enc_data(); cdecl; external;
procedure tree_find_sk(); cdecl; external;
procedure TS_ACCURACY_dup(); cdecl; external;
procedure TS_ACCURACY_free(); cdecl; external;
procedure TS_ACCURACY_get_micros(); cdecl; external;
procedure TS_ACCURACY_get_millis(); cdecl; external;
procedure TS_ACCURACY_get_seconds(); cdecl; external;
procedure TS_ACCURACY_it(); cdecl; external;
procedure TS_ACCURACY_new(); cdecl; external;
procedure TS_ACCURACY_set_micros(); cdecl; external;
procedure TS_ACCURACY_set_millis(); cdecl; external;
procedure TS_ACCURACY_set_seconds(); cdecl; external;
procedure TS_ASN1_INTEGER_print_bio(); cdecl; external;
procedure TS_CONF_get_tsa_section(); cdecl; external;
procedure TS_CONF_load_cert(); cdecl; external;
procedure TS_CONF_load_certs(); cdecl; external;
procedure TS_CONF_load_key(); cdecl; external;
procedure TS_CONF_set_accuracy(); cdecl; external;
procedure TS_CONF_set_certs(); cdecl; external;
procedure TS_CONF_set_clock_precision_digits(); cdecl; external;
procedure TS_CONF_set_crypto_device(); cdecl; external;
procedure TS_CONF_set_def_policy(); cdecl; external;
procedure TS_CONF_set_default_engine(); cdecl; external;
procedure TS_CONF_set_digests(); cdecl; external;
procedure TS_CONF_set_ess_cert_id_chain(); cdecl; external;
procedure TS_CONF_set_ordering(); cdecl; external;
procedure TS_CONF_set_policies(); cdecl; external;
procedure TS_CONF_set_serial(); cdecl; external;
procedure TS_CONF_set_signer_cert(); cdecl; external;
procedure TS_CONF_set_signer_key(); cdecl; external;
procedure TS_CONF_set_tsa_name(); cdecl; external;
procedure TS_ext_print_bio(); cdecl; external;
procedure TS_MSG_IMPRINT_dup(); cdecl; external;
procedure TS_MSG_IMPRINT_free(); cdecl; external;
procedure TS_MSG_IMPRINT_get_algo(); cdecl; external;
procedure TS_MSG_IMPRINT_get_msg(); cdecl; external;
procedure TS_MSG_IMPRINT_it(); cdecl; external;
procedure TS_MSG_IMPRINT_new(); cdecl; external;
procedure TS_MSG_IMPRINT_print_bio(); cdecl; external;
procedure TS_MSG_IMPRINT_set_algo(); cdecl; external;
procedure TS_MSG_IMPRINT_set_msg(); cdecl; external;
procedure TS_OBJ_print_bio(); cdecl; external;
procedure TS_REQ_add_ext(); cdecl; external;
procedure TS_REQ_delete_ext(); cdecl; external;
procedure TS_REQ_dup(); cdecl; external;
procedure TS_REQ_ext_free(); cdecl; external;
procedure TS_REQ_free(); cdecl; external;
procedure TS_REQ_get_cert_req(); cdecl; external;
procedure TS_REQ_get_ext(); cdecl; external;
procedure TS_REQ_get_ext_by_critical(); cdecl; external;
procedure TS_REQ_get_ext_by_NID(); cdecl; external;
procedure TS_REQ_get_ext_by_OBJ(); cdecl; external;
procedure TS_REQ_get_ext_count(); cdecl; external;
procedure TS_REQ_get_ext_d2i(); cdecl; external;
procedure TS_REQ_get_exts(); cdecl; external;
procedure TS_REQ_get_msg_imprint(); cdecl; external;
procedure TS_REQ_get_nonce(); cdecl; external;
procedure TS_REQ_get_policy_id(); cdecl; external;
procedure TS_REQ_get_version(); cdecl; external;
procedure TS_REQ_it(); cdecl; external;
procedure TS_REQ_new(); cdecl; external;
procedure TS_REQ_print_bio(); cdecl; external;
procedure TS_REQ_set_cert_req(); cdecl; external;
procedure TS_REQ_set_msg_imprint(); cdecl; external;
procedure TS_REQ_set_nonce(); cdecl; external;
procedure TS_REQ_set_policy_id(); cdecl; external;
procedure TS_REQ_set_version(); cdecl; external;
procedure TS_REQ_to_TS_VERIFY_CTX(); cdecl; external;
procedure TS_RESP_create_response(); cdecl; external;
procedure TS_RESP_CTX_add_failure_info(); cdecl; external;
procedure TS_RESP_CTX_add_flags(); cdecl; external;
procedure TS_RESP_CTX_add_md(); cdecl; external;
procedure TS_RESP_CTX_add_policy(); cdecl; external;
procedure TS_RESP_CTX_free(); cdecl; external;
procedure TS_RESP_CTX_get_request(); cdecl; external;
procedure TS_RESP_CTX_get_tst_info(); cdecl; external;
procedure TS_RESP_CTX_new(); cdecl; external;
procedure TS_RESP_CTX_set_accuracy(); cdecl; external;
procedure TS_RESP_CTX_set_certs(); cdecl; external;
procedure TS_RESP_CTX_set_clock_precision_digits(); cdecl; external;
procedure TS_RESP_CTX_set_def_policy(); cdecl; external;
procedure TS_RESP_CTX_set_extension_cb(); cdecl; external;
procedure TS_RESP_CTX_set_serial_cb(); cdecl; external;
procedure TS_RESP_CTX_set_signer_cert(); cdecl; external;
procedure TS_RESP_CTX_set_signer_key(); cdecl; external;
procedure TS_RESP_CTX_set_status_info(); cdecl; external;
procedure TS_RESP_CTX_set_status_info_cond(); cdecl; external;
procedure TS_RESP_CTX_set_time_cb(); cdecl; external;
procedure TS_RESP_dup(); cdecl; external;
procedure TS_RESP_free(); cdecl; external;
procedure TS_RESP_get_status_info(); cdecl; external;
procedure TS_RESP_get_token(); cdecl; external;
procedure TS_RESP_get_tst_info(); cdecl; external;
procedure TS_RESP_it(); cdecl; external;
procedure TS_RESP_new(); cdecl; external;
procedure TS_RESP_print_bio(); cdecl; external;
procedure TS_RESP_set_status_info(); cdecl; external;
procedure TS_RESP_set_tst_info(); cdecl; external;
procedure TS_RESP_verify_response(); cdecl; external;
procedure TS_RESP_verify_signature(); cdecl; external;
procedure TS_RESP_verify_token(); cdecl; external;
procedure TS_STATUS_INFO_dup(); cdecl; external;
procedure TS_STATUS_INFO_free(); cdecl; external;
procedure TS_STATUS_INFO_it(); cdecl; external;
procedure TS_STATUS_INFO_new(); cdecl; external;
procedure TS_STATUS_INFO_print_bio(); cdecl; external;
procedure TS_TST_INFO_add_ext(); cdecl; external;
procedure TS_TST_INFO_delete_ext(); cdecl; external;
procedure TS_TST_INFO_dup(); cdecl; external;
procedure TS_TST_INFO_ext_free(); cdecl; external;
procedure TS_TST_INFO_free(); cdecl; external;
procedure TS_TST_INFO_get_accuracy(); cdecl; external;
procedure TS_TST_INFO_get_ext(); cdecl; external;
procedure TS_TST_INFO_get_ext_by_critical(); cdecl; external;
procedure TS_TST_INFO_get_ext_by_NID(); cdecl; external;
procedure TS_TST_INFO_get_ext_by_OBJ(); cdecl; external;
procedure TS_TST_INFO_get_ext_count(); cdecl; external;
procedure TS_TST_INFO_get_ext_d2i(); cdecl; external;
procedure TS_TST_INFO_get_exts(); cdecl; external;
procedure TS_TST_INFO_get_msg_imprint(); cdecl; external;
procedure TS_TST_INFO_get_nonce(); cdecl; external;
procedure TS_TST_INFO_get_ordering(); cdecl; external;
procedure TS_TST_INFO_get_policy_id(); cdecl; external;
procedure TS_TST_INFO_get_serial(); cdecl; external;
procedure TS_TST_INFO_get_time(); cdecl; external;
procedure TS_TST_INFO_get_tsa(); cdecl; external;
procedure TS_TST_INFO_get_version(); cdecl; external;
procedure TS_TST_INFO_it(); cdecl; external;
procedure TS_TST_INFO_new(); cdecl; external;
procedure TS_TST_INFO_print_bio(); cdecl; external;
procedure TS_TST_INFO_set_accuracy(); cdecl; external;
procedure TS_TST_INFO_set_msg_imprint(); cdecl; external;
procedure TS_TST_INFO_set_nonce(); cdecl; external;
procedure TS_TST_INFO_set_ordering(); cdecl; external;
procedure TS_TST_INFO_set_policy_id(); cdecl; external;
procedure TS_TST_INFO_set_serial(); cdecl; external;
procedure TS_TST_INFO_set_time(); cdecl; external;
procedure TS_TST_INFO_set_tsa(); cdecl; external;
procedure TS_TST_INFO_set_version(); cdecl; external;
procedure TS_VERIFY_CTX_cleanup(); cdecl; external;
procedure TS_VERIFY_CTX_free(); cdecl; external;
procedure TS_VERIFY_CTX_init(); cdecl; external;
procedure TS_VERIFY_CTX_new(); cdecl; external;
procedure TS_X509_ALGOR_print_bio(); cdecl; external;
procedure TXT_DB_create_index(); cdecl; external;
procedure TXT_DB_free(); cdecl; external;
procedure TXT_DB_get_by_index(); cdecl; external;
procedure TXT_DB_insert(); cdecl; external;
procedure TXT_DB_read(); cdecl; external;
procedure TXT_DB_version(); cdecl; external;
procedure TXT_DB_write(); cdecl; external;
procedure UI_add_error_string(); cdecl; external;
procedure UI_add_info_string(); cdecl; external;
procedure UI_add_input_boolean(); cdecl; external;
procedure UI_add_input_string(); cdecl; external;
procedure UI_add_user_data(); cdecl; external;
procedure UI_add_verify_string(); cdecl; external;
procedure UI_construct_prompt(); cdecl; external;
procedure UI_create_method(); cdecl; external;
procedure UI_ctrl(); cdecl; external;
procedure UI_destroy_method(); cdecl; external;
procedure UI_dup_error_string(); cdecl; external;
procedure UI_dup_info_string(); cdecl; external;
procedure UI_dup_input_boolean(); cdecl; external;
procedure UI_dup_input_string(); cdecl; external;
procedure UI_dup_verify_string(); cdecl; external;
procedure UI_free(); cdecl; external;
procedure UI_get_default_method(); cdecl; external;
procedure UI_get_ex_data(); cdecl; external;
procedure UI_get_ex_new_index(); cdecl; external;
procedure UI_get_input_flags(); cdecl; external;
procedure UI_get_method(); cdecl; external;
procedure UI_get_result_maxsize(); cdecl; external;
procedure UI_get_result_minsize(); cdecl; external;
procedure UI_get_string_type(); cdecl; external;
procedure UI_get0_action_string(); cdecl; external;
procedure UI_get0_output_string(); cdecl; external;
procedure UI_get0_result(); cdecl; external;
procedure UI_get0_result_string(); cdecl; external;
procedure UI_get0_test_string(); cdecl; external;
procedure UI_get0_user_data(); cdecl; external;
procedure UI_method_get_closer(); cdecl; external;
procedure UI_method_get_flusher(); cdecl; external;
procedure UI_method_get_opener(); cdecl; external;
procedure UI_method_get_prompt_constructor(); cdecl; external;
procedure UI_method_get_reader(); cdecl; external;
procedure UI_method_get_writer(); cdecl; external;
procedure UI_method_set_closer(); cdecl; external;
procedure UI_method_set_flusher(); cdecl; external;
procedure UI_method_set_opener(); cdecl; external;
procedure UI_method_set_prompt_constructor(); cdecl; external;
procedure UI_method_set_reader(); cdecl; external;
procedure UI_method_set_writer(); cdecl; external;
procedure UI_new(); cdecl; external;
procedure UI_new_method(); cdecl; external;
procedure UI_OpenSSL(); cdecl; external;
procedure UI_process(); cdecl; external;
procedure UI_set_default_method(); cdecl; external;
procedure UI_set_ex_data(); cdecl; external;
procedure UI_set_method(); cdecl; external;
procedure UI_set_result(); cdecl; external;
procedure UI_UTIL_read_pw(); cdecl; external;
procedure UI_UTIL_read_pw_string(); cdecl; external;
procedure unpack_cp_signature(); cdecl; external;
procedure USERNOTICE_free(); cdecl; external;
procedure USERNOTICE_it(); cdecl; external;
procedure USERNOTICE_new(); cdecl; external;
procedure UTF8_getc(); cdecl; external;
procedure UTF8_putc(); cdecl; external;
procedure v2i_ASN1_BIT_STRING(); cdecl; external;
procedure v2i_GENERAL_NAME(); cdecl; external;
procedure v2i_GENERAL_NAME_ex(); cdecl; external;
procedure v2i_GENERAL_NAMES(); cdecl; external;
procedure v3_akey_id(); cdecl; external;
procedure v3_alt(); cdecl; external;
procedure v3_bcons(); cdecl; external;
procedure v3_cpols(); cdecl; external;
procedure v3_crl_hold(); cdecl; external;
procedure v3_crl_invdate(); cdecl; external;
procedure v3_crl_num(); cdecl; external;
procedure v3_crl_reason(); cdecl; external;
procedure v3_crld(); cdecl; external;
procedure v3_ct_scts(); cdecl; external;
procedure v3_delta_crl(); cdecl; external;
procedure v3_ext_ku(); cdecl; external;
procedure v3_freshest_crl(); cdecl; external;
procedure v3_idp(); cdecl; external;
procedure v3_info(); cdecl; external;
procedure v3_inhibit_anyp(); cdecl; external;
procedure v3_key_usage(); cdecl; external;
procedure v3_name_constraints(); cdecl; external;
procedure v3_ns_ia5_list(); cdecl; external;
procedure v3_nscert(); cdecl; external;
procedure v3_ocsp_accresp(); cdecl; external;
procedure v3_ocsp_acutoff(); cdecl; external;
procedure v3_ocsp_crlid(); cdecl; external;
procedure v3_ocsp_nocheck(); cdecl; external;
procedure v3_ocsp_nonce(); cdecl; external;
procedure v3_ocsp_serviceloc(); cdecl; external;
procedure v3_pci(); cdecl; external;
procedure v3_pkey_usage_period(); cdecl; external;
procedure v3_policy_constraints(); cdecl; external;
procedure v3_policy_mappings(); cdecl; external;
procedure v3_sinfo(); cdecl; external;
procedure v3_skey_id(); cdecl; external;
procedure v3_sxnet(); cdecl; external;
procedure WHIRLPOOL(); cdecl; external;
procedure WHIRLPOOL_BitUpdate(); cdecl; external;
procedure whirlpool_block(); cdecl; external;
procedure WHIRLPOOL_Final(); cdecl; external;
procedure WHIRLPOOL_Init(); cdecl; external;
procedure WHIRLPOOL_Update(); cdecl; external;
procedure X509_add_ext(); cdecl; external;
procedure X509_add1_ext_i2d(); cdecl; external;
procedure X509_add1_reject_object(); cdecl; external;
procedure X509_add1_trust_object(); cdecl; external;
procedure X509_ALGOR_cmp(); cdecl; external;
procedure X509_ALGOR_dup(); cdecl; external;
procedure X509_ALGOR_free(); cdecl; external;
procedure X509_ALGOR_get0(); cdecl; external;
procedure X509_ALGOR_it(); cdecl; external;
procedure X509_ALGOR_new(); cdecl; external;
procedure X509_ALGOR_set_md(); cdecl; external;
procedure X509_ALGOR_set0(); cdecl; external;
procedure X509_ALGORS_it(); cdecl; external;
procedure X509_alias_get0(); cdecl; external;
procedure X509_alias_set1(); cdecl; external;
procedure X509_ATTRIBUTE_count(); cdecl; external;
procedure X509_ATTRIBUTE_create(); cdecl; external;
procedure X509_ATTRIBUTE_create_by_NID(); cdecl; external;
procedure X509_ATTRIBUTE_create_by_OBJ(); cdecl; external;
procedure X509_ATTRIBUTE_create_by_txt(); cdecl; external;
procedure X509_ATTRIBUTE_dup(); cdecl; external;
procedure X509_ATTRIBUTE_free(); cdecl; external;
procedure X509_ATTRIBUTE_get0_data(); cdecl; external;
procedure X509_ATTRIBUTE_get0_object(); cdecl; external;
procedure X509_ATTRIBUTE_get0_type(); cdecl; external;
procedure X509_ATTRIBUTE_it(); cdecl; external;
procedure X509_ATTRIBUTE_new(); cdecl; external;
procedure X509_ATTRIBUTE_SET_it(); cdecl; external;
procedure X509_ATTRIBUTE_set1_data(); cdecl; external;
procedure X509_ATTRIBUTE_set1_object(); cdecl; external;
procedure X509_CERT_AUX_free(); cdecl; external;
procedure X509_CERT_AUX_it(); cdecl; external;
procedure X509_CERT_AUX_new(); cdecl; external;
procedure X509_CERT_AUX_print(); cdecl; external;
procedure X509_CERT_PAIR_free(); cdecl; external;
procedure X509_CERT_PAIR_it(); cdecl; external;
procedure X509_CERT_PAIR_new(); cdecl; external;
procedure X509_certificate_type(); cdecl; external;
procedure X509_chain_check_suiteb(); cdecl; external;
procedure X509_chain_up_ref(); cdecl; external;
procedure X509_check_akid(); cdecl; external;
procedure X509_check_ca(); cdecl; external;
procedure X509_check_email(); cdecl; external;
procedure X509_check_host(); cdecl; external;
procedure X509_check_ip(); cdecl; external;
procedure X509_check_ip_asc(); cdecl; external;
procedure X509_check_issued(); cdecl; external;
procedure X509_check_private_key(); cdecl; external;
procedure X509_check_purpose(); cdecl; external;
procedure X509_check_trust(); cdecl; external;
procedure X509_CINF_free(); cdecl; external;
procedure X509_CINF_it(); cdecl; external;
procedure X509_CINF_new(); cdecl; external;
procedure X509_cmp(); cdecl; external;
procedure X509_cmp_current_time(); cdecl; external;
procedure X509_cmp_time(); cdecl; external;
procedure X509_CRL_add_ext(); cdecl; external;
procedure X509_CRL_add0_revoked(); cdecl; external;
procedure X509_CRL_add1_ext_i2d(); cdecl; external;
procedure X509_CRL_check_suiteb(); cdecl; external;
procedure X509_CRL_cmp(); cdecl; external;
procedure X509_CRL_delete_ext(); cdecl; external;
procedure X509_CRL_diff(); cdecl; external;
procedure X509_CRL_digest(); cdecl; external;
procedure X509_CRL_dup(); cdecl; external;
procedure X509_CRL_free(); cdecl; external;
procedure X509_CRL_get_ext(); cdecl; external;
procedure X509_CRL_get_ext_by_critical(); cdecl; external;
procedure X509_CRL_get_ext_by_NID(); cdecl; external;
procedure X509_CRL_get_ext_by_OBJ(); cdecl; external;
procedure X509_CRL_get_ext_count(); cdecl; external;
procedure X509_CRL_get_ext_d2i(); cdecl; external;
procedure X509_CRL_get_meth_data(); cdecl; external;
procedure X509_CRL_get0_by_cert(); cdecl; external;
procedure X509_CRL_get0_by_serial(); cdecl; external;
procedure X509_CRL_http_nbio(); cdecl; external;
procedure X509_CRL_INFO_free(); cdecl; external;
procedure X509_CRL_INFO_it(); cdecl; external;
procedure X509_CRL_INFO_new(); cdecl; external;
procedure X509_CRL_it(); cdecl; external;
procedure X509_CRL_match(); cdecl; external;
procedure X509_CRL_METHOD_free(); cdecl; external;
procedure X509_CRL_METHOD_new(); cdecl; external;
procedure X509_CRL_new(); cdecl; external;
procedure X509_CRL_print(); cdecl; external;
procedure X509_CRL_print_fp(); cdecl; external;
procedure X509_CRL_set_default_method(); cdecl; external;
procedure X509_CRL_set_issuer_name(); cdecl; external;
procedure X509_CRL_set_lastUpdate(); cdecl; external;
procedure X509_CRL_set_meth_data(); cdecl; external;
procedure X509_CRL_set_nextUpdate(); cdecl; external;
procedure X509_CRL_set_version(); cdecl; external;
procedure X509_CRL_sign(); cdecl; external;
procedure X509_CRL_sign_ctx(); cdecl; external;
procedure X509_CRL_sort(); cdecl; external;
procedure X509_CRL_verify(); cdecl; external;
procedure X509_delete_ext(); cdecl; external;
procedure X509_digest(); cdecl; external;
procedure x509_dir_lookup(); cdecl; external;
procedure X509_dup(); cdecl; external;
procedure X509_email_free(); cdecl; external;
procedure X509_EXTENSION_create_by_NID(); cdecl; external;
procedure X509_EXTENSION_create_by_OBJ(); cdecl; external;
procedure X509_EXTENSION_dup(); cdecl; external;
procedure X509_EXTENSION_free(); cdecl; external;
procedure X509_EXTENSION_get_critical(); cdecl; external;
procedure X509_EXTENSION_get_data(); cdecl; external;
procedure X509_EXTENSION_get_object(); cdecl; external;
procedure X509_EXTENSION_it(); cdecl; external;
procedure X509_EXTENSION_new(); cdecl; external;
procedure X509_EXTENSION_set_critical(); cdecl; external;
procedure X509_EXTENSION_set_data(); cdecl; external;
procedure X509_EXTENSION_set_object(); cdecl; external;
procedure X509_EXTENSIONS_it(); cdecl; external;
procedure x509_file_lookup(); cdecl; external;
procedure X509_find_by_issuer_and_serial(); cdecl; external;
procedure X509_find_by_subject(); cdecl; external;
procedure X509_free(); cdecl; external;
procedure X509_get_default_cert_area(); cdecl; external;
procedure X509_get_default_cert_dir(); cdecl; external;
procedure X509_get_default_cert_dir_env(); cdecl; external;
procedure X509_get_default_cert_file(); cdecl; external;
procedure X509_get_default_cert_file_env(); cdecl; external;
procedure X509_get_default_private_dir(); cdecl; external;
procedure X509_get_ex_data(); cdecl; external;
procedure X509_get_ex_new_index(); cdecl; external;
procedure X509_get_ext(); cdecl; external;
procedure X509_get_ext_by_critical(); cdecl; external;
procedure X509_get_ext_by_NID(); cdecl; external;
procedure X509_get_ext_by_OBJ(); cdecl; external;
procedure X509_get_ext_count(); cdecl; external;
procedure X509_get_ext_d2i(); cdecl; external;
procedure X509_get_pubkey(); cdecl; external;
procedure X509_get_pubkey_parameters(); cdecl; external;
procedure X509_get_serialNumber(); cdecl; external;
procedure X509_get_signature_nid(); cdecl; external;
procedure X509_get0_pubkey_bitstr(); cdecl; external;
procedure X509_get0_signature(); cdecl; external;
procedure X509_get1_email(); cdecl; external;
procedure X509_get1_ocsp(); cdecl; external;
procedure X509_gmtime_adj(); cdecl; external;
procedure X509_http_nbio(); cdecl; external;
procedure X509_INFO_free(); cdecl; external;
procedure X509_INFO_new(); cdecl; external;
procedure X509_issuer_and_serial_cmp(); cdecl; external;
procedure X509_issuer_and_serial_hash(); cdecl; external;
procedure X509_issuer_name_cmp(); cdecl; external;
procedure X509_issuer_name_hash(); cdecl; external;
procedure X509_issuer_name_hash_old(); cdecl; external;
procedure X509_it(); cdecl; external;
procedure X509_keyid_get0(); cdecl; external;
procedure X509_keyid_set1(); cdecl; external;
procedure X509_load_cert_crl_file(); cdecl; external;
procedure X509_load_cert_file(); cdecl; external;
procedure X509_load_crl_file(); cdecl; external;
procedure X509_LOOKUP_by_alias(); cdecl; external;
procedure X509_LOOKUP_by_fingerprint(); cdecl; external;
procedure X509_LOOKUP_by_issuer_serial(); cdecl; external;
procedure X509_LOOKUP_by_subject(); cdecl; external;
procedure X509_LOOKUP_ctrl(); cdecl; external;
procedure X509_LOOKUP_file(); cdecl; external;
procedure X509_LOOKUP_free(); cdecl; external;
procedure X509_LOOKUP_hash_dir(); cdecl; external;
procedure X509_LOOKUP_init(); cdecl; external;
procedure X509_LOOKUP_new(); cdecl; external;
procedure X509_LOOKUP_shutdown(); cdecl; external;
procedure X509_NAME_add_entry(); cdecl; external;
procedure X509_NAME_add_entry_by_NID(); cdecl; external;
procedure X509_NAME_add_entry_by_OBJ(); cdecl; external;
procedure X509_NAME_add_entry_by_txt(); cdecl; external;
procedure X509_NAME_cmp(); cdecl; external;
procedure X509_NAME_delete_entry(); cdecl; external;
procedure X509_NAME_digest(); cdecl; external;
procedure X509_NAME_dup(); cdecl; external;
procedure X509_NAME_ENTRIES_it(); cdecl; external;
procedure X509_NAME_entry_count(); cdecl; external;
procedure X509_NAME_ENTRY_create_by_NID(); cdecl; external;
procedure X509_NAME_ENTRY_create_by_OBJ(); cdecl; external;
procedure X509_NAME_ENTRY_create_by_txt(); cdecl; external;
procedure X509_NAME_ENTRY_dup(); cdecl; external;
procedure X509_NAME_ENTRY_free(); cdecl; external;
procedure X509_NAME_ENTRY_get_data(); cdecl; external;
procedure X509_NAME_ENTRY_get_object(); cdecl; external;
procedure X509_NAME_ENTRY_it(); cdecl; external;
procedure X509_NAME_ENTRY_new(); cdecl; external;
procedure X509_NAME_ENTRY_set_data(); cdecl; external;
procedure X509_NAME_ENTRY_set_object(); cdecl; external;
procedure x509_name_ff(); cdecl; external;
procedure X509_NAME_free(); cdecl; external;
procedure X509_NAME_get_entry(); cdecl; external;
procedure X509_NAME_get_index_by_NID(); cdecl; external;
procedure X509_NAME_get_index_by_OBJ(); cdecl; external;
procedure X509_NAME_get_text_by_NID(); cdecl; external;
procedure X509_NAME_get_text_by_OBJ(); cdecl; external;
procedure X509_NAME_hash(); cdecl; external;
procedure X509_NAME_hash_old(); cdecl; external;
procedure X509_NAME_INTERNAL_it(); cdecl; external;
procedure X509_NAME_it(); cdecl; external;
procedure X509_NAME_new(); cdecl; external;
procedure X509_NAME_print(); cdecl; external;
procedure X509_NAME_print_ex(); cdecl; external;
procedure X509_NAME_print_ex_fp(); cdecl; external;
procedure X509_NAME_set(); cdecl; external;
procedure X509_new(); cdecl; external;
procedure X509_OBJECT_free_contents(); cdecl; external;
procedure X509_OBJECT_idx_by_subject(); cdecl; external;
procedure X509_OBJECT_retrieve_by_subject(); cdecl; external;
procedure X509_OBJECT_retrieve_match(); cdecl; external;
procedure X509_OBJECT_up_ref_count(); cdecl; external;
procedure X509_ocspid_print(); cdecl; external;
procedure X509_PKEY_free(); cdecl; external;
procedure X509_PKEY_new(); cdecl; external;
procedure X509_policy_check(); cdecl; external;
procedure X509_policy_level_get0_node(); cdecl; external;
procedure X509_policy_level_node_count(); cdecl; external;
procedure X509_policy_node_get0_parent(); cdecl; external;
procedure X509_policy_node_get0_policy(); cdecl; external;
procedure X509_policy_node_get0_qualifiers(); cdecl; external;
procedure X509_POLICY_NODE_print(); cdecl; external;
procedure X509_policy_tree_free(); cdecl; external;
procedure X509_policy_tree_get0_level(); cdecl; external;
procedure X509_policy_tree_get0_policies(); cdecl; external;
procedure X509_policy_tree_get0_user_policies(); cdecl; external;
procedure X509_policy_tree_level_count(); cdecl; external;
procedure X509_print(); cdecl; external;
procedure X509_print_ex(); cdecl; external;
procedure X509_print_ex_fp(); cdecl; external;
procedure X509_print_fp(); cdecl; external;
procedure X509_pubkey_digest(); cdecl; external;
procedure X509_PUBKEY_free(); cdecl; external;
procedure X509_PUBKEY_get(); cdecl; external;
procedure X509_PUBKEY_get0_param(); cdecl; external;
procedure X509_PUBKEY_it(); cdecl; external;
procedure X509_PUBKEY_new(); cdecl; external;
procedure X509_PUBKEY_set(); cdecl; external;
procedure X509_PUBKEY_set0_param(); cdecl; external;
procedure X509_PURPOSE_add(); cdecl; external;
procedure X509_PURPOSE_cleanup(); cdecl; external;
procedure X509_PURPOSE_get_by_id(); cdecl; external;
procedure X509_PURPOSE_get_by_sname(); cdecl; external;
procedure X509_PURPOSE_get_count(); cdecl; external;
procedure X509_PURPOSE_get_id(); cdecl; external;
procedure X509_PURPOSE_get_trust(); cdecl; external;
procedure X509_PURPOSE_get0(); cdecl; external;
procedure X509_PURPOSE_get0_name(); cdecl; external;
procedure X509_PURPOSE_get0_sname(); cdecl; external;
procedure X509_PURPOSE_set(); cdecl; external;
procedure X509_reject_clear(); cdecl; external;
procedure X509_REQ_add_extensions(); cdecl; external;
procedure X509_REQ_add_extensions_nid(); cdecl; external;
procedure X509_REQ_add1_attr(); cdecl; external;
procedure X509_REQ_add1_attr_by_NID(); cdecl; external;
procedure X509_REQ_add1_attr_by_OBJ(); cdecl; external;
procedure X509_REQ_add1_attr_by_txt(); cdecl; external;
procedure X509_REQ_check_private_key(); cdecl; external;
procedure X509_REQ_delete_attr(); cdecl; external;
procedure X509_REQ_digest(); cdecl; external;
procedure X509_REQ_dup(); cdecl; external;
procedure X509_REQ_extension_nid(); cdecl; external;
procedure X509_REQ_free(); cdecl; external;
procedure X509_REQ_get_attr(); cdecl; external;
procedure X509_REQ_get_attr_by_NID(); cdecl; external;
procedure X509_REQ_get_attr_by_OBJ(); cdecl; external;
procedure X509_REQ_get_attr_count(); cdecl; external;
procedure X509_REQ_get_extension_nids(); cdecl; external;
procedure X509_REQ_get_extensions(); cdecl; external;
procedure X509_REQ_get_pubkey(); cdecl; external;
procedure X509_REQ_get1_email(); cdecl; external;
procedure X509_REQ_INFO_free(); cdecl; external;
procedure X509_REQ_INFO_it(); cdecl; external;
procedure X509_REQ_INFO_new(); cdecl; external;
procedure X509_REQ_it(); cdecl; external;
procedure X509_REQ_new(); cdecl; external;
procedure X509_REQ_print(); cdecl; external;
procedure X509_REQ_print_ex(); cdecl; external;
procedure X509_REQ_print_fp(); cdecl; external;
procedure X509_REQ_set_extension_nids(); cdecl; external;
procedure X509_REQ_set_pubkey(); cdecl; external;
procedure X509_REQ_set_subject_name(); cdecl; external;
procedure X509_REQ_set_version(); cdecl; external;
procedure X509_REQ_sign(); cdecl; external;
procedure X509_REQ_sign_ctx(); cdecl; external;
procedure X509_REQ_to_X509(); cdecl; external;
procedure X509_REQ_verify(); cdecl; external;
procedure X509_REVOKED_add_ext(); cdecl; external;
procedure X509_REVOKED_add1_ext_i2d(); cdecl; external;
procedure X509_REVOKED_delete_ext(); cdecl; external;
procedure X509_REVOKED_dup(); cdecl; external;
procedure X509_REVOKED_free(); cdecl; external;
procedure X509_REVOKED_get_ext(); cdecl; external;
procedure X509_REVOKED_get_ext_by_critical(); cdecl; external;
procedure X509_REVOKED_get_ext_by_NID(); cdecl; external;
procedure X509_REVOKED_get_ext_by_OBJ(); cdecl; external;
procedure X509_REVOKED_get_ext_count(); cdecl; external;
procedure X509_REVOKED_get_ext_d2i(); cdecl; external;
procedure X509_REVOKED_it(); cdecl; external;
procedure X509_REVOKED_new(); cdecl; external;
procedure X509_REVOKED_set_revocationDate(); cdecl; external;
procedure X509_REVOKED_set_serialNumber(); cdecl; external;
procedure X509_set_ex_data(); cdecl; external;
procedure X509_set_issuer_name(); cdecl; external;
procedure X509_set_notAfter(); cdecl; external;
procedure X509_set_notBefore(); cdecl; external;
procedure X509_set_pubkey(); cdecl; external;
procedure X509_set_serialNumber(); cdecl; external;
procedure X509_set_subject_name(); cdecl; external;
procedure X509_set_version(); cdecl; external;
procedure X509_SIG_free(); cdecl; external;
procedure X509_SIG_it(); cdecl; external;
procedure X509_SIG_new(); cdecl; external;
procedure X509_sign(); cdecl; external;
procedure X509_sign_ctx(); cdecl; external;
procedure X509_signature_dump(); cdecl; external;
procedure X509_signature_print(); cdecl; external;
procedure X509_STORE_add_cert(); cdecl; external;
procedure X509_STORE_add_crl(); cdecl; external;
procedure X509_STORE_add_lookup(); cdecl; external;
procedure X509_STORE_CTX_cleanup(); cdecl; external;
procedure X509_STORE_CTX_free(); cdecl; external;
procedure X509_STORE_CTX_get_chain(); cdecl; external;
procedure X509_STORE_CTX_get_current_cert(); cdecl; external;
procedure X509_STORE_CTX_get_error(); cdecl; external;
procedure X509_STORE_CTX_get_error_depth(); cdecl; external;
procedure X509_STORE_CTX_get_ex_data(); cdecl; external;
procedure X509_STORE_CTX_get_ex_new_index(); cdecl; external;
procedure X509_STORE_CTX_get_explicit_policy(); cdecl; external;
procedure X509_STORE_CTX_get0_current_crl(); cdecl; external;
procedure X509_STORE_CTX_get0_current_issuer(); cdecl; external;
procedure X509_STORE_CTX_get0_param(); cdecl; external;
procedure X509_STORE_CTX_get0_parent_ctx(); cdecl; external;
procedure X509_STORE_CTX_get0_policy_tree(); cdecl; external;
procedure X509_STORE_CTX_get0_store(); cdecl; external;
procedure X509_STORE_CTX_get1_chain(); cdecl; external;
procedure X509_STORE_CTX_get1_issuer(); cdecl; external;
procedure X509_STORE_CTX_init(); cdecl; external;
procedure X509_STORE_CTX_new(); cdecl; external;
procedure X509_STORE_CTX_purpose_inherit(); cdecl; external;
procedure X509_STORE_CTX_set_cert(); cdecl; external;
procedure X509_STORE_CTX_set_chain(); cdecl; external;
procedure X509_STORE_CTX_set_default(); cdecl; external;
procedure X509_STORE_CTX_set_depth(); cdecl; external;
procedure X509_STORE_CTX_set_error(); cdecl; external;
procedure X509_STORE_CTX_set_ex_data(); cdecl; external;
procedure X509_STORE_CTX_set_flags(); cdecl; external;
procedure X509_STORE_CTX_set_purpose(); cdecl; external;
procedure X509_STORE_CTX_set_time(); cdecl; external;
procedure X509_STORE_CTX_set_trust(); cdecl; external;
procedure X509_STORE_CTX_set_verify_cb(); cdecl; external;
procedure X509_STORE_CTX_set0_crls(); cdecl; external;
procedure X509_STORE_CTX_set0_param(); cdecl; external;
procedure X509_STORE_CTX_trusted_stack(); cdecl; external;
procedure X509_STORE_free(); cdecl; external;
procedure X509_STORE_get_by_subject(); cdecl; external;
procedure X509_STORE_get1_certs(); cdecl; external;
procedure X509_STORE_get1_crls(); cdecl; external;
procedure X509_STORE_load_locations(); cdecl; external;
procedure X509_STORE_new(); cdecl; external;
procedure X509_STORE_set_default_paths(); cdecl; external;
procedure X509_STORE_set_depth(); cdecl; external;
procedure X509_STORE_set_flags(); cdecl; external;
procedure X509_STORE_set_lookup_crls_cb(); cdecl; external;
procedure X509_STORE_set_purpose(); cdecl; external;
procedure X509_STORE_set_trust(); cdecl; external;
procedure X509_STORE_set_verify_cb(); cdecl; external;
procedure X509_STORE_set1_param(); cdecl; external;
procedure X509_subject_name_cmp(); cdecl; external;
procedure X509_subject_name_hash(); cdecl; external;
procedure X509_subject_name_hash_old(); cdecl; external;
procedure X509_supported_extension(); cdecl; external;
procedure X509_time_adj(); cdecl; external;
procedure X509_time_adj_ex(); cdecl; external;
procedure X509_to_X509_REQ(); cdecl; external;
procedure X509_TRUST_add(); cdecl; external;
procedure X509_TRUST_cleanup(); cdecl; external;
procedure X509_trust_clear(); cdecl; external;
procedure X509_TRUST_get_by_id(); cdecl; external;
procedure X509_TRUST_get_count(); cdecl; external;
procedure X509_TRUST_get_flags(); cdecl; external;
procedure X509_TRUST_get_trust(); cdecl; external;
procedure X509_TRUST_get0(); cdecl; external;
procedure X509_TRUST_get0_name(); cdecl; external;
procedure X509_TRUST_set(); cdecl; external;
procedure X509_TRUST_set_default(); cdecl; external;
procedure X509_VAL_free(); cdecl; external;
procedure X509_VAL_it(); cdecl; external;
procedure X509_VAL_new(); cdecl; external;
procedure X509_verify(); cdecl; external;
procedure X509_verify_cert(); cdecl; external;
procedure X509_verify_cert_error_string(); cdecl; external;
procedure X509_VERIFY_PARAM_add0_policy(); cdecl; external;
procedure X509_VERIFY_PARAM_add0_table(); cdecl; external;
procedure X509_VERIFY_PARAM_add1_host(); cdecl; external;
procedure X509_VERIFY_PARAM_clear_flags(); cdecl; external;
procedure X509_VERIFY_PARAM_free(); cdecl; external;
procedure X509_VERIFY_PARAM_get_count(); cdecl; external;
procedure X509_VERIFY_PARAM_get_depth(); cdecl; external;
procedure X509_VERIFY_PARAM_get_flags(); cdecl; external;
procedure X509_VERIFY_PARAM_get0(); cdecl; external;
procedure X509_VERIFY_PARAM_get0_name(); cdecl; external;
procedure X509_VERIFY_PARAM_get0_peername(); cdecl; external;
procedure X509_VERIFY_PARAM_inherit(); cdecl; external;
procedure X509_VERIFY_PARAM_lookup(); cdecl; external;
procedure X509_VERIFY_PARAM_new(); cdecl; external;
procedure X509_VERIFY_PARAM_set_depth(); cdecl; external;
procedure X509_VERIFY_PARAM_set_flags(); cdecl; external;
procedure X509_VERIFY_PARAM_set_hostflags(); cdecl; external;
procedure X509_VERIFY_PARAM_set_purpose(); cdecl; external;
procedure X509_VERIFY_PARAM_set_time(); cdecl; external;
procedure X509_VERIFY_PARAM_set_trust(); cdecl; external;
procedure X509_VERIFY_PARAM_set1(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_email(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_host(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_ip(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_ip_asc(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_name(); cdecl; external;
procedure X509_VERIFY_PARAM_set1_policies(); cdecl; external;
procedure X509_VERIFY_PARAM_table_cleanup(); cdecl; external;
procedure X509_version(); cdecl; external;
procedure X509at_add1_attr(); cdecl; external;
procedure X509at_add1_attr_by_NID(); cdecl; external;
procedure X509at_add1_attr_by_OBJ(); cdecl; external;
procedure X509at_add1_attr_by_txt(); cdecl; external;
procedure X509at_delete_attr(); cdecl; external;
procedure X509at_get_attr(); cdecl; external;
procedure X509at_get_attr_by_NID(); cdecl; external;
procedure X509at_get_attr_by_OBJ(); cdecl; external;
procedure X509at_get_attr_count(); cdecl; external;
procedure X509at_get0_data_by_OBJ(); cdecl; external;
procedure X509v3_add_ext(); cdecl; external;
procedure X509V3_add_standard_extensions(); cdecl; external;
procedure X509V3_add_value(); cdecl; external;
procedure X509V3_add_value_bool(); cdecl; external;
procedure X509V3_add_value_bool_nf(); cdecl; external;
procedure X509V3_add_value_int(); cdecl; external;
procedure X509V3_add_value_uchar(); cdecl; external;
procedure X509V3_add1_i2d(); cdecl; external;
procedure X509V3_conf_free(); cdecl; external;
procedure X509v3_delete_ext(); cdecl; external;
procedure X509V3_EXT_add(); cdecl; external;
procedure X509V3_EXT_add_alias(); cdecl; external;
procedure X509V3_EXT_add_conf(); cdecl; external;
procedure X509V3_EXT_add_list(); cdecl; external;
procedure X509V3_EXT_add_nconf(); cdecl; external;
procedure X509V3_EXT_add_nconf_sk(); cdecl; external;
procedure X509V3_EXT_cleanup(); cdecl; external;
procedure X509V3_EXT_conf(); cdecl; external;
procedure X509V3_EXT_conf_nid(); cdecl; external;
procedure X509V3_EXT_CRL_add_conf(); cdecl; external;
procedure X509V3_EXT_CRL_add_nconf(); cdecl; external;
procedure X509V3_EXT_d2i(); cdecl; external;
procedure X509V3_EXT_free(); cdecl; external;
procedure X509V3_EXT_get(); cdecl; external;
procedure X509V3_EXT_get_nid(); cdecl; external;
procedure X509V3_EXT_i2d(); cdecl; external;
procedure X509V3_EXT_nconf(); cdecl; external;
procedure X509V3_EXT_nconf_nid(); cdecl; external;
procedure X509V3_EXT_print(); cdecl; external;
procedure X509V3_EXT_print_fp(); cdecl; external;
procedure X509V3_EXT_REQ_add_conf(); cdecl; external;
procedure X509V3_EXT_REQ_add_nconf(); cdecl; external;
procedure X509V3_EXT_val_prn(); cdecl; external;
procedure X509V3_extensions_print(); cdecl; external;
procedure X509V3_get_d2i(); cdecl; external;
procedure X509v3_get_ext(); cdecl; external;
procedure X509v3_get_ext_by_critical(); cdecl; external;
procedure X509v3_get_ext_by_NID(); cdecl; external;
procedure X509v3_get_ext_by_OBJ(); cdecl; external;
procedure X509v3_get_ext_count(); cdecl; external;
procedure X509V3_get_section(); cdecl; external;
procedure X509V3_get_string(); cdecl; external;
procedure X509V3_get_value_bool(); cdecl; external;
procedure X509V3_get_value_int(); cdecl; external;
procedure X509V3_NAME_from_section(); cdecl; external;
procedure X509V3_parse_list(); cdecl; external;
procedure X509V3_section_free(); cdecl; external;
procedure X509V3_set_conf_lhash(); cdecl; external;
procedure X509V3_set_ctx(); cdecl; external;
procedure X509V3_set_nconf(); cdecl; external;
procedure X509V3_string_free(); cdecl; external;
procedure X9_62_CHARACTERISTIC_TWO_free(); cdecl; external;
procedure X9_62_CHARACTERISTIC_TWO_it(); cdecl; external;
procedure X9_62_CHARACTERISTIC_TWO_new(); cdecl; external;
procedure X9_62_CURVE_it(); cdecl; external;
procedure X9_62_FIELDID_it(); cdecl; external;
procedure X9_62_PENTANOMIAL_free(); cdecl; external;
procedure X9_62_PENTANOMIAL_it(); cdecl; external;
procedure X9_62_PENTANOMIAL_new(); cdecl; external;
procedure ZLONG_it(); cdecl; external;

{$L .\win32\aes_cbc.obj}
{$L .\win32\aes_cfb.obj}
{$L .\win32\aes_core.obj}
{$L .\win32\aes_ctr.obj}
{$L .\win32\aes_ecb.obj}
{$L .\win32\aes_ige.obj}
{$L .\win32\aes_misc.obj}
{$L .\win32\aes_ofb.obj}
{$L .\win32\aes_wrap.obj}
{$L .\win32\ameth_lib.obj}
{$L .\win32\asn1_err.obj}
{$L .\win32\asn1_gen.obj}
{$L .\win32\asn1_lib.obj}
{$L .\win32\asn1_par.obj}
{$L .\win32\asn_mime.obj}
{$L .\win32\asn_moid.obj}
{$L .\win32\asn_pack.obj}
{$L .\win32\a_bitstr.obj}
{$L .\win32\a_bool.obj}
{$L .\win32\a_bytes.obj}
{$L .\win32\a_d2i_fp.obj}
{$L .\win32\a_digest.obj}
{$L .\win32\a_dup.obj}
{$L .\win32\a_enum.obj}
{$L .\win32\a_gentm.obj}
{$L .\win32\a_i2d_fp.obj}
{$L .\win32\a_int.obj}
{$L .\win32\a_mbstr.obj}
{$L .\win32\a_object.obj}
{$L .\win32\a_octet.obj}
{$L .\win32\a_print.obj}
{$L .\win32\a_set.obj}
{$L .\win32\a_sign.obj}
{$L .\win32\a_strex.obj}
{$L .\win32\a_strnid.obj}
{$L .\win32\a_time.obj}
{$L .\win32\a_type.obj}
{$L .\win32\a_utctm.obj}
{$L .\win32\a_utf8.obj}
{$L .\win32\a_verify.obj}
{$L .\win32\bf_buff.obj}
{$L .\win32\bf_cfb64.obj}
{$L .\win32\bf_ecb.obj}
{$L .\win32\bf_enc.obj}
{$L .\win32\bf_nbio.obj}
{$L .\win32\bf_null.obj}
{$L .\win32\bf_ofb64.obj}
{$L .\win32\bf_skey.obj}
{$L .\win32\bio_asn1.obj}
{$L .\win32\bio_b64.obj}
{$L .\win32\bio_cb.obj}
{$L .\win32\bio_enc.obj}
{$L .\win32\bio_err.obj}
{$L .\win32\bio_lib.obj}
{$L .\win32\bio_md.obj}
{$L .\win32\bio_ndef.obj}
{$L .\win32\bio_ok.obj}
{$L .\win32\bio_pk7.obj}
{$L .\win32\bio_ssl.obj}
{$L .\win32\bn_add.obj}
{$L .\win32\bn_asm.obj}
{$L .\win32\bn_blind.obj}
{$L .\win32\bn_const.obj}
{$L .\win32\bn_ctx.obj}
{$L .\win32\bn_depr.obj}
{$L .\win32\bn_div.obj}
{$L .\win32\bn_err.obj}
{$L .\win32\bn_exp.obj}
{$L .\win32\bn_exp2.obj}
{$L .\win32\bn_gcd.obj}
{$L .\win32\bn_gf2m.obj}
{$L .\win32\bn_kron.obj}
{$L .\win32\bn_lib.obj}
{$L .\win32\bn_mod.obj}
{$L .\win32\bn_mont.obj}
{$L .\win32\bn_mpi.obj}
{$L .\win32\bn_mul.obj}
{$L .\win32\bn_nist.obj}
{$L .\win32\bn_prime.obj}
{$L .\win32\bn_print.obj}
{$L .\win32\bn_rand.obj}
{$L .\win32\bn_recp.obj}
{$L .\win32\bn_shift.obj}
{$L .\win32\bn_sqr.obj}
{$L .\win32\bn_sqrt.obj}
{$L .\win32\bn_word.obj}
{$L .\win32\bn_x931p.obj}
{$L .\win32\bss_acpt.obj}
{$L .\win32\bss_bio.obj}
{$L .\win32\bss_conn.obj}
{$L .\win32\bss_dgram.obj}
{$L .\win32\bss_fd.obj}
{$L .\win32\bss_file.obj}
{$L .\win32\bss_log.obj}
{$L .\win32\bss_mem.obj}
{$L .\win32\bss_null.obj}
{$L .\win32\bss_sock.obj}
{$L .\win32\buffer.obj}
{$L .\win32\buf_err.obj}
{$L .\win32\buf_str.obj}
{$L .\win32\by_dir.obj}
{$L .\win32\by_file.obj}
{$L .\win32\b_dump.obj}
{$L .\win32\b_print.obj}
{$L .\win32\b_sock.obj}
{$L .\win32\camellia.obj}
{$L .\win32\cbc128.obj}
{$L .\win32\cbc_cksm.obj}
{$L .\win32\cbc_enc.obj}
{$L .\win32\ccm128.obj}
{$L .\win32\cfb128.obj}
{$L .\win32\cfb64ede.obj}
{$L .\win32\cfb64enc.obj}
{$L .\win32\cfb_enc.obj}
{$L .\win32\cmac.obj}
{$L .\win32\cmll_cbc.obj}
{$L .\win32\cmll_cfb.obj}
{$L .\win32\cmll_ctr.obj}
{$L .\win32\cmll_ecb.obj}
{$L .\win32\cmll_misc.obj}
{$L .\win32\cmll_ofb.obj}
{$L .\win32\cmll_utl.obj}
{$L .\win32\cms_asn1.obj}
{$L .\win32\cms_att.obj}
{$L .\win32\cms_cd.obj}
{$L .\win32\cms_dd.obj}
{$L .\win32\cms_enc.obj}
{$L .\win32\cms_env.obj}
{$L .\win32\cms_err.obj}
{$L .\win32\cms_ess.obj}
{$L .\win32\cms_io.obj}
{$L .\win32\cms_kari.obj}
{$L .\win32\cms_lib.obj}
{$L .\win32\cms_pwri.obj}
{$L .\win32\cms_sd.obj}
{$L .\win32\cms_smime.obj}
{$L .\win32\cm_ameth.obj}
{$L .\win32\cm_pmeth.obj}
{$L .\win32\comp_err.obj}
{$L .\win32\comp_lib.obj}
{$L .\win32\conf_api.obj}
{$L .\win32\conf_def.obj}
{$L .\win32\conf_err.obj}
{$L .\win32\conf_lib.obj}
{$L .\win32\conf_mall.obj}
{$L .\win32\conf_mod.obj}
{$L .\win32\conf_sap.obj}
{$L .\win32\cpt_err.obj}
{$L .\win32\cryptlib.obj}
{$L .\win32\ctr128.obj}
{$L .\win32\cts128.obj}
{$L .\win32\cversion.obj}
{$L .\win32\c_all.obj}
{$L .\win32\c_allc.obj}
{$L .\win32\c_alld.obj}
{$L .\win32\c_cfb64.obj}
{$L .\win32\c_ecb.obj}
{$L .\win32\c_enc.obj}
{$L .\win32\c_ofb64.obj}
{$L .\win32\c_rle.obj}
{$L .\win32\c_skey.obj}
{$L .\win32\c_zlib.obj}
{$L .\win32\d1_both.obj}
{$L .\win32\d1_clnt.obj}
{$L .\win32\d1_lib.obj}
{$L .\win32\d1_meth.obj}
{$L .\win32\d1_pkt.obj}
{$L .\win32\d1_srtp.obj}
{$L .\win32\d1_srvr.obj}
{$L .\win32\d2i_pr.obj}
{$L .\win32\d2i_pu.obj}
{$L .\win32\des_enc.obj}
{$L .\win32\des_old.obj}
{$L .\win32\des_old2.obj}
{$L .\win32\dh_ameth.obj}
{$L .\win32\dh_asn1.obj}
{$L .\win32\dh_check.obj}
{$L .\win32\dh_depr.obj}
{$L .\win32\dh_err.obj}
{$L .\win32\dh_gen.obj}
{$L .\win32\dh_kdf.obj}
{$L .\win32\dh_key.obj}
{$L .\win32\dh_lib.obj}
{$L .\win32\dh_pmeth.obj}
{$L .\win32\dh_prn.obj}
{$L .\win32\dh_rfc5114.obj}
{$L .\win32\digest.obj}
{$L .\win32\dsa_ameth.obj}
{$L .\win32\dsa_asn1.obj}
{$L .\win32\dsa_depr.obj}
{$L .\win32\dsa_err.obj}
{$L .\win32\dsa_gen.obj}
{$L .\win32\dsa_key.obj}
{$L .\win32\dsa_lib.obj}
{$L .\win32\dsa_ossl.obj}
{$L .\win32\dsa_pmeth.obj}
{$L .\win32\dsa_prn.obj}
{$L .\win32\dsa_sign.obj}
{$L .\win32\dsa_vrf.obj}
{$L .\win32\dso_beos.obj}
{$L .\win32\dso_dl.obj}
{$L .\win32\dso_dlfcn.obj}
{$L .\win32\dso_err.obj}
{$L .\win32\dso_lib.obj}
{$L .\win32\dso_null.obj}
{$L .\win32\dso_openssl.obj}
{$L .\win32\dso_vms.obj}
{$L .\win32\dso_win32.obj}
{$L .\win32\ebcdic.obj}
{$L .\win32\ec2_mult.obj}
{$L .\win32\ec2_oct.obj}
{$L .\win32\ec2_smpl.obj}
{$L .\win32\ecb3_enc.obj}
{$L .\win32\ecb_enc.obj}
{$L .\win32\ech_err.obj}
{$L .\win32\ech_kdf.obj}
{$L .\win32\ech_key.obj}
{$L .\win32\ech_lib.obj}
{$L .\win32\ech_ossl.obj}
{$L .\win32\eck_prn.obj}
{$L .\win32\ecp_mont.obj}
{$L .\win32\ecp_nist.obj}
{$L .\win32\ecp_nistp224.obj}
{$L .\win32\ecp_nistp256.obj}
{$L .\win32\ecp_nistp521.obj}
{$L .\win32\ecp_nistputil.obj}
{$L .\win32\ecp_oct.obj}
{$L .\win32\ecp_smpl.obj}
{$L .\win32\ecs_asn1.obj}
{$L .\win32\ecs_err.obj}
{$L .\win32\ecs_lib.obj}
{$L .\win32\ecs_ossl.obj}
{$L .\win32\ecs_sign.obj}
{$L .\win32\ecs_vrf.obj}
{$L .\win32\ec_ameth.obj}
{$L .\win32\ec_asn1.obj}
{$L .\win32\ec_check.obj}
{$L .\win32\ec_curve.obj}
{$L .\win32\ec_cvt.obj}
{$L .\win32\ec_err.obj}
{$L .\win32\ec_key.obj}
{$L .\win32\ec_lib.obj}
{$L .\win32\ec_mult.obj}
{$L .\win32\ec_oct.obj}
{$L .\win32\ec_pmeth.obj}
{$L .\win32\ec_print.obj}
{$L .\win32\ede_cbcm_enc.obj}
{$L .\win32\encode.obj}
{$L .\win32\enc_read.obj}
{$L .\win32\enc_writ.obj}
{$L .\win32\eng_all.obj}
{$L .\win32\eng_cnf.obj}
{$L .\win32\eng_cryptodev.obj}
{$L .\win32\eng_ctrl.obj}
{$L .\win32\eng_dyn.obj}
{$L .\win32\eng_err.obj}
{$L .\win32\eng_fat.obj}
{$L .\win32\eng_init.obj}
{$L .\win32\eng_lib.obj}
{$L .\win32\eng_list.obj}
{$L .\win32\eng_openssl.obj}
{$L .\win32\eng_pkey.obj}
{$L .\win32\eng_rdrand.obj}
{$L .\win32\eng_table.obj}
{$L .\win32\err.obj}
{$L .\win32\err_all.obj}
{$L .\win32\err_prn.obj}
{$L .\win32\evp_acnf.obj}
{$L .\win32\evp_asn1.obj}
{$L .\win32\evp_cnf.obj}
{$L .\win32\evp_enc.obj}
{$L .\win32\evp_err.obj}
{$L .\win32\evp_key.obj}
{$L .\win32\evp_lib.obj}
{$L .\win32\evp_pbe.obj}
{$L .\win32\evp_pkey.obj}
{$L .\win32\ex_data.obj}
{$L .\win32\e_4758cca.obj}
{$L .\win32\e_aep.obj}
{$L .\win32\e_aes.obj}
{$L .\win32\e_aes_cbc_hmac_sha1.obj}
{$L .\win32\e_aes_cbc_hmac_sha256.obj}
{$L .\win32\e_atalla.obj}
{$L .\win32\e_bf.obj}
{$L .\win32\e_camellia.obj}
{$L .\win32\e_capi.obj}
{$L .\win32\e_cast.obj}
{$L .\win32\e_chil.obj}
{$L .\win32\e_cswift.obj}
{$L .\win32\e_des.obj}
{$L .\win32\e_des3.obj}
{$L .\win32\e_gmp.obj}
{$L .\win32\e_gost_err.obj}
{$L .\win32\e_idea.obj}
{$L .\win32\e_null.obj}
{$L .\win32\e_nuron.obj}
{$L .\win32\e_old.obj}
{$L .\win32\e_padlock.obj}
{$L .\win32\e_rc2.obj}
{$L .\win32\e_rc4.obj}
{$L .\win32\e_rc4_hmac_md5.obj}
{$L .\win32\e_rc5.obj}
{$L .\win32\e_seed.obj}
{$L .\win32\e_sureware.obj}
{$L .\win32\e_ubsec.obj}
{$L .\win32\e_xcbc_d.obj}
{$L .\win32\fcrypt.obj}
{$L .\win32\fcrypt_b.obj}
{$L .\win32\fips_ers.obj}
{$L .\win32\f_enum.obj}
{$L .\win32\f_int.obj}
{$L .\win32\f_string.obj}
{$L .\win32\gcm128.obj}
{$L .\win32\gost2001.obj}
{$L .\win32\gost2001_keyx.obj}
{$L .\win32\gost89.obj}
{$L .\win32\gost94_keyx.obj}
{$L .\win32\gosthash.obj}
{$L .\win32\gost_ameth.obj}
{$L .\win32\gost_asn1.obj}
{$L .\win32\gost_crypt.obj}
{$L .\win32\gost_ctl.obj}
{$L .\win32\gost_eng.obj}
{$L .\win32\gost_keywrap.obj}
{$L .\win32\gost_md.obj}
{$L .\win32\gost_params.obj}
{$L .\win32\gost_pmeth.obj}
{$L .\win32\gost_sign.obj}
{$L .\win32\hmac.obj}
{$L .\win32\hm_ameth.obj}
{$L .\win32\hm_pmeth.obj}
{$L .\win32\i2d_pr.obj}
{$L .\win32\i2d_pu.obj}
{$L .\win32\i_cbc.obj}
{$L .\win32\i_cfb64.obj}
{$L .\win32\i_ecb.obj}
{$L .\win32\i_ofb64.obj}
{$L .\win32\i_skey.obj}
{$L .\win32\krb5_asn.obj}
{$L .\win32\kssl.obj}
{$L .\win32\lhash.obj}
{$L .\win32\lh_stats.obj}
{$L .\win32\md4_dgst.obj}
{$L .\win32\md4_one.obj}
{$L .\win32\md5_dgst.obj}
{$L .\win32\md5_one.obj}
{$L .\win32\mdc2dgst.obj}
{$L .\win32\mdc2_one.obj}
{$L .\win32\md_rand.obj}
{$L .\win32\mem.obj}
{$L .\win32\mem_clr.obj}
{$L .\win32\mem_dbg.obj}
{$L .\win32\m_dss.obj}
{$L .\win32\m_dss1.obj}
{$L .\win32\m_ecdsa.obj}
{$L .\win32\m_md4.obj}
{$L .\win32\m_md5.obj}
{$L .\win32\m_mdc2.obj}
{$L .\win32\m_null.obj}
{$L .\win32\m_ripemd.obj}
{$L .\win32\m_sha.obj}
{$L .\win32\m_sha1.obj}
{$L .\win32\m_sigver.obj}
{$L .\win32\m_wp.obj}
{$L .\win32\names.obj}
{$L .\win32\nsseq.obj}
{$L .\win32\n_pkey.obj}
{$L .\win32\obj_dat.obj}
{$L .\win32\obj_err.obj}
{$L .\win32\obj_lib.obj}
{$L .\win32\obj_xref.obj}
{$L .\win32\ocsp_asn.obj}
{$L .\win32\ocsp_cl.obj}
{$L .\win32\ocsp_err.obj}
{$L .\win32\ocsp_ext.obj}
{$L .\win32\ocsp_ht.obj}
{$L .\win32\ocsp_lib.obj}
{$L .\win32\ocsp_prn.obj}
{$L .\win32\ocsp_srv.obj}
{$L .\win32\ocsp_vfy.obj}
{$L .\win32\ofb128.obj}
{$L .\win32\ofb64ede.obj}
{$L .\win32\ofb64enc.obj}
{$L .\win32\ofb_enc.obj}
{$L .\win32\o_dir.obj}
{$L .\win32\o_fips.obj}
{$L .\win32\o_init.obj}
{$L .\win32\o_names.obj}
{$L .\win32\o_str.obj}
{$L .\win32\o_time.obj}
{$L .\win32\p12_add.obj}
{$L .\win32\p12_asn.obj}
{$L .\win32\p12_attr.obj}
{$L .\win32\p12_crpt.obj}
{$L .\win32\p12_crt.obj}
{$L .\win32\p12_decr.obj}
{$L .\win32\p12_init.obj}
{$L .\win32\p12_key.obj}
{$L .\win32\p12_kiss.obj}
{$L .\win32\p12_mutl.obj}
{$L .\win32\p12_npas.obj}
{$L .\win32\p12_p8d.obj}
{$L .\win32\p12_p8e.obj}
{$L .\win32\p12_utl.obj}
{$L .\win32\p5_crpt.obj}
{$L .\win32\p5_crpt2.obj}
{$L .\win32\p5_pbe.obj}
{$L .\win32\p5_pbev2.obj}
{$L .\win32\p8_pkey.obj}
{$L .\win32\pcbc_enc.obj}
{$L .\win32\pcy_cache.obj}
{$L .\win32\pcy_data.obj}
{$L .\win32\pcy_lib.obj}
{$L .\win32\pcy_map.obj}
{$L .\win32\pcy_node.obj}
{$L .\win32\pcy_tree.obj}
{$L .\win32\pem_all.obj}
{$L .\win32\pem_err.obj}
{$L .\win32\pem_info.obj}
{$L .\win32\pem_lib.obj}
{$L .\win32\pem_oth.obj}
{$L .\win32\pem_pk8.obj}
{$L .\win32\pem_pkey.obj}
{$L .\win32\pem_seal.obj}
{$L .\win32\pem_sign.obj}
{$L .\win32\pem_x509.obj}
{$L .\win32\pem_xaux.obj}
{$L .\win32\pk12err.obj}
{$L .\win32\pk7_asn1.obj}
{$L .\win32\pk7_attr.obj}
{$L .\win32\pk7_doit.obj}
{$L .\win32\pk7_lib.obj}
{$L .\win32\pk7_mime.obj}
{$L .\win32\pk7_smime.obj}
{$L .\win32\pkcs7err.obj}
{$L .\win32\pmeth_fn.obj}
{$L .\win32\pmeth_gn.obj}
{$L .\win32\pmeth_lib.obj}
{$L .\win32\pqueue.obj}
{$L .\win32\pvkfmt.obj}
{$L .\win32\p_dec.obj}
{$L .\win32\p_enc.obj}
{$L .\win32\p_lib.obj}
{$L .\win32\p_open.obj}
{$L .\win32\p_seal.obj}
{$L .\win32\p_sign.obj}
{$L .\win32\p_verify.obj}
{$L .\win32\qud_cksm.obj}
{$L .\win32\randfile.obj}
{$L .\win32\rand_egd.obj}
{$L .\win32\rand_err.obj}
{$L .\win32\rand_key.obj}
{$L .\win32\rand_lib.obj}
{$L .\win32\rand_nw.obj}
{$L .\win32\rand_os2.obj}
{$L .\win32\rand_unix.obj}
{$L .\win32\rand_win.obj}
{$L .\win32\rc2cfb64.obj}
{$L .\win32\rc2ofb64.obj}
{$L .\win32\rc2_cbc.obj}
{$L .\win32\rc2_ecb.obj}
{$L .\win32\rc2_skey.obj}
{$L .\win32\rc4_enc.obj}
{$L .\win32\rc4_skey.obj}
{$L .\win32\rc4_utl.obj}
{$L .\win32\read2pwd.obj}
{$L .\win32\rmd_dgst.obj}
{$L .\win32\rmd_one.obj}
{$L .\win32\rpc_enc.obj}
{$L .\win32\rsa_ameth.obj}
{$L .\win32\rsa_asn1.obj}
{$L .\win32\rsa_chk.obj}
{$L .\win32\rsa_crpt.obj}
{$L .\win32\rsa_depr.obj}
{$L .\win32\rsa_eay.obj}
{$L .\win32\rsa_err.obj}
{$L .\win32\rsa_gen.obj}
{$L .\win32\rsa_lib.obj}
{$L .\win32\rsa_none.obj}
{$L .\win32\rsa_null.obj}
{$L .\win32\rsa_oaep.obj}
{$L .\win32\rsa_pk1.obj}
{$L .\win32\rsa_pmeth.obj}
{$L .\win32\rsa_prn.obj}
{$L .\win32\rsa_pss.obj}
{$L .\win32\rsa_saos.obj}
{$L .\win32\rsa_sign.obj}
{$L .\win32\rsa_ssl.obj}
{$L .\win32\rsa_x931.obj}
{$L .\win32\s23_clnt.obj}
{$L .\win32\s23_lib.obj}
{$L .\win32\s23_meth.obj}
{$L .\win32\s23_pkt.obj}
{$L .\win32\s23_srvr.obj}
{$L .\win32\s2_clnt.obj}
{$L .\win32\s2_enc.obj}
{$L .\win32\s2_lib.obj}
{$L .\win32\s2_meth.obj}
{$L .\win32\s2_pkt.obj}
{$L .\win32\s2_srvr.obj}
{$L .\win32\s3_both.obj}
{$L .\win32\s3_cbc.obj}
{$L .\win32\s3_clnt.obj}
{$L .\win32\s3_enc.obj}
{$L .\win32\s3_lib.obj}
{$L .\win32\s3_meth.obj}
{$L .\win32\s3_pkt.obj}
{$L .\win32\s3_srvr.obj}
{$L .\win32\seed.obj}
{$L .\win32\seed_cbc.obj}
{$L .\win32\seed_cfb.obj}
{$L .\win32\seed_ecb.obj}
{$L .\win32\seed_ofb.obj}
{$L .\win32\set_key.obj}
{$L .\win32\sha1dgst.obj}
{$L .\win32\sha1_one.obj}
{$L .\win32\sha256.obj}
{$L .\win32\sha512.obj}
{$L .\win32\sha_dgst.obj}
{$L .\win32\sha_one.obj}
{$L .\win32\srp_lib.obj}
{$L .\win32\srp_vfy.obj}
{$L .\win32\ssl_algs.obj}
{$L .\win32\ssl_asn1.obj}
{$L .\win32\ssl_cert.obj}
{$L .\win32\ssl_ciph.obj}
{$L .\win32\ssl_conf.obj}
{$L .\win32\ssl_err.obj}
{$L .\win32\ssl_err2.obj}
{$L .\win32\ssl_lib.obj}
{$L .\win32\ssl_rsa.obj}
{$L .\win32\ssl_sess.obj}
{$L .\win32\ssl_stat.obj}
{$L .\win32\ssl_txt.obj}
{$L .\win32\ssl_utst.obj}
{$L .\win32\stack.obj}
{$L .\win32\str2key.obj}
{$L .\win32\t1_clnt.obj}
{$L .\win32\t1_enc.obj}
{$L .\win32\t1_ext.obj}
{$L .\win32\t1_lib.obj}
{$L .\win32\t1_meth.obj}
{$L .\win32\t1_reneg.obj}
{$L .\win32\t1_srvr.obj}
{$L .\win32\t1_trce.obj}
{$L .\win32\tasn_dec.obj}
{$L .\win32\tasn_enc.obj}
{$L .\win32\tasn_fre.obj}
{$L .\win32\tasn_new.obj}
{$L .\win32\tasn_prn.obj}
{$L .\win32\tasn_typ.obj}
{$L .\win32\tasn_utl.obj}
{$L .\win32\tb_asnmth.obj}
{$L .\win32\tb_cipher.obj}
{$L .\win32\tb_dh.obj}
{$L .\win32\tb_digest.obj}
{$L .\win32\tb_dsa.obj}
{$L .\win32\tb_ecdh.obj}
{$L .\win32\tb_ecdsa.obj}
{$L .\win32\tb_pkmeth.obj}
{$L .\win32\tb_rand.obj}
{$L .\win32\tb_rsa.obj}
{$L .\win32\tb_store.obj}
{$L .\win32\tls_srp.obj}
{$L .\win32\ts_asn1.obj}
{$L .\win32\ts_conf.obj}
{$L .\win32\ts_err.obj}
{$L .\win32\ts_lib.obj}
{$L .\win32\ts_req_print.obj}
{$L .\win32\ts_req_utils.obj}
{$L .\win32\ts_rsp_print.obj}
{$L .\win32\ts_rsp_sign.obj}
{$L .\win32\ts_rsp_utils.obj}
{$L .\win32\ts_rsp_verify.obj}
{$L .\win32\ts_verify_ctx.obj}
{$L .\win32\txt_db.obj}
{$L .\win32\t_bitst.obj}
{$L .\win32\t_crl.obj}
{$L .\win32\t_pkey.obj}
{$L .\win32\t_req.obj}
{$L .\win32\t_spki.obj}
{$L .\win32\t_x509.obj}
{$L .\win32\t_x509a.obj}
{$L .\win32\uid.obj}
{$L .\win32\ui_compat.obj}
{$L .\win32\ui_err.obj}
{$L .\win32\ui_lib.obj}
{$L .\win32\ui_openssl.obj}
{$L .\win32\ui_util.obj}
{$L .\win32\v3err.obj}
{$L .\win32\v3_addr.obj}
{$L .\win32\v3_akey.obj}
{$L .\win32\v3_akeya.obj}
{$L .\win32\v3_alt.obj}
{$L .\win32\v3_asid.obj}
{$L .\win32\v3_bcons.obj}
{$L .\win32\v3_bitst.obj}
{$L .\win32\v3_conf.obj}
{$L .\win32\v3_cpols.obj}
{$L .\win32\v3_crld.obj}
{$L .\win32\v3_enum.obj}
{$L .\win32\v3_extku.obj}
{$L .\win32\v3_genn.obj}
{$L .\win32\v3_ia5.obj}
{$L .\win32\v3_info.obj}
{$L .\win32\v3_int.obj}
{$L .\win32\v3_lib.obj}
{$L .\win32\v3_ncons.obj}
{$L .\win32\v3_ocsp.obj}
{$L .\win32\v3_pci.obj}
{$L .\win32\v3_pcia.obj}
{$L .\win32\v3_pcons.obj}
{$L .\win32\v3_pku.obj}
{$L .\win32\v3_pmaps.obj}
{$L .\win32\v3_prn.obj}
{$L .\win32\v3_purp.obj}
{$L .\win32\v3_scts.obj}
{$L .\win32\v3_skey.obj}
{$L .\win32\v3_sxnet.obj}
{$L .\win32\v3_utl.obj}
{$L .\win32\wp_block.obj}
{$L .\win32\wp_dgst.obj}
{$L .\win32\wrap128.obj}
{$L .\win32\x509cset.obj}
{$L .\win32\x509name.obj}
{$L .\win32\x509rset.obj}
{$L .\win32\x509spki.obj}
{$L .\win32\x509type.obj}
{$L .\win32\x509_att.obj}
{$L .\win32\x509_cmp.obj}
{$L .\win32\x509_d2.obj}
{$L .\win32\x509_def.obj}
{$L .\win32\x509_err.obj}
{$L .\win32\x509_ext.obj}
{$L .\win32\x509_lu.obj}
{$L .\win32\x509_obj.obj}
{$L .\win32\x509_r2x.obj}
{$L .\win32\x509_req.obj}
{$L .\win32\x509_set.obj}
{$L .\win32\x509_trs.obj}
{$L .\win32\x509_txt.obj}
{$L .\win32\x509_v3.obj}
{$L .\win32\x509_vfy.obj}
{$L .\win32\x509_vpm.obj}
{$L .\win32\xcbc_enc.obj}
{$L .\win32\xts128.obj}
{$L .\win32\x_algor.obj}
{$L .\win32\x_all.obj}
{$L .\win32\x_attrib.obj}
{$L .\win32\x_bignum.obj}
{$L .\win32\x_crl.obj}
{$L .\win32\x_exten.obj}
{$L .\win32\x_info.obj}
{$L .\win32\x_long.obj}
{$L .\win32\x_name.obj}
{$L .\win32\x_nx509.obj}
{$L .\win32\x_pkey.obj}
{$L .\win32\x_pubkey.obj}
{$L .\win32\x_req.obj}
{$L .\win32\x_sig.obj}
{$L .\win32\x_spki.obj}
{$L .\win32\x_val.obj}
{$L .\win32\x_x509.obj}
{$L .\win32\x_x509a.obj}


end.
