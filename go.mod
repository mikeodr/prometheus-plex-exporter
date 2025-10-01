module github.com/grafana/plexporter

go 1.24.7

require (
	github.com/go-kit/log v0.2.1
	github.com/gorilla/websocket v1.5.3
	github.com/jrudio/go-plex-client v0.0.0-20220428052413-e5b4386beb17
	github.com/prometheus/client_golang v1.23.2
)

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/go-logfmt/logfmt v0.5.1 // indirect
	github.com/google/uuid v1.3.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/prometheus/client_model v0.6.2 // indirect
	github.com/prometheus/common v0.66.1 // indirect
	github.com/prometheus/procfs v0.16.1 // indirect
	go.yaml.in/yaml/v2 v2.4.2 // indirect
	golang.org/x/sys v0.35.0 // indirect
	google.golang.org/protobuf v1.36.8 // indirect
)

// Replace for fix: https://github.com/jrudio/go-plex-client/pull/56
replace github.com/jrudio/go-plex-client => github.com/jsclayton/go-plex-client v0.0.0-20230428220949-afd78005d7d3
