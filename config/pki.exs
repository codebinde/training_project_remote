import Config

config :online_mock, PKI,
  world_root: :priv,
  world_cloud: [
    serialNumber: 10,
    issuer: :world_root,
    subject: [
      organizationName: "Cloud",
      commonName: {:mfa, {OnlineMock.PKI, :host, [OnlineMockCloud.Endpoint]}}
    ],
    extensions: [
      keyUsage: {[:digitalSignature, :keyEncipherment], :critical}
    ]
  ],
  vorwerk_root: :priv,
  vorwerk_intermediate: :priv,
  vorwerk_issuing: [
    serialNumber: 100,
    issuer: :vorwerk_intermediate,
    not_after: {:mfa, {OnlineMock.PKI, :certificate_expired, [:issuing]}},
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: "Integration Testing Issuing CA"
    ],
    extensions: [
      authorityInfoAccess: [
        ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, []}}
      ],
      basicConstraints: {[cA: true], :critical},
      keyUsage: {[:digitalSignature, :keyCertSign, :cRLSign], :critical}
    ]
  ],
  vorwerk_issuing_ocsp: [
    serialNumber: 1000,
    issuer: :vorwerk_issuing,
    not_before: {:mfa, {OnlineMock.PKI, :utc_time, [{:hour, -12}]}},
    not_after: {:mfa, {OnlineMock.PKI, :utc_time, [{:hour, 12}]}},
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: "Integration Testing Issuing OCSP Signing Cert"
    ],
    extensions: [
      extKeyUsage: {[:OCSPSigning], :critical}
    ]
  ],
  time_signing: [
    serialNumber: 2000,
    issuer: :vorwerk_issuing,
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: "Time Signing Cert"
    ],
    extensions: [
      authorityInfoAccess: [
        ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, ["/vorwerk_issuing"]}}
      ],
      basicConstraints: {[cA: false], :critical},
      keyUsage: {[:digitalSignature], :critical}
    ]
  ],
  est: [
    serialNumber: 5000,
    issuer: :vorwerk_issuing,
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: {:mfa, {OnlineMock.PKI, :host, [OnlineMockEST.Endpoint]}}
    ],
    extensions: [
      authorityInfoAccess: [
        ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, ["/vorwerk_issuing"]}}
      ],
      keyUsage: {[:digitalSignature, :keyEncipherment], :critical}
    ]
  ],
  cookidoo: [
    serialNumber: 5001,
    issuer: :vorwerk_issuing,
    subject: [
      countryName: "DE",
      organizationName: "Vorwerk",
      organizationalUnitName: "TQES",
      commonName: {:mfa, {OnlineMock.PKI, :host, [OnlineMockCookidoo.Endpoint]}}
    ],
    extensions: [
      authorityInfoAccess: [
        ocsp: {:mfa, {OnlineMock.PKI, :ocsp_uri, ["/vorwerk_issuing"]}}
      ],
      keyUsage: {[:digitalSignature, :keyEncipherment], :critical},
      subjectAltName: {:mfa, {OnlineMock.PKI, :subject_alt_name, [OnlineMockCookidoo.Endpoint]}}
    ]
  ]
