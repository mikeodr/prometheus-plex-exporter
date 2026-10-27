module github.com/grafana/plexporter

go 1.27.3

require (
	github.com/go-kit/log v0.2.1
	github.com/gorilla/websocket v1.5.3
	github.com/jrudio/go-plex-client v0.0.0-20250127195314-943dc7a39f7c
	github.com/prometheus/client_golang v1.25.0
)

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/go-logfmt/logfmt v0.6.1 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/prometheus/client_model v0.6.3 // indirect
	github.com/prometheus/common v0.72.1 // indirect
	github.com/prometheus/procfs v0.23.0 // indirect
	go.yaml.in/yaml/v2 v2.4.4 // indirect
	golang.org/x/crypto v0.58.0 // indirect
	golang.org/x/net v0.61.0 // indirect
	golang.org/x/sys v0.49.0 // indirect
	google.golang.org/protobuf v1.36.12 // indirect
)

// Replace for fix: https://github.com/jrudio/go-plex-client/pull/56
replace github.com/jrudio/go-plex-client => github.com/jsclayton/go-plex-client v0.0.0-20230428220949-afd78005d7d3
