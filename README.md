# ovpnmgr: OpenVPN Client CA Manager

A shell-based tool to manage OpenVPN user credentials (using an OpenSSL-managed
PKI) with support for PGP encryption of user private keys and automatic
e-mailing of configuration files, if you wish.


## Building

```console
$ make
$ make install
```

The build can be configured by creating a `build.config` file in this directory.
The `build.config` is an OpenRC-style config file defining variables in shell
syntax. It supports the following options:

### Generic
<dl>
	<dt><tt>CONFDIR</tt>=<tt>/etc/ovpnmgr</tt></dt>
	<dd>the directory in which ovpnmgr will store the PKI's files.</dd>
	<dt><tt>USER_PACKAGE_DIR</tt>=<tt>$CONFDIR/users</tt></dt>
	<dd>the directory in which ovpnmgr will store the users' files.</dd>
</dl>

### OpenVPN config
<dl>
	<dt><tt>REQUIRE_KEY_PASSPHRASE</tt>=<tt>true|false</tt> (default <tt>true</tt>)</dt>
	<dd>if enabled, ovpnmgr refuses to store a private key without a
	passphrase set.</dd>
	<dt><tt>DEFAULT_CERT_LIFETIME</tt>=<tt>365</tt></dt>
	<dd>the default lifetime of a generated certificate in days. This
	setting can be overwritten in the config file, later on.</dd>
	<dt><tt>USE_CONFIG_OVPN</tt>=<tt>flat|dir|false</tt> (default <tt>flat</tt>)</dt>
	<dd>whether to create "plain" OpenVPN config files.
	This option supports two modes:
	<dl>
		<dt><tt>dir</tt></dt>
		<dd>compile the user certificate and keys together with the
		OpenVPN config each as a separate file in a directory.</dd>
		<dt><tt>flat</tt></dt>
		<dd>create a single <tt>.ovpn</tt> config file with the user
		certificate and all keys inlined.</dd>
	</dl></dd>
	<dt><tt>USE_CONFIG_TBLK</tt>=<tt>true|false</tt> (default <tt>true</tt>)</dt>
	<dd>whether to create <tt>.tblk</tt> config files for use with the
	<a href="https://www.tunnelblick.net" target="_blank">Tunnelblick</a>
	OpenVPN client.</dd>
</dl>

### E-mail
<dl>
	<dt><tt>USE_MAIL_CONFIG</tt>=<tt>true|false</tt> (default <tt>true</tt>)</dt>
	<dd>whether to enable the capability to send configuration files to
	users after they were created or renewed.<br />
	E-Mails are sent using the system <b>sendmail</b>(1) command.</dd>
	<dt><tt>USE_PGP_MAIL</tt>=<tt>true|false</tt> (default <tt>false</tt>)</dt>
	<dd>whether to send PGP-encrypted e-mail.</dd>
</dl>

### PGP
<dl>
	<dt><tt>USE_PGP</tt>=<tt>true|false</tt> (default <tt>false</tt>)</dt>
	<dd>whether to enable the PGP functionalitites (using
	<a href="https://www.gnupg.org" target="_blank">GnuPG</a>).</dd>
	<dt><tt>GNUPGHOME</tt>=<tt>$CONFDIR/.gnupg</tt></dt>
	<dd>where GnuPG's home directory is located, by default a separate
	directory inside the <tt>CONFDIR</tt> is used.</dd>
	<dt><tt>PGP_USER_IS_RECIPIENT</tt>=<tt>true|false</tt> (default <tt>true</tt>)</dt>
	<dd>the default value for the config option with the name name.
	If enabled, the generated private key passphrase will be encrypted to
	the user's PGP key. Only disable this option if you use the
	<tt>PGP_ADDITIONAL_RECIPIENTS</tt> config option.</dd>
</dl>


## Configuration

ovpnmgr can futher be configured using a config file stored in
`$CONFDIR/config`.
This configuration file is an OpenRC style file defining variables in
shell syntax.

Available options:
<dl>
	<dt><tt>CONFIG_NAME</tt>=<tt>'OpenVPN'</tt></dt>
	<dd>the name of the OpenVPN configuration (will also be used in the
	file names of the configuration files sent to users).</dd>
	<dt><tt>EMAIL</tt>=<tt>${LOGNAME:-$(whoami)}</tt></dt>
	<dd>the sender e-mail address for configuration mails.</dd>
	<dt><tt>PKI_DIR</tt>=<tt>"$CONFDIR/pki"</tt></dt>
	<dd>the directory in which the OpenSSL PKI is stored.</dd>
	<dt><tt>CERT_LIFETIME</tt>=<tt>$DEFAULT_CERT_LIFETIME</tt></dt>
	<dd>the lifetime of a generated certificate in days.</dd>
	<dt><tt>MAX_RENEW_DAYS</tt>=<tt>14</tt></dt>
	<dd>maximum number of days a certificate is allowed to be valid for to
	be renewed.</dd>
	<dt><tt>PGP_USER_IS_RECIPIENT</tt>=<tt>$PGP_USER_IS_RECIPIENT</tt></dt>
	<dd>if enabled, the generated private key passphrase will be encrypted
	to the user's PGP key. Only disable this option if you use the
	<tt>PGP_ADDITIONAL_RECIPIENTS</tt> config option.</dd>
	<dt><tt>PGP_ADDITIONAL_RECIPIENTS</tt>=<tt>''</tt></dt>
	<dd>a white space separated list of recipients to encrypt the generated
	passphrases to.</dd>
</dl>

Further, a `client.conf.d` skeleton directory has to be installed into
`$CONFDIR`.
Its contents will be used to populate the OpenVPN configuration directory
mailed out to users. It needs to contain at least a `config.ovpn` file
(`@@username@@` and `@@cn@@` will be replaced with the real username when
adding users).
Any other files will be copied verbatim.

The contents of the e-mail message sent to users can be configured by installing
a file named `config-mail` into `$CONFDIR`.

## Usage

To work with ovpnmgr use the `ovpnmgr` command installed on your system.
Run `ovpnmgr help` to learn more on the available sub-commands.


### Getting started

After you installed ovpnmgr, you first need to create a Certificate
Authority (CA):

```console
$ ovpnmgr create-ca
Creating a new CA...
Enter CA private key pass phrase:
Confirm:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CH]:
State or Province Name (full name) [SG]:
Locality Name (eg, city) []:.
Organization Name (eg, company) [riiengineering]:
Organizational Unit Name (eg, section) []:.
Your User Name [OpenVPN CA]:riiengineering VPN CA
Email Address []:.
```

After the Certificate authority is created, new users can be added:
```console
$ ovpnmgr add-user john john@example.com
Using configuration from /etc/ovpnmgr/pki/openssl.cnf
Enter pass phrase for /etc/ovpnmgr/pki/ca/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            3e:27:16:7b:9c:ed:84:d7:b6:06:11:40:8f:f6:60:d8:98:7e:e7:55
        Validity
            Not Before: Apr 23 12:27:45 2024 GMT
            Not After : Apr 23 12:27:45 2025 GMT
        Subject:
            countryName               = CH
            stateOrProvinceName       = SG
            organizationName          = riiengineering
            commonName                = john
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature
            X509v3 Subject Key Identifier:
                49:17:33:AE:A7:99:31:E9:94:A9:D3:01:FB:82:6F:3B:21:22:FB:27
            X509v3 Authority Key Identifier:
                keyid:06:15:B5:9E:76:47:87:0F:88:9D:14:55:E6:3D:AF:F8:13:9A:91:4D
                DirName:/C=CH/ST=SG/O=riiengineering/CN=riiengineering VPN CA
                serial:78:35:10:A5:D9:D7:DE:D2:7E:58:94:06:6C:F7:8F:8D:C3:23:41:A2
            X509v3 Extended Key Usage: critical
                TLS Web Client Authentication
Certificate is to be certified until Apr 23 12:27:45 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Database updated
Do you want to e-mail the VPN configuration to the user? [Y/n]
```

> [!NOTE]
> If you choose to e-mail the VPN configuration files to the user, the user will
> receive an e-mail immediately with the renewed configuration files attached.
> Otherwise, you will have to send the file `/etc/ovpnmgr/users/{CN}/config.tar`
> to the user manually.

You can list all current users:
```console
$ ovpnmgr list-users
V john (expires 2025-04-23 12:27:45Z)
```
(the first character shows the current status of the user's credentials. `V` = valid, `E` = expired, `R` = revoked.)

> [!IMPORTANT]
> Remember to run `ovpnmgr monitor` regularly (e.g. as a cron job) to be notified
> about an expired CA, CRL or expiring user certificates.


## Revoking user certificates

ovpnmgr supports revoking existing user credentials. These revoked credentials
will be stored in the CRL file.

> [!IMPORTANT]
> If you want to make use of the revoke feature, configure the OpenVPN server
> to respect the CRL.  
> To do so, add the following line to your OpenVPN server configuration:
> ```
> crl-verify /etc/ovpnmgr/pki/crl.pem
> ```
> 
> Also remember to run `ovpnmgr gencrl` regularly to ensure the CRL doesn't
> expire. If you let the CRL expire nobody will be able to connect to the
> OpenVPN server anymore.

To revoke a certificate determine its CN (the name printed by
`ovpnmgr list-users`) and then execute the `revoke` sub-command:

```console
$ ovpnmgr revoke john
Revoking certificate for john...
Using configuration from /etc/ovpnmgr/pki/openssl.cnf
Enter pass phrase for /etc/ovpnmgr/pki/ca/ca.key:
Revoking Certificate 3E27167B9CED84D7B60611408FF660D8987EE755.
Database updated
Updating certificate revocation list...
Using configuration from /etc/ovpnmgr/pki/openssl.cnf
Enter pass phrase for /etc/ovpnmgr/pki/ca/ca.key:
```

## Renewing user certificates

To revoke a certificate determine its CN (the name printed by
`ovpnmgr list-users`) and then execute the `renew` sub-command:

```console
$ ovpnmgr renew john
Renewing user certificate for john...
Using configuration from /etc/ovpnmgr/pki/openssl.cnf
Enter pass phrase for /etc/ovpnmgr/pki/ca/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            1b:fb:d5:3a:c9:97:e2:aa:29:b3:3c:0d:78:8a:f6:7f:a8:c7:65:25
        Validity
            Not Before: May  1 15:36:05 2024 GMT
            Not After : May  1 15:36:05 2025 GMT
        Subject:
            countryName               = CH
            stateOrProvinceName       = SG
            organizationName          = riiengineering
            commonName                = john
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature
            X509v3 Subject Key Identifier:
                9E:FD:CA:90:19:65:B6:FF:A8:0D:8F:B1:5E:1C:86:01:1A:8E:8B:1B
            X509v3 Authority Key Identifier:
                keyid:10:8A:6E:5C:15:5A:07:98:19:8D:3C:E8:0D:1F:48:20:41:BC:9D:81
                DirName:/C=CH/ST=SG/O=riiengineering/CN=riiengineering VPN CA
                serial:1D:7F:46:9D:F8:CC:AE:4E:BD:3D:F6:6A:0C:4E:7E:C4:9D:20:3C:4C
            X509v3 Extended Key Usage: critical
                TLS Web Client Authentication
Certificate is to be certified until May  1 15:36:05 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Database updated
Do you want to e-mail the VPN configuration to the user? [Y/n] y
```

> [!NOTE]
> If you choose to e-mail the VPN configuration files to the user, the user will
> receive an e-mail immediately with the renewed configuration files attached.
> Otherwise, you will have to send the file `/etc/ovpnmgr/users/{CN}/config.tar`
> to the user manually.


-----
[![riiengineered.](https://www.riiengineering.ch/riiengineered-400.png)](//www.riiengineering.ch)
