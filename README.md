# vdns

DNS implementation for V


```v
import teodor_pripoae.vdns

fn main() {
	hostname := 'cloudflare.com'
	addresses := vdns.lookup_host(hostname) or { panic(err) }
	eprintln('$hostname is at: $addresses')
}
```