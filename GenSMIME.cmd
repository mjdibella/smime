@echo off
set key_length=4096
set days_valid=7300
set openssl_path=openssl.exe
if Not [%3]==[] goto GotParams
echo Generate a self-signed s/mime certificate
echo Usage: %0 email name password [organization]
echo. 
goto TheEnd
:GotParams
md %1
cd %1
rem Create the certifcate request configuration file
echo [req] >%1.inf
echo distinguished_name=req_distinguished_name >>%1.inf
echo prompt=no >>%1.inf
echo. >>%1.inf
echo [req_distinguished_name] >>%1.inf
echo emailAddress=%1 >>%1.inf
if not "%~4"=="" echo O=%~4 >>%1.inf
echo CN=%~2 >>%1.inf
echo. >>%1.inf
echo [req_extensions] >>%1.inf
echo keyUsage=digitalSignature,keyEncipherment,dataEncipherment >>%1.inf
echo extendedKeyUsage=clientAuth,emailProtection >>%1.inf
echo subjectAltName=email:%1 >>%1.inf
echo basicConstraints=CA:FALSE >>%1.inf
rem Generate the key
%openssl_path% genrsa -des3 -passout pass:%3 -out %1.key %key_length%
rem Generate the certificate
%openssl_path% req -new -config %1.inf -x509 -extensions req_extensions -key %1.key -passin pass:%3 -out %1.cer -days %days_valid%
rem Merge the key with certificate and export as PKCS#12
%openssl_path% pkcs12 -export -keyex -in %1.cer -inkey %1.key -passin pass:%3 -out %1.pfx -passout pass:%3
cd ..
:TheEnd