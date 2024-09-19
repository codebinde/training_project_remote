import Config
# This file contains the configuration used to create certificates for keys
# used for signing the ID Token in the TokenController Endpoint for OIDC Authorization Code Flow

config :online_mock, Auth,
  token_signing_rsa: [
    serialNumber: 5001,
    issuer: :vorwerk_issuing,
    not_after: {:mfa, {OnlineMock.PKI, :certificate_expired, [:token_signing]}},
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: "Integration Testing OIDC ID Token Signing Key"
    ],
    extensions: [
      authorityInfoAccess: [ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, ["/vorwerk_issuing"]}}],
      keyUsage: {:mfa, {OnlineMock.PKI, :token_signing_usage, []}}
    ]
  ],
  token_signing_rsa_new: [
    serialNumber: 5002,
    issuer: :vorwerk_issuing,
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: "Integration Testing OIDC ID Token Signing Key"
    ],
    extensions: [
      authorityInfoAccess: [ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, ["/vorwerk_issuing"]}}],
      keyUsage: {:mfa, {OnlineMock.PKI, :token_signing_usage, []}}
    ]
  ]
