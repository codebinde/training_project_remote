{application,mime,
             [{compile_env,[{mime,[extensions],error},
                            {mime,[suffixes],error},
                            {mime,[types],
                                  {ok,#{<<"application/hal+json">> =>
                                            [<<"json-hal">>],
                                        <<"application/ocsp-response">> =>
                                            [<<"ors">>],
                                        <<"application/vnd.vorwerk.tmde2.rhd.device.hal+json">> =>
                                            [<<"rhd-device">>]}}}]},
              {applications,[kernel,stdlib,elixir,logger]},
              {description,"A MIME type module for Elixir"},
              {modules,['Elixir.MIME']},
              {registered,[]},
              {vsn,"2.0.5"},
              {env,[]}]}.
